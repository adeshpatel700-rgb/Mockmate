/// Main Dashboard Screen — Premium Home Experience
///
/// Features:
/// - Premium stat cards with AppStatCard
/// - Design token integration throughout
/// - Content guidelines for messaging
/// - Enhanced empty states with AppEmptyState
/// - Premium card components
/// - Improved typography and spacing
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_card.dart';
import 'package:mockmate/core/widgets/app_empty_state.dart';
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
                    // ── Pinned App Bar ────────────────────────────────────
                    SliverAppBar(
                      pinned: true,
                      floating: false,
                      expandedHeight: 0,
                      elevation: 0,
                      scrolledUnderElevation: 0.5,
                      backgroundColor: AppColors.darkBackground,
                      titleSpacing: AppSpacing.x3l.toDouble(),
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 30,
                            height: 30,
                            filterQuality: FilterQuality.medium,
                          ),
                          SizedBox(width: AppSpacing.xs.toDouble()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'MockMate',
                                style: AppTypography.titleM.copyWith(
                                  color: AppColors.primary500,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Ready to practice?',
                                style: AppTypography.labelM.copyWith(
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.person_outline_rounded),
                          tooltip: 'Profile',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push(AppRoutes.profile);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: 'Settings',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push(AppRoutes.settings);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: 'Log out',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<AuthBloc>().add(LogoutRequested());
                          },
                        ),
                        SizedBox(width: AppSpacing.s.toDouble()),
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
          label: Text(
            CTALibrary.startInterview,
            style: AppTypography.labelM.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          elevation: 4.0,
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
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.toDouble(),
        AppSpacing.l.toDouble(),
        AppSpacing.xl.toDouble(),
        100,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Quick Access Navigation ─────────────────────────────────
          Text(
            'Quick Access',
            style: AppTypography.titleM.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(AppSpacing.m.toDouble()),
          Row(
            children: [
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  color: AppColors.primary500,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.analytics);
                  },
                ),
              ),
              Gap(AppSpacing.xs.toDouble()),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.book_outlined,
                  label: 'Prep',
                  color: AppColors.secondary500,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.interviewPrep);
                  },
                ),
              ),
              Gap(AppSpacing.xs.toDouble()),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.leaderboard_outlined,
                  label: 'Board',
                  color: const Color(0xFFFFD700),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.leaderboard);
                  },
                ),
              ),
              Gap(AppSpacing.xs.toDouble()),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.help_outline_rounded,
                  label: 'Help',
                  color: AppColors.info500,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.help);
                  },
                ),
              ),
            ],
          ),

          Gap(AppSpacing.xxl.toDouble() + 4),

          // ── Stats Row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Sessions',
                  value: analytics.totalSessions.toString(),
                ),
              ),
              Gap(AppSpacing.xs.toDouble()),
              Expanded(
                child: AppStatCard(
                  label: 'Avg Score',
                  value: '${analytics.averageScore.toStringAsFixed(0)}%',
                ),
              ),
              Gap(AppSpacing.xs.toDouble()),
              Expanded(
                child: AppStatCard(
                  label: 'Best',
                  value: '${analytics.bestScore.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),

          Gap(AppSpacing.xxl.toDouble() + 4),

          // ── Weekly Progress Chart ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: AppTypography.titleM.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Score (0–100)',
                style: AppTypography.labelM.copyWith(
                  color: AppColors.primary400,
                ),
              ),
            ],
          ),
          Gap(AppSpacing.m.toDouble()),
          Container(
            height: 190,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s.toDouble(),
              AppSpacing.l.toDouble(),
              AppSpacing.l.toDouble(),
              AppSpacing.s.toDouble(),
            ),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppRadius.l),
              border: Border.all(
                color: AppColors.neutral700.withOpacity(0.5),
              ),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.neutral700.withOpacity(0.3),
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
                        style: AppTypography.labelS.copyWith(
                          color: AppColors.neutral400,
                        ),
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
                        return Text(
                          days[idx],
                          style: AppTypography.labelS.copyWith(
                            color: AppColors.neutral400,
                          ),
                        );
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
                    color: AppColors.primary500,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary500,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary500.withOpacity(0.15),
                          AppColors.primary500.withOpacity(0.0),
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

          Gap(AppSpacing.xxl.toDouble() + 4),

          // ── Recent History ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sessions',
                style: AppTypography.titleM.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.history),
                child: Text(
                  'See All →',
                  style: AppTypography.labelM.copyWith(
                    color: AppColors.primary400,
                  ),
                ),
              ),
            ],
          ),
          Gap(AppSpacing.s.toDouble()),

          if (history.isEmpty)
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: AppSpacing.x4l.toDouble()),
              child: AppEmptyState.noSessions(
                onAction: () => context.push(AppRoutes.roleSelection),
              ),
            )
          else
            ...history.take(5).map((session) => _HistoryTile(session: session)),
        ]),
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
    final score = session.score;
    final scoreColor = score >= 80
        ? const Color(0xFF22C55E)
        : score >= 60
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs.toDouble()),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: AppColors.neutral700.withOpacity(0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: () => HapticFeedback.selectionClick(),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.m.toDouble()),
            child: Row(
              children: [
                // Score badge
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
                      '${score.toStringAsFixed(0)}',
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${session.difficulty} · ${session.questionCount} questions',
                        style: AppTypography.labelM.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(session.completedAt),
                      style: AppTypography.labelM.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    Gap(AppSpacing.xs.toDouble()),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.neutral600,
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

// ── Quick Access Card Widget ───────────────────────────────────────────────

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.m.toDouble(),
          horizontal: AppSpacing.xs.toDouble(),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Gap(AppSpacing.s.toDouble()),
            Text(
              label,
              style: AppTypography.labelM.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
