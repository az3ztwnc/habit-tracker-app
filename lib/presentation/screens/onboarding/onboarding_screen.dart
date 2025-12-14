import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/habit_suggestions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/premium_icons.dart';
import '../../../core/constants/avatars.dart';
import '../../../providers/habit_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../../core/utils/avatar_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserNameFromSignup();
  }

  Future<void> _loadUserNameFromSignup() async {
    final provider = context.read<OnboardingProvider>();
    final prefs = await SharedPreferences.getInstance();
    final nameFromSignup = prefs.getString('user_name') ?? '';
    
    if (nameFromSignup.isNotEmpty && provider.userName.isEmpty) {
      _nameController.text = nameFromSignup;
      provider.setUserName(nameFromSignup);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final onboardingProvider = context.read<OnboardingProvider>();
    await onboardingProvider.saveOnboardingData();
    
    // Update user name and avatar in HabitProvider
    final habitProvider = context.read<HabitProvider>();
    await habitProvider.updateUser(
      name: onboardingProvider.userName,
      avatarIndex: onboardingProvider.userAvatar,
    );
    
    // Create habits from selections
    final selectedGoodHabits = onboardingProvider.selectedGoodHabits;
    final selectedBadHabits = onboardingProvider.selectedBadHabits;
    
    // Add GOOD habits (to build)
    for (final habitName in selectedGoodHabits) {
      await _addHabitFromSelection(
        habitName: habitName,
        habitList: HabitSuggestions.goodHabits.map((h) => h.toMap()).toList(),
        isQuit: false,
        colorIndex: 0,
        provider: onboardingProvider,
      );
    }
    
    // Add BAD habits (to quit)
    for (final habitName in selectedBadHabits) {
      await _addHabitFromSelection(
        habitName: habitName,
        habitList: HabitSuggestions.badHabits.map((h) => h.toMap()).toList(),
        isQuit: true,
        colorIndex: 1,
        provider: onboardingProvider,
      );
    }
    
    if (mounted) {
      await context.read<HabitProvider>().completeOnboarding();
    }
  }

  int _getIconIndex(IconData icon) {
    // Find the index of this icon in AppConstants.habitIcons
    final index = AppConstants.habitIcons.indexOf(icon);
    // If not found, return a default index
    return index >= 0 ? index : 0;
  }

  /// Get reminder time based on habit category and schedule preference
  String _getReminderTime(String category, String schedulePreference) {
    final isMorning = schedulePreference == 'morning';
    
    // Morning habits (Fitness, Health, Productivity)
    if (['Fitness', 'Health', 'Productivity'].contains(category)) {
      return isMorning ? '07:00' : '09:00';
    }
    // Evening habits (Sleep, Mindfulness)
    if (['Sleep', 'Mindfulness'].contains(category)) {
      return isMorning ? '20:00' : '22:00';
    }
    // Default times
    return isMorning ? '08:00' : '21:00';
  }

  Future<void> _addHabitFromSelection({
    required String habitName,
    required List<Map<String, dynamic>> habitList,
    required bool isQuit,
    required int colorIndex,
    required OnboardingProvider provider,
  }) async {
    final habitData = habitList.firstWhere(
      (h) => h['name'] == habitName,
      orElse: () => <String, dynamic>{},
    );
    
    // Skip if habit not found
    if (habitData.isEmpty) return;
    
    final category = habitData['category'] as String;
    final reminderTime = _getReminderTime(category, provider.schedulePreference);
    // Use preferred days from provider, defaulting to all days if somehow empty
    final preferredDays = provider.preferredDays.isEmpty 
        ? [1, 2, 3, 4, 5, 6, 7]
        : provider.preferredDays;
    
    final habitProvider = context.read<HabitProvider>();
    await habitProvider.addHabit(
      name: habitData['name'] as String,
      iconIndex: _getIconIndex(habitData['icon'] as IconData),
      colorIndex: colorIndex,
      category: category,
      scheduledDays: preferredDays,
      targetDaysPerWeek: preferredDays.length,
      reminderTime: reminderTime,
      isQuitHabit: isQuit,
      quitStartDate: isQuit ? DateTime.now() : null,
      moneySavedPerDay: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the global OnboardingProvider from main.dart instead of creating a local one
    return Scaffold(
      body: GalaxyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      )
                    else
                      const SizedBox(width: 48),
                    Text(
                      'Step ${_currentPage + 1} of 6',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildNameAvatarPage(),
                    _buildGoalsPage(),
                    _buildGoodHabitsPage(),
                    _buildBadHabitsPage(),
                    _buildSchedulePage(),
                  ],
                ),
              ),
              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: _currentPage == index
                            ? AppColors.primaryGradient
                            : null,
                        color: _currentPage == index
                            ? null
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withAlpha(102),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: Text(
                'Welcome to Habit Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: const Text(
              'Your journey to better habits starts here ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: GradientButton(
              text: 'Get Started',
              onPressed: _nextPage,
              width: double.infinity,
              icon: Icons.rocket_launch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameAvatarPage() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'What\'s Your Name?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                onChanged: provider.setUserName,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(102)),
                  filled: true,
                  fillColor: Colors.white.withAlpha(25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Avatar Selection using AvatarManager
              Container(
                height: 300,
                child: SingleChildScrollView(
                  child: AvatarManager.buildSectionedAvatarSelection(
                    selectedIndex: provider.userAvatar,
                    onAvatarSelected: (index) => provider.setUserAvatar(index),
                    avatarSize: 55,
                    crossAxisCount: 3,
                    spacing: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GradientButton(
                text: 'Continue',
                onPressed: provider.userName.isNotEmpty ? _nextPage : () {},
                width: double.infinity,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsPage() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'What Brings You Here?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select all that apply',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),
              ...HabitSuggestions.userGoals.map((goal) {
                final isSelected = provider.selectedGoals.contains(goal);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => provider.toggleGoal(goal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? AppColors.primaryPurple.withAlpha(102)
                            : Colors.white.withAlpha(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryPurple,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
              GradientButton(
                text: 'Continue',
                onPressed:
                    provider.selectedGoals.isNotEmpty ? _nextPage : () {},
                width: double.infinity,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoodHabitsPage() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        // Sort habits by recommendation based on user's selected goals
        final sortedHabits = HabitSuggestions.sortGoodHabitsByRecommendation(
          HabitSuggestions.goodHabits,
          provider.selectedGoals,
        );
        final recommendedCategories = HabitSuggestions.getRecommendedGoodCategories(
          provider.selectedGoals,
        );
        
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Choose Good Habits to Build',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to select, tap again to deselect',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: sortedHabits.length,
                itemBuilder: (context, index) {
                  final habit = sortedHabits[index];
                  final isSelected =
                      provider.selectedGoodHabits.contains(habit.name);
                  final isRecommended = recommendedCategories.contains(habit.category);
                  
                  return GestureDetector(
                    onTap: () => provider.toggleGoodHabit(habit.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppColors.accentGreen.withAlpha(102)
                            : Colors.white.withAlpha(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentGreen
                              : isRecommended
                                  ? AppColors.warning.withAlpha(128)
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                habit.icon,
                                size: 28,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                habit.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.accentGreen,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                          if (isRecommended)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withAlpha(204),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '✨',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GradientButton(
                text: 'Continue',
                onPressed: _nextPage,
                width: double.infinity,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadHabitsPage() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        // Sort habits by recommendation based on user's selected goals
        final sortedHabits = HabitSuggestions.sortBadHabitsByRecommendation(
          HabitSuggestions.badHabits,
          provider.selectedGoals,
        );
        final recommendedCategories = HabitSuggestions.getRecommendedBadCategories(
          provider.selectedGoals,
        );
        
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Habits to Quit (Optional)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'ll help you break free from these',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: sortedHabits.length,
                itemBuilder: (context, index) {
                  final habit = sortedHabits[index];
                  final isSelected =
                      provider.selectedBadHabits.contains(habit.name);
                  final isRecommended = recommendedCategories.contains(habit.category);
                  
                  return GestureDetector(
                    onTap: () => provider.toggleBadHabit(habit.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppColors.error.withAlpha(102)
                            : Colors.white.withAlpha(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.error
                              : isRecommended
                                  ? AppColors.warning.withAlpha(128)
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                habit.icon,
                                size: 28,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                habit.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.error,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                          if (isRecommended)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withAlpha(204),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '✨',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GradientButton(
                    text: 'Continue',
                    onPressed: _nextPage,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _nextPage,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchedulePage() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Your Schedule',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Are you a morning person or night owl?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => provider.setSchedulePreference('morning'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: provider.schedulePreference == 'morning'
                              ? AppColors.warning.withAlpha(102)
                              : Colors.white.withAlpha(25),
                          border: Border.all(
                            color: provider.schedulePreference == 'morning'
                                ? AppColors.warning
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text('🌅', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 8),
                            Text(
                              'Morning',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => provider.setSchedulePreference('night'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: provider.schedulePreference == 'night'
                              ? AppColors.primaryPurple.withAlpha(102)
                              : Colors.white.withAlpha(25),
                          border: Border.all(
                            color: provider.schedulePreference == 'night'
                                ? AppColors.primaryPurple
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text('🌙', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 8),
                            Text(
                              'Night',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Preferred days of the week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildDayChip(provider, 1, 'Mon'),
                  _buildDayChip(provider, 2, 'Tue'),
                  _buildDayChip(provider, 3, 'Wed'),
                  _buildDayChip(provider, 4, 'Thu'),
                  _buildDayChip(provider, 5, 'Fri'),
                  _buildDayChip(provider, 6, 'Sat'),
                  _buildDayChip(provider, 7, 'Sun'),
                ],
              ),
              const SizedBox(height: 40),
              GradientButton(
                text: 'Continue',
                onPressed: _nextPage,
                width: double.infinity,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayChip(OnboardingProvider provider, int day, String label) {
    final isSelected = provider.preferredDays.contains(day);
    return GestureDetector(
      onTap: () => provider.togglePreferredDay(day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.accentCyan.withAlpha(102)
              : Colors.white.withAlpha(25),
          border: Border.all(
            color: isSelected ? AppColors.accentCyan : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPage() {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withAlpha(102),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.flash_1,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  const Text(
                    'All Set!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${provider.userName}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withAlpha(25),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.cup,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'You earned your first stone!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.flash_1,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Starter Crystal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your journey begins now!',
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  GradientButton(
                    text: 'Begin Your Journey',
                    onPressed: _completeOnboarding,
                    width: double.infinity,
                    icon: Icons.rocket_launch,
                  ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14 / 2,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  AppColors.primaryPurple,
                  AppColors.secondaryPink,
                  AppColors.accentCyan,
                  AppColors.accentGreen,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
