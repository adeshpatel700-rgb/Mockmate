/// Register Screen — Premium Account Creation Experience
///
/// Features:
/// - Premium design with design tokens
/// - Specialized input fields (AppEmailField, AppPasswordField)
/// - Content guidelines integration
/// - Enhanced validation and error handling
/// - Loading states with AppToast
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/di/injection_container.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/widgets/app_button.dart';
import 'package:mockmate/core/widgets/app_text_field.dart';
import 'package:mockmate/core/widgets/app_toast.dart';
import 'package:mockmate/features/auth/presentation/bloc/auth_bloc.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      context.read<AuthBloc>().add(
            RegisterRequested(
              name: _nameController.text.trim(),
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
                      HeadlineLibrary.registerHeadline,
                      style: AppTypography.displayL.copyWith(
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: AppSpacing.s.toDouble()),

                    Text(
                      HeadlineLibrary.registerSubheadline,
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),

                    SizedBox(height: AppSpacing.x5l.toDouble()),

                    // Full Name field
                    AppTextField(
                      label: 'Full Name',
                      hint: 'Adesh Patel',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return ErrorMessages.nameRequired;
                        }
                        if (v.length < 2) {
                          return ErrorMessages.nameTooShort;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.l.toDouble()),

                    // Email field
                    AppEmailField(
                      controller: _emailController,
                      onSubmitted: (_) {
                        FocusScope.of(context).nextFocus();
                      },
                    ),

                    SizedBox(height: AppSpacing.l.toDouble()),

                    // Password field
                    AppPasswordField(
                      controller: _passwordController,
                      onSubmitted: (_) {
                        FocusScope.of(context).nextFocus();
                      },
                    ),

                    SizedBox(height: AppSpacing.l.toDouble()),

                    // Confirm Password field
                    AppTextField(
                      controller: _confirmPasswordController,
                      isPassword: true,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onRegisterPressed(context),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return ErrorMessages.passwordRequired;
                        }
                        if (v != _passwordController.text) {
                          return ErrorMessages.passwordsMismatch;
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.xxl.toDouble()),

                    // Register button
                    AppButton(
                      label: CTALibrary.createAccount,
                      onPressed:
                          isLoading ? null : () => _onRegisterPressed(context),
                      isLoading: isLoading,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      isFullWidth: true,
                    ),

                    SizedBox(height: AppSpacing.x4l.toDouble()),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Log In',
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
