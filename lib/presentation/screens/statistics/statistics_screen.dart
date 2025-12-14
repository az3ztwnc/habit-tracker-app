import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../widgets/charts/weekly_chart.dart';
import '../../widgets/charts/heat_map.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GalaxyBackground(
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final weeklyRates = habitProvider.getWeeklyCompletionRates();
          final monthCompletions = habitProvider.getMonthCompletions(_selectedMonth);
          final bestHabits = habitProvider.getBestPerformingHabits();

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
                    'Statistics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Stats cards
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: _buildStatsCards(context, habitProvider),
              ),
              const SizedBox(height: 24),
              // Weekly chart
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: WeeklyChart(completionRates: weeklyRates),
              ),
              const SizedBox(height: 24),
              // Heat map
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    // Month navigation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month - 1,
                                );
                              });
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month + 1,
                                );
                              });
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    HeatMap(
                      completions: monthCompletions,
                      month: _selectedMonth,
                      maxHabitsPerDay: habitProvider.totalHabits,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Best performing habits
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: _buildBestHabits(context, bestHabits, habitProvider),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    ),
    );
  }

  Widget _buildStatsCards(BuildContext context, HabitProvider provider) {
    return const SizedBox.shrink(); // Removed stats cards as requested
  }

  Widget _buildWeeklySuccessCard(BuildContext context, HabitProvider provider) {
    final completionRate = provider.getThisWeekCompletionRate();
    final completedThisWeek = provider.getThisWeekCompletedCount();
    final totalThisWeek = provider.getThisWeekTotalCount();
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.greenCyanGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Week Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedThisWeek of $totalThisWeek completed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: _getPerformanceGradient(completionRate),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(completionRate * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: completionRate.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _getPerformanceGradient(completionRate),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPerformanceMessage(completionRate),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getPerformanceGradient(double rate) {
    if (rate >= 0.8) return AppColors.greenCyanGradient;
    if (rate >= 0.6) return AppColors.greenCyanGradient;
    if (rate >= 0.4) return AppColors.cyanPurpleGradient;
    return AppColors.pinkOrangeGradient;
  }

  String _getPerformanceMessage(double rate) {
    if (rate >= 0.9) return 'Excellent! Keep up the amazing work! 🔥';
    if (rate >= 0.7) return 'Great progress! You\'re doing well! 💪';
    if (rate >= 0.5) return 'Good effort! Room for improvement! 📈';
    if (rate >= 0.3) return 'Getting started! Keep pushing! 🌱';
    return 'Don\'t give up! Every step counts! 💙';
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestHabits(
    BuildContext context,
    List habits,
    HabitProvider provider,
  ) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Performing Habits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...habits.map((habit) {
            final gradient = AppColors.habitGradients[
                habit.colorIndex % AppColors.habitGradients.length];
            final icon = AppConstants.habitIcons[
                habit.iconIndex % AppConstants.habitIcons.length];
            final completionRate = (habit.getCompletionRate() * 100).toInt();

            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.currentStreak} streak',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completionRate%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
