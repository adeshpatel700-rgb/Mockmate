/// Dependency Injection setup using GetIt.
///
/// WHY DEPENDENCY INJECTION (DI)?
/// When class A needs class B to work, instead of A creating B itself
/// (tight coupling), we register B in a central container (GetIt) and
/// inject it wherever needed. This makes testing easy — you can inject
/// mock versions of dependencies in tests.
///
/// HOW IT WORKS:
/// 1. Register all classes (singletons or factories) in [setupDI]
/// 2. Any widget/bloc that needs a class calls [sl<YourClass>()]
/// 3. GetIt returns the registered instance
///
/// SINGLETON vs FACTORY:
/// - Singleton: One instance for the whole app lifetime (Dio, Storage)
/// - Factory: New instance each time it's requested (Blocs)
library;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockmate/core/network/dio_client.dart';
import 'package:mockmate/core/network/connectivity_service.dart';

// Auth feature
import 'package:mockmate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mockmate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mockmate/features/auth/domain/repositories/auth_repository.dart';
import 'package:mockmate/features/auth/domain/usecases/login_usecase.dart';
import 'package:mockmate/features/auth/domain/usecases/register_usecase.dart';
import 'package:mockmate/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mockmate/features/auth/presentation/bloc/auth_bloc.dart';

// Interview feature
import 'package:mockmate/features/interview/data/datasources/interview_remote_datasource.dart';
import 'package:mockmate/features/interview/data/datasources/groq_datasource.dart';
import 'package:mockmate/features/interview/data/repositories/interview_repository_impl.dart';
import 'package:mockmate/features/interview/domain/repositories/interview_repository.dart';
import 'package:mockmate/features/interview/domain/usecases/generate_questions_usecase.dart';
import 'package:mockmate/features/interview/domain/usecases/submit_answer_usecase.dart';
import 'package:mockmate/features/interview/presentation/bloc/interview_bloc.dart';

// Dashboard feature
import 'package:mockmate/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mockmate/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mockmate/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mockmate/features/dashboard/domain/usecases/get_history_usecase.dart';
import 'package:mockmate/features/dashboard/domain/usecases/get_analytics_usecase.dart';
import 'package:mockmate/features/dashboard/presentation/bloc/dashboard_bloc.dart';

/// The global service locator — the single instance of GetIt.
/// Access it from anywhere as `sl<YourClass>()`.
final GetIt sl = GetIt.instance;

/// Sets up all dependencies. Called once in [main.dart] before [runApp].
Future<void> setupDependencies() async {
  // ── External / Platform dependencies ─────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  sl.registerSingleton<Logger>(
    Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    ),
  );

  // ── Network ───────────────────────────────────────────────────────────────
  // Two separate Dio instances: one for backend API, one for Groq.
  sl.registerSingleton<Dio>(
    DioFactory.createApiDio(
      secureStorage: sl(),
      logger: sl(),
    ),
    instanceName: 'apiDio',
  );

  sl.registerSingleton<Dio>(
    DioFactory.createGroqDio(logger: sl()),
    instanceName: 'groqDio',
  );

  // Connectivity service for offline detection
  sl.registerLazySingleton(() => ConnectivityService());

  // ── Auth Feature ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl(instanceName: 'apiDio')),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // AuthBloc is a factory — each screen gets a fresh instance.
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ── Interview Feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton<GroqDataSource>(
    () => GroqDataSourceImpl(dio: sl(instanceName: 'groqDio')),
  );
  sl.registerLazySingleton<InterviewRemoteDataSource>(
    () => InterviewRemoteDataSourceImpl(
      dio: sl(instanceName: 'apiDio'),
      groqDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GenerateQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAnswerUseCase(sl()));

  sl.registerFactory(
    () => InterviewBloc(
      generateQuestionsUseCase: sl(),
      submitAnswerUseCase: sl(),
    ),
  );

  // ── Dashboard Feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl(instanceName: 'apiDio')),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetAnalyticsUseCase(sl()));

  sl.registerFactory(
    () => DashboardBloc(
      getHistoryUseCase: sl(),
      getAnalyticsUseCase: sl(),
    ),
  );
}
