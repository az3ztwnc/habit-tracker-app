import 'package:flutter/material.dart';
import '../data/models/habit_model.dart';
import '../data/models/user_model.dart';
import '../data/models/achievement_model.dart';
import '../data/models/stone_model.dart';
import '../data/repositories/habit_repository.dart';
import '../data/services/notification_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final NotificationService _notificationService = NotificationService();

  List<HabitModel> _habits = [];
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  List<String> _newlyUnlockedAchievements = [];
  List<String> _newlyUnlockedStones = [];

  // Getters
  List<HabitModel> get habits => _habits;
  List<HabitModel> get todayHabits => _repository.getHabitsForToday();
  List<HabitModel> get quitHabits => _habits.where((h) => h.isQuitHabit && !h.isArchived).toList();
  List<HabitModel> get buildHabits => _habits.where((h) => !h.isQuitHabit && !h.isArchived).toList();
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get newlyUnlockedAchievements => _newlyUnlockedAchievements;
  List<String> get newlyUnlockedStones => _newlyUnlockedStones;
  bool get hasCompletedOnboarding => _user?.hasCompletedOnboarding ?? false;

  // Statistics
  int get totalHabits => _habits.length;
  int get totalCompletions => _repository.getTotalCompletions();
  int get longestStreak => _repository.getLongestStreak();
  int get currentMaxStreak => _repository.getCurrentMaxStreak();
  int get totalXP => _user?.totalXP ?? 0;
  int get level => _user?.level ?? 0;
  double get levelProgress {
    if (_user?.levelProgress != null) {
      return _user!.levelProgress;
    }
    const xpPerLevel = 100;
    final xp = _user?.totalXP ?? 0;
    final remainder = xp % xpPerLevel;
    return (remainder / xpPerLevel).clamp(0.0, 1.0);
  }

  int get completedTodayCount {
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    return todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
  }

  int get totalTodayCount => todayHabits.length;

  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔄 Initializing HabitProvider...');
      
      debugPrint('📦 Initializing repository...');
      await _repository.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Repository initialization timed out');
        },
      );
      debugPrint('✅ Repository initialized');
      
      debugPrint('🔔 Initializing notification service...');
      await _notificationService.init().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Notification service initialization timed out, continuing...');
        },
      );
      debugPrint('✅ Notification service initialized');

      debugPrint('👤 Loading user data...');
      _user = _repository.getUser();
      if (_user == null) {
        debugPrint('👤 Creating default user...');
        _user = await _repository.createDefaultUser();
      }
      debugPrint('✅ User data loaded: ${_user?.name}');

      debugPrint('📋 Loading habits...');
      _habits = _repository.getAllHabits();
      debugPrint('✅ Loaded ${_habits.length} habits');
      
      _isLoading = false;
      _error = null;
      debugPrint('✅ HabitProvider initialization complete');
    } catch (e, stackTrace) {
      debugPrint('❌ Error during initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      // Create a minimal state so the app can still run
      _user ??= UserModel(
        id: 'default_user',
        name: 'User',
        avatarEmoji: '😊',
        totalXP: 0,
        createdAt: DateTime.now(),
        hasCompletedOnboarding: false,
      );
      _habits = [];
    }
    debugPrint('🔔 Calling notifyListeners() - isLoading=$_isLoading, hasCompletedOnboarding=${_user?.hasCompletedOnboarding}');
    notifyListeners();
    debugPrint('✅ notifyListeners() called successfully');
  }

  // User operations
  Future<void> updateUser({
    String? name,
    String? avatarEmoji,
    int? avatarIndex,
    bool? isDarkMode,
    int? accentColorIndex,
    bool? notificationsEnabled,
  }) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      name: name,
      avatarEmoji: avatarEmoji,
      avatarIndex: avatarIndex,
      isDarkMode: isDarkMode,
      accentColorIndex: accentColorIndex,
      notificationsEnabled: notificationsEnabled,
    );

    await _repository.saveUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_user == null) return;

    _user = _user!.copyWith(hasCompletedOnboarding: true);
    await _repository.saveUser(_user!);
    notifyListeners();
  }

  // Habit operations
  Future<void> addHabit({
    required String name,
    String? description,
    required int iconIndex,
    required int colorIndex,
    required String category,
    required List<int> scheduledDays,
    required int targetDaysPerWeek,
    String? reminderTime,
    bool isQuitHabit = false,
    DateTime? quitStartDate,
    double? moneySavedPerDay,
  }) async {
    final habit = HabitModel(
      id: Helpers.generateId(),
      name: name,
      description: description,
      iconIndex: iconIndex,
      colorIndex: colorIndex,
      category: category,
      scheduledDays: scheduledDays,
      targetDaysPerWeek: targetDaysPerWeek,
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
      isQuitHabit: isQuitHabit,
      quitStartDate: quitStartDate,
      moneySavedPerDay: moneySavedPerDay,
    );

    await _repository.addHabit(habit);
    _habits = _repository.getAllHabits();

    // Schedule notification if reminder time is set
    if (reminderTime != null && _user?.notificationsEnabled == true) {
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: reminderTime,
        days: scheduledDays,
      );
    }

    // Check for new achievements
    await _checkAchievements();
    
    // Check for new stone unlocks
    await _checkStoneUnlocks();
    
    notifyListeners();
  }

  // Add habit from model (useful for onboarding)
  Future<void> addHabitFromModel(HabitModel habit) async {
    await _repository.addHabit(habit);
    _habits = _repository.getAllHabits();

    // Schedule notification if reminder time is set
    if (habit.reminderTime != null && _user?.notificationsEnabled == true) {
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: habit.reminderTime!,
        days: habit.scheduledDays,
      );
    }

    // Check for new achievements
    await _checkAchievements();
    
    // Check for new stone unlocks
    await _checkStoneUnlocks();
    
    notifyListeners();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _repository.updateHabit(habit);
    _habits = _repository.getAllHabits();

    // Update notification if needed
    if (habit.reminderTime != null && _user?.notificationsEnabled == true) {
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: habit.reminderTime!,
        days: habit.scheduledDays,
      );
    } else {
      await _notificationService.cancelNotification(habit.id.hashCode);
    }

    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repository.deleteHabit(id);
    _habits = _repository.getAllHabits();
    notifyListeners();
  }

  Future<void> archiveHabit(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repository.archiveHabit(id);
    _habits = _repository.getAllHabits();
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String habitId, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateKey = Helpers.formatDateForStorage(targetDate);
    final habit = _repository.getHabitById(habitId);
    
    if (habit == null) return;

    final wasCompleted = habit.isCompletedOn(dateKey);
    
    await _repository.toggleHabitCompletion(habitId, targetDate);
    _habits = _repository.getAllHabits();

    // Add XP for completion
    if (!wasCompleted) {
      int xpGained = AppConstants.baseXP;
      
      // Check for streak bonus
      final updatedHabit = _repository.getHabitById(habitId);
      if (updatedHabit != null) {
        xpGained += Helpers.calculateStreakBonus(updatedHabit.currentStreak);
      }
      
      await _repository.updateUserXP(xpGained);
      _user = _repository.getUser();
    }

    // Check for new achievements
    await _checkAchievements();
    
    // Check for new stone unlocks
    await _checkStoneUnlocks();

    notifyListeners();
  }

  Future<void> _checkAchievements() async {
    _newlyUnlockedAchievements = await _repository.checkAndUnlockAchievements();
    _user = _repository.getUser();
    
    // Award XP for newly unlocked achievements
    for (var achievementId in _newlyUnlockedAchievements) {
      final achievement = AchievementModel.getById(achievementId);
      if (achievement != null) {
        await _repository.updateUserXP(achievement.xpReward);
      }
    }
    _user = _repository.getUser();
  }

  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements = [];
    notifyListeners();
  }

  /// Check and unlock stones based on current progress
  Future<void> _checkStoneUnlocks() async {
    if (_user == null) return;
    
    _newlyUnlockedStones = [];
    final unlockedStones = _user!.unlockedStones;
    final now = DateTime.now();
    final todayKey = Helpers.formatDateForStorage(now);
    
    for (final stone in StoneModel.allStones) {
      // Skip already unlocked stones
      if (unlockedStones.contains(stone.id)) continue;
      
      bool shouldUnlock = false;
      
      switch (stone.id) {
        // === COMMON STONES ===
        case 'celestial_quartz': // Complete your first habit
          shouldUnlock = totalCompletions >= 1;
          break;
          
        case 'crystal_rose_quartz': // Complete 3 habits in one day
          final todayCompleted = todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
          shouldUnlock = todayCompleted >= 3;
          break;
          
        case 'spirit_jade': // Create 3 different habits
          shouldUnlock = _habits.length >= 3;
          break;
          
        case 'ancient_amber': // Maintain a habit for 3 days
          shouldUnlock = _habits.any((h) => h.currentStreak >= 3);
          break;
          
        case 'nature_peridot': // Complete 5 habits total
          shouldUnlock = totalCompletions >= 5;
          break;
          
        case 'earth_jasper': // Complete habits for 5 consecutive days
          shouldUnlock = currentMaxStreak >= 5;
          break;
          
        case 'starlight_pearl': // Complete a habit before 6 AM
          if (now.hour < 6) {
            final completedNow = todayHabits.any((h) => h.isCompletedOn(todayKey));
            shouldUnlock = completedNow;
          }
          break;
          
        case 'wisdom_turquoise': // Complete 10 habits total
          shouldUnlock = totalCompletions >= 10;
          break;
          
        case 'harmony_malachite': // Complete all habits in a single day
          if (todayHabits.isNotEmpty) {
            shouldUnlock = todayHabits.every((h) => h.isCompletedOn(todayKey));
          }
          break;
          
        case 'golden_pyrite': // Reach level 2
          shouldUnlock = level >= 2;
          break;
          
        // === RARE STONES ===
        case 'phoenix_ruby': // Complete 7 consecutive days
          shouldUnlock = currentMaxStreak >= 7;
          break;
          
        case 'frost_sapphire': // Reach level 5
          shouldUnlock = level >= 5;
          break;
          
        case 'shadow_amethyst': // Complete 25 habits total
          shouldUnlock = totalCompletions >= 25;
          break;
          
        case 'storm_topaz': // Complete habits for 14 consecutive days
          shouldUnlock = currentMaxStreak >= 14;
          break;
          
        case 'ocean_aquamarine': // Complete 30 habits total
          shouldUnlock = totalCompletions >= 30;
          break;
          
        case 'solar_citrine': // Complete 50 habits total
          shouldUnlock = totalCompletions >= 50;
          break;
          
        case 'inferno_garnet': // Reach level 7
          shouldUnlock = level >= 7;
          break;
          
        case 'thunder_lapis': // Complete 5 habits in one day
          final todayCount = todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
          shouldUnlock = todayCount >= 5;
          break;
          
        case 'prism_tourmaline': // Complete habits for 21 consecutive days
          shouldUnlock = currentMaxStreak >= 21;
          break;
          
        case 'lunar_selenite': // Complete a habit after 10 PM
          if (now.hour >= 22) {
            final completedNow = todayHabits.any((h) => h.isCompletedOn(todayKey));
            shouldUnlock = completedNow;
          }
          break;
          
        // === EPIC STONES ===
        case 'enchanted_emerald': // Complete 30 consecutive days
          shouldUnlock = currentMaxStreak >= 30;
          break;
          
        case 'aurora_crystal': // Reach level 10
          shouldUnlock = level >= 10;
          break;
          
        case 'celestial_diamond': // Complete 100 habits total
          shouldUnlock = totalCompletions >= 100;
          break;
          
        case 'mystic_moonstone': // Complete 60 consecutive days
          shouldUnlock = currentMaxStreak >= 60;
          break;
          
        case 'blazing_sunstone': // Reach level 15
          shouldUnlock = level >= 15;
          break;
          
        case 'ancient_obsidian': // Complete 200 habits total
          shouldUnlock = totalCompletions >= 200;
          break;
          
        case 'ethereal_opal': // Complete 90 consecutive days
          shouldUnlock = currentMaxStreak >= 90;
          break;
          
        case 'phantom_tanzanite': // Reach level 20
          shouldUnlock = level >= 20;
          break;
          
        // === LEGENDARY STONES ===
        case 'cosmic_nebula': // Complete 365 consecutive days
          shouldUnlock = currentMaxStreak >= 365;
          break;
          
        case 'void_alexandrite': // Complete 500 habits total
          shouldUnlock = totalCompletions >= 500;
          break;
          
        case 'divine_kunzite': // Reach level 30
          shouldUnlock = level >= 30;
          break;
          
        case 'eternal_infinity': // Complete 1000 habits total
          shouldUnlock = totalCompletions >= 1000;
          break;
      }
      
      if (shouldUnlock) {
        _user!.unlockStone(stone.id);
        _newlyUnlockedStones.add(stone.id);
        // Award XP for unlocking stone
        await _repository.updateUserXP(stone.xpReward);
      }
    }
    
    // Save user if any stones were unlocked
    if (_newlyUnlockedStones.isNotEmpty) {
      await _repository.saveUser(_user!);
      _user = _repository.getUser();
    }
  }

  void clearNewlyUnlockedStones() {
    _newlyUnlockedStones = [];
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    await _notificationService.cancelAllNotifications();
    await _repository.clearAllData();

    // Recreate a fresh default user and empty habit list
    _user = await _repository.createDefaultUser();
    _habits = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> requestNotificationPermission() async {
    await _notificationService.init();
    return _notificationService.requestPermissions();
  }

  Future<void> disableAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    await updateUser(notificationsEnabled: false);
  }

  Future<void> rescheduleAllReminders() async {
    if (_user?.notificationsEnabled != true) return;
    await _notificationService.init();

    for (final habit in _habits) {
      if (habit.reminderTime == null) continue;
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: habit.reminderTime!,
        days: habit.scheduledDays,
      );
    }
  }

  Future<void> restoreFromBackup(
    Map<String, dynamic>? userData,
    List<dynamic> habitsData,
  ) async {
    _isLoading = true;
    notifyListeners();

    await clearAllData();

    if (userData != null) {
      final restoredUser = UserModel(
        id: userData['id'] as String,
        name: userData['name'] as String? ?? 'User',
        avatarEmoji: userData['avatarEmoji'] as String? ?? '😊',
        totalXP: userData['totalXP'] as int? ?? 0,
        createdAt: DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
        hasCompletedOnboarding: userData['hasCompletedOnboarding'] as bool? ?? false,
        isDarkMode: userData['isDarkMode'] as bool? ?? true,
        accentColorIndex: userData['accentColorIndex'] as int? ?? 0,
        notificationsEnabled: userData['notificationsEnabled'] as bool? ?? true,
        unlockedAchievements: (userData['unlockedAchievements'] as List<dynamic>? ?? []).cast<String>(),
        unlockedStones: (userData['unlockedStones'] as List<dynamic>? ?? []).cast<String>(),
      );
      await _repository.saveUser(restoredUser);
      _user = restoredUser;
    }

    for (final raw in habitsData) {
      final map = raw as Map<String, dynamic>;
      final habit = HabitModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        iconIndex: map['iconIndex'] as int? ?? 0,
        colorIndex: map['colorIndex'] as int? ?? 0,
        category: map['category'] as String? ?? 'General',
        scheduledDays: (map['scheduledDays'] as List<dynamic>? ?? []).cast<int>(),
        targetDaysPerWeek: map['targetDaysPerWeek'] as int? ?? 7,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        reminderTime: map['reminderTime'] as String?,
        isArchived: map['isArchived'] as bool? ?? false,
        currentStreak: map['currentStreak'] as int? ?? 0,
        longestStreak: map['longestStreak'] as int? ?? 0,
        totalCompletions: map['totalCompletions'] as int? ?? 0,
        completedDates: (map['completedDates'] as List<dynamic>? ?? []).cast<String>(),
        isQuitHabit: map['isQuitHabit'] as bool? ?? false,
        quitStartDate: map['quitStartDate'] != null
            ? DateTime.tryParse(map['quitStartDate'])
            : null,
        moneySavedPerDay: (map['moneySavedPerDay'] as num?)?.toDouble(),
        relapses: (map['relapses'] as List<dynamic>? ?? [])
            .map<DateTime?>((d) => d == null ? null : DateTime.tryParse(d))
            .whereType<DateTime>()
            .toList(),
      );

      await _repository.addHabit(habit);
    }

    _habits = _repository.getAllHabits();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Statistics
  Map<String, int> getWeeklyCompletions() {
    return _repository.getWeeklyCompletions();
  }

  Map<String, double> getWeeklyCompletionRates() {
    return _repository.getWeeklyCompletionRates();
  }

  List<HabitModel> getBestPerformingHabits({int limit = 5}) {
    return _repository.getBestPerformingHabits(limit: limit);
  }

  Map<String, int> getMonthCompletions(DateTime month) {
    return _repository.getMonthCompletions(month);
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    return _repository.getHabitsForDate(date);
  }

  // Today's progress
  double getTodayProgress() {
    final todayHabits = this.todayHabits;
    if (todayHabits.isEmpty) return 0;
    
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    final completed = todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
    return completed / todayHabits.length;
  }

  int getTodayCompletedCount() {
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    return todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
  }

  // Get this week's completion rate (0.0 to 1.0)
  double getThisWeekCompletionRate() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final totalPossible = _calculateWeekTotal(startOfWeek);
    
    if (totalPossible == 0) return 0.0;
    
    final completed = _calculateWeekCompleted(startOfWeek);
    return completed / totalPossible;
  }

  // Get this week's completed count
  int getThisWeekCompletedCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _calculateWeekCompleted(startOfWeek).toInt();
  }

  // Get this week's total possible count
  int getThisWeekTotalCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _calculateWeekTotal(startOfWeek).toInt();
  }

  // Helper: Calculate total possible completions for the week
  double _calculateWeekTotal(DateTime startOfWeek) {
    double total = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      if (date.isAfter(now)) break; // Don't count future days
      
      final dayOfWeek = date.weekday - 1; // 0 = Monday, 6 = Sunday
      final habitsForDay = _habits.where((h) => 
        h.scheduledDays.contains(dayOfWeek) && 
        date.isAfter(h.createdAt.subtract(const Duration(days: 1)))
      );
      total += habitsForDay.length;
    }
    
    return total;
  }

  // Helper: Calculate completed habits for the week
  double _calculateWeekCompleted(DateTime startOfWeek) {
    double completed = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      if (date.isAfter(now)) break; // Don't count future days
      
      final dateKey = Helpers.formatDateForStorage(date);
      final dayOfWeek = date.weekday - 1;
      final habitsForDay = _habits.where((h) => 
        h.scheduledDays.contains(dayOfWeek) && 
        date.isAfter(h.createdAt.subtract(const Duration(days: 1)))
      );
      
      for (final habit in habitsForDay) {
        if (habit.isCompletedOn(dateKey)) {
          completed++;
        }
      }
    }
    
    return completed;
  }

  // Check if all today's habits are completed
  bool isTodayPerfect() {
    if (todayHabits.isEmpty) return false;
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    return todayHabits.every((h) => h.isCompletedOn(todayKey));
  }

  // Record a relapse for a quit habit
  Future<void> recordRelapse(String habitId) async {
    final habit = _repository.getHabitById(habitId);
    if (habit == null || !habit.isQuitHabit) return;

    final updatedRelapses = List<DateTime>.from(habit.relapses ?? []);
    updatedRelapses.add(DateTime.now());

    final updatedHabit = habit.copyWith(
      relapses: updatedRelapses,
      quitStartDate: DateTime.now(), // Reset the quit timer
    );

    await _repository.updateHabit(updatedHabit);
    _habits = _repository.getAllHabits();
    notifyListeners();
  }
}
