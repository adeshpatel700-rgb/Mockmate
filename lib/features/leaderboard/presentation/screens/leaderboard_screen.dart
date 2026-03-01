/// ═══════════════════════════════════════════════════════════════════════════════
/// 🏆 LEADERBOARD SCREEN - Community Rankings
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Gamified leaderboard showing top performers and user ranking.
///
/// FEATURES:
/// - Global leaderboard (last 30 days)
/// - User's current rank
/// - Top 3 podium display
/// - Score and streak info
/// - Filter by time period
/// - Achievement badges
///
/// UX PRINCIPLES:
/// - Competitive yet encouraging
/// - Clear ranking visualization
/// - User's position highlighted
/// - Motivational design
/// - Premium aesthetics
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: AppTypography.titleM.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top 3 Podium ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(AppSpacing.x3l),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary800,
                    AppColors.darkBackground,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PodiumPlace(
                    rank: 2,
                    name: 'Alice',
                    score: 92,
                    height: 100,
                    color: const Color(0xFFC0C0C0),
                  ),
                  Gap(AppSpacing.m),
                  _PodiumPlace(
                    rank: 1,
                    name: 'Bob',
                    score: 98,
                    height: 130,
                    color: const Color(0xFFFFD700),
                  ),
                  Gap(AppSpacing.m),
                  _PodiumPlace(
                    rank: 3,
                    name: 'Charlie',
                    score: 89,
                    height: 80,
                    color: const Color(0xFFCD7F32),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Rest of Leaderboard ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
              child: Column(
                children: [
                  _LeaderboardItem(
                    rank: 4,
                    name: 'Diana',
                    score: 87,
                    streak: 5,
                    isCurrentUser: false,
                  ),
                  Gap(AppSpacing.s),
                  _LeaderboardItem(
                    rank: 5,
                    name: 'You',
                    score: 85,
                    streak: 7,
                    isCurrentUser: true,
                  ),
                  Gap(AppSpacing.s),
                  _LeaderboardItem(
                    rank: 6,
                    name: 'Frank',
                    score: 83,
                    streak: 3,
                    isCurrentUser: false,
                  ),
                  Gap(AppSpacing.s),
                  _LeaderboardItem(
                    rank: 7,
                    name: 'Grace',
                    score: 80,
                    streak: 4,
                    isCurrentUser: false,
                  ),
                  Gap(AppSpacing.s),
                  _LeaderboardItem(
                    rank: 8,
                    name: 'Henry',
                    score: 78,
                    streak: 2,
                    isCurrentUser: false,
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.x4l),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.rank,
    required this.name,
    required this.score,
    required this.height,
    required this.color,
  });

  final int rank;
  final String name;
  final int score;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: AppShadows.m,
          ),
          child: Center(
            child: Text(
              name[0],
              style: AppTypography.headlineM.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Gap(AppSpacing.xs),
        Text(
          name,
          style: AppTypography.labelM.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Gap(AppSpacing.xs / 2),
        Text(
          '$score pts',
          style: AppTypography.labelS.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Gap(AppSpacing.m),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xs),
            ),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: AppTypography.titleL.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.score,
    required this.streak,
    required this.isCurrentUser,
  });

  final int rank;
  final String name;
  final int score;
  final int streak;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: isCurrentUser ? CardVariant.outlined : CardVariant.elevated,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.l),
        decoration: isCurrentUser
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(
                  color: AppColors.primary500,
                  width: 2,
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isCurrentUser ? AppColors.primary500 : AppColors.neutral700,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: AppTypography.labelM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isCurrentUser ? Colors.white : AppColors.neutral300,
                  ),
                ),
              ),
            ),
            Gap(AppSpacing.m),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primary500.withOpacity(0.2)
                    : AppColors.neutral700,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: AppTypography.titleM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isCurrentUser
                        ? AppColors.primary500
                        : AppColors.neutral300,
                  ),
                ),
              ),
            ),
            Gap(AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCurrentUser
                          ? AppColors.primary500
                          : AppColors.neutral100,
                    ),
                  ),
                  Gap(AppSpacing.xs / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: const Color(0xFFEF4444),
                      ),
                      Gap(AppSpacing.xs / 2),
                      Text(
                        '$streak day streak',
                        style: AppTypography.labelS.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$score',
              style: AppTypography.titleM.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    isCurrentUser ? AppColors.primary500 : AppColors.neutral100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
