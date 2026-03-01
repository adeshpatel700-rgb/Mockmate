/// ═══════════════════════════════════════════════════════════════════════════════
/// 👤 PROFILE SCREEN - Premium User Profile Experience
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Modern profile screen showcasing user stats, achievements, and activity.
///
/// FEATURES:
/// - User avatar and basic info
/// - Performance statistics (sessions, avg score, best score, streak)
/// - Achievement badges system
/// - Recent activity timeline
/// - Progress charts
/// - Premium design token integration
///
/// UX PRINCIPLES:
/// - Hero section with user identity
/// - Visual hierarchy with stats grid
/// - Achievement gamification
/// - Timeline for recent activity
/// - Accessible and responsive
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Premium App Bar with Profile Header ──────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.darkBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary600,
                      AppColors.primary800,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.x3l),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary400,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: AppShadows.m,
                          ),
                          child: Center(
                            child: Text(
                              'JD',
                              style: AppTypography.headlineL.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Gap(AppSpacing.m),
                        Text(
                          'John Doe',
                          style: AppTypography.headlineM.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(AppSpacing.xs / 2),
                        Text(
                          'john.doe@example.com',
                          style: AppTypography.bodyM.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.x3l),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats Grid ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.history_rounded,
                        label: 'Sessions',
                        value: '47',
                        color: AppColors.primary500,
                      ),
                    ),
                    Gap(AppSpacing.m),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Avg Score',
                        value: '78',
                        color: AppColors.secondary500,
                      ),
                    ),
                  ],
                ),
                Gap(AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        label: 'Best Score',
                        value: '95',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    Gap(AppSpacing.m),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Streak',
                        value: '7 days',
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),

                Gap(AppSpacing.x3l),

                // ── Achievements Section ─────────────────────────────────
                Text(
                  'Achievements',
                  style: AppTypography.titleM.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap(AppSpacing.m),

                AppSectionCard(
                  title: 'Unlocked Badges',
                  subtitle: '5 of 12 achievements earned',
                  child: Wrap(
                    spacing: AppSpacing.m,
                    runSpacing: AppSpacing.m,
                    children: [
                      _AchievementBadge(
                        icon: Icons.rocket_launch_rounded,
                        label: 'First Steps',
                        description: 'Complete your first interview',
                        unlocked: true,
                      ),
                      _AchievementBadge(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Hot Streak',
                        description: '7 day practice streak',
                        unlocked: true,
                      ),
                      _AchievementBadge(
                        icon: Icons.emoji_events_rounded,
                        label: 'Top Performer',
                        description: 'Score 90+ on an interview',
                        unlocked: true,
                      ),
                      _AchievementBadge(
                        icon: Icons.school_rounded,
                        label: 'Dedicated Learner',
                        description: 'Complete 50 sessions',
                        unlocked: false,
                      ),
                      _AchievementBadge(
                        icon: Icons.psychology_rounded,
                        label: 'Expert',
                        description: 'Average score above 85',
                        unlocked: false,
                      ),
                      _AchievementBadge(
                        icon: Icons.workspace_premium_rounded,
                        label: 'Premium Member',
                        description: 'Upgrade to premium',
                        unlocked: false,
                      ),
                    ],
                  ),
                ),

                Gap(AppSpacing.x3l),

                // ── Recent Activity Section ──────────────────────────────
                Text(
                  'Recent Activity',
                  style: AppTypography.titleM.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap(AppSpacing.m),

                AppCard(
                  variant: CardVariant.elevated,
                  child: Column(
                    children: [
                      _ActivityItem(
                        icon: Icons.check_circle_rounded,
                        title: 'Completed Flutter Interview',
                        subtitle: 'Score: 82/100',
                        time: '2 hours ago',
                        color: AppColors.success500,
                      ),
                      Divider(
                        color: AppColors.neutral700,
                        height: 1,
                      ),
                      _ActivityItem(
                        icon: Icons.local_fire_department_rounded,
                        title: '7 Day Streak Milestone',
                        subtitle: 'Keep up the great work!',
                        time: '1 day ago',
                        color: const Color(0xFFEF4444),
                      ),
                      Divider(
                        color: AppColors.neutral700,
                        height: 1,
                      ),
                      _ActivityItem(
                        icon: Icons.emoji_events_rounded,
                        title: 'Unlocked Achievement',
                        subtitle: 'Top Performer badge earned',
                        time: '3 days ago',
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),

                Gap(AppSpacing.x4l),

                // ── Action Buttons ───────────────────────────────────────
                AppButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: Navigate to edit profile
                  },
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.large,
                  isFullWidth: true,
                ),

                Gap(AppSpacing.m),

                AppButton(
                  label: 'View Full Statistics',
                  icon: Icons.analytics_outlined,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.settings);
                  },
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.large,
                  isFullWidth: true,
                ),

                Gap(AppSpacing.x4l),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Gap(AppSpacing.m),
          Text(
            value,
            style: AppTypography.headlineM.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Gap(AppSpacing.xs / 2),
          Text(
            label,
            style: AppTypography.labelS.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.description,
    required this.unlocked,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.primary500.withOpacity(0.15)
                  : AppColors.neutral700,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? AppColors.primary500 : AppColors.neutral600,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: unlocked ? AppColors.primary500 : AppColors.neutral500,
              size: 28,
            ),
          ),
          Gap(AppSpacing.xs),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Text(
                  label,
                  style: AppTypography.labelS.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        unlocked ? AppColors.neutral100 : AppColors.neutral500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Gap(AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(AppSpacing.xs / 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.labelXS.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
