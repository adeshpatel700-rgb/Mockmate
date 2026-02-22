/// Interview Repository Implementation.
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/exceptions.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/interview/data/datasources/interview_remote_datasource.dart';
import 'package:mockmate/features/interview/domain/entities/interview_entities.dart';
import 'package:mockmate/features/interview/domain/repositories/interview_repository.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final InterviewRemoteDataSource _remoteDataSource;
  const InterviewRepositoryImpl({required InterviewRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Question>>> generateQuestions({
    required String role,
    required String difficulty,
    required int count,
  }) async {
    try {
      final models = await _remoteDataSource.generateQuestions(
        role: role,
        difficulty: difficulty,
        count: count,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(AIFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnswerFeedback>> submitAnswer({
    required String question,
    required String answer,
    required String role,
  }) async {
    try {
      final model = await _remoteDataSource.submitAnswer(
        question: question,
        answer: answer,
        role: role,
      );
      return Right(model.toEntity());
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(AIFailure(message: e.toString()));
    }
  }
}
