/// Main Dashboard Screen — home of the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/widgets/app_loader.dart';
import 'package:mockmate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mockmate/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:mockmate/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DashboardBloc>()..add(LoadDashboard()),
        ),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                },
                child: CustomScrollView(
                  slivers: [
                    // ── App Bar ────────────────────────────────────────────
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: true,
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MockMate',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Ready to practice?',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                        ),
                      ],
                    ),

                    // ── Content ────────────────────────────────────────────
                    if (state is DashboardLoading)
                      const SliverFillRemaining(
                        child: AppLoader(message: 'Loading your dashboard...'),
                      )
                    else if (state is DashboardError)
                      SliverFillRemaining(
                        child: AppErrorWidget(
                          message: state.message,
                          onRetry: () => context.read<DashboardBloc>().add(RefreshDashboard()),
                        ),
                      )
                    else if (state is DashboardLoaded)
                      _DashboardContent(analytics: state.analytics, history: state.history)
                    else
                      const SliverFillRemaining(child: AppLoader()),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Start Interview FAB ──────────────────────────────────────────
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.roleSelection),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Interview'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

// ── Dashboard Content ─────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final Analytics analytics;
  final List<SessionHistory> history;

  const _DashboardContent({required this.analytics, required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Stats Row ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Sessions',
                  value: analytics.totalSessions.toString(),
                  icon: Icons.history_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _StatCard(
                  label: 'Avg Score',
                  value: '${analytics.averageScore.toStringAsFixed(0)}%',
                  icon: Icons.bar_chart_rounded,
                  color: Colors.orange,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _StatCard(
                  label: 'Best',
                  value: '${analytics.bestScore.toStringAsFixed(0)}%',
                  icon: Icons.emoji_events_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const Gap(28),

          // ── Weekly Progress Chart ──────────────────────────────────────
          Text('Weekly Progress', style: theme.textTheme.titleMedium),
          const Gap(16),
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) return const SizedBox();
                        return Text(days[idx], style: theme.textTheme.bodySmall);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: analytics.weeklyScores.asMap().entries.map(
                      (e) => FlSpot(e.key.toDouble(), e.value),
                    ).toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),

          const Gap(28),

          // ── Recent History Header ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Sessions', style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => context.push(AppRoutes.history),
                child: const Text('See All'),
              ),
            ],
          ),
          const Gap(8),

          // ── History List ───────────────────────────────────────────────
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const Gap(12),
                    Text(
                      'No sessions yet.\nTap + to start your first interview!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...history.take(5).map((session) => _HistoryTile(session: session)),
        ]),
      ),
    );
  }
}

// ── Stat Card Widget ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const Gap(8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── History Tile Widget ───────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final SessionHistory session;

  const _HistoryTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = session.score;
    final scoreColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.role, style: theme.textTheme.titleMedium),
                Text(
                  '${session.difficulty} • ${session.questionCount} questions',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatDate(session.completedAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${diff}d ago';
  }
}
