/// Interview domain entities — the core concepts of an interview session.
library;

import 'package:equatable/equatable.dart';

/// A single interview question.
class Question extends Equatable {
  final String id;
  final String question;
  final String type; // 'conceptual', 'practical', 'scenario'
  final int expectedDuration; // minutes

  const Question({
    required this.id,
    required this.question,
    required this.type,
    required this.expectedDuration,
  });

  @override
  List<Object> get props => [id, question, type, expectedDuration];
}

/// AI feedback for a single answer.
class AnswerFeedback extends Equatable {
  final int score;
  final List<String> strengths;
  final List<String> improvements;
  final String idealAnswer;
  final String overallFeedback;

  const AnswerFeedback({
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.idealAnswer,
    required this.overallFeedback,
  });

  @override
  List<Object> get props => [score, strengths, improvements, idealAnswer, overallFeedback];
}

/// A complete interview session containing questions, answers, and feedback.
class InterviewSession extends Equatable {
  final String id;
  final String role;
  final String difficulty;
  final List<Question> questions;
  final Map<String, String> answers;         // questionId → answer text
  final Map<String, AnswerFeedback> feedbacks; // questionId → feedback
  final double finalScore;
  final DateTime startedAt;
  final DateTime? completedAt;

  const InterviewSession({
    required this.id,
    required this.role,
    required this.difficulty,
    required this.questions,
    this.answers = const {},
    this.feedbacks = const {},
    this.finalScore = 0.0,
    required this.startedAt,
    this.completedAt,
  });

  /// Creates a copy with updated fields — common pattern for immutable state updates.
  InterviewSession copyWith({
    Map<String, String>? answers,
    Map<String, AnswerFeedback>? feedbacks,
    double? finalScore,
    DateTime? completedAt,
  }) {
    return InterviewSession(
      id: id,
      role: role,
      difficulty: difficulty,
      questions: questions,
      answers: answers ?? this.answers,
      feedbacks: feedbacks ?? this.feedbacks,
      finalScore: finalScore ?? this.finalScore,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [id, role, difficulty, questions, answers, feedbacks, finalScore];
}
