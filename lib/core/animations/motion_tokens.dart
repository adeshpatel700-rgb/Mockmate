// ═══════════════════════════════════════════════════════════════════════════════
// 🎬 MOCKMATE MOTION & ANIMATION SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
//
// A comprehensive motion language defining how elements move, transition, and
// respond to user interaction throughout MockMate.
//
// Philosophy: Premium motion feels natural, purposeful, and delightful without
// being distracting. Every animation should communicate state or provide feedback.
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Page transition configurations for routing
class PageTransitions {
  /// Forward navigation: Slide up with fade (iOS-style)
  static PageTransitionsBuilder get slideUp =>
      const CupertinoPageTransitionsBuilder();

  /// Shared axis transition (Material 3 style)
  static Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) get sharedAxisY => (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      };

  /// Cross-fade transition for replacements
  static Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) get crossFade => (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      };
}

/// Micro-interaction animations for UI feedback
class MicroAnimations {
  /// Button press animation: Scale down slightly
  static Widget buttonPress({
    required Widget child,
    required AnimationController controller,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      ),
      child: child,
    );
  }

  /// Selection pulse: Scale up with border emphasis
  static Animation<double> selectionScale(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  /// Error shake: Horizontal vibration
  static Animation<Offset> errorShake(AnimationController controller) {
    return TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.02, 0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.02, 0),
          end: const Offset(-0.02, 0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.02, 0),
          end: const Offset(0.02, 0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.02, 0),
          end: Offset.zero,
        ),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Success bounce: Elastic scale for celebration
  static Animation<double> successBounce(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  /// Loading pulse: Gentle scale breathing
  static Animation<double> loadingPulse(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}

/// List and grid entrance animations
class EntranceAnimations {
  /// Staggered list item fadeIn + slideUp
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    required AnimationController controller,
  }) {
    final itemDelay = index * 50; // 50ms stagger between items
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        itemDelay / 1000,
        (itemDelay + 300) / 1000,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// Card scale-in from center
  static Widget cardScaleIn({
    required Widget child,
    required AnimationController controller,
    int index = 0,
  }) {
    final delay = index * 80; // 80ms stagger for cards
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay / 1000,
        (delay + 400) / 1000,
        curve: Curves.easeOutBack,
      ),
    );

    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Data visualization animations
class ChartAnimations {
  /// Line chart path drawing animation
  static Animation<double> lineChartDraw(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
  }

  /// Bar chart height grow animation
  static Animation<double> barChartGrow(
    AnimationController controller,
    int barIndex,
    int totalBars,
  ) {
    final delay = barIndex * (600 / totalBars);
    return CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay / 1000,
        (delay + 800) / 1000,
        curve: Curves.easeOutExpo,
      ),
    );
  }

  /// Number count-up animation
  static Animation<double> numberCountUp(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
  }
}

/// Modal and overlay animations
class OverlayAnimations {
  /// Bottom sheet slide up with backdrop blur
  static Widget bottomSheetSlide({
    required Widget child,
    required AnimationController controller,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: child,
    );
  }

  /// Dialog scale-in from center
  static Widget dialogScaleIn({
    required Widget child,
    required AnimationController controller,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      ),
      child: FadeTransition(
        opacity: controller,
        child: child,
      ),
    );
  }

  /// Backdrop fade-in
  static Widget backdropFade({
    required AnimationController controller,
  }) {
    return FadeTransition(
      opacity: controller,
      child: Container(
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Confetti burst animation for celebrations
class ConfettiAnimation extends StatefulWidget {
  final bool trigger;
  final Widget child;

  const ConfettiAnimation({
    super.key,
    required this.trigger,
    required this.child,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.trigger)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(_controller.value),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Simple confetti implementation
    // In production, use a proper confetti package
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
    ];

    for (int i = 0; i < 30; i++) {
      final angle = (i / 30) * 2 * 3.14159;
      final distance = progress * size.width * 0.6;
      final x =
          size.width / 2 + distance * (angle.isFinite ? (angle % 2 - 1) : 0);
      final y = size.height / 2 - distance * progress * 2;

      canvas.drawCircle(
        Offset(x, y),
        4.0 * (1 - progress),
        Paint()..color = colors[i % colors.length].withOpacity(1 - progress),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Animation helper functions
class AnimationHelpers {
  /// Create a stagger controller for multiple items
  static List<AnimationController> createStaggeredControllers({
    required TickerProvider vsync,
    required int count,
    required Duration duration,
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    return List.generate(count, (index) {
      final controller = AnimationController(
        vsync: vsync,
        duration: duration,
      );
      Future.delayed(staggerDelay * index, () {
        if (controller.isAnimating == false) {
          controller.forward();
        }
      });
      return controller;
    });
  }

  /// Dispose multiple controllers safely
  static void disposeControllers(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}
