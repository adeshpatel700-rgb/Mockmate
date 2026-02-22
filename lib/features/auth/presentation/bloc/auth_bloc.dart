/// Auth Bloc — the brain of the auth feature.
///
/// WHY BLOC INSTEAD OF setState?
///
/// Imagine a app with 50 screens. If auth state is managed with setState
/// inside a widget, every widget that cares about "is user logged in?"
/// needs its own copy of that state — this creates bugs, duplication, and
/// spaghetti code.
///
/// With Bloc:
/// 1. State lives in ONE place (AuthBloc)
/// 2. Any widget can listen with BlocBuilder
/// 3. UI and logic are completely separated
/// 4. Easy to test (just dispatch events and assert states)
///
/// ARCHITECTURE:
/// Widget → dispatches Event → Bloc processes it → emits State → Widget rebuilds
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mockmate/features/auth/domain/entities/user.dart';
import 'package:mockmate/features/auth/domain/usecases/login_usecase.dart';
import 'package:mockmate/features/auth/domain/usecases/logout_usecase.dart';

// ── Events ─────────────────────────────────────────────────────────────────

/// Events = things that happen (user actions or system events)
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class LogoutRequested extends AuthEvent {}

// ── States ─────────────────────────────────────────────────────────────────

/// States = what the UI should show at any moment
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Initial state — user hasn't done anything yet
class AuthInitial extends AuthState {}

/// Loading — waiting for API response
class AuthLoading extends AuthState {}

/// Authenticated — user is logged in, we have their data
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Unauthenticated — user is not logged in
class Unauthenticated extends AuthState {}

/// Error — something went wrong
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// ── Bloc ───────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Handles LoginRequested event.
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // ← Tell UI to show loading spinner

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    // fold = handle Left(Failure) and Right(User) in one call
    result.fold(
      (failure) => emit(AuthError(failure.message)), // ← Show error
      (user) => emit(Authenticated(user)),           // ← Show success
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(Unauthenticated());
  }
}
