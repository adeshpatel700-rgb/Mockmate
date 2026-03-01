/// ═══════════════════════════════════════════════════════════════════════════════
/// 👋 ONBOARDING SCREEN - Premium First Impression
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// First touchpoint of the MockMate experience. Sets brand expectations and
/// communicates value proposition with premium animations.
///
/// UX PRINCIPLES:
/// - Real logo creates immediate brand recognition
/// - Staggered feature animations guide the eye
/// - Clear value proposition in headline
/// - Single primary CTA reduces decision paralysis
/// - Prominent secondary action for returning users
///
/// ANIMATION FLOW:
/// - Logo scales in with elastic bounce (0-900ms)
/// - Content slides up with fade (600-1300ms)
/// - Feature pills stagger in 120ms apart (starting at 1300ms)
///
/// WHY THIS APPROACH?
/// - Consistent with premium design system
/// - Uses design tokens for maintainability
/// - Reduced complexity vs previous implementation
/// - Clear CTAs guide user to next action
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';
import 'package:mockmate/core/constants/copy_guidelines.dart';
import 'package:mockmate/core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroController;
  late final AnimationController _contentController;
  late final List<AnimationController> _pillControllers;

  late final Animation<double> _heroScale;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;

  static const _features = [
    (Icons.psychology_rounded, 'AI-powered questions for your role'),
    (Icons.insights_rounded, 'Track progress over time'),
    (Icons.tips_and_updates_rounded, 'Instant detailed feedback per answer'),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Hero logo animation
    _heroController = AnimationController(
      vsync: this,
      duration: AppDurations.dramatic,
    );

    _heroScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );

    _heroFade = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    );

    // Content animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: AppCurves.easeOutCubic,
      ),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    // Feature pills staggered animation
    _pillControllers = List.generate(
      _features.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _startSequence() async {
    await _heroController.forward();
    _contentController.forward();

    // Stagger feature pills 120ms apart
    for (final ctrl in _pillControllers) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) ctrl.forward();
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    for (final c in _pillControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3l.toDouble()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.10),

              // Logo with animation
              FadeTransition(
                opacity: _heroFade,
                child: ScaleTransition(
                  scale: _heroScale,
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.m.toDouble()),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      boxShadow: AppShadows.brandPrimary,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.055),

              // Content with slide animation
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline
                      Text(
                        HeadlineLibrary.onboardingHeadline1,
                        style: AppTypography.displayL.copyWith(
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: AppSpacing.l.toDouble()),

                      // Subheadline
                      Text(
                        HeadlineLibrary.onboardingSubheadline1,
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),

                      SizedBox(height: size.height * 0.045),

                      // Feature pills with staggered animation
                      for (int i = 0; i < _features.length; i++) ...[
                        AnimatedBuilder(
                          animation: _pillControllers[i],
                          builder: (context, child) => FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _pillControllers[i],
                              curve: Curves.easeOut,
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.15, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _pillControllers[i],
                                  curve: AppCurves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                          child: _FeaturePill(
                            icon: _features[i].$1,
                            label: _features[i].$2,
                            color: i == 1
                                ? AppColors.secondary500
                                : AppColors.primary500,
                          ),
                        ),
                        if (i < _features.length - 1)
                          SizedBox(height: AppSpacing.m.toDouble()),
                      ],

                      SizedBox(height: size.height * 0.055),

                      // Primary CTA
                      AppButton(
                        label: CTALibrary.getStarted,
                        icon: Icons.arrow_forward_rounded,
                        iconPosition: IconPosition.trailing,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go(AppRoutes.register);
                        },
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        isFullWidth: true,
                      ),

                      SizedBox(height: AppSpacing.m.toDouble()),

                      // Secondary CTA
                      AppButton(
                        label: CTALibrary.alreadyHaveAccount,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go(AppRoutes.login);
                        },
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.large,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// FEATURE PILL - Premium feature display component
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.s.toDouble() + 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        SizedBox(width: AppSpacing.m.toDouble() + 2),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyL.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
