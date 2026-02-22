/// Interview data models — JSON-serializable versions of domain entities.
library;

import 'package:mockmate/features/interview/domain/entities/interview_entities.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.question,
    required super.type,
    required super.expectedDuration,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: (json['id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      type: (json['type'] ?? 'conceptual').toString(),
      expectedDuration: (json['expectedDuration'] as num?)?.toInt() ?? 3,
    );
  }

  Question toEntity() => Question(
    id: id,
    question: question,
    type: type,
    expectedDuration: expectedDuration,
  );
}

class AnswerFeedbackModel extends AnswerFeedback {
  const AnswerFeedbackModel({
    required super.score,
    required super.strengths,
    required super.improvements,
    required super.idealAnswer,
    required super.overallFeedback,
  });

  factory AnswerFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AnswerFeedbackModel(
      score: (json['score'] as num?)?.toInt() ?? 0,
      strengths: (json['strengths'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      improvements: (json['improvements'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      idealAnswer: (json['idealAnswer'] ?? '').toString(),
      overallFeedback: (json['overallFeedback'] ?? '').toString(),
    );
  }

  AnswerFeedback toEntity() => AnswerFeedback(
    score: score,
    strengths: strengths,
    improvements: improvements,
    idealAnswer: idealAnswer,
    overallFeedback: overallFeedback,
  );
}
