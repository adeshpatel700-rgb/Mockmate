/// Role Selection Screen — where users configure their interview session.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/widgets/app_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = AppConstants.jobRoles.first;
  String _selectedDifficulty = AppConstants.difficultyLevels[1]; // Intermediate default
  int _questionCount = 5;

  void _startInterview() {
    context.push(
      AppRoutes.interview,
      extra: {
        'role': _selectedRole,
        'difficulty': _selectedDifficulty,
        'questionCount': _questionCount,
      },
    );
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Your Role', style: theme.textTheme.titleLarge),
              const Gap(8),
              Text(
                'AI will generate questions tailored to your role.',
                style: theme.textTheme.bodyMedium,
              ),
              const Gap(20),

              // ── Role Grid ─────────────────────────────────────────────────
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.jobRoles.map((role) {
                  final isSelected = role == _selectedRole;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        role,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : null,
                          fontWeight:
                              isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Gap(32),

              // ── Difficulty ────────────────────────────────────────────────
              Text('Difficulty', style: theme.textTheme.titleMedium),
              const Gap(12),
              Row(
                children: AppConstants.difficultyLevels.map((level) {
                  final isSelected = level == _selectedDifficulty;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDifficulty = level),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          level,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Gap(32),

              // ── Question Count ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of Questions', style: theme.textTheme.titleMedium),
                  Text(
                    '$_questionCount questions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
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
                      onTap: () => setState(() => _questionCount = count),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.secondary.withOpacity(0.2)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Gap(40),

              // ── Summary Card ─────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session Summary', style: theme.textTheme.titleMedium),
                    const Gap(12),
                    _SummaryRow(label: 'Role', value: _selectedRole),
                    _SummaryRow(label: 'Difficulty', value: _selectedDifficulty),
                    _SummaryRow(
                      label: 'Questions',
                      value: '$_questionCount questions',
                    ),
                  ],
                ),
              ),

              const Gap(24),

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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
