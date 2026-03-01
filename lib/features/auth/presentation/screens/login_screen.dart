/// ═══════════════════════════════════════════════════════════════════════════════
/// 🔐 LOGIN SCREEN - Premium Authentication Experience
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Clean, professional login screen with form validation and loading states.
/// Uses BlocConsumer pattern for reactive UI and state management.
///
/// FEATURES:
/// - Email and password validation with error messages
/// - Loading state with disabled input during auth
/// - Forgot password link (placeholder)
/// - Sign up link for new users
/// - Keyboard-aware scroll behavior
/// - Premium toast notifications
///
/// UX PRINCIPLES:
/// - Clear back button to onboarding
/// - Friendly headline copy
/// - Immediate validation feedback
/// - Loading state on button during auth
/// - Error toasts with retry option
///
/// WHY THIS APPROACH?
/// - Uses new AppTextField and AppButton components
/// - AppToast for error notifications
/// - Design tokens for spacing/typography
/// - Content from copy_guidelines.dart
/// - Consistent with premium design system
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_text_field.dart';
import 'package:mockmate/core/widgets/app_toast.dart';
import 'package:mockmate/features/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(AppRoutes.dashboard);
        } else if (state is AuthError) {
          AppToast.error(
            context,
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.x3l.toDouble(),
                vertical: AppSpacing.x5l.toDouble(),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.onboarding),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkSurface,
                        padding: EdgeInsets.all(AppSpacing.m.toDouble()),
                      ),
                    ),

                    SizedBox(height: AppSpacing.x4l.toDouble()),

                    // Headline
                    Text(
                      HeadlineLibrary.loginHeadline,
                      style: AppTypography.displayL.copyWith(
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: AppSpacing.s.toDouble()),

                    Text(
                      HeadlineLibrary.loginSubheadline,
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),

                    SizedBox(height: AppSpacing.x5l.toDouble()),

                    // Email field
                    AppEmailField(
                      controller: _emailController,
                      onSubmitted: (_) {
                        // Move focus to password field
                        FocusScope.of(context).nextFocus();
                      },
                    ),

                    SizedBox(height: AppSpacing.l.toDouble()),

                    // Password field
                    AppPasswordField(
                      controller: _passwordController,
                      onSubmitted: (_) => _onLoginPressed(context),
                    ),

                    SizedBox(height: AppSpacing.xs.toDouble()),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password flow
                          AppToast.info(
                            context,
                            message: 'Forgot password feature coming soon!',
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs.toDouble(),
                            vertical: AppSpacing.s.toDouble(),
                          ),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: AppTypography.labelM.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxl.toDouble()),

                    // Login button
                    AppButton(
                      label: CTALibrary.signIn,
                      onPressed:
                          isLoading ? null : () => _onLoginPressed(context),
                      isLoading: isLoading,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      isFullWidth: true,
                    ),

                    SizedBox(height: AppSpacing.x4l.toDouble()),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppTypography.bodyM.copyWith(
                              color: AppColors.primary500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
