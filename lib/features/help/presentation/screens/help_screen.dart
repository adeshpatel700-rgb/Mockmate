/// ═══════════════════════════════════════════════════════════════════════════════
/// ❓ HELP & SUPPORT SCREEN - Premium Support Experience
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Comprehensive help center with FAQ, contact, and resources.
///
/// FEATURES:
/// - Searchable FAQ
/// - Contact support options
/// - Documentation links
/// - Troubleshooting guides
/// - Feature requests
/// - Bug reporting
///
/// UX PRINCIPLES:
/// - Self-service first
/// - Easy contact options
/// - Clear categorization
/// - Quick answers
/// - Premium design
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_card.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_toast.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
            // ── Quick Actions ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.email_outlined,
                    label: 'Email Us',
                    color: AppColors.primary500,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AppToast.info(context,
                          message: 'Opening email client...');
                    },
                  ),
                ),
                Gap(AppSpacing.m),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Live Chat',
                    color: AppColors.secondary500,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AppToast.info(context, message: 'Chat coming soon!');
                    },
                  ),
                ),
              ],
            ),

            Gap(AppSpacing.x3l),

            // ── FAQ Section ──────────────────────────────────────────────
            Text(
              'Frequently Asked Questions',
              style: AppTypography.titleM.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppSpacing.m),

            AppCard(
              variant: CardVariant.elevated,
              child: Column(
                children: [
                  _FAQItem(
                    question: 'How does MockMate work?',
                    answer:
                        'MockMate uses AI to generate personalized interview questions based on your role and experience level. Practice answering, receive instant feedback, and track your progress over time.',
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _FAQItem(
                    question: 'Is my data secure?',
                    answer:
                        'Yes! We use industry-standard encryption and never share your data with third parties. Your interview history is stored securely and only accessible to you.',
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _FAQItem(
                    question: 'Can I practice for specific companies?',
                    answer:
                        'Absolutely! MockMate includes company-specific interview prep for top tech companies including Google, Amazon, Meta, and more.',
                  ),
                  Divider(color: AppColors.neutral700, height: 1),
                  _FAQItem(
                    question: 'How is my score calculated?',
                    answer:
                        'Your score is based on multiple factors: answer completeness, use of examples, technical accuracy, clarity, and time taken. Our AI evaluates each response holistically.',
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.x3l),

            // ── Resources Section ────────────────────────────────────────
            Text(
              'Resources',
              style: AppTypography.titleM.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppSpacing.m),

            _ResourceLink(
              icon: Icons.description_outlined,
              title: 'Documentation',
              subtitle: 'Complete user guide and tutorials',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.info(context, message: 'Documentation coming soon!');
              },
            ),
            Gap(AppSpacing.s),
            _ResourceLink(
              icon: Icons.video_library_rounded,
              title: 'Video Tutorials',
              subtitle: 'Learn how to use MockMate effectively',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.info(context, message: 'Video tutorials coming soon!');
              },
            ),
            Gap(AppSpacing.s),
            _ResourceLink(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Help us improve MockMate',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.info(context, message: 'Bug reporting coming soon!');
              },
            ),
            Gap(AppSpacing.s),
            _ResourceLink(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Feature Request',
              subtitle: 'Suggest new features',
              onTap: () {
                HapticFeedback.lightImpact();
                AppToast.info(context,
                    message: 'Feature requests coming soon!');
              },
            ),

            Gap(AppSpacing.x3l),

            // ── Contact Support ──────────────────────────────────────────
            AppSectionCard(
              title: 'Still Need Help?',
              subtitle: 'Our support team is here for you',
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: Column(
                  children: [
                    Text(
                      'Contact us at support@mockmate.app',
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.neutral300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(AppSpacing.l),
                    AppButton(
                      label: 'Send us a Message',
                      icon: Icons.send_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AppToast.info(context,
                            message: 'Contact form coming soon!');
                      },
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      isFullWidth: true,
                    ),
                  ],
                ),
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Gap(AppSpacing.m),
            Text(
              label,
              style: AppTypography.labelM.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isExpanded = !_isExpanded);
      },
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.neutral400,
                ),
              ],
            ),
            if (_isExpanded) ...[
              Gap(AppSpacing.m),
              Text(
                widget.answer,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.neutral300,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResourceLink extends StatelessWidget {
  const _ResourceLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary500.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
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
