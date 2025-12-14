import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/avatar_manager.dart';
import '../../../data/models/user_model.dart';

class PremiumProfileHeader extends StatefulWidget {
  final UserModel? user;
  final int totalHabits;
  final int completedToday;
  final int totalToday;
  final int currentStreak;
  final int longestStreak;
  final double levelProgress;
  final VoidCallback? onAvatarTap;
  // Weekly mission data (optional, with safe defaults)
  final int weeklyTargetDays;
  final int weeklyAchievedDays;
  final int weeklyRewardXP;
  // Navigation callback for weekly mission chip
  final VoidCallback? onWeeklyMissionTap;
  // Callback for streak tap - opens same sheet as level/progress
  final VoidCallback? onStreakTap;

  const PremiumProfileHeader({
    super.key,
    this.user,
    required this.totalHabits,
    required this.completedToday,
    required this.totalToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.levelProgress,
    this.onAvatarTap,
    this.weeklyTargetDays = 5,
    this.weeklyAchievedDays = 0,
    this.weeklyRewardXP = 100,
    this.onWeeklyMissionTap,
    this.onStreakTap,
  });

  @override
  State<PremiumProfileHeader> createState() => _PremiumProfileHeaderState();
}

class _PremiumProfileHeaderState extends State<PremiumProfileHeader>
    with TickerProviderStateMixin {
  late AnimationController _fireController;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fire animation for streak
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _fireAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  // Calculate XP to next level
  int get _xpToNextLevel {
    final totalXP = widget.user?.totalXP ?? 0;
    final remainder = totalXP % AppConstants.xpPerLevel;
    // Handle the case where XP is exactly at a level boundary
    if (remainder == 0 && totalXP > 0) {
      return 0; // Just leveled up
    }
    return AppConstants.xpPerLevel - remainder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Info + Quick Stats
          Row(
            children: [
              // Clean avatar without ring
              _buildAvatarWithProgress(),
              
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Level + XP
                    Row(
                      children: [
                        _buildLevelBadge(),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.user?.totalXP ?? 0} XP',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // NEW: XP Bar with text showing current XP and "+XP to next level"
          _buildXPProgressBar(),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Streak Duo (current vs best) and Weekly Mission Pill
          Row(
            children: [
              // Single streak indicator
              Expanded(child: _buildStreakDuo()),
              const SizedBox(width: 12),
              // Weekly Mission Pill
              Expanded(child: _buildWeeklyMissionPill()),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: XP Progress Bar with current XP and "+XP to next level" text
  Widget _buildXPProgressBar() {
    final totalXP = widget.user?.totalXP ?? 0;
    final currentLevelXP = totalXP % AppConstants.xpPerLevel;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.cyanPurpleGradient.createShader(bounds),
                    child: const Icon(
                      Iconsax.flash_15,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$currentLevelXP XP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.cyanPurpleGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$_xpToNextLevel to next level',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Progress with gradient
                FractionallySizedBox(
                  widthFactor: widget.levelProgress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Streak indicator - clicking opens same sheet as level/progress (via callback)
  Widget _buildStreakDuo() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Use the provided callback to open the same sheet as level/progress
        if (widget.onStreakTap != null) {
          widget.onStreakTap!();
        } else {
          // Fallback to internal streak details if no callback provided
          _showStreakDetails();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _fireAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.currentStreak > 0 ? _fireAnimation.value : 1.0,
                  child: Icon(
                    Icons.local_fire_department,
                    size: 28,
                    color: widget.currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${widget.currentStreak}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.currentStreak > 0 ? Colors.orange : Colors.grey,
                        ),
                      ),
                      Text(
                        ' / ${widget.longestStreak}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Current / Best',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Weekly Mission Pill with target/achieved days and reward XP
  Widget _buildWeeklyMissionPill() {
    final progress = widget.weeklyTargetDays > 0
        ? (widget.weeklyAchievedDays / widget.weeklyTargetDays).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = widget.weeklyAchievedDays >= widget.weeklyTargetDays;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onWeeklyMissionTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isComplete
              ? AppColors.cyanPurpleGradient
              : null,
          color: isComplete ? null : AppColors.primaryPurple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComplete
                ? Colors.transparent
                : AppColors.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Progress chip
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? Colors.white : AppColors.accentCyan,
                    ),
                  ),
                ),
                Icon(
                  isComplete ? Icons.check : Iconsax.cup5,
                  size: 14,
                  color: isComplete ? Colors.white : AppColors.accentCyan,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.weeklyAchievedDays}/${widget.weeklyTargetDays} days',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isComplete ? 'Mission Complete!' : '+${widget.weeklyRewardXP} XP reward',
                    style: TextStyle(
                      fontSize: 10,
                      color: isComplete ? Colors.white.withOpacity(0.8) : AppColors.accentCyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Clean avatar without ring (per feedback)
  Widget _buildAvatarWithProgress() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onAvatarTap?.call();
      },
      child: AvatarManager.getAvatarWidget(
        widget.user?.avatarIndex,
        size: 64,
        showBorder: true,
        borderColor: AppColors.primaryPurple.withOpacity(0.6),
        borderWidth: 3,
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Level ${widget.user?.level ?? 0}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showStreakDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.local_fire_department,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.currentStreak} Day Streak!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Best: ${widget.longestStreak} days',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            // Streak milestones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMilestone(7, 'Week', widget.currentStreak >= 7),
                _buildMilestone(30, 'Month', widget.currentStreak >= 30),
                _buildMilestone(100, '100!', widget.currentStreak >= 100),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(int days, String label, bool achieved) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: achieved 
                ? Colors.orange.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: achieved ? Colors.orange : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: achieved
                ? const Icon(Icons.check, color: Colors.orange)
                : Text(
                    '$days',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: achieved ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }
}
