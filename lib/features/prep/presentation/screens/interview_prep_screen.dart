/// ═══════════════════════════════════════════════════════════════════════════════
/// 📚 INTERVIEW PREP SCREEN - Premium Study Resources
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Comprehensive interview preparation resources and guidance.
///
/// FEATURES:
/// - Interview tips by category
/// - Common questions bank
/// - STAR method guide
/// - Company-specific prep
/// - Video tutorials (upcoming)
/// - Cheat sheets
///
/// UX PRINCIPLES:
/// - Organized by topic
/// - Searchable content
/// - Bookmarking capability
/// - Progressive disclosure
/// - Premium design
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_card.dart';
import 'package:mockmate/core/widgets/app_toast.dart';

class InterviewPrepScreen extends StatelessWidget {
  const InterviewPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Interview Prep',
          style: AppTypography.titleM.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Quick Tips Section ───────────────────────────────────────
            AppSectionCard(
              title: 'Quick Tips',
              subtitle: 'Essential interview strategies',
              child: Column(
                children: [
                  _TipCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Use the STAR Method',
                    description:
                        'Situation, Task, Action, Result framework for behavioral questions',
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _TipCard(
                    icon: Icons.access_time_rounded,
                    title: 'Practice Time Management',
                    description: 'Aim for 2-3 minute concise answers',
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _TipCard(
                    icon: Icons.question_answer_rounded,
                    title: 'Ask Clarifying Questions',
                    description: 'Show critical thinking before diving in',
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Common Questions ─────────────────────────────────────────
            Text(
              'Common Questions',
              style: AppTypography.titleM.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppSpacing.m),
            _QuestionCategoryCard(
              title: 'Technical',
              icon: Icons.code_rounded,
              count: 50,
              color: AppColors.primary500,
            ),
            Gap(AppSpacing.m),
            _QuestionCategoryCard(
              title: 'Behavioral',
              icon: Icons.people_rounded,
              count: 35,
              color: AppColors.secondary500,
            ),
            Gap(AppSpacing.m),
            _QuestionCategoryCard(
              title: 'System Design',
              icon: Icons.architecture_rounded,
              count: 20,
              color: const Color(0xFFF59E0B),
            ),
            Gap(AppSpacing.m),
            _QuestionCategoryCard(
              title: 'Problem Solving',
              icon: Icons.psychology_rounded,
              count: 40,
              color: const Color(0xFF10B981),
            ),

            Gap(AppSpacing.x3l),

            // ── Study Resources ──────────────────────────────────────────
            AppSectionCard(
              title: 'Study Resources',
              subtitle: 'Curated learning materials',
              child: Column(
                children: [
                  _ResourceCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Interview Handbook',
                    subtitle: 'Complete guide to ace interviews',
                    color: AppColors.primary500,
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _ResourceCard(
                    icon: Icons.video_library_rounded,
                    title: 'Video Tutorials',
                    subtitle: 'Coming soon',
                    color: AppColors.secondary500,
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _ResourceCard(
                    icon: Icons.article_rounded,
                    title: 'Cheat Sheets',
                    subtitle: 'Quick reference guides',
                    color: const Color(0xFFF59E0B),
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

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary500, size: 24),
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
                  description,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCategoryCard extends StatelessWidget {
  const _QuestionCategoryCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
  });

  final String title;
  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.elevated,
      onTap: () {
        HapticFeedback.lightImpact();
        AppToast.info(context, message: '$title questions coming soon!');
      },
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Gap(AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleM.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gap(AppSpacing.xs / 2),
                  Text(
                    '$count questions',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        AppToast.info(context, message: 'Resource coming soon!');
      },
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
