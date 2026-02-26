/// Generate Questions Use Case — requests interview questions from AI.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/interview/domain/entities/interview_entities.dart';
import 'package:mockmate/features/interview/domain/repositories/interview_repository.dart';

// ── Generate Questions ─────────────────────────────────────────────────────

class GenerateQuestionsParams extends Equatable {
  final String role;
  final String difficulty;
  final int count;

  const GenerateQuestionsParams({
    required this.role,
    required this.difficulty,
    required this.count,
  });

  @override
  List<Object> get props => [role, difficulty, count];
}

class GenerateQuestionsUseCase {
  final InterviewRepository _repository;
  const GenerateQuestionsUseCase(this._repository);

  Future<Either<Failure, List<Question>>> call(GenerateQuestionsParams params) {
    return _repository.generateQuestions(
      role: params.role,
      difficulty: params.difficulty,
      count: params.count,
    );
  }
}
