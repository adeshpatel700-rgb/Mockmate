/// InterviewRepository — domain contract for all interview operations.
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/interview/domain/entities/interview_entities.dart';

abstract class InterviewRepository {
  /// Generates interview questions using the Groq AI for the given role and difficulty.
  Future<Either<Failure, List<Question>>> generateQuestions({
    required String role,
    required String difficulty,
    required int count,
  });

  /// Submits an answer and returns AI feedback.
  Future<Either<Failure, AnswerFeedback>> submitAnswer({
    required String question,
    required String answer,
    required String role,
  });
}
