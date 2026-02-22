/// Feedback/Results Screen — shown after completing all interview questions.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/widgets/app_button.dart';

class FeedbackScreen extends StatelessWidget {
  final String sessionId;
  final int score;
  final String feedback;

  const FeedbackScreen({
    super.key,
    required this.sessionId,
    required this.score,
    required this.feedback,
  });

  Color _scoreColor(BuildContext context) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Theme.of(context).colorScheme.error;
  }

  String _scoreLabel() {
    if (score >= 80) return 'Outstanding! 🏆';
    if (score >= 60) return 'Good Job! 👍';
    return 'Keep Practicing! 💪';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _scoreColor(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Score Circle ───────────────────────────────────────────
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('/100', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),

              const Gap(24),

              Text(
                _scoreLabel(),
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),

              const Gap(12),

              Text(
                feedback,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const Gap(48),

              // ── Performance Stats ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session Summary', style: theme.textTheme.titleMedium),
                    const Gap(16),
                    _StatRow(
                      icon: Icons.star_rounded,
                      label: 'Final Score',
                      value: '$score / 100',
                      color: color,
                    ),
                    const Gap(12),
                    _StatRow(
                      icon: Icons.check_circle_rounded,
                      label: 'Status',
                      value: 'Completed',
                      color: Colors.green,
                    ),
                    const Gap(12),
                    _StatRow(
                      icon: Icons.psychology_rounded,
                      label: 'AI Evaluations',
                      value: 'Detailed feedback given',
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),

              const Gap(40),

              AppPrimaryButton(
                label: 'Practice Again',
                icon: Icons.refresh_rounded,
                onPressed: () => context.go(AppRoutes.roleSelection),
              ),

              const Gap(14),

              AppOutlinedButton(
                label: 'Go to Dashboard',
                onPressed: () => context.go(AppRoutes.dashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const Gap(12),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
