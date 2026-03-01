/// Role Selection Screen — Premium Interview Configuration Experience
///
/// Features:
/// - Premium card-based selection with design tokens
/// - Color-coded difficulty levels
/// - Emoji-enhanced role chips for visual scanning
/// - Session summary with AppCard
/// - Estimated duration calculator
/// - Content guidelines integration
/// - Haptic feedback on selections
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_card.dart';

// Emoji mapping for visual role scanning
const _roleEmojis = {
  'Flutter Developer': '📱',
  'Frontend Developer': '🎨',
  'Backend Developer': '⚙️',
  'Full Stack Developer': '🔧',
  'Machine Learning Engineer': '🤖',
  'Data Scientist': '📊',
  'DevOps Engineer': '☁️',
  'Product Manager': '📋',
  'UI/UX Designer': '✏️',
  'Android Developer': '🤖',
  'iOS Developer': '🍎',
  'QA Engineer': '🧪',
};

// Difficulty colour coding
const _difficultyColors = {
  'Easy': Color(0xFF22C55E), // Green
  'Intermediate': Color(0xFFF59E0B), // Amber
  'Hard': Color(0xFFEF4444), // Red
};

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = AppConstants.jobRoles.first;
  String _selectedDifficulty = AppConstants.difficultyLevels[1]; // Intermediate
  int _questionCount = 5;

  void _startInterview() {
    HapticFeedback.mediumImpact();
    context.push(
      AppRoutes.interview,
      extra: {
        'role': _selectedRole,
        'difficulty': _selectedDifficulty,
        'questionCount': _questionCount,
      },
    );
  }

  int get _estimatedMinutes => (_questionCount * 2.5).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Interview',
          style: AppTypography.titleL,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.x3l.toDouble(),
            vertical: AppSpacing.l.toDouble(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Role ──────────────────────────────────────────
              _SectionLabel(label: 'Select Your Role'),
              Text(
                'AI tailors questions specifically to your role.',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              Gap(AppSpacing.l.toDouble()),

              Wrap(
                spacing: AppSpacing.s.toDouble(),
                runSpacing: AppSpacing.s.toDouble(),
                children: AppConstants.jobRoles.map((role) {
                  final isSelected = role == _selectedRole;
                  final emoji = _roleEmojis[role] ?? '💼';
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedRole = role);
                    },
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      curve: AppCurves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.m.toDouble(),
                        vertical: AppSpacing.s.toDouble() + 1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary500.withOpacity(0.12)
                            : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary500
                              : AppColors.neutral700,
                          width: isSelected ? 1.8 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary500.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: AppTypography.bodyM),
                          SizedBox(width: AppSpacing.xs.toDouble()),
                          Text(
                            role,
                            style: AppTypography.bodyM.copyWith(
                              color: isSelected
                                  ? AppColors.primary400
                                  : AppColors.neutral200,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              Gap(AppSpacing.xxl.toDouble() + 4),

              // ── Section: Difficulty ────────────────────────────────────
              _SectionLabel(label: 'Difficulty'),
              Gap(AppSpacing.m.toDouble()),
              Row(
                children: AppConstants.difficultyLevels.map((level) {
                  final isSelected = level == _selectedDifficulty;
                  final levelColor =
                      _difficultyColors[level] ?? AppColors.primary500;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDifficulty = level);
                      },
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: EdgeInsets.only(
                          right: AppSpacing.s.toDouble(),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.m.toDouble() + 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? levelColor.withOpacity(0.12)
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(AppRadius.m),
                          border: Border.all(
                            color:
                                isSelected ? levelColor : AppColors.neutral700,
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: levelColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              level == 'Easy'
                                  ? '🟢'
                                  : level == 'Intermediate'
                                      ? '🟡'
                                      : '🔴',
                              style: AppTypography.titleM,
                            ),
                            SizedBox(height: AppSpacing.xs.toDouble()),
                            Text(
                              level,
                              textAlign: TextAlign.center,
                              style: AppTypography.labelM.copyWith(
                                color: isSelected
                                    ? levelColor
                                    : AppColors.neutral300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              Gap(AppSpacing.xxl.toDouble() + 4),

              // ── Section: Question Count ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Questions'),
                  Text(
                    '~$_estimatedMinutes min',
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.secondary400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Gap(AppSpacing.m.toDouble()),
              Row(
                children: AppConstants.questionCounts.map((count) {
                  final isSelected = count == _questionCount;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _questionCount = count);
                      },
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        margin: EdgeInsets.only(
                          right: AppSpacing.s.toDouble(),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.m.toDouble() + 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary500.withOpacity(0.12)
                              : AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(AppRadius.m),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary500
                                : AppColors.neutral700,
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.secondary500.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleM.copyWith(
                            color: isSelected
                                ? AppColors.secondary400
                                : AppColors.neutral300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              Gap(AppSpacing.xxl.toDouble() + 4),

              // ── Summary Card ─────────────────────────────────────────
              AppSectionCard(
                title: 'Session Summary',
                child: Column(
                  children: [
                    _SummaryRow(label: 'Role', value: _selectedRole),
                    _SummaryRow(
                      label: 'Difficulty',
                      value: _selectedDifficulty,
                    ),
                    _SummaryRow(
                      label: 'Questions',
                      value: '$_questionCount questions',
                    ),
                    _SummaryRow(
                      label: 'Est. Duration',
                      value: '~$_estimatedMinutes minutes',
                    ),
                  ],
                ),
              ),

              Gap(AppSpacing.xl.toDouble()),

              AppButton(
                label: CTALibrary.startInterview,
                icon: Icons.play_arrow_rounded,
                onPressed: _startInterview,
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                isFullWidth: true,
              ),

              Gap(AppSpacing.l.toDouble()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs.toDouble()),
      child: Text(
        label,
        style: AppTypography.titleM.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.toDouble()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}
