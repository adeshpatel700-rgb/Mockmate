/// Logout Use Case.
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
