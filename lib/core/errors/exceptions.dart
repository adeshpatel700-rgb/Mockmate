/// Exception-to-Failure mapper for the data layer.
///
/// WHY EXCEPTIONS HERE?
/// The data layer (API calls, storage) throws exceptions because that's
/// how Dart/packages work. We catch them and convert to our custom Failures
/// in repositories — so the domain and presentation layer never see raw exceptions.
library;

/// Base exception class for the data layer.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

/// Thrown when the server returns an HTTP error.
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// Thrown when there's no internet connection.
class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection.'});
}

/// Thrown when a request times out.
class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timed out.'});
}

/// Thrown when token is missing or invalid.
class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized. Please log in again.', super.statusCode = 401});
}

/// Thrown when Groq API fails.
class AIException extends AppException {
  const AIException({required super.message, super.statusCode});
}

/// Thrown when reading/writing local cache fails.
class CacheException extends AppException {
  const CacheException({super.message = 'Cache operation failed.'});
}
