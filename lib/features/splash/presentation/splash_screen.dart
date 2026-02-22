/// MockMate Splash Screen — "Intelligence Awakening"
///
/// Animation stages:
///  0–400ms   → Background radial bloom (dark → brand dark)
///  300–900ms → Logo scales in with elastic spring + glow halo expands
///  700–1400ms→ Neural-node particles orbit/ping outward, then retract
///  900–1500ms→ "MockMate" wordmark slides up + shimmer sweeps
/// 1100–1700ms→ Tagline typewriter reveal
/// 2600–3000ms→ Full fade-out, then navigate
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockmate/core/constants/app_constants.dart';
import 'package:mockmate/core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _particleController;
  late final AnimationController _textController;
  late final AnimationController _exitController;

  // Background
  late final Animation<double> _bgOpacity;
  late final Animation<double> _bgBloom;

  // Logo
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowRadius;
  late final Animation<double> _glowOpacity;

  // Particles
  late final Animation<double> _particleProgress;

  // Text
  late final Animation<double> _wordmarkSlide;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _shimmerPosition;
  late final Animation<double> _taglineOpacity;

  // Typewriter
  final String _tagline = 'Ace Every Interview';
  int _visibleChars = 0;

  // Exit
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // ── Background (600ms) ─────────────────────────────────────────
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bgOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeIn),
    );
    _bgBloom = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOut),
    );

    // ── Logo (800ms) ───────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.96), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 15),
    ]).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _glowRadius = Tween<double>(begin: 60, end: 120).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.45), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.45, end: 0.2), weight: 50),
    ]).animate(_logoController);

    // ── Particles (1200ms, loops for pulse feel) ───────────────────
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particleProgress = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    );

    // ── Text (900ms) ───────────────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _wordmarkSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _wordmarkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _shimmerPosition = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // ── Exit (500ms) ───────────────────────────────────────────────
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
  }

  Future<void> _startSequence() async {
    // Stage 1: Background blooms
    await _bgController.forward();

    // Stage 2: Logo materializes (slight overlap with bg)
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Stage 3: Particles orbit
    _particleController.forward();

    // Stage 4: Text reveals (slight overlap)
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // Stage 4b: Typewriter for tagline
    await Future.delayed(const Duration(milliseconds: 600));
    await _runTypewriter();

    // Hold for appreciation
    await Future.delayed(const Duration(milliseconds: 700));

    // Stage 5: Exit
    _exitController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) _navigate();
  }

  Future<void> _runTypewriter() async {
    for (int i = 0; i <= _tagline.length; i++) {
      if (!mounted) return;
      setState(() => _visibleChars = i);
      await Future.delayed(const Duration(milliseconds: 45));
    }
  }

  Future<void> _navigate() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.accessTokenKey);
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoController,
          _particleController,
          _textController,
          _exitController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitOpacity,
            child: Stack(
              children: [
                // ── Radial Gradient Bloom ──────────────────────────────────
                Opacity(
                  opacity: _bgOpacity.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.15),
                        radius: 0.8 + (_bgBloom.value * 0.4),
                        colors: [
                          const Color(0xFF1A1042).withValues(alpha: _bgBloom.value),
                          const Color(0xFF0F0E17),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Neural Particle Painter ────────────────────────────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: _NeuralParticlePainter(
                      progress: _particleProgress.value,
                      center: Offset(size.width / 2, size.height * 0.38),
                    ),
                  ),
                ),

                // ── Glow Halo behind logo ──────────────────────────────────
                Center(
                  child: Transform.translate(
                    offset: Offset(0, -size.height * 0.06),
                    child: Container(
                      width: _glowRadius.value * 2,
                      height: _glowRadius.value * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6C63FF).withValues(alpha: _glowOpacity.value),
                            const Color(0xFF03DAC6).withValues(alpha: _glowOpacity.value * 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Logo ───────────────────────────────────────────────────
                Center(
                  child: Transform.translate(
                    offset: Offset(0, -size.height * 0.06),
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 160,
                          height: 160,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Wordmark + Tagline ─────────────────────────────────────
                Align(
                  alignment: const Alignment(0, 0.18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Wordmark "MockMate" with shimmer
                      Opacity(
                        opacity: _wordmarkOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _wordmarkSlide.value),
                          child: _ShimmerText(
                            shimmerPosition: _shimmerPosition.value,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Mock',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1.2,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Mate',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF6C63FF),
                                      letterSpacing: -1.2,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF6C63FF).withValues(alpha: 0.6),
                                          blurRadius: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline — typewriter
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: Text(
                          _tagline.substring(0, _visibleChars),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF03DAC6),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Subtle bottom vignette ─────────────────────────────────
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF0F0E17), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Shimmer Text Wrapper ──────────────────────────────────────────────────

class _ShimmerText extends StatelessWidget {
  final Widget child;
  final double shimmerPosition; // -1 → 2

  const _ShimmerText({required this.child, required this.shimmerPosition});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final center = shimmerPosition * bounds.width;
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Colors.white,
            Color(0xFFFFFFFF),
            Color(0xFFE8E0FF),
            Colors.white,
          ],
          stops: [
            0.0,
            (center / bounds.width - 0.12).clamp(0.0, 1.0),
            (center / bounds.width).clamp(0.0, 1.0),
            (center / bounds.width + 0.12).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

// ── Neural Particle Painter ───────────────────────────────────────────────

class _NeuralParticlePainter extends CustomPainter {
  final double progress; // 0 → 1
  final Offset center;

  _NeuralParticlePainter({required this.progress, required this.center});

  // Node configuration: [angle (radians), maxRadius, size]
  static const List<List<double>> _nodes = [
    [0.0, 80, 4],
    [0.785, 95, 3],
    [1.571, 85, 5],
    [2.356, 78, 3.5],
    [3.14, 90, 4],
    [3.927, 82, 3],
    [4.712, 88, 4.5],
    [5.498, 75, 3],
  ];

  // Line pairs (index pairs from _nodes)
  static const List<List<int>> _edges = [
    [0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7],
    [7, 0], [0, 4], [2, 6],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    // Ease in-out for orbit
    final eased = _easeInOut(progress);
    final fadeIn = (progress * 3).clamp(0.0, 1.0);
    final fadeOut = progress > 0.7 ? ((1 - progress) / 0.3).clamp(0.0, 1.0) : 1.0;
    final alpha = fadeIn * fadeOut;

    final positions = <Offset>[];

    for (final node in _nodes) {
      final angle = node[0];
      final maxR = node[1];
      final r = maxR * eased;
      positions.add(Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      ));
    }

    // Draw edges
    final linePaint = Paint()
      ..color = const Color(0xFF6C63FF).withValues(alpha: alpha * 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final edge in _edges) {
      if (edge[0] < positions.length && edge[1] < positions.length) {
        canvas.drawLine(positions[edge[0]], positions[edge[1]], linePaint);
      }
    }

    // Draw nodes
    for (int i = 0; i < _nodes.length; i++) {
      final pos = positions[i];
      final radius = _nodes[i][2];

      // Glow
      final glowPaint = Paint()
        ..color = const Color(0xFF6C63FF).withValues(alpha: alpha * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, radius * 2.5, glowPaint);

      // Node
      final nodePaint = Paint()
        ..color = const Color(0xFF9D98FF).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius, nodePaint);

      // Teal accent on alternates
      if (i % 3 == 0) {
        final accentPaint = Paint()
          ..color = const Color(0xFF03DAC6).withValues(alpha: alpha * 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, radius * 0.5, accentPaint);
      }
    }
  }

  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }

  @override
  bool shouldRepaint(_NeuralParticlePainter old) =>
      old.progress != progress || old.center != center;
}
