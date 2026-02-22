/// Auth Repository Implementation — bridges domain and data layers.
///
/// WHY DOES REPOSITORY CATCH EXCEPTIONS AND RETURN FAILURES?
/// Data sources throw Exceptions (raw errors).
/// The domain/presentation layer expects Failures (handled errors).
/// The repository converts between them — this is the only place where
/// this translation happens, keeping both layers clean.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/errors/exceptions.dart';
import 'package:mockmate/core/errors/failures.dart';
import 'package:mockmate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mockmate/features/auth/domain/entities/user.dart';
import 'package:mockmate/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required FlutterSecureStorage secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(email: email, password: password);

      // Store tokens securely after successful login
      await Future.wait([
        _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: response.accessToken,
        ),
        _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.refreshToken,
        ),
      ]);

      return Right(response.user.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      await Future.wait([
        _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: response.accessToken,
        ),
        _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.refreshToken,
        ),
      ]);

      return Right(response.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Even if the API call fails, we still clear local tokens.
      // The user experience should always be: tap logout → logged out.
    }
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
      _secureStorage.delete(key: AppConstants.userIdKey),
    ]);
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }
}
