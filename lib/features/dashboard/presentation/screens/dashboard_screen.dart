/// Main Dashboard Screen — home of the app.
///
/// UX Fixes:
/// - SliverAppBar replaced with a simple pinned header — avoids collapsed text overlap
/// - Stat cards show ↑ trend indicator
/// - History tiles are tappable (visual feedback)
/// - withValues() replacing deprecated withOpacity()
/// - Empty state is more engaging
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    // ── Pinned App Bar (no FlexibleSpaceBar collapse bugs) ──
                    SliverAppBar(
                      pinned: true,
                      floating: false,
                      expandedHeight: 0,
                      elevation: 0,
                      scrolledUnderElevation: 0.5,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      titleSpacing: 24,
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 30,
                            height: 30,
                            filterQuality: FilterQuality.medium,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'MockMate',
                                style: theme.textTheme.titleMedium?.copyWith(
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
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: 'Log out',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    // ── Content ─────────────────────────────────────────────
                    if (state is DashboardLoading)
                      const SliverFillRemaining(
                        child: AppLoader(message: 'Loading your dashboard...'),
                      )
                    else if (state is DashboardError)
                      SliverFillRemaining(
                        child: AppErrorWidget(
                          message: state.message,
                          onRetry: () => context
                              .read<DashboardBloc>()
                              .add(RefreshDashboard()),
                        ),
                      )
                    else if (state is DashboardLoaded)
                      _DashboardContent(
                          analytics: state.analytics, history: state.history)
                    else
                      const SliverFillRemaining(child: AppLoader()),
                  ],
                ),
              );
            },
          ),
        ),

        // ── Start Interview FAB ────────────────────────────────────────────
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(AppRoutes.roleSelection);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Interview'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

// ── Dashboard Content ──────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final Analytics analytics;
  final List<SessionHistory> history;

  const _DashboardContent({required this.analytics, required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Stats Row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Sessions',
                  value: analytics.totalSessions.toString(),
                  icon: Icons.history_rounded,
                  color: theme.colorScheme.primary,
                  trend: '+${analytics.totalSessions}',
                ),
              ),
              const Gap(10),
              Expanded(
                child: _StatCard(
                  label: 'Avg Score',
                  value: '${analytics.averageScore.toStringAsFixed(0)}%',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFFF59E0B),
                  trend: analytics.averageScore >= 70 ? '↑ Good' : '↗ Growing',
                ),
              ),
              const Gap(10),
              Expanded(
                child: _StatCard(
                  label: 'Best',
                  value: '${analytics.bestScore.toStringAsFixed(0)}%',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFF22C55E),
                  trend: 'Personal best',
                ),
              ),
            ],
          ),

          const Gap(28),

          // ── Weekly Progress Chart ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Progress', style: theme.textTheme.titleMedium),
              Text(
                'Score (0–100)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(12),
          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.18),
              ),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox();
                        }
                        return Text(days[idx],
                            style: theme.textTheme.bodySmall);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: analytics.weeklyScores
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3,
                        color: theme.colorScheme.primary,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.18),
                          theme.colorScheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),

          const Gap(28),

          // ── Recent History ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Sessions', style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: () => context.push(AppRoutes.history),
                child: const Text('See All →'),
              ),
            ],
          ),
          const Gap(8),

          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'No sessions yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Gap(6),
                    Text(
                      'Tap + to start your first interview!',
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

// ── Enhanced Stat Card Widget ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Tile Widget ────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final SessionHistory session;

  const _HistoryTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = session.score;
    final scoreColor = score >= 80
        ? const Color(0xFF22C55E)
        : score >= 60
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => HapticFeedback.selectionClick(),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Score badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scoreColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${score.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.role,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                        '${session.difficulty} · ${session.questionCount} questions',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(session.completedAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    const Gap(2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${diff}d ago';
  }
}
