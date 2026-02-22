/// Dashboard Use Cases.
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:mockmate/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetHistoryUseCase {
  final DashboardRepository _repository;
  const GetHistoryUseCase(this._repository);
  Future<Either<Failure, List<SessionHistory>>> call() => _repository.getHistory();
}

class GetAnalyticsUseCase {
  final DashboardRepository _repository;
  const GetAnalyticsUseCase(this._repository);
  Future<Either<Failure, Analytics>> call() => _repository.getAnalytics();
}
