/// Interview Screen — Premium Interview Session Experience
///
/// Features:
/// - Design token integration throughout
/// - Premium card styling with AppCard
/// - AppTextField for answer input
/// - Content guidelines integration
/// - Stepped progress bar with design tokens
/// - Premium feedback cards
/// - AppBadge for difficulty display
/// - Haptic feedback on interactions
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_badge.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_loader.dart';
import 'package:mockmate/core/widgets/app_toast.dart';
import 'package:mockmate/features/interview/presentation/bloc/interview_bloc.dart';

class InterviewScreen extends StatelessWidget {
  final String role;
  final String difficulty;
  final int questionCount;

  const InterviewScreen({
    super.key,
    required this.role,
    required this.difficulty,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InterviewBloc>()
        ..add(StartInterview(
          role: role,
          difficulty: difficulty,
          questionCount: questionCount,
        )),
      child: const _InterviewView(),
    );
  }
}

class _InterviewView extends StatefulWidget {
  const _InterviewView();

  @override
  State<_InterviewView> createState() => _InterviewViewState();
}

class _InterviewViewState extends State<_InterviewView>
    with SingleTickerProviderStateMixin {
  final _answerController = TextEditingController();
  late final AnimationController _pulseController;
  DateTime? _submissionTime;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_InterviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track when answer submission starts
    final state = context.read<InterviewBloc>().state;
    if (state is AnswerSubmitting && _submissionTime == null) {
      _submissionTime = DateTime.now();
    } else if (state is! AnswerSubmitting) {
      _submissionTime = null;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InterviewBloc, InterviewState>(
      listener: (context, state) {
        if (state is InterviewError) {
          AppToast.error(
            context,
            message: state.message,
          );
        }
        if (state is FeedbackReceived) {
          _answerController.clear();
        }
        if (state is InterviewCompleted) {
          context.go(
            AppRoutes.feedback,
            extra: {
              'sessionId': state.session.id,
              'score': state.session.finalScore.toInt(),
              'feedback':
                  'Interview completed! See your detailed results below.',
            },
          );
        }
      },
      builder: (context, state) {
        if (state is InterviewLoading) {
          return Scaffold(
            body: AppLoader(message: state.message),
          );
        }

        if (state is InterviewError) {
          return Scaffold(
            body: AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<InterviewBloc>().add(ResetInterview()),
            ),
          );
        }

        if (state is InterviewInProgress ||
            state is AnswerSubmitting ||
            state is FeedbackReceived) {
          return _buildInterviewUI(context, state);
        }

        return const Scaffold(
            body: AppLoader(message: 'Starting interview...'));
      },
    );
  }

  Widget _buildInterviewUI(BuildContext context, InterviewState state) {
    late final int currentIndex;
    late final int totalQuestions;
    late final String question;
    late final String role;
    late final bool isSubmitting;
    late final bool hasFeedback;

    if (state is InterviewInProgress) {
      currentIndex = state.currentQuestionIndex;
      totalQuestions = state.session.questions.length;
      question = state.currentQuestion.question;
      role = state.session.role;
      isSubmitting = false;
      hasFeedback = false;
    } else if (state is AnswerSubmitting) {
      currentIndex = state.currentQuestionIndex;
      totalQuestions = state.session.questions.length;
      question = state.session.questions[currentIndex].question;
      role = state.session.role;
      isSubmitting = true;
      hasFeedback = false;
    } else if (state is FeedbackReceived) {
      currentIndex = state.currentQuestionIndex;
      totalQuestions = state.session.questions.length;
      question = state.session.questions[currentIndex].question;
      role = state.session.role;
      isSubmitting = false;
      hasFeedback = true;
    } else {
      return const SizedBox.shrink();
    }

    final progress = (currentIndex + 1) / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        // Show role + progress for full context
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              role,
              style: AppTypography.titleM.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Question ${currentIndex + 1} of $totalQuestions',
              style: AppTypography.labelM.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.l.toDouble()),
            child: AppBadge(
              label:
                  state is InterviewInProgress ? state.session.difficulty : '',
              variant: BadgeVariant.info,
              size: BadgeSize.large,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Animated Stepped Progress Bar ─────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl.toDouble(),
                AppSpacing.xs.toDouble(),
                AppSpacing.xl.toDouble(),
                0,
              ),
              child: Row(
                children: List.generate(totalQuestions, (i) {
                  final filled = i < currentIndex + 1;
                  final isActive = i == currentIndex;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: AppDurations.normal,
                      curve: AppCurves.easeOutCubic,
                      height: 4,
                      margin: EdgeInsets.only(right: AppSpacing.xs.toDouble()),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        color: filled
                            ? (isActive
                                ? AppColors.primary500
                                : AppColors.primary500.withOpacity(0.5))
                            : AppColors.darkSurface,
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.x3l.toDouble()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Question Card ────────────────────────────────────
                    AnimatedSwitcher(
                      duration: AppDurations.normal,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: Container(
                        key: ValueKey(currentIndex),
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSpacing.xl.toDouble()),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          border: Border.all(
                            color: AppColors.primary500.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.all(AppSpacing.xs.toDouble()),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary500.withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.s),
                                  ),
                                  child: Icon(
                                    Icons.psychology_rounded,
                                    size: 18,
                                    color: AppColors.primary400,
                                  ),
                                ),
                                Gap(AppSpacing.xs.toDouble()),
                                Text(
                                  'Question ${currentIndex + 1}',
                                  style: AppTypography.labelM.copyWith(
                                    color: AppColors.primary400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: AppTypography.labelM.copyWith(
                                    color: AppColors.primary400,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Gap(AppSpacing.m.toDouble()),
                            Text(
                              question,
                              style: AppTypography.bodyL.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                                color: AppColors.neutral100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Gap(AppSpacing.x3l.toDouble()),

                    // ── Answer Field ────────────────────────────────────
                    if (!hasFeedback) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Answer',
                            style: AppTypography.titleM.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _answerController,
                            builder: (_, __) {
                              final wordCount = _answerController.text
                                  .trim()
                                  .split(' ')
                                  .where((w) => w.isNotEmpty)
                                  .length;
                              final charCount =
                                  _answerController.text.trim().length;
                              final isValid =
                                  charCount >= 20; // Minimum 20 characters

                              return Row(
                                children: [
                                  if (!isValid && charCount > 0)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: AppSpacing.s.toDouble(),
                                      ),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: AppColors.error500,
                                      ),
                                    ),
                                  Text(
                                    '$wordCount words · $charCount chars',
                                    style: AppTypography.labelM.copyWith(
                                      color: isValid || charCount == 0
                                          ? AppColors.primary400
                                          : AppColors.error500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      Gap(AppSpacing.xs.toDouble()),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          border: Border.all(
                            color: AppColors.primary500.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: _answerController,
                          maxLines: 10,
                          minLines: 8,
                          enabled: !isSubmitting,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText:
                                'Type your answer here...\n\n💡 Tips:\n• Be specific and detailed\n• Use real examples\n• Explain your reasoning\n• Mention relevant technologies',
                            hintStyle: AppTypography.bodyM.copyWith(
                              color: AppColors.neutral500,
                              height: 1.6,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.l),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.darkSurface,
                            contentPadding:
                                EdgeInsets.all(AppSpacing.xl.toDouble()),
                          ),
                          style: AppTypography.bodyL.copyWith(
                            color: AppColors.neutral100,
                          ),
                        ),
                      ),
                      Gap(AppSpacing.xl.toDouble()),
                      if (isSubmitting)
                        // Pulsing AI evaluation indicator with timeout warning
                        _AiEvaluatingRow(
                          pulse: _pulseController,
                          submissionTime: _submissionTime,
                        )
                      else
                        AppButton(
                          label: 'Submit Answer',
                          onPressed: _answerController.text.trim().length >= 20
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  context.read<InterviewBloc>().add(
                                        SubmitCurrentAnswer(
                                            _answerController.text.trim()),
                                      );
                                }
                              : null, // Disabled if answer too short
                          variant: ButtonVariant.primary,
                          size: ButtonSize.large,
                          isFullWidth: true,
                        ),
                      if (_answerController.text.trim().isNotEmpty &&
                          _answerController.text.trim().length < 20)
                        Padding(
                          padding:
                              EdgeInsets.only(top: AppSpacing.m.toDouble()),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.error500,
                              ),
                              Gap(AppSpacing.s.toDouble()),
                              Expanded(
                                child: Text(
                                  ErrorMessages.answerTooShort,
                                  style: AppTypography.labelM.copyWith(
                                    color: AppColors.error500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    // ── Feedback Card ───────────────────────────────────
                    if (hasFeedback && state is FeedbackReceived) ...[
                      _FeedbackCard(feedback: state.feedback),
                      Gap(AppSpacing.xl.toDouble()),
                      AppButton(
                        label: state.isLastQuestion
                            ? CTALibrary.viewResults
                            : 'Next Question →',
                        icon: state.isLastQuestion
                            ? Icons.emoji_events_rounded
                            : null,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.read<InterviewBloc>().add(NextQuestion());
                        },
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing AI Evaluating Row with Timeout Warning ───────────────────────

class _AiEvaluatingRow extends StatefulWidget {
  final AnimationController pulse;
  final DateTime? submissionTime;

  const _AiEvaluatingRow({
    required this.pulse,
    this.submissionTime,
  });

  @override
  State<_AiEvaluatingRow> createState() => _AiEvaluatingRowState();
}

class _AiEvaluatingRowState extends State<_AiEvaluatingRow> {
  bool _showTimeoutWarning = false;

  @override
  void initState() {
    super.initState();
    // Show timeout warning after 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && widget.submissionTime != null) {
        final elapsed = DateTime.now().difference(widget.submissionTime!);
        if (elapsed.inSeconds >= 15) {
          setState(() => _showTimeoutWarning = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: widget.pulse,
          builder: (context, _) {
            final opacity = 0.5 + (widget.pulse.value * 0.5);
            return Container(
              padding: EdgeInsets.all(AppSpacing.l.toDouble() + 2),
              decoration: BoxDecoration(
                color: AppColors.primary500.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.l),
                border: Border.all(
                  color: AppColors.primary500.withOpacity(opacity * 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primary500.withOpacity(opacity),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.l.toDouble()),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI is evaluating your answer…',
                          style: AppTypography.bodyL.copyWith(
                            color: AppColors.primary500.withOpacity(opacity),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.toDouble()),
                        Text(
                          'Analyzing your response intelligently',
                          style: AppTypography.labelM.copyWith(
                            color: AppColors.primary500.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // DNA-strand dots
                  Row(
                    children: List.generate(3, (i) {
                      final phase = (widget.pulse.value + i / 3) % 1.0;
                      return Container(
                        margin: EdgeInsets.only(
                          left: AppSpacing.xs.toDouble() + 1,
                        ),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary500.withOpacity(
                            (0.3 + math.sin(phase * math.pi) * 0.7)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
        if (_showTimeoutWarning) ...[
          SizedBox(height: AppSpacing.m.toDouble()),
          Container(
            padding: EdgeInsets.all(AppSpacing.m.toDouble()),
            decoration: BoxDecoration(
              color: AppColors.error500.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: AppColors.error500.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: AppColors.error500,
                ),
                SizedBox(width: AppSpacing.m.toDouble()),
                Expanded(
                  child: Text(
                    'This is taking longer than usual. Please wait…',
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.error500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Feedback Card ─────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final dynamic feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final score = feedback.score as int;
    final scoreColor = score >= 80
        ? const Color(0xFF22C55E)
        : score >= 60
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Badge
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.xl.toDouble()),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.l),
            border: Border.all(
              color: scoreColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                '$score',
                style: AppTypography.displayL.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gap(AppSpacing.xs.toDouble()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '/100',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                  Gap(AppSpacing.xs.toDouble()),
                  Text(
                    score >= 80
                        ? 'Excellent! 🎉'
                        : score >= 60
                            ? 'Good answer 👍'
                            : 'Keep practicing 💪',
                    style: AppTypography.bodyM.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Gap(AppSpacing.l.toDouble()),

        Text(
          feedback.overallFeedback as String,
          style: AppTypography.bodyL.copyWith(
            color: AppColors.neutral100,
            height: 1.6,
          ),
        ),

        if ((feedback.strengths as List).isNotEmpty) ...[
          Gap(AppSpacing.l.toDouble()),
          Text(
            '✅ Strengths',
            style: AppTypography.titleM.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(AppSpacing.s.toDouble()),
          ...(feedback.strengths as List).map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs.toDouble()),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                  Gap(AppSpacing.s.toDouble()),
                  Expanded(
                    child: Text(
                      s.toString(),
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        if ((feedback.improvements as List).isNotEmpty) ...[
          Gap(AppSpacing.l.toDouble()),
          Text(
            '📈 Areas to Improve',
            style: AppTypography.titleM.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(AppSpacing.s.toDouble()),
          ...(feedback.improvements as List).map(
            (i) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs.toDouble()),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  Gap(AppSpacing.s.toDouble()),
                  Expanded(
                    child: Text(
                      i.toString(),
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
