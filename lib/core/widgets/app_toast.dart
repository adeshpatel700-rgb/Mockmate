/// ═══════════════════════════════════════════════════════════════════════════════
/// 🍞 APP TOAST - Premium Notification System
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Elegant toast notifications with semantic colors, icons, and actions.
/// Replaces basic SnackBars with premium, accessible notifications.
///
/// TYPES:
/// - Success: Green with check icon
/// - Error: Red with error icon
/// - Warning: Amber with warning icon
/// - Info: Blue with info icon
/// - Loading: Progress indicator
///
/// USAGE:
/// ```dart
/// AppToast.success(
///   context,
///   message: 'Session saved successfully',
/// );
///
/// AppToast.error(
///   context,
///   message: 'Failed to load data',
///   action: ToastAction(label: 'Retry', onPressed: _retry),
/// );
/// ```
///
/// WHY CUSTOM TOAST?
/// - Consistent notification styling
/// - Semantic color coding (success, error, etc.)
/// - Built-in icons for quick comprehension
/// - Action button support
/// - Dismissible with swipe
/// - Accessible with screen reader support
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
  loading,
}

class ToastAction {
  const ToastAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

class AppToast {
  static void success(
    BuildContext context, {
    required String message,
    ToastAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      type: ToastType.success,
      message: message,
      action: action,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    ToastAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      type: ToastType.error,
      message: message,
      action: action,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    ToastAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      type: ToastType.warning,
      message: message,
      action: action,
      duration: duration,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    ToastAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      type: ToastType.info,
      message: message,
      action: action,
      duration: duration,
    );
  }

  static void loading(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      type: ToastType.loading,
      message: message,
      duration: const Duration(days: 1), // Effectively infinite
    );
  }

  static void _show(
    BuildContext context, {
    required ToastType type,
    required String message,
    ToastAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _getColors(type, isDark);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Icon
            if (type == ToastType.loading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors['icon']!),
                ),
              ),
            ] else ...[
              Icon(
                _getIcon(type),
                color: colors['icon'],
                size: 20,
              ),
            ],

            SizedBox(width: AppSpacing.m.toDouble()),

            // Message
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyM.copyWith(
                  color: colors['text'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors['background'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          side: BorderSide(
            color: colors['border']!,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(AppSpacing.m.toDouble()),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.l.toDouble(),
          vertical: AppSpacing.m.toDouble() + 2,
        ),
        duration: duration,
        action: action != null
            ? SnackBarAction(
                label: action.label,
                onPressed: action.onPressed,
                textColor: colors['action'],
              )
            : null,
      ),
    );
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.loading:
        return Icons.hourglass_empty_rounded; // Fallback, not used
    }
  }

  static Map<String, Color> _getColors(ToastType type, bool isDark) {
    switch (type) {
      case ToastType.success:
        return {
          'background': isDark
              ? AppColors.success700.withOpacity(0.2)
              : AppColors.success50,
          'text': isDark ? AppColors.neutral50 : AppColors.success700,
          'icon': AppColors.success500,
          'border': AppColors.success500.withOpacity(0.3),
          'action': AppColors.success500,
        };

      case ToastType.error:
        return {
          'background':
              isDark ? AppColors.error700.withOpacity(0.2) : AppColors.error50,
          'text': isDark ? AppColors.neutral50 : AppColors.error700,
          'icon': AppColors.error500,
          'border': AppColors.error500.withOpacity(0.3),
          'action': AppColors.error500,
        };

      case ToastType.warning:
        return {
          'background': isDark
              ? AppColors.warning700.withOpacity(0.2)
              : AppColors.warning50,
          'text': isDark ? AppColors.neutral50 : AppColors.warning700,
          'icon': AppColors.warning500,
          'border': AppColors.warning500.withOpacity(0.3),
          'action': AppColors.warning700,
        };

      case ToastType.info:
        return {
          'background':
              isDark ? AppColors.info700.withOpacity(0.2) : AppColors.info50,
          'text': isDark ? AppColors.neutral50 : AppColors.info700,
          'icon': AppColors.info500,
          'border': AppColors.info500.withOpacity(0.3),
          'action': AppColors.info500,
        };

      case ToastType.loading:
        return {
          'background': isDark ? AppColors.darkCard : AppColors.lightCard,
          'text': isDark ? AppColors.neutral50 : AppColors.neutral900,
          'icon': AppColors.primary500,
          'border': isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          'action': AppColors.primary500,
        };
    }
  }

  /// Hide current toast
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SUCCESS MESSAGES - Predefined success toasts
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension AppToastSuccess on AppToast {
  static void sessionSaved(BuildContext context) {
    AppToast.success(
      context,
      message: 'Session saved successfully',
    );
  }

  static void answerSubmitted(BuildContext context) {
    AppToast.success(
      context,
      message: 'Answer submitted for evaluation',
    );
  }

  static void profileUpdated(BuildContext context) {
    AppToast.success(
      context,
      message: 'Profile updated successfully',
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ERROR MESSAGES - Predefined error toasts
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

extension AppToastError on AppToast {
  static void networkError(BuildContext context, {VoidCallback? onRetry}) {
    AppToast.error(
      context,
      message: 'Connection lost. Check your internet.',
      action: onRetry != null
          ? ToastAction(label: 'Retry', onPressed: onRetry)
          : null,
    );
  }

  static void serverError(BuildContext context) {
    AppToast.error(
      context,
      message: 'Server error. Please try again in a moment.',
    );
  }

  static void sessionLoadFailed(BuildContext context, {VoidCallback? onRetry}) {
    AppToast.error(
      context,
      message: 'Failed to load session data',
      action: onRetry != null
          ? ToastAction(label: 'Retry', onPressed: onRetry)
          : null,
    );
  }
}
