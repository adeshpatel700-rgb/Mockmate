/// Onboarding Screen — first impression of MockMate.
///
/// UX PRINCIPLES APPLIED:
/// 1. Clear value proposition above the fold — user knows what the app does instantly
/// 2. Visual hierarchy: big headline → subtitle → CTA button
/// 3. Whitespace creates breathing room and makes content scannable
/// 4. Single clear CTA (Get Started) reduces decision paralysis
library;

import 'package:flutter/material.dart';
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
  late final Animation<double> _heroFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    // Hero animation — the icon fades in first
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Content animation — text and buttons slide up + fade in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeOut);

    // Start animations sequentially
    _heroController.forward().then((_) => _contentController.forward());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
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
              SizedBox(height: size.height * 0.12),

              // ── Hero Icon ───────────────────────────────────────────────
              FadeTransition(
                opacity: _heroFade,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // ── Headline + Body ─────────────────────────────────────────
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
                      const SizedBox(height: 20),
                      Text(
                        'Practice with AI-powered mock interviews tailored to your role. Get instant feedback and track your growth.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      SizedBox(height: size.height * 0.06),

                      // ── Feature Pills ──────────────────────────────────
                      _FeaturePill(
                        icon: Icons.smart_toy_outlined,
                        label: 'AI-powered questions for your role',
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      _FeaturePill(
                        icon: Icons.bar_chart_rounded,
                        label: 'Track progress over time',
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      _FeaturePill(
                        icon: Icons.feedback_outlined,
                        label: 'Instant detailed feedback',
                        color: theme.colorScheme.primary,
                      ),

                      SizedBox(height: size.height * 0.06),

                      // ── CTA Buttons ────────────────────────────────────
                      AppPrimaryButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.go(AppRoutes.register),
                      ),
                      const SizedBox(height: 14),
                      AppOutlinedButton(
                        label: 'I already have an account',
                        onPressed: () => context.go(AppRoutes.login),
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

// ── Feature Pill Widget ────────────────────────────────────────────────────

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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
