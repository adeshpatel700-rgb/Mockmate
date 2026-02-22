/// Failure classes — our custom error types for clean error handling.
///
/// WHY CUSTOM FAILURES INSTEAD OF EXCEPTIONS?
/// Exceptions crash your app if not caught. With Failures, we treat errors
/// as values (data), not surprises. The UI can always handle them gracefully.
///
/// This is inspired by the "Either" pattern in functional programming:
///   - Left  = Failure (something went wrong)
///   - Right = Success (here's your data)
library;

import 'package:equatable/equatable.dart';

/// Base class for all failures in the app.
/// Every error is a type of [Failure], which makes handling predictable.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// ── Network Failures ───────────────────────────────────────────────────────

/// Thrown when there's no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network.'});
}

/// Thrown when the server returns an error (4xx, 5xx status codes).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Thrown when the server takes too long to respond.
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out. Please try again.'});
}

// ── Auth Failures ──────────────────────────────────────────────────────────

/// Thrown when login credentials are wrong.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Thrown when the user's session has expired.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Session expired. Please log in again.'});
}

// ── Validation Failures ────────────────────────────────────────────────────

/// Thrown when user input doesn't pass validation.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

// ── Cache Failures ─────────────────────────────────────────────────────────

/// Thrown when reading/writing local storage fails.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to read local data.'});
}

// ── AI Failures ────────────────────────────────────────────────────────────

/// Thrown when the Groq AI API fails or returns unexpected data.
class AIFailure extends Failure {
  const AIFailure({required super.message, super.statusCode});
}
