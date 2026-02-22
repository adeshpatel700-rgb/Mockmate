/// Dashboard Repository Implementation.
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/exceptions.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mockmate/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:mockmate/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  const DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<SessionHistory>>> getHistory() async {
    try {
      final models = await _remoteDataSource.getHistory();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Analytics>> getAnalytics() async {
    try {
      final model = await _remoteDataSource.getAnalytics();
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }
}
