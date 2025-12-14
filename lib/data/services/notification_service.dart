import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int? _quietStartMinutes; // 0-1439 minutes from midnight
  int? _quietEndMinutes;   // 0-1439 minutes from midnight

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Could navigate to specific habit
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // Ensure notification ID fits within 32-bit signed integer range
  int _safeNotificationId(int id) {
    // Use modulo to fit within 32-bit signed positive range (0 to 2^30 - 1)
    // We use 2^30 instead of 2^31 to leave room for day offsets
    return (id.abs() % 100000000);
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required String time, // HH:mm format
    required List<int> days, // 0 = Monday, 6 = Sunday
  }) async {
    try {
      await _refreshQuietHours();
      
      // Convert to safe 32-bit ID
      final safeId = _safeNotificationId(id);
      await cancelNotification(safeId);

      final parts = time.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;

      for (var day in days) {
        final weekDay = day + 1; // Convert to 1 = Monday, 7 = Sunday
        
        // Skip invalid days
        if (weekDay < 1 || weekDay > 7) continue;
        
        final scheduledTime = _applyQuietHours(
          _nextInstanceOfDay(weekDay, hour, minute),
        );

        try {
          await _notifications.zonedSchedule(
            safeId * 10 + day, // Unique ID for each day
            'Habit Reminder',
            "Time to complete: $habitName",
            scheduledTime,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'habit_reminders',
                'Habit Reminders',
                channelDescription: 'Reminders for your habits',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        } catch (e) {
          // Silently fail if exact alarms are not permitted
        }
      }
    } catch (e) {
      // Silently fail - notifications are not critical
      print('Failed to schedule notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfDay(int weekDay, int hour, int minute) {
    // Validate weekDay (1-7 in DateTime, 1=Monday, 7=Sunday)
    if (weekDay < 1 || weekDay > 7) {
      weekDay = 1; // Default to Monday if invalid
    }
    
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Safety limit to prevent infinite loop
    int maxIterations = 8;
    while ((scheduled.weekday != weekDay || scheduled.isBefore(now)) && maxIterations > 0) {
      scheduled = scheduled.add(const Duration(days: 1));
      maxIterations--;
    }

    return scheduled;
  }

  Future<void> _refreshQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    _quietStartMinutes = _parsePrefsTimeToMinutes(
      prefs.getString('settings_quiet_start'),
    );
    _quietEndMinutes = _parsePrefsTimeToMinutes(
      prefs.getString('settings_quiet_end'),
    );
  }

  int? _parsePrefsTimeToMinutes(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  tz.TZDateTime _applyQuietHours(tz.TZDateTime scheduled) {
    if (_quietStartMinutes == null || _quietEndMinutes == null) return scheduled;
    if (_quietStartMinutes == _quietEndMinutes) return scheduled;

    final minuteOfDay = scheduled.hour * 60 + scheduled.minute;

    // Quiet hours that don't cross midnight (e.g., 13:00-15:00)
    if (_quietStartMinutes! < _quietEndMinutes!) {
      final isQuiet =
          minuteOfDay >= _quietStartMinutes! && minuteOfDay < _quietEndMinutes!;
      if (!isQuiet) return scheduled;

      // Move to quiet end on the same day
      final adjustedTime = _quietEndMinutes!;
      return tz.TZDateTime(
        scheduled.location,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        adjustedTime ~/ 60,
        adjustedTime % 60,
      );
    }

    // Quiet hours that cross midnight (e.g., 22:00-08:00)
    final isQuiet =
        minuteOfDay >= _quietStartMinutes! || minuteOfDay < _quietEndMinutes!;
    if (!isQuiet) return scheduled;

    final adjustedTime = _quietEndMinutes!;
    // If scheduled during late-night quiet window, shift to next morning at quiet end
    if (minuteOfDay >= _quietStartMinutes!) {
      final nextDay = scheduled.add(const Duration(days: 1));
      return tz.TZDateTime(
        scheduled.location,
        nextDay.year,
        nextDay.month,
        nextDay.day,
        adjustedTime ~/ 60,
        adjustedTime % 60,
      );
    }

    // Early-morning quiet time: move to quiet end of the same day
    return tz.TZDateTime(
      scheduled.location,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      adjustedTime ~/ 60,
      adjustedTime % 60,
    );
  }

  Future<void> cancelNotification(int id) async {
    // Convert to safe 32-bit ID
    final safeId = _safeNotificationId(id);
    // Cancel all day-specific notifications for this habit
    for (var day = 0; day < 7; day++) {
      try {
        await _notifications.cancel(safeId * 10 + day);
      } catch (e) {
        // Ignore errors when canceling non-existent notifications
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Instant notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
