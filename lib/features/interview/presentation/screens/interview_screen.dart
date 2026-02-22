/// Interview Screen — the main interview session UI.
library;

import 'package:flutter/material.dart';
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

class _InterviewViewState extends State<_InterviewView> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
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
              'feedback': 'Interview completed! See your detailed results below.',
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
              onRetry: () => context.read<InterviewBloc>().add(ResetInterview()),
            ),
          );
        }

        if (state is InterviewInProgress || state is AnswerSubmitting || state is FeedbackReceived) {
          return _buildInterviewUI(context, state);
        }

        // Default loading state
        return const Scaffold(body: AppLoader(message: 'Starting interview...'));
      },
    );
  }

  Widget _buildInterviewUI(BuildContext context, InterviewState state) {
    final theme = Theme.of(context);

    late final int currentIndex;
    late final int totalQuestions;
    late final String question;
    late final bool isSubmitting;
    late final bool hasFeedback;

    if (state is InterviewInProgress) {
      currentIndex = state.currentQuestionIndex;
      totalQuestions = state.session.questions.length;
      question = state.currentQuestion.question;
      isSubmitting = false;
      hasFeedback = false;
    } else if (state is AnswerSubmitting) {
      currentIndex = state.currentQuestionIndex;
      totalQuestions = state.session.questions.length;
      question = state.session.questions[currentIndex].question;
      isSubmitting = true;
      hasFeedback = false;
    } else if (state is FeedbackReceived) {
      currentIndex = state.currentQuestionIndex;
      totalQuestions = state.session.questions.length;
      question = state.session.questions[currentIndex].question;
      isSubmitting = false;
      hasFeedback = true;
    } else {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1} of $totalQuestions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text(
                state is InterviewInProgress
                    ? state.session.difficulty
                    : '',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Bar ─────────────────────────────────────────────
            LinearProgressIndicator(
              value: (currentIndex + 1) / totalQuestions,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Question Card ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
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
                                  color: theme.colorScheme.primary.withOpacity(0.15),
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
                            ],
                          ),
                          const Gap(16),
                          Text(
                            question,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(24),

                    // ── Answer Field ────────────────────────────────────────
                    if (!hasFeedback) ...[
                      Text('Your Answer', style: theme.textTheme.titleMedium),
                      const Gap(12),
                      TextFormField(
                        controller: _answerController,
                        maxLines: 8,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          hintText: 'Type your answer here...\n\nTip: Be specific, use examples, and explain your reasoning.',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        style: theme.textTheme.bodyLarge,
                      ),

                      const Gap(20),

                      AppPrimaryButton(
                        label: 'Submit Answer',
                        isLoading: isSubmitting,
                        onPressed: isSubmitting
                            ? null
                            : () {
                                if (_answerController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please write an answer first.')),
                                  );
                                  return;
                                }
                                context.read<InterviewBloc>().add(
                                  SubmitCurrentAnswer(_answerController.text.trim()),
                                );
                              },
                      ),

                      if (isSubmitting) ...[
                        const Gap(16),
                        Center(
                          child: Text(
                            '🤖 AI is evaluating your answer...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ],

                    // ── Feedback Card ─────────────────────────────────────
                    if (hasFeedback && state is FeedbackReceived) ...[
                      _FeedbackCard(feedback: state.feedback),
                      const Gap(20),

                      AppPrimaryButton(
                        label: state.isLastQuestion
                            ? 'View Results'
                            : 'Next Question',
                        icon: state.isLastQuestion
                            ? Icons.emoji_events_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: () => context.read<InterviewBloc>().add(NextQuestion()),
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

// ── Feedback Card ─────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final dynamic feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = feedback.score as int;
    final scoreColor = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scoreColor.withOpacity(0.3)),
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
                    score >= 80 ? 'Excellent!' : score >= 60 ? 'Good' : 'Needs Work',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scoreColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Gap(16),

        // Overall Feedback
        Text(feedback.overallFeedback as String, style: theme.textTheme.bodyLarge),

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
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                  const Gap(8),
                  Expanded(child: Text(s.toString(), style: theme.textTheme.bodyMedium)),
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
                  Icon(Icons.arrow_upward, size: 16, color: Colors.orange),
                  const Gap(8),
                  Expanded(child: Text(i.toString(), style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
