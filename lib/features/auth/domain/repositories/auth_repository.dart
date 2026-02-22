/// AuthRepository interface — the contract between domain and data layers.
///
/// WHY AN ABSTRACT INTERFACE?
/// The domain layer defines WHAT needs to happen (login, register, logout).
/// The data layer decides HOW it happens (HTTP, local DB, mock).
///
/// This separation means:
/// 1. Tests can use a MockAuthRepository without making real network calls.
/// 2. You can swap the backend (e.g., Firebase → FastAPI) without changing domain code.
/// 3. This is the Dependency Inversion Principle (the D in SOLID).
library;

import 'package:dartz/dartz.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/auth/domain/entities/user.dart';

/// WHY Either<Failure, T>?
/// Most functions return success OR failure. Either<L, R> makes this explicit:
/// - Left(Failure) = something went wrong
/// - Right(User)   = success, here's the data
///
/// This forces callers to handle both cases — no silent failures.
abstract class AuthRepository {
  /// Logs in with email and password.
  /// Returns [User] on success, [Failure] on error.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Creates a new account.
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Logs out and clears stored tokens.
  Future<Either<Failure, void>> logout();

  /// Gets the currently authenticated user.
  Future<Either<Failure, User>> getCurrentUser();
}
