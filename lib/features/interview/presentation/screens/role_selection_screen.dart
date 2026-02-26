/// Role Selection Screen — polished interview session configurator.
///
/// UX Fixes applied:
/// - Role chips show relevant emoji for faster scanning
/// - Difficulty buttons are colour-coded (green/amber/red)
/// - Roles wrap in a scrollable chip grid, not a list
/// - Question count picker uses large tappable tiles with good contrast
/// - Summary card upgraded to show estimated duration
/// - Haptic feedback on every selection
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/widgets/app_button.dart';

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
  'Easy': Color(0xFF22C55E),      // Green
  'Intermediate': Color(0xFFF59E0B), // Amber
  'Hard': Color(0xFFEF4444),      // Red
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Interview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Role ──────────────────────────────────────────
              _SectionLabel(label: 'Select Your Role'),
              Text(
                'AI tailors questions specifically to your role.',
                style: theme.textTheme.bodySmall,
              ),
              const Gap(16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.jobRoles.map((role) {
                  final isSelected = role == _selectedRole;
                  final emoji = _roleEmojis[role] ?? '💼';
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedRole = role);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.15)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.25),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            role,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : null,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Gap(28),

              // ── Section: Difficulty ────────────────────────────────────
              _SectionLabel(label: 'Difficulty'),
              const Gap(12),
              Row(
                children: AppConstants.difficultyLevels.map((level) {
                  final isSelected = level == _selectedDifficulty;
                  final levelColor = _difficultyColors[level] ??
                      theme.colorScheme.primary;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDifficulty = level);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? levelColor.withValues(alpha: 0.15)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? levelColor
                                : theme.colorScheme.outline.withValues(alpha: 0.25),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              level == 'Easy'
                                  ? '🟢'
                                  : level == 'Intermediate'
                                      ? '🟡'
                                      : '🔴',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              level,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected ? levelColor : null,
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

              const Gap(28),

              // ── Section: Question Count ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Questions'),
                  Text(
                    '~$_estimatedMinutes min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(12),
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
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.outline.withValues(alpha: 0.25),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Gap(28),

              // ── Summary Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Session Summary',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    _SummaryRow(label: 'Role', value: _selectedRole),
                    _SummaryRow(label: 'Difficulty', value: _selectedDifficulty),
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

              const Gap(20),

              AppPrimaryButton(
                label: 'Start Interview',
                icon: Icons.play_arrow_rounded,
                onPressed: _startInterview,
              ),

              const Gap(16),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
