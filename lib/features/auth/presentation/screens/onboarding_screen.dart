/// Onboarding Screen — first impression of MockMate.
///
/// UX PRINCIPLES APPLIED:
/// 1. Real brand logo as hero — immediate visual brand recognition
/// 2. Staggered feature pill animation — each pill slides in 100ms apart
/// 3. Clear value proposition above the fold
/// 4. Single clear CTA reduces decision paralysis
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mockmate/core/router/app_router.dart';
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
    (Icons.smart_toy_outlined, 'AI-powered questions for your role'),
    (Icons.bar_chart_rounded,  'Track progress over time'),
    (Icons.feedback_outlined,  'Instant detailed feedback per answer'),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pillControllers = List.generate(
      _features.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _heroScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.08), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeOut);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _heroController.forward();
    _contentController.forward();
    // Stagger the feature pills 120ms apart
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.10),

              // ── Hero Logo (real brand asset) ────────────────────────────
              FadeTransition(
                opacity: _heroFade,
                child: ScaleTransition(
                  scale: _heroScale,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 88,
                    height: 88,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.055),

              // ── Headline + Body ──────────────────────────────────────────
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ace Every\nInterview.',
                        style: theme.textTheme.displayLarge?.copyWith(
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Practice with AI mock interviews tailored to your role. Get instant feedback and track your growth.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      SizedBox(height: size.height * 0.045),

                      // ── Feature Pills (staggered) ───────────────────────
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
                              ).animate(CurvedAnimation(
                                parent: _pillControllers[i],
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          ),
                          child: _FeaturePill(
                            icon: _features[i].$1,
                            label: _features[i].$2,
                            color: i == 1
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.primary,
                          ),
                        ),
                        if (i < _features.length - 1) const SizedBox(height: 12),
                      ],

                      SizedBox(height: size.height * 0.055),

                      // ── CTA Buttons ─────────────────────────────────────
                      AppPrimaryButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go(AppRoutes.register);
                        },
                      ),
                      const SizedBox(height: 14),
                      AppOutlinedButton(
                        label: 'I already have an account',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go(AppRoutes.login);
                        },
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

// ── Feature Pill Widget ─────────────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
