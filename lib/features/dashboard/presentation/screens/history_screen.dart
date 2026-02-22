/// History Screen — all past interview sessions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/di/injection_container.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
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
              onRetry: () => context.read<DashboardBloc>().add(RefreshDashboard()),
            );
          }
          if (state is DashboardLoaded) {
            final history = state.history;
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_toggle_off, size: 64, color: theme.colorScheme.outline),
                    const Gap(16),
                    Text('No sessions yet!', style: theme.textTheme.titleMedium),
                    const Gap(8),
                    Text('Start an interview to see results here.', style: theme.textTheme.bodyMedium),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[index];
                final score = session.score;
                final scoreColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scoreColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${score.toInt()}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scoreColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.role, style: theme.textTheme.titleMedium),
                            Text(
                              '${session.difficulty} • ${session.questionCount} Qs',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _ago(session.completedAt),
                        style: theme.textTheme.bodySmall,
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
