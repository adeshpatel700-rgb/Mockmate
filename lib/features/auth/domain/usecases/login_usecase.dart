/// Use Cases — the heart of the domain layer.
///
/// WHY USE CASES?
/// A use case = one specific thing the app can do.
/// Instead of putting all business logic in the Bloc, each action
/// has its own class: LoginUseCase, RegisterUseCase, etc.
///
/// Benefits:
/// 1. Testable in isolation
/// 2. Reusable across multiple Blocs/Features
/// 3. Single Responsibility Principle (each class does ONE thing)
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/auth/domain/entities/user.dart';
import 'package:mockmate/features/auth/domain/repositories/auth_repository.dart';

// ── Login Use Case ─────────────────────────────────────────────────────────

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  /// Call the use case like a function: [loginUseCase(params)]
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

// ── Register Use Case ──────────────────────────────────────────────────────

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}
