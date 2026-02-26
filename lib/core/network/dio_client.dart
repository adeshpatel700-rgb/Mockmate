/// Dio HTTP Client Configuration.
///
/// WHY DIO INSTEAD OF http PACKAGE?
/// Dio is a powerful HTTP client with:
/// - Interceptors (run code before/after every request — perfect for adding auth tokens)
/// - Automatic timeout handling
/// - Better error messages
/// - Request cancellation
/// - Built-in JSON decoding
///
/// WHY INTERCEPTORS?
/// Instead of manually adding "Authorization: Bearer <token>" to every API call,
/// we add an interceptor that does it automatically. DRY principle in action.
library;

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/errors/exceptions.dart';

// ── Auth Token Interceptor ─────────────────────────────────────────────────

/// Automatically attaches the JWT token to every request header.
/// If the token is expired (401), attempts to refresh it.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  bool _isRefreshing = false;

  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  })  : _secureStorage = secureStorage,
        _logger = logger;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints (login/register don't need it)
    final isAuthEndpoint = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');

    if (!isAuthEndpoint) {
      final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.d('🔑 Token attached to request: ${options.path}');
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _logger.w('⚠️ 401 Unauthorized — attempting token refresh');
      _isRefreshing = true;

      try {
        // Attempt to refresh token
        final refreshToken =
            await _secureStorage.read(key: AppConstants.refreshTokenKey);

        if (refreshToken != null) {
          // TODO: Implement actual token refresh endpoint call
          // For now, we'll just clear the token and force re-login
          _logger.i('🔄 Token refresh not implemented yet — clearing storage');
          await _secureStorage.delete(key: AppConstants.accessTokenKey);
          await _secureStorage.delete(key: AppConstants.refreshTokenKey);
        }
      } catch (e) {
        _logger.e('❌ Token refresh failed: $e');
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}

// ── Logging Interceptor ─────────────────────────────────────────────────────

/// Logs all requests and responses in development mode.
/// This is only active in debug builds.
class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('→ ${options.method} ${options.path}');
    _logger.d('  Headers: ${options.headers}');
    if (options.data != null) _logger.d('  Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('✗ Error: ${err.message} | ${err.response?.statusCode}');
    handler.next(err);
  }
}

// ── Dio Factory ──────────────────────────────────────────────────────────────

/// Creates configured Dio instances for the Backend API and Groq API.
class DioFactory {
  DioFactory._();

  /// Creates a Dio instance for the main backend API.
  static Dio createApiDio({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) {
    final baseUrl =
        dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage, logger: logger),
      LoggingInterceptor(logger),
    ]);

    return dio;
  }

  /// Creates a Dio instance specifically for the Groq AI API.
  /// Uses a separate base URL and API key header (not JWT).
  static Dio createGroqDio({required Logger logger}) {
    final baseUrl =
        dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        contentType: 'application/json',
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    dio.interceptors.add(LoggingInterceptor(logger));

    return dio;
  }
}

// ── Dio Error Handler ─────────────────────────────────────────────────────

/// Converts Dio exceptions into our custom AppExceptions.
/// Called inside every data source to normalize errors.
AppException handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();

    case DioExceptionType.connectionError:
      return const NetworkException();

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == 401) return const UnauthorizedException();

      final message = e.response?.data?['detail'] ??
          e.response?.data?['message'] ??
          'Server error occurred';
      return ServerException(
          message: message.toString(), statusCode: statusCode);

    default:
      return ServerException(message: e.message ?? 'Unexpected error occurred');
  }
}
