/// ═══════════════════════════════════════════════════════════════════════════════
/// 🏷️ APP BADGE - Status & Label Component
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Compact badge component for status indicators, labels, counts, and tags.
/// Supports semantic color variants and custom styling.
///
/// VARIANTS:
/// - primary: Brand primary color
/// - secondary: Secondary brand color
/// - success: Green for positive states
/// - warning: Amber for caution states
/// - error: Red for error/danger states
/// - info: Blue for informational states
/// - neutral: Gray for neutral states
///
/// USAGE:
/// ```dart
/// AppBadge(
///   label: 'New',
///   variant: BadgeVariant.success,
/// )
///
/// AppBadge.count(
///   count: 5,
///   variant: BadgeVariant.error,
/// )
/// ```
///
/// WHY THIS COMPONENT?
/// - Consistent badge styling across features
/// - Semantic color coding for status
/// - Built-in accessibility
/// - Compact notification counts
/// - Easy to scan visually
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum BadgeVariant {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  neutral,
}

enum BadgeSize {
  small, // Compact
  medium, // Default
  large, // Prominent
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.medium,
    this.icon,
    this.outlined = false,
  });

  /// Numeric count badge (circular)
  const AppBadge.count({
    super.key,
    required int count,
    this.variant = BadgeVariant.error,
    this.size = BadgeSize.medium,
    this.outlined = false,
  })  : label = count > 99 ? '99+' : '$count',
        icon = null;

  /// Icon-only badge
  const AppBadge.icon({
    super.key,
    required this.icon,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.medium,
    this.outlined = false,
  }) : label = '';

  /// Badge text content
  final String label;

  /// Color variant
  final BadgeVariant variant;

  /// Size variant
  final BadgeSize size;

  /// Optional leading icon
  final IconData? icon;

  /// Outlined style (border only)
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final dimensions = _getDimensions();

    // Icon-only badge
    if (label.isEmpty && icon != null) {
      return Container(
        width: dimensions['height'],
        height: dimensions['height'],
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : colors['background'],
          shape: BoxShape.circle,
          border: outlined
              ? Border.all(
                  color: colors['foreground']!,
                  width: 1.5,
                )
              : null,
        ),
        child: Icon(
          icon,
          size: dimensions['iconSize'],
          color: colors['foreground'],
        ),
      );
    }

    return Container(
      height: dimensions['height'],
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : colors['background'],
        borderRadius: BorderRadius.circular(dimensions['radius']!),
        border: outlined
            ? Border.all(
                color: colors['foreground']!,
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: dimensions['iconSize'],
              color: colors['foreground'],
            ),
            SizedBox(width: AppSpacing.xs.toDouble()),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dimensions['fontSize'],
              fontWeight: FontWeight.w600,
              color: colors['foreground'],
              height: 1.2,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Get colors based on variant and outline state
  Map<String, Color> _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color background;
    Color foreground;

    switch (variant) {
      case BadgeVariant.primary:
        background = AppColors.primary500.withOpacity(outlined ? 0 : 0.15);
        foreground = AppColors.primary500;
        break;

      case BadgeVariant.secondary:
        background = AppColors.secondary500.withOpacity(outlined ? 0 : 0.15);
        foreground = AppColors.secondary500;
        break;

      case BadgeVariant.success:
        background = AppColors.success500.withOpacity(outlined ? 0 : 0.15);
        foreground = AppColors.success500;
        break;

      case BadgeVariant.warning:
        background = AppColors.warning500.withOpacity(outlined ? 0 : 0.15);
        foreground = AppColors.warning700; // Darker for readability
        break;

      case BadgeVariant.error:
        background = AppColors.error500.withOpacity(outlined ? 0 : 0.15);
        foreground = AppColors.error500;
        break;

      case BadgeVariant.info:
        background = AppColors.info500.withOpacity(outlined ? 0 : 0.15);
        foreground = AppColors.info500;
        break;

      case BadgeVariant.neutral:
        background = isDark
            ? AppColors.neutral700.withOpacity(outlined ? 0 : 1)
            : AppColors.neutral200.withOpacity(outlined ? 0 : 1);
        foreground = isDark ? AppColors.neutral200 : AppColors.neutral700;
        break;
    }

    return {
      'background': background,
      'foreground': foreground,
    };
  }

  /// Get dimensions based on size
  Map<String, double> _getDimensions() {
    switch (size) {
      case BadgeSize.small:
        return {
          'height': 20.0,
          'paddingH': 6.0,
          'paddingV': 2.0,
          'fontSize': 11.0,
          'iconSize': 12.0,
          'radius': AppRadius.xs.toDouble(),
        };

      case BadgeSize.medium:
        return {
          'height': 24.0,
          'paddingH': 8.0,
          'paddingV': 4.0,
          'fontSize': 13.0,
          'iconSize': 14.0,
          'radius': AppRadius.xs.toDouble(),
        };

      case BadgeSize.large:
        return {
          'height': 28.0,
          'paddingH': 12.0,
          'paddingV': 6.0,
          'fontSize': 14.0,
          'iconSize': 16.0,
          'radius': AppRadius.s.toDouble(),
        };
    }
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// STATUS BADGE - Preset status badges for common use cases
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge.active({super.key})
      : label = 'Active',
        variant = BadgeVariant.success,
        icon = Icons.check_circle_rounded;

  const AppStatusBadge.pending({super.key})
      : label = 'Pending',
        variant = BadgeVariant.warning,
        icon = Icons.pending_rounded;

  const AppStatusBadge.inactive({super.key})
      : label = 'Inactive',
        variant = BadgeVariant.neutral,
        icon = Icons.pause_circle_rounded;

  const AppStatusBadge.error({super.key})
      : label = 'Error',
        variant = BadgeVariant.error,
        icon = Icons.error_rounded;

  const AppStatusBadge.new_({super.key})
      : label = 'New',
        variant = BadgeVariant.info,
        icon = Icons.auto_awesome_rounded;

  final String label;
  final BadgeVariant variant;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      variant: variant,
      icon: icon,
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// DOT BADGE - Notification dot indicator
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppDotBadge extends StatelessWidget {
  const AppDotBadge({
    super.key,
    this.size = 8.0,
    this.color = AppColors.error500,
    this.positioned = true,
  });

  final double size;
  final Color color;
  final bool positioned; // Whether to position as overlay

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
    );

    if (positioned) {
      return Positioned(
        top: 0,
        right: 0,
        child: dot,
      );
    }

    return dot;
  }
}
