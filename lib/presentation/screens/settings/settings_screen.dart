import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/avatar_manager.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/galaxy_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _soundsEnabled = true;
  bool _hapticsEnabled = true;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<HabitProvider>().user;
    _nameController.text = user?.name ?? 'User';
    _loadLocalSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const Center(child: CircularProgressIndicator());
    }

    return GalaxyBackground(
      child: Consumer2<HabitProvider, ThemeProvider>(
        builder: (context, habitProvider, themeProvider, child) {
          final user = habitProvider.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Profile section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: _buildProfileSection(context, habitProvider, user),
                ),
                const SizedBox(height: 24),
                // Appearance section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: _buildAppearanceSection(context, themeProvider),
                ),
                const SizedBox(height: 24),
                // Notifications section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: _buildNotificationsSection(
                    context,
                    habitProvider,
                    user,
                  ),
                ),
                const SizedBox(height: 24),
                // Data section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 350),
                  child: _buildDataSection(context, habitProvider),
                ),
                const SizedBox(height: 24),
                // About section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: _buildAboutSection(context),
                ),
                const SizedBox(height: 24),
                // Account section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 450),
                  child: _buildAccountSection(context),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    HabitProvider habitProvider,
    user,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar - Show actual selected avatar
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAvatarPicker(context, habitProvider);
                  },
                  child: AvatarManager.getAvatarWidget(
                    user?.avatarIndex ?? 0,
                    size: 80,
                    showBorder: true,
                    borderColor: AppColors.primaryPurple,
                    borderWidth: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to change avatar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 20),
                // Name
                if (_isEditingName)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          habitProvider.updateUser(
                            name: _nameController.text.trim(),
                          );
                          setState(() => _isEditingName = false);
                        },
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () {
                          _nameController.text = user?.name ?? 'User';
                          setState(() => _isEditingName = false);
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isEditingName = true);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // Level and XP
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.cyanPurpleGradient.createShader(bounds),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Level ${habitProvider.level} • ${habitProvider.totalXP} XP',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                // Theme toggle
                _buildSettingsTile(
                  context,
                  icon: themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  title: 'Dark Mode',
                  subtitle: themeProvider.isDarkMode ? 'On' : 'Off',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.setDarkMode(value),
                  ),
                ),
                // Accent color
                _buildSettingsTile(
                  context,
                  icon: Icons.palette,
                  title: 'Accent Color',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeProvider.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showColorPicker(context, themeProvider);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    HabitProvider habitProvider,
    user,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications & Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications,
                  title: 'Habit Reminders',
                  subtitle: user?.notificationsEnabled == true
                      ? 'Enabled'
                      : 'Disabled',
                  trailing: Switch(
                    value: user?.notificationsEnabled ?? true,
                    onChanged: (value) async {
                      HapticFeedback.lightImpact();
                      if (value) {
                        final granted = await habitProvider
                            .requestNotificationPermission();
                        if (!granted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enable notification permission in settings',
                                ),
                              ),
                            );
                          }
                          setState(() {});
                          return;
                        }
                        await habitProvider.updateUser(
                          notificationsEnabled: true,
                        );
                      } else {
                        await habitProvider.disableAllNotifications();
                      }
                      setState(() {});
                    },
                  ),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.nightlight_round,
                  title: 'Quiet Hours',
                  subtitle:
                      '${_formatTime(_quietStart)} - ${_formatTime(_quietEnd)}',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await _pickQuietHours();
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.vibration,
                  title: 'Sounds',
                  subtitle: _soundsEnabled ? 'Enabled' : 'Muted',
                  trailing: Switch(
                    value: _soundsEnabled,
                    onChanged: (value) async {
                      HapticFeedback.lightImpact();
                      await _savePrefs(sounds: value);
                    },
                  ),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.touch_app,
                  title: 'Haptics',
                  subtitle: _hapticsEnabled ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: _hapticsEnabled,
                    onChanged: (value) async {
                      HapticFeedback.lightImpact();
                      await _savePrefs(haptics: value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context, HabitProvider habitProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data & Privacy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.upload_file,
                  title: 'Export Data',
                  subtitle: 'Backup your habits',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await _exportData(context, habitProvider);
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.download,
                  title: 'Import Data',
                  subtitle: 'Restore from backup',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await _importData(context, habitProvider);
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Clear All Data',
                  subtitle: 'Reset everything',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showClearDataDialog(context, habitProvider);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.info,
                  title: 'Version',
                  subtitle: AppConstants.appVersion,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.code,
                  title: 'Made with ❤️',
                  subtitle: 'Flutter & Dart',
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.star_rate,
                  title: 'Rate App',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thanks for rating!')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.share,
                  title: 'Share App',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'Check out this Habit Tracker app!',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share text copied to clipboard'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(13),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showAvatarPicker(BuildContext context, HabitProvider habitProvider) {
    int selectedIndex = habitProvider.user?.avatarIndex ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  const Text(
                    'Choose Avatar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemCount: AppConstants.avatarImages.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedIndex;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedIndex = index);
                            habitProvider.updateUser(avatarIndex: index);
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryPurple
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AppConstants.avatarImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Accent Color',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(AppColors.habitColors.length, (index) {
                  final isSelected = index == themeProvider.accentColorIndex;
                  return GestureDetector(
                    onTap: () {
                      themeProvider.setAccentColor(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.habitColors[index],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.habitColors[index].withAlpha(102),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryPurple),
            SizedBox(width: 12),
            Text('Coming Soon'),
          ],
        ),
        content: const Text('This feature is coming in a future update!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will delete all your habits, progress, and achievements. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await provider.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Pop back to profile screen - the app will handle state changes
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userEmail = authProvider.userEmail;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                if (userEmail != null)
                  _buildSettingsTile(
                    context,
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: userEmail,
                  ),
                _buildSettingsTile(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Log out of your account',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Capture providers before showing dialog to avoid context issues
    final authProvider = context.read<AuthProvider>();
    final habitProvider = context.read<HabitProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.primaryPurple),
            SizedBox(width: 12),
            Text('Sign Out?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out? You can sign back in anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authProvider.signOut();
              await habitProvider.clearAllData();
              // The app will automatically show LoginScreen because auth state changed
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString('settings_quiet_start');
    final endStr = prefs.getString('settings_quiet_end');
    final start = startStr != null ? _parseTime(startStr) : _quietStart;
    final end = endStr != null ? _parseTime(endStr) : _quietEnd;

    // Persist defaults so NotificationService can read quiet hours even before edits
    if (startStr == null) {
      await prefs.setString('settings_quiet_start', _formatPrefsTime(start));
    }
    if (endStr == null) {
      await prefs.setString('settings_quiet_end', _formatPrefsTime(end));
    }

    setState(() {
      _soundsEnabled = prefs.getBool('settings_sounds') ?? true;
      _hapticsEnabled = prefs.getBool('settings_haptics') ?? true;
      _quietStart = start;
      _quietEnd = end;
      _loadingPrefs = false;
    });
  }

  Future<void> _savePrefs({
    bool? sounds,
    bool? haptics,
    TimeOfDay? start,
    TimeOfDay? end,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool quietChanged = false;
    if (sounds != null) {
      await prefs.setBool('settings_sounds', sounds);
      setState(() => _soundsEnabled = sounds);
    }
    if (haptics != null) {
      await prefs.setBool('settings_haptics', haptics);
      setState(() => _hapticsEnabled = haptics);
    }
    if (start != null) {
      await prefs.setString('settings_quiet_start', _formatPrefsTime(start));
      setState(() => _quietStart = start);
      quietChanged = true;
    }
    if (end != null) {
      await prefs.setString('settings_quiet_end', _formatPrefsTime(end));
      setState(() => _quietEnd = end);
      quietChanged = true;
    }

    if (quietChanged) {
      final habitProvider = context.read<HabitProvider>();
      await habitProvider.rescheduleAllReminders();
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatPrefsTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $suffix';
  }

  Future<void> _pickQuietHours() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _quietStart,
    );
    if (start == null) return;
    final end = await showTimePicker(context: context, initialTime: _quietEnd);
    if (end == null) return;
    await _savePrefs(start: start, end: end);
  }

  Future<void> _exportData(BuildContext context, HabitProvider provider) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/habit_backup.json');

    final user = provider.user;
    final habits = provider.habits;
    final data = {
      'user': user == null
          ? null
          : {
              'id': user.id,
              'name': user.name,
              'avatarEmoji': user.avatarEmoji,
              'totalXP': user.totalXP,
              'createdAt': user.createdAt.toIso8601String(),
              'hasCompletedOnboarding': user.hasCompletedOnboarding,
              'isDarkMode': user.isDarkMode,
              'accentColorIndex': user.accentColorIndex,
              'notificationsEnabled': user.notificationsEnabled,
              'unlockedAchievements': user.unlockedAchievements,
              'unlockedStones': user.unlockedStones,
            },
      'habits': habits
          .map(
            (h) => {
              'id': h.id,
              'name': h.name,
              'description': h.description,
              'iconIndex': h.iconIndex,
              'colorIndex': h.colorIndex,
              'category': h.category,
              'scheduledDays': h.scheduledDays,
              'targetDaysPerWeek': h.targetDaysPerWeek,
              'createdAt': h.createdAt.toIso8601String(),
              'reminderTime': h.reminderTime,
              'isArchived': h.isArchived,
              'currentStreak': h.currentStreak,
              'longestStreak': h.longestStreak,
              'totalCompletions': h.totalCompletions,
              'completedDates': h.completedDates,
              'isQuitHabit': h.isQuitHabit,
              'quitStartDate': h.quitStartDate?.toIso8601String(),
              'moneySavedPerDay': h.moneySavedPerDay,
              'relapses': h.relapses?.map((d) => d.toIso8601String()).toList(),
            },
          )
          .toList(),
    };

    await file.writeAsString(jsonEncode(data));

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup saved to ${file.path}')));
    }
  }

  Future<void> _importData(BuildContext context, HabitProvider provider) async {
    final dir = await getApplicationDocumentsDirectory();
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Habit Backup',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      initialDirectory: (Platform.isAndroid || Platform.isIOS)
          ? null
          : dir.path,
    );

    if (result == null || result.files.single.path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No backup selected')));
      }
      return;
    }

    final file = File(result.files.single.path!);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File not found: ${file.path}')));
      }
      return;
    }

    final content = await file.readAsString();
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final userData = decoded['user'] as Map<String, dynamic>?;
    final habitsData = (decoded['habits'] as List<dynamic>? ?? []);

    await provider.restoreFromBackup(userData, habitsData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully')),
      );
    }
  }
}
