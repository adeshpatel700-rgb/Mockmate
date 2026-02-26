/// Interview Screen — the main interview session UI.
///
/// UX Fixes applied:
/// - AppBar shows role + question count for context (not just "1 of 5")
/// - Progress bar is taller, rounded, animated between questions
/// - "AI evaluating" state replaced with a pulsing shimmer row
/// - Answer field shows character count
/// - Haptic feedback on submit
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_loader.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
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
    final theme = Theme.of(context);

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
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Question ${currentIndex + 1} of $totalQuestions',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(
                state is InterviewInProgress ? state.session.difficulty : '',
                style: theme.textTheme.bodySmall,
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Animated Stepped Progress Bar ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: List.generate(totalQuestions, (i) {
                  final filled = i < currentIndex + 1;
                  final isActive = i == currentIndex;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: filled
                            ? (isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary
                                    .withValues(alpha: 0.5))
                            : theme.colorScheme.surface,
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Question Card ────────────────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.psychology_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  'Question ${currentIndex + 1}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(14),
                            Text(
                              question,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(24),

                    // ── Answer Field ────────────────────────────────────
                    if (!hasFeedback) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Answer',
                              style: theme.textTheme.titleMedium),
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
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  Text(
                                    '$wordCount words · $charCount chars',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isValid || charCount == 0
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const Gap(10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.15),
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
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor.withOpacity(0.7),
                              height: 1.6,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const Gap(20),
                      if (isSubmitting)
                        // Pulsing AI evaluation indicator with timeout warning
                        _AiEvaluatingRow(
                          pulse: _pulseController,
                          submissionTime: _submissionTime,
                        )
                      else
                        AppPrimaryButton(
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
                        ),
                      if (_answerController.text.trim().isNotEmpty &&
                          _answerController.text.trim().length < 20)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: theme.colorScheme.error,
                              ),
                              const Gap(8),
                              Text(
                                'Please provide at least 20 characters for a meaningful answer',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    // ── Feedback Card ───────────────────────────────────
                    if (hasFeedback && state is FeedbackReceived) ...[
                      _FeedbackCard(feedback: state.feedback),
                      const Gap(20),
                      AppPrimaryButton(
                        label: state.isLastQuestion
                            ? 'View Results'
                            : 'Next Question →',
                        icon: state.isLastQuestion
                            ? Icons.emoji_events_rounded
                            : null,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.read<InterviewBloc>().add(NextQuestion());
                        },
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
    final theme = Theme.of(context);
    return Column(
      children: [
        AnimatedBuilder(
          animation: widget.pulse,
          builder: (context, _) {
            final opacity = 0.5 + (widget.pulse.value * 0.5);
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(opacity * 0.5),
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
                        theme.colorScheme.primary.withOpacity(opacity),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI is evaluating your answer…',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color:
                                theme.colorScheme.primary.withOpacity(opacity),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Analyzing your response intelligently',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.6),
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
                        margin: const EdgeInsets.only(left: 5),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is taking longer than usual. Please wait…',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
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
    final theme = Theme.of(context);
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(
                '$score',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('/100', style: theme.textTheme.bodyMedium),
                  const Gap(2),
                  Text(
                    score >= 80
                        ? 'Excellent! 🎉'
                        : score >= 60
                            ? 'Good answer 👍'
                            : 'Keep practicing 💪',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: scoreColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Gap(16),

        Text(feedback.overallFeedback as String,
            style: theme.textTheme.bodyLarge),

        if ((feedback.strengths as List).isNotEmpty) ...[
          const Gap(16),
          Text('✅ Strengths', style: theme.textTheme.titleMedium),
          const Gap(8),
          ...(feedback.strengths as List).map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Color(0xFF22C55E)),
                  const Gap(8),
                  Expanded(
                      child: Text(s.toString(),
                          style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],

        if ((feedback.improvements as List).isNotEmpty) ...[
          const Gap(16),
          Text('📈 Areas to Improve', style: theme.textTheme.titleMedium),
          const Gap(8),
          ...(feedback.improvements as List).map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trending_up_rounded,
                      size: 16, color: Color(0xFFF59E0B)),
                  const Gap(8),
                  Expanded(
                      child: Text(i.toString(),
                          style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
