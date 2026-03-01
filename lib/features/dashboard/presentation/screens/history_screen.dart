/// History Screen — Premium Session History Experience
///
/// Features:
/// - Design token integration
/// - AppEmptyState for empty history
/// - Premium card styling for sessions
/// - Content guidelines integration
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_empty_state.dart';
import 'package:mockmate/core/widgets/app_loader.dart';
import 'package:mockmate/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(LoadDashboard()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session History',
          style: AppTypography.titleL,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const AppLoader(message: 'Loading history...');
          }
          if (state is DashboardError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<DashboardBloc>().add(RefreshDashboard()),
            );
          }
          if (state is DashboardLoaded) {
            final history = state.history;
            if (history.isEmpty) {
              return Center(
                child: AppEmptyState(
                  icon: Icons.history_toggle_off,
                  title: EmptyStateMessages.noHistory,
                  message: EmptyStateMessages.noHistoryCTA,
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(AppSpacing.x3l.toDouble()),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[index];
                final score = session.score;
                final scoreColor = score >= 80
                    ? const Color(0xFF22C55E)
                    : score >= 60
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFEF4444);

                return Container(
                  margin: EdgeInsets.only(bottom: AppSpacing.m.toDouble()),
                  padding: EdgeInsets.all(AppSpacing.l.toDouble()),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    border: Border.all(
                      color: AppColors.neutral700.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scoreColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.m),
                          border: Border.all(
                            color: scoreColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${score.toInt()}',
                            style: AppTypography.titleM.copyWith(
                              color: scoreColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Gap(AppSpacing.m.toDouble()),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.role,
                              style: AppTypography.titleM.copyWith(
                                color: AppColors.neutral100,
                              ),
                            ),
                            Text(
                              '${session.difficulty} • ${session.questionCount} Qs',
                              style: AppTypography.labelM.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _ago(session.completedAt),
                        style: AppTypography.labelM.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const AppLoader();
        },
      ),
    );
  }

  String _ago(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return '1d ago';
    return '${diff}d ago';
  }
}
