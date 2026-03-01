/// ═══════════════════════════════════════════════════════════════════════════════
/// 📂 APP EMPTY STATE - Premium Empty State Component
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Beautiful empty state screens with illustrations, messaging, and CTAs.
/// Replaces cold "No data" messages with warm, action-oriented states.
///
/// STATES:
/// - No sessions yet
/// - No results found
/// - Network error
/// - Generic empty with custom message
///
/// USAGE:
/// ```dart
/// AppEmptyState(
///   icon: Icons.inbox_rounded,
///   title: 'No sessions yet',
///   message: EmptyStateMessages.noSessionsCTA,
///   actionLabel: 'Start Your First Mock',
///   onAction: () => context.push('/interview/new'),
/// )
/// ```
///
/// WHY EMPTY STATES?
/// - Reduces user confusion (explains what's happening)
/// - Provides actionable next steps
/// - Maintains brand personality (warm, encouraging)
/// - Better UX than generic "No data" messages
/// - Reduces bounce rate from empty screens
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../constants/copy_guidelines.dart';
import '../theme/design_tokens.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  /// Predefined empty state: No sessions yet
  const AppEmptyState.noSessions({
    super.key,
    required VoidCallback this.onAction,
  })  : icon = Icons.calendar_today_rounded,
        title = EmptyStateMessages.noSessions,
        message = EmptyStateMessages.noSessionsCTA,
        actionLabel = 'Start Practice Session',
        secondaryActionLabel = null,
        onSecondaryAction = null;

  /// Predefined empty state: Search no results
  const AppEmptyState.noResults({
    super.key,
    String? searchQuery,
  })  : icon = Icons.search_off_rounded,
        title = 'No results found',
        message = searchQuery != null
            ? 'We couldn\'t find anything matching "$searchQuery". Try different keywords.'
            : 'We couldn\'t find anything. Try adjusting your search.',
        actionLabel = null,
        onAction = null,
        secondaryActionLabel = null,
        onSecondaryAction = null;

  /// Predefined empty state: Network error
  const AppEmptyState.networkError({
    super.key,
    required VoidCallback this.onAction,
  })  : icon = Icons.wifi_off_rounded,
        title = 'Connection lost',
        message = ErrorMessages.networkError,
        actionLabel = 'Retry',
        secondaryActionLabel = null,
        onSecondaryAction = null;

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl.toDouble()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          colors: [
                            AppColors.primary500.withOpacity(0.2),
                            AppColors.secondary500.withOpacity(0.1),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.primary100,
                            AppColors.secondary100,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary500,
                ),
              ),

              SizedBox(height: AppSpacing.xxl.toDouble()),

              // Title
              Text(
                title,
                style: AppTypography.titleL.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.m.toDouble()),

              // Message
              Text(
                message,
                style: AppTypography.bodyL.copyWith(
                  color: AppColors.neutral400,
                ),
                textAlign: TextAlign.center,
              ),

              // Action buttons
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: AppSpacing.x3l.toDouble()),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  isFullWidth: true,
                ),
              ],

              if (secondaryActionLabel != null &&
                  onSecondaryAction != null) ...[
                SizedBox(height: AppSpacing.m.toDouble()),
                AppButton(
                  label: secondaryActionLabel!,
                  onPressed: onSecondaryAction,
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.medium,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// LOADING EMPTY STATE - Shows while content is loading
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.l.toDouble()),
            Text(
              message!,
              style: AppTypography.bodyL.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ERROR STATE - Shows when something goes wrong
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}
