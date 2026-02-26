/// Interview Bloc — manages the complete interview session state.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:mockmate/features/interview/domain/entities/interview_entities.dart';
import 'package:mockmate/features/interview/domain/usecases/generate_questions_usecase.dart';
import 'package:mockmate/features/interview/domain/usecases/submit_answer_usecase.dart';

// ── Events ─────────────────────────────────────────────────────────────────

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();
  @override
  List<Object?> get props => [];
}

class StartInterview extends InterviewEvent {
  final String role;
  final String difficulty;
  final int questionCount;

  const StartInterview({
    required this.role,
    required this.difficulty,
    required this.questionCount,
  });

  @override
  List<Object> get props => [role, difficulty, questionCount];
}

class SubmitCurrentAnswer extends InterviewEvent {
  final String answer;
  const SubmitCurrentAnswer(this.answer);

  @override
  List<Object> get props => [answer];
}

class NextQuestion extends InterviewEvent {}

class ResetInterview extends InterviewEvent {}

// ── States ─────────────────────────────────────────────────────────────────

abstract class InterviewState extends Equatable {
  const InterviewState();
  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {
  final String message;
  const InterviewLoading({this.message = 'Preparing your interview...'});

  @override
  List<Object> get props => [message];
}

class InterviewInProgress extends InterviewState {
  final InterviewSession session;
  final int currentQuestionIndex;

  const InterviewInProgress({
    required this.session,
    required this.currentQuestionIndex,
  });

  Question get currentQuestion => session.questions[currentQuestionIndex];
  bool get isLastQuestion =>
      currentQuestionIndex == session.questions.length - 1;

  @override
  List<Object> get props => [session, currentQuestionIndex];
}

class AnswerSubmitting extends InterviewState {
  final InterviewSession session;
  final int currentQuestionIndex;

  const AnswerSubmitting({
    required this.session,
    required this.currentQuestionIndex,
  });

  @override
  List<Object> get props => [session, currentQuestionIndex];
}

class FeedbackReceived extends InterviewState {
  final InterviewSession session;
  final int currentQuestionIndex;
  final AnswerFeedback feedback;

  const FeedbackReceived({
    required this.session,
    required this.currentQuestionIndex,
    required this.feedback,
  });

  bool get isLastQuestion =>
      currentQuestionIndex == session.questions.length - 1;

  @override
  List<Object> get props => [session, currentQuestionIndex, feedback];
}

class InterviewCompleted extends InterviewState {
  final InterviewSession session;
  const InterviewCompleted(this.session);

  @override
  List<Object> get props => [session];
}

class InterviewError extends InterviewState {
  final String message;
  const InterviewError(this.message);

  @override
  List<Object> get props => [message];
}

// ── Bloc ───────────────────────────────────────────────────────────────────

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final GenerateQuestionsUseCase _generateQuestionsUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;

  InterviewBloc({
    required GenerateQuestionsUseCase generateQuestionsUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
  })  : _generateQuestionsUseCase = generateQuestionsUseCase,
        _submitAnswerUseCase = submitAnswerUseCase,
        super(InterviewInitial()) {
    on<StartInterview>(_onStartInterview);
    on<SubmitCurrentAnswer>(_onSubmitCurrentAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<ResetInterview>(_onResetInterview);
  }

  Future<void> _onStartInterview(
    StartInterview event,
    Emitter<InterviewState> emit,
  ) async {
    emit(const InterviewLoading(
        message: 'Generating your questions with AI...'));

    final result = await _generateQuestionsUseCase(
      GenerateQuestionsParams(
        role: event.role,
        difficulty: event.difficulty,
        count: event.questionCount,
      ),
    );

    result.fold(
      (failure) => emit(InterviewError(failure.message)),
      (questions) {
        final session = InterviewSession(
          id: const Uuid().v4(),
          role: event.role,
          difficulty: event.difficulty,
          questions: questions,
          startedAt: DateTime.now(),
        );
        emit(InterviewInProgress(session: session, currentQuestionIndex: 0));
      },
    );
  }

  Future<void> _onSubmitCurrentAnswer(
    SubmitCurrentAnswer event,
    Emitter<InterviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InterviewInProgress) return;

    final session = currentState.session;
    final currentIndex = currentState.currentQuestionIndex;
    final currentQuestion = session.questions[currentIndex];

    // Update session with the answer
    final updatedAnswers = Map<String, String>.from(session.answers)
      ..[currentQuestion.id] = event.answer;
    final updatedSession = session.copyWith(answers: updatedAnswers);

    emit(AnswerSubmitting(
        session: updatedSession, currentQuestionIndex: currentIndex));

    // Get AI feedback
    final result = await _submitAnswerUseCase(
      SubmitAnswerParams(
        question: currentQuestion.question,
        answer: event.answer,
        role: session.role,
      ),
    );

    result.fold(
      (failure) => emit(InterviewError(failure.message)),
      (feedback) {
        final updatedFeedbacks =
            Map<String, AnswerFeedback>.from(updatedSession.feedbacks)
              ..[currentQuestion.id] = feedback;
        final sessionWithFeedback =
            updatedSession.copyWith(feedbacks: updatedFeedbacks);
        emit(FeedbackReceived(
          session: sessionWithFeedback,
          currentQuestionIndex: currentIndex,
          feedback: feedback,
        ));
      },
    );
  }

  void _onNextQuestion(NextQuestion event, Emitter<InterviewState> emit) {
    final currentState = state;
    if (currentState is! FeedbackReceived) return;

    final session = currentState.session;
    final nextIndex = currentState.currentQuestionIndex + 1;

    if (nextIndex >= session.questions.length) {
      // Calculate final score as average of all feedback scores
      final scores = session.feedbacks.values.map((f) => f.score).toList();
      final avgScore =
          scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

      emit(InterviewCompleted(
        session.copyWith(
          finalScore: avgScore,
          completedAt: DateTime.now(),
        ),
      ));
    } else {
      emit(InterviewInProgress(
          session: session, currentQuestionIndex: nextIndex));
    }
  }

  void _onResetInterview(ResetInterview event, Emitter<InterviewState> emit) {
    emit(InterviewInitial());
  }
}
