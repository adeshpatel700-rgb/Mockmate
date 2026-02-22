/// Dashboard Bloc.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mockmate/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:mockmate/features/dashboard/domain/usecases/get_history_usecase.dart';

// ── Events ─────────────────────────────────────────────────────────────────

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}
class RefreshDashboard extends DashboardEvent {}

// ── States ─────────────────────────────────────────────────────────────────

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<SessionHistory> history;
  final Analytics analytics;

  const DashboardLoaded({required this.history, required this.analytics});

  @override
  List<Object> get props => [history, analytics];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

// ── Bloc ───────────────────────────────────────────────────────────────────

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetHistoryUseCase _getHistoryUseCase;
  final GetAnalyticsUseCase _getAnalyticsUseCase;

  DashboardBloc({
    required GetHistoryUseCase getHistoryUseCase,
    required GetAnalyticsUseCase getAnalyticsUseCase,
  })  : _getHistoryUseCase = getHistoryUseCase,
        _getAnalyticsUseCase = getAnalyticsUseCase,
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<RefreshDashboard>(_onLoad);
  }

  Future<void> _onLoad(DashboardEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    // Run both requests in parallel for better performance.
    final results = await Future.wait([
      _getHistoryUseCase(),
      _getAnalyticsUseCase(),
    ]);

    final historyResult = results[0] as dynamic;
    final analyticsResult = results[1] as dynamic;

    if (historyResult.isLeft() || analyticsResult.isLeft()) {
      emit(const DashboardError('Failed to load dashboard. Check your connection.'));
      return;
    }

    emit(DashboardLoaded(
      history: historyResult.getOrElse(() => []) as List<SessionHistory>,
      analytics: analyticsResult.getOrElse(() => null) as Analytics,
    ));
  }
}
