/// ═══════════════════════════════════════════════════════════════════════════════
/// 🃏 APP CARD - Premium Card Component
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Versatile card component with multiple variants, interactive states, and
/// premium styling. Supports glass morphism, gradients, and custom shadows.
///
/// VARIANTS:
/// - elevated: Standard card with shadow (default)
/// - outlined: Border-only card
/// - filled: Solid background card
/// - glass: Glass morphism effect
/// - gradient: Branded gradient background
///
/// USAGE:
/// ```dart
/// AppCard(
///   variant: CardVariant.elevated,
///   padding: EdgeInsets.all(AppSpacing.m),
///   child: Text('Card content'),
/// )
/// ```
///
/// WHY THIS COMPONENT?
/// - Consistent card styling across the app
/// - Built-in interactive states (tap, hover)
/// - Professional shadows and borders
/// - Accessible with semantic labels
/// - Performance-optimized with const constructors
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum CardVariant {
  elevated, // Default elevated card with shadow
  outlined, // Border-only card
  filled, // Solid background
  glass, // Glass morphism
  gradient, // Gradient background
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.width,
    this.height,
  });

  /// Card content
  final Widget child;

  /// Visual style of the card
  final CardVariant variant;

  /// Internal padding (defaults based on variant)
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Border radius (defaults to AppRadius.m)
  final BorderRadius? borderRadius;

  /// Override card background color
  final Color? color;

  /// Tap callback (makes card interactive)
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  /// Accessibility label
  final String? semanticLabel;

  /// Fixed width (optional)
  final double? width;

  /// Fixed height (optional)
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default padding based on variant
    final effectivePadding = padding ??
        EdgeInsets.all(
          variant == CardVariant.glass ? AppSpacing.l : AppSpacing.m,
        );

    // Border radius
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.m);

    // Card content
    final cardChild = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      child: child,
    );

    // Card decoration based on variant
    final decoration = _buildDecoration(isDark);

    // Interactive card (with tap)
    if (onTap != null || onLongPress != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: Container(
          margin: margin,
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: effectiveRadius,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: effectiveRadius,
              splashColor: AppColors.primary500.withOpacity(0.1),
              highlightColor: AppColors.primary500.withOpacity(0.05),
              child: cardChild,
            ),
          ),
        ),
      );
    }

    // Static card (no tap)
    return Semantics(
      label: semanticLabel,
      child: Container(
        margin: margin,
        decoration: decoration,
        child: cardChild,
      ),
    );
  }

  /// Build decoration based on variant
  BoxDecoration _buildDecoration(bool isDark) {
    final baseColor =
        color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);

    switch (variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.m),
          boxShadow: AppShadows.m,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.m),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.m),
        );

      case CardVariant.glass:
        return BoxDecoration(
          gradient: isDark ? AppColors.glassGradient : null,
          color: isDark ? null : Colors.white.withOpacity(0.7),
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.m),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
            width: 1,
          ),
          boxShadow: AppShadows.glass,
        );

      case CardVariant.gradient:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.m),
          boxShadow: AppShadows.brandPrimary,
        );
    }
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SPECIALIZED CARD COMPONENTS
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Interactive stat card with icon, label, and value
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendValue,
    this.onTap,
    this.variant = CardVariant.elevated,
  });

  final String label;
  final String value;
  final IconData? icon;
  final TrendDirection? trend;
  final String? trendValue;
  final VoidCallback? onTap;
  final CardVariant variant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: variant,
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon & Label Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 20,
                  color: AppColors.neutral400,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.s),

          // Value
          Text(
            value,
            style: AppTypography.headlineL.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // Trend indicator (optional)
          if (trend != null && trendValue != null) ...[
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  trend == TrendDirection.up
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: trend == TrendDirection.up
                      ? AppColors.success500
                      : AppColors.error500,
                ),
                SizedBox(width: AppSpacing.xs.toDouble()),
                Text(
                  trendValue!,
                  style: AppTypography.labelS.copyWith(
                    color: trend == TrendDirection.up
                        ? AppColors.success500
                        : AppColors.error500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum TrendDirection { up, down }

/// Card with header section and body
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.variant = CardVariant.elevated,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final CardVariant variant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: variant,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleM.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.xs.toDouble()),
                        Text(
                          subtitle!,
                          style: AppTypography.bodyS.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(AppSpacing.l),
            child: child,
          ),
        ],
      ),
    );
  }
}
