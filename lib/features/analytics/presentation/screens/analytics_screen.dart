/// ═══════════════════════════════════════════════════════════════════════════════
/// 📊 ANALYTICS SCREEN - Premium Performance Insights
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Detailed analytics dashboard with charts and performance metrics.
///
/// FEATURES:
/// - Performance trend charts (fl_chart integration)
/// - Category breakdown (pie chart, bar chart)
/// - Time-based analytics (weekly, monthly progress)
/// - Difficulty level performance
/// - Strengths & weaknesses analysis
/// - Export data option
///
/// UX PRINCIPLES:
/// - Data visualization first
/// - Interactive charts
/// - Clear insights and recommendations
/// - Comparative metrics
/// - Premium design tokens
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: AppTypography.titleM.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Data',
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Export analytics data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Period Selector ──────────────────────────────────────────
            Row(
              children: [
                _PeriodChip(
                  label: 'Week',
                  selected: _selectedPeriod == 'Week',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPeriod = 'Week');
                  },
                ),
                Gap(AppSpacing.m),
                _PeriodChip(
                  label: 'Month',
                  selected: _selectedPeriod == 'Month',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPeriod = 'Month');
                  },
                ),
                Gap(AppSpacing.m),
                _PeriodChip(
                  label: 'Year',
                  selected: _selectedPeriod == 'Year',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPeriod = 'Year');
                  },
                ),
              ],
            ),

            Gap(AppSpacing.x3l),

            // ── Performance Trend Chart ─────────────────────────────────
            AppSectionCard(
              title: 'Performance Trend',
              subtitle: 'Your scores over time',
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.m),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.neutral700,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < labels.length) {
                                return Text(
                                  labels[value.toInt()],
                                  style: AppTypography.labelXS.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 65),
                            const FlSpot(1, 72),
                            const FlSpot(2, 68),
                            const FlSpot(3, 78),
                            const FlSpot(4, 85),
                            const FlSpot(5, 82),
                            const FlSpot(6, 88),
                          ],
                          isCurved: true,
                          color: AppColors.primary500,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.primary500,
                                strokeWidth: 2,
                                strokeColor: AppColors.darkBackground,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary500.withOpacity(0.2),
                                AppColors.primary500.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Gap(AppSpacing.l),

            // ── Category Performance ────────────────────────────────────
            AppSectionCard(
              title: 'Category Performance',
              subtitle: 'Your average scores by category',
              child: Column(
                children: [
                  _CategoryBar(
                    label: 'Technical',
                    percentage: 0.85,
                    color: AppColors.primary500,
                  ),
                  Gap(AppSpacing.m),
                  _CategoryBar(
                    label: 'Behavioral',
                    percentage: 0.72,
                    color: AppColors.secondary500,
                  ),
                  Gap(AppSpacing.m),
                  _CategoryBar(
                    label: 'Problem Solving',
                    percentage: 0.68,
                    color: const Color(0xFFF59E0B),
                  ),
                  Gap(AppSpacing.m),
                  _CategoryBar(
                    label: 'System Design',
                    percentage: 0.78,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Difficulty Breakdown ────────────────────────────────────
            AppSectionCard(
              title: 'Difficulty Breakdown',
              subtitle: 'Sessions by difficulty level',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DifficultyPill(
                    label: 'Easy',
                    count: 12,
                    color: AppColors.success500,
                  ),
                  _DifficultyPill(
                    label: 'Medium',
                    count: 28,
                    color: const Color(0xFFF59E0B),
                  ),
                  _DifficultyPill(
                    label: 'Hard',
                    count: 7,
                    color: AppColors.error500,
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.l),

            // ── Insights Section ────────────────────────────────────────
            AppSectionCard(
              title: 'Key Insights',
              subtitle: 'AI-powered recommendations',
              child: Column(
                children: [
                  _InsightCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Strong Progress',
                    description:
                        'Your scores have improved 15% this week. Keep it up!',
                    color: AppColors.success500,
                  ),
                  Gap(AppSpacing.m),
                  _InsightCard(
                    icon: Icons.business_center_rounded,
                    title: 'Focus Area',
                    description:
                        'System Design needs attention. Consider more practice.',
                    color: const Color(0xFFF59E0B),
                  ),
                  Gap(AppSpacing.m),
                  _InsightCard(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Streak Bonus',
                    description:
                        '7-day streak! Practice daily to maintain momentum.',
                    color: AppColors.error500,
                  ),
                ],
              ),
            ),

            Gap(AppSpacing.x4l),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary500 : AppColors.neutral700,
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        child: Text(
          label,
          style: AppTypography.labelM.copyWith(
            color: selected ? Colors.white : AppColors.neutral300,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: AppTypography.labelM.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap(AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.neutral700,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: AppTypography.titleL.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Gap(AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelS.copyWith(
            color: AppColors.neutral300,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Gap(AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(AppSpacing.xs / 2),
                Text(
                  description,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
