/// Dashboard Repository Interface.
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/dashboard/domain/entities/dashboard_entities.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<SessionHistory>>> getHistory();
  Future<Either<Failure, Analytics>> getAnalytics();
}
