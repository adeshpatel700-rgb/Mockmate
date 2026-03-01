/// ═══════════════════════════════════════════════════════════════════════════════
/// 📝 APP TEXT FIELD - Premium Input Component
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Enhanced text input field with premium styling, animations, and features.
/// Replaces standard TextFormField with consistent design system integration.
///
/// FEATURES:
/// - Prefix/suffix icons and custom widgets
/// - Password visibility toggle with animation
/// - Character counter with max length
/// - Error shake animation
/// - Helper text support
/// - Multiline support
/// - Focus state animations
/// - Copy content guidelines integration
///
/// USAGE:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   controller: emailController,
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
/// )
/// ```
///
/// WHY CUSTOM TEXT FIELD?
/// - Consistent input styling across app
/// - Built-in validation UI
/// - Reusable password toggle
/// - Error handling with animations
/// - Easy to extend with new features
/// - Integrates with design tokens
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/copy_guidelines.dart';
import '../theme/design_tokens.dart';

enum TextFieldVariant {
  standard, // Default filled background
  outlined, // Border only
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textInputAction,
    this.focusNode,
    this.variant = TextFieldVariant.standard,
    this.inputFormatters,
    this.autofillHints,
    this.showCharacterCounter = false,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextFieldVariant variant;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool showCharacterCounter;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  String? _errorText;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);

    // Error shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  void _triggerErrorShake() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build prefix widget
    Widget? prefixWidget;
    if (widget.prefix != null) {
      prefixWidget = widget.prefix;
    } else if (widget.prefixIcon != null) {
      prefixWidget = Icon(
        widget.prefixIcon,
        size: 20,
        color: _isFocused
            ? AppColors.primary500
            : (isDark ? AppColors.neutral400 : AppColors.neutral600),
      );
    }

    // Build suffix widget
    Widget? suffixWidget;
    if (widget.isPassword) {
      suffixWidget = IconButton(
        icon: AnimatedSwitcher(
          duration: AppDurations.fast,
          child: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            key: ValueKey(_obscureText),
            size: 20,
          ),
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    } else if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    } else if (widget.suffixIcon != null) {
      suffixWidget = Icon(
        widget.suffixIcon,
        size: 20,
        color: isDark ? AppColors.neutral400 : AppColors.neutral600,
      );
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(_shakeAnimation.value * (_errorText != null ? 1 : 0), 0),
          child: child,
        );
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscureText,
        keyboardType: widget.keyboardType,
        validator: (value) {
          final error = widget.validator?.call(value);
          if (error != null) {
            setState(() => _errorText = error);
            _triggerErrorShake();
          } else {
            setState(() => _errorText = null);
          }
          return error;
        },
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        textInputAction: widget.textInputAction,
        focusNode: _internalFocusNode,
        inputFormatters: widget.inputFormatters,
        autofillHints: widget.autofillHints,
        style: AppTypography.bodyL.copyWith(
          color: widget.enabled
              ? (isDark ? AppColors.neutral50 : AppColors.neutral900)
              : AppColors.neutral400,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          helperStyle: AppTypography.bodyS.copyWith(
            color: AppColors.neutral400,
          ),
          prefixIcon: prefixWidget,
          suffixIcon: suffixWidget,
          counterText: widget.showCharacterCounter ? null : '',
          errorMaxLines: 2,
          filled: widget.variant == TextFieldVariant.standard,
          fillColor: widget.variant == TextFieldVariant.standard
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : Colors.transparent,
          border: widget.variant == TextFieldVariant.standard
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                  ),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
          enabledBorder: widget.variant == TextFieldVariant.standard
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                  ),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
            borderSide: BorderSide(
              color: AppColors.primary500,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
            borderSide: BorderSide(
              color: AppColors.error500,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
            borderSide: BorderSide(
              color: AppColors.error500,
              width: 2.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.04),
            ),
          ),
        ),
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SPECIALIZED TEXT FIELD VARIANTS
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Search field with search icon and clear button
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Search',
      hint: hint ?? InputHelpers.searchPlaceholder,
      controller: controller,
      prefixIcon: Icons.search_rounded,
      suffix: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
            )
          : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Email field with validation
class AppEmailField extends StatelessWidget {
  const AppEmailField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Email',
      hint: InputHelpers.emailPlaceholder,
      controller: controller,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return ErrorMessages.emailRequired;
        }
        if (!value.contains('@') || !value.contains('.')) {
          return ErrorMessages.emailInvalid;
        }
        return null;
      },
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// Password field with validation
class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.showStrength = false,
  });

  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool showStrength;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Password',
      hint: InputHelpers.passwordPlaceholder,
      controller: controller,
      isPassword: true,
      prefixIcon: Icons.lock_outline_rounded,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return ErrorMessages.passwordRequired;
        }
        if (value.length < 6) {
          return ErrorMessages.passwordTooShort;
        }
        return null;
      },
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
