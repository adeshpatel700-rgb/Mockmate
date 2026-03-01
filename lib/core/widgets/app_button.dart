/// ═══════════════════════════════════════════════════════════════════════════════
/// 🔘 APP BUTTON - Premium Button Component System
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Comprehensive button component with multiple variants, sizes, states, and
/// premium interactions. Replaces all standard Material buttons for consistency.
///
/// VARIANTS:
/// - primary: Solid primary color (default)
/// - secondary: Solid secondary color
/// - outlined: Border-only with transparent background
/// - ghost: Text-only subtle button
/// - gradient: Premium gradient background
/// - danger: Red for destructive actions
///
/// SIZES:
/// - small: Compact (40px height)
/// - medium: Standard (48px height)
/// - large: Prominent (56px height)
///
/// FEATURES:
/// - Loading states with spinner
/// - Icon support (leading/trailing/icon-only)
/// - Press animations (scale effect)
/// - Full-width or auto-sized
/// - Disabled state styling
/// - Accessibility labels
///
/// USAGE:
/// ```dart
/// AppButton(
///   label: 'Continue',
///   onPressed: () {},
///   variant: ButtonVariant.primary,
///   size: ButtonSize.large,
///   icon: Icons.arrow_forward,
///   iconPosition: IconPosition.trailing,
/// )
/// ```
///
/// WHY CUSTOM BUTTON?
/// - Single source of truth for all buttons
/// - Consistent interactions across the app
/// - Easy to modify globally (one change updates all)
/// - Built-in loading states
/// - Premium animations and styling
/// - Reduces code duplication
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  gradient,
  danger,
}

enum ButtonSize {
  small, // 40px
  medium, // 48px
  large, // 56px
}

enum IconPosition {
  leading,
  trailing,
  iconOnly,
}

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
  });

  /// Icon-only button constructor
  const AppButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.semanticLabel,
  })  : label = '',
        iconPosition = IconPosition.iconOnly,
        isFullWidth = false;

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isFullWidth;
  final String? semanticLabel;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null && !widget.isLoading;
    final isIconOnly = widget.iconPosition == IconPosition.iconOnly;

    // Size dimensions
    final dimensions = _getSizeDimensions();

    // Button styles
    final colors = _getColors(isDark, isDisabled);

    // Button content
    final buttonContent = _buildButtonContent(colors, dimensions);

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      button: true,
      enabled: !isDisabled,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: dimensions['height'],
            width: isIconOnly
                ? dimensions['height']
                : (widget.isFullWidth ? double.infinity : null),
            decoration: _buildDecoration(colors),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(dimensions['radius']!),
                splashColor: colors['foreground']!.withOpacity(0.1),
                highlightColor: colors['foreground']!.withOpacity(0.05),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isIconOnly ? 0 : dimensions['paddingH']!,
                  ),
                  child: buttonContent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build button content (icon, label, loading)
  Widget _buildButtonContent(
    Map<String, Color> colors,
    Map<String, double> dimensions,
  ) {
    // Loading state
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: dimensions['iconSize'],
          height: dimensions['iconSize'],
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(colors['foreground']!),
          ),
        ),
      );
    }

    // Icon-only button
    if (widget.iconPosition == IconPosition.iconOnly && widget.icon != null) {
      return Center(
        child: Icon(
          widget.icon,
          size: dimensions['iconSize'],
          color: colors['foreground'],
        ),
      );
    }

    // Icon + label button
    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null &&
            widget.iconPosition == IconPosition.leading) ...[
          Icon(
            widget.icon,
            size: dimensions['iconSize'],
            color: colors['foreground'],
          ),
          SizedBox(width: AppSpacing.xs.toDouble()),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: dimensions['fontSize'],
            fontWeight: FontWeight.w600,
            color: colors['foreground'],
            letterSpacing: 0.2,
            height: 1.2,
          ),
        ),
        if (widget.icon != null &&
            widget.iconPosition == IconPosition.trailing) ...[
          SizedBox(width: AppSpacing.xs.toDouble()),
          Icon(
            widget.icon,
            size: dimensions['iconSize'],
            color: colors['foreground'],
          ),
        ],
      ],
    );
  }

  /// Build decoration based on variant
  BoxDecoration _buildDecoration(Map<String, Color> colors) {
    final dimensions = _getSizeDimensions();

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return BoxDecoration(
          color: colors['background'],
          borderRadius: BorderRadius.circular(dimensions['radius']!),
          boxShadow: widget.onPressed != null && !widget.isLoading
              ? [
                  BoxShadow(
                    color: colors['background']!.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case ButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(dimensions['radius']!),
          border: Border.all(
            color: colors['foreground']!.withOpacity(0.5),
            width: 2,
          ),
        );

      case ButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(dimensions['radius']!),
        );

      case ButtonVariant.gradient:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(dimensions['radius']!),
          boxShadow: widget.onPressed != null && !widget.isLoading
              ? AppShadows.brandPrimary
              : null,
        );
    }
  }

  /// Get colors based on variant and state
  Map<String, Color> _getColors(bool isDark, bool isDisabled) {
    if (isDisabled) {
      return {
        'background': isDark ? AppColors.neutral800 : AppColors.neutral200,
        'foreground': isDark ? AppColors.neutral600 : AppColors.neutral400,
      };
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return {
          'background': AppColors.primary500,
          'foreground': Colors.white,
        };

      case ButtonVariant.secondary:
        return {
          'background': AppColors.secondary500,
          'foreground': Colors.white,
        };

      case ButtonVariant.outlined:
        return {
          'background': Colors.transparent,
          'foreground': AppColors.primary500,
        };

      case ButtonVariant.ghost:
        return {
          'background': Colors.transparent,
          'foreground': isDark ? AppColors.neutral50 : AppColors.neutral900,
        };

      case ButtonVariant.gradient:
        return {
          'background': Colors.transparent,
          'foreground': Colors.white,
        };

      case ButtonVariant.danger:
        return {
          'background': AppColors.error500,
          'foreground': Colors.white,
        };
    }
  }

  /// Get dimensions based on size
  Map<String, double> _getSizeDimensions() {
    switch (widget.size) {
      case ButtonSize.small:
        return {
          'height': 40.0,
          'paddingH': AppSpacing.m.toDouble(),
          'fontSize': 14.0,
          'iconSize': 18.0,
          'radius': AppRadius.s.toDouble(),
        };

      case ButtonSize.medium:
        return {
          'height': 48.0,
          'paddingH': AppSpacing.l.toDouble(),
          'fontSize': 15.0,
          'iconSize': 20.0,
          'radius': AppRadius.s.toDouble(),
        };

      case ButtonSize.large:
        return {
          'height': 56.0,
          'paddingH': AppSpacing.xl.toDouble(),
          'fontSize': 16.0,
          'iconSize': 22.0,
          'radius': AppRadius.m.toDouble(),
        };
    }
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// LEGACY BUTTON ALIASES (for backward compatibility)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Primary button (legacy compatibility)
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: ButtonSize.large,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
    );
  }
}

/// Outlined button (legacy compatibility)
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      size: ButtonSize.medium,
      isFullWidth: isFullWidth,
      icon: icon,
    );
  }
}
