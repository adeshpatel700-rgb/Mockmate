/// Feedback/Results Screen — Premium Results Experience
///
/// Features:
/// - Animated score count-up with design tokens
/// - Animated circular progress arc
/// - Premium card styling with AppCard
/// - Content guidelines integration
/// - AppButton components
/// - Design token spacing and typography
/// - Confetti-style feedback for high scores
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_card.dart';

class FeedbackScreen extends StatefulWidget {
  final String sessionId;
  final int score;
  final String feedback;

  const FeedbackScreen({
    super.key,
    required this.sessionId,
    required this.score,
    required this.feedback,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreProgress;
  late final Animation<int> _scoreCount;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scoreProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    );
    _scoreCount = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    // Delay slightly for dramatic effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
        if (widget.score >= 80) HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _scoreColor() {
    if (widget.score >= 80) return const Color(0xFF22C55E);
    if (widget.score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _scoreLabel() {
    if (widget.score >= 80) return 'Outstanding! 🏆';
    if (widget.score >= 60) return 'Good Job! 👍';
    return 'Keep Practicing! 💪';
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.x3l.toDouble(),
            vertical: AppSpacing.x4l.toDouble(),
          ),
          child: Column(
            children: [
              // ── Animated Score Arc ──────────────────────────────────
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Arc painter
                        CustomPaint(
                          size: const Size(180, 180),
                          painter: _ScoreArcPainter(
                            progress: _scoreProgress.value,
                            targetScore: widget.score,
                            color: color,
                            backgroundColor: color.withOpacity(0.12),
                          ),
                        ),
                        // Animated score number
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_scoreCount.value}',
                              style: AppTypography.displayXXL.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 52,
                              ),
                            ),
                            Text(
                              '/100',
                              style: AppTypography.bodyM.copyWith(
                                color: color.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              Gap(AppSpacing.x3l.toDouble()),

              FadeTransition(
                opacity: _contentFade,
                child: Text(
                  _scoreLabel(),
                  style: AppTypography.headlineXL.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Gap(AppSpacing.m.toDouble()),

              FadeTransition(
                opacity: _contentFade,
                child: Text(
                  widget.feedback,
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.neutral300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Gap(AppSpacing.x5l.toDouble()),

              // ── Performance Stats ─────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: AppSectionCard(
                  title: 'Session Summary',
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.star_rounded,
                        label: 'Final Score',
                        value: '${widget.score} / 100',
                        color: color,
                      ),
                      Gap(AppSpacing.m.toDouble()),
                      _StatRow(
                        icon: Icons.check_circle_rounded,
                        label: 'Status',
                        value: 'Completed ✓',
                        color: const Color(0xFF22C55E),
                      ),
                      Gap(AppSpacing.m.toDouble()),
                      _StatRow(
                        icon: Icons.psychology_rounded,
                        label: 'AI Evaluations',
                        value: 'Answer-by-answer',
                        color: AppColors.primary500,
                      ),
                      Gap(AppSpacing.m.toDouble()),
                      _StatRow(
                        icon: Icons.bar_chart_rounded,
                        label: 'Performance',
                        value: widget.score >= 80
                            ? 'Top tier'
                            : widget.score >= 60
                                ? 'Average'
                                : 'Needs work',
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),

              Gap(AppSpacing.x4l.toDouble()),

              FadeTransition(
                opacity: _contentFade,
                child: Column(
                  children: [
                    AppButton(
                      label: CTALibrary.practiceAgain,
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go(AppRoutes.roleSelection);
                      },
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      isFullWidth: true,
                    ),
                    Gap(AppSpacing.m.toDouble()),
                    AppButton(
                      label: 'Go to Dashboard',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go(AppRoutes.dashboard);
                      },
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.large,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score Arc Painter ─────────────────────────────────────────────────────

class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final int targetScore;
  final Color color;
  final Color backgroundColor;

  const _ScoreArcPainter({
    required this.progress,
    required this.targetScore,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;
    const startAngle = -math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      bgPaint,
    );

    // Foreground arc (animated)
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sweep = sweepTotal * (targetScore / 100) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) =>
      old.progress != progress || old.targetScore != targetScore;
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
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        Gap(AppSpacing.m.toDouble()),
        Text(
          label,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral300,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyM.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral100,
          ),
        ),
      ],
    );
  }
}
