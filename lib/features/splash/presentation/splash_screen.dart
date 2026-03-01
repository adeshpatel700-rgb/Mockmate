/// ═══════════════════════════════════════════════════════════════════════════════
/// 🚀 MOCKMATE SPLASH SCREEN - Premium Brand Experience
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Elegant splash experience with premium animations and brand introduction.
/// Uses design token system for consistency and maintainability.
///
/// ANIMATION SEQUENCE:
/// - Logo fade-in with elastic scale (0-800ms)
/// - Tagline slide-up with fade (600-1200ms)
/// - Gradient shimmer sweep (800-1600ms)
/// - Exit fade (2800-3000ms, then navigate)
///
/// TOTAL DURATION: ~3 seconds (optimal for brand perception)
///
/// WHY THIS APPROACH?
/// - Simpler, more maintainable animation logic
/// - Uses design tokens for consistent branding
/// - Elegant without being over-complicated
/// - Fast enough to not frustrate users
/// - Memorable brand introduction
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/router/app_router.dart';
import 'package:mockmate/core/theme/design_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _shimmerPosition;
  late final Animation<double> _exitFade;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Logo: Simple scale-in with bounce (0-800ms)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.27, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // Tagline: Slide-up with fade (600-1200ms)
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: AppCurves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.35, curve: Curves.easeIn),
      ),
    );

    // Shimmer sweep (800-1600ms)
    _shimmerPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.27, 0.53, curve: Curves.easeInOut),
      ),
    );

    // Exit fade (2800-3000ms)
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.93, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _startSequence() async {
    await _controller.forward();
    if (!_isDisposed && mounted) _navigate();
  }

  Future<void> _navigate() async {
    if (_isDisposed || !mounted) return;

    // DEV MODE: Skip auth check, go directly to dashboard
    if (kDevBypassAuth) {
      context.go(AppRoutes.dashboard);
      return;
    }

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.accessTokenKey);

      if (_isDisposed || !mounted) return;

      if (token != null && token.isNotEmpty) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitFade,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBackground,
                    AppColors.primary900,
                    AppColors.darkBackground,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glow effect
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary500.withOpacity(0.5),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 140,
                            height: 140,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.x4l.toDouble()),

                    // Wordmark with shimmer
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            final shimmerValue = _shimmerPosition.value;
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: const [
                                AppColors.neutral50,
                                AppColors.primary500,
                                AppColors.secondary500,
                                AppColors.neutral50,
                              ],
                              stops: [
                                (shimmerValue - 0.3).clamp(0.0, 1.0),
                                (shimmerValue - 0.1).clamp(0.0, 1.0),
                                (shimmerValue + 0.1).clamp(0.0, 1.0),
                                (shimmerValue + 0.3).clamp(0.0, 1.0),
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'MockMate',
                            style: AppTypography.displayXXL.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.m.toDouble()),

                    // Tagline
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Your AI Interview Coach',
                          style: AppTypography.bodyL.copyWith(
                            color: AppColors.secondary500,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
