/// ═══════════════════════════════════════════════════════════════════════════════
/// ✨ APP SHIMMER - Loading Skeleton Component
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Elegant shimmer loading effect for skeleton screens. Provides smooth
/// animated placeholders while content is loading.
///
/// VARIANTS:
/// - Basic shimmer box (customizable)
/// - Card shimmer (full card placeholder)
/// - List item shimmer (avatar + text lines)
/// - Text line shimmer (single or multiple lines)
///
/// USAGE:
/// ```dart
/// ShimmerBox(
///   width: 100,
///   height: 100,
///   borderRadius: BorderRadius.circular(12),
/// )
///
/// ShimmerCard()
///
/// ShimmerListTile()
/// ```
///
/// WHY SHIMMER LOADING?
/// - Perceived performance improvement (feels faster)
/// - Reduces user frustration during loading
/// - Premium, modern loading experience
/// - Better UX than spinning indicators for content
/// - Maintains layout stability (no content shift)
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Base shimmer effect wrapper using ShimmerAnimation from motion_tokens
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration duration;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBF4),
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SHIMMER BOX - Basic building block
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : AppColors.neutral200,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.xs),
        ),
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SHIMMER CARD - Full card placeholder
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 200,
    this.hasImage = true,
    this.hasText = true,
  });

  final double height;
  final bool hasImage;
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.s),
      padding: EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            ShimmerBox(
              width: double.infinity,
              height: 120,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            SizedBox(height: AppSpacing.m),
          ],
          if (hasText) ...[
            const ShimmerBox(width: 120, height: 20),
            SizedBox(height: AppSpacing.s),
            const ShimmerBox(width: double.infinity, height: 14),
            SizedBox(height: AppSpacing.xs),
            const ShimmerBox(width: double.infinity, height: 14),
            SizedBox(height: AppSpacing.xs),
            const ShimmerBox(width: 180, height: 14),
          ],
        ],
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SHIMMER LIST TILE - Avatar + text lines
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lineCount = 2,
  });

  final bool hasLeading;
  final bool hasTrailing;
  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.s,
        horizontal: AppSpacing.m,
      ),
      child: Row(
        children: [
          // Leading avatar
          if (hasLeading) ...[
            const ShimmerBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            SizedBox(width: AppSpacing.m),
          ],

          // Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 150, height: 16),
                if (lineCount > 1) ...[
                  SizedBox(height: AppSpacing.xs),
                  const ShimmerBox(width: 100, height: 14),
                ],
                if (lineCount > 2) ...[
                  SizedBox(height: AppSpacing.xs),
                  const ShimmerBox(width: 120, height: 14),
                ],
              ],
            ),
          ),

          // Trailing element
          if (hasTrailing) ...[
            SizedBox(width: AppSpacing.m),
            const ShimmerBox(width: 24, height: 24),
          ],
        ],
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SHIMMER TEXT LINES - Multiple text line placeholders
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShimmerTextLines extends StatelessWidget {
  const ShimmerTextLines({
    super.key,
    this.lineCount = 3,
    this.lineHeight = 14,
    this.gap = 8,
  });

  final int lineCount;
  final double lineHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lineCount,
        (index) {
          // Last line is shorter
          final isLast = index == lineCount - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: index < lineCount - 1 ? gap : 0),
            child: ShimmerBox(
              width: isLast ? 180 : double.infinity,
              height: lineHeight,
            ),
          );
        },
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SHIMMER GRID - Grid of shimmer boxes
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.itemHeight = 120,
  });

  final int itemCount;
  final int crossAxisCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.m.toDouble(),
        mainAxisSpacing: AppSpacing.m.toDouble(),
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerBox(
          height: itemHeight,
          borderRadius: BorderRadius.circular(AppRadius.m),
        );
      },
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SHIMMER STAT CARD - Stat card placeholder
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerBox(width: 80, height: 14),
              ShimmerBox(
                width: 20,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s),
          const ShimmerBox(width: 120, height: 28),
          SizedBox(height: AppSpacing.xs),
          const ShimmerBox(width: 60, height: 12),
        ],
      ),
    );
  }
}
