// ═══════════════════════════════════════════════════════════════════════════════
// 🎨 MOCKMATE PREMIUM DESIGN TOKENS — Cred-inspired
// ═══════════════════════════════════════════════════════════════════════════════
//
// Design Philosophy: Ultra-premium, Dark luxury, Confident
// Inspired by Cred's deep black + gold aesthetic
// - OLED black backgrounds for depth
// - Gold/amber accent spectrum for premium feel
// - Deep purple secondary for richness
// - Generous whitespace and bold typography
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Premium color palette — Cred-inspired Gold + Deep Black
class AppColors {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIMARY SPECTRUM: Gold/Amber (Brand Identity — Cred-inspired)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color primary50 = Color(0xFFFEF9EC);
  static const Color primary100 = Color(0xFFFDF0C4);
  static const Color primary200 = Color(0xFFFAE08A);
  static const Color primary300 = Color(0xFFF5C842);
  static const Color primary400 = Color(0xFFE8B44B);
  static const Color primary500 =
      Color(0xFFD4A843); // Primary brand — Cred gold
  static const Color primary600 = Color(0xFFB8902E);
  static const Color primary700 = Color(0xFF9A741D);
  static const Color primary800 = Color(0xFF7C5C12);
  static const Color primary900 = Color(0xFF5C4209);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECONDARY SPECTRUM: Deep Purple (Rich accent)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color secondary50 = Color(0xFFF5F0FF);
  static const Color secondary100 = Color(0xFFEBDCFF);
  static const Color secondary200 = Color(0xFFD5BAFF);
  static const Color secondary300 = Color(0xFFB68EF8);
  static const Color secondary400 = Color(0xFF9B6EF0);
  static const Color secondary500 =
      Color(0xFF7C3AED); // Secondary — deep purple
  static const Color secondary600 = Color(0xFF6D28D9);
  static const Color secondary700 = Color(0xFF5B21B6);
  static const Color secondary800 = Color(0xFF4C1D95);
  static const Color secondary900 = Color(0xFF2E1065);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NEUTRAL SPECTRUM: Zinc (Backgrounds, Borders, Text)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF4F4F5);
  static const Color neutral200 = Color(0xFFE4E4E7);
  static const Color neutral300 = Color(0xFFD4D4D8);
  static const Color neutral400 = Color(0xFFA1A1AA);
  static const Color neutral500 = Color(0xFF71717A);
  static const Color neutral600 = Color(0xFF52525B);
  static const Color neutral700 = Color(0xFF3F3F46);
  static const Color neutral800 = Color(0xFF27272A);
  static const Color neutral900 = Color(0xFF18181B);
  static const Color neutral950 = Color(0xFF09090B);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEMANTIC COLORS: Success, Warning, Error, Info
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // Success (Green)
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success500 = Color(0xFF10B981);
  static const Color success700 = Color(0xFF047857);

  // Warning (Amber)
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning700 = Color(0xFFB45309);

  // Error (Red)
  static const Color error50 = Color(0xFFFEF2F2);
  static const Color error500 = Color(0xFFEF4444);
  static const Color error700 = Color(0xFFC81E1E);

  // Info (Blue)
  static const Color info50 = Color(0xFFEFF6FF);
  static const Color info500 = Color(0xFF3B82F6);
  static const Color info700 = Color(0xFF1D4ED8);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK MODE SPECIFIC — Cred-level deep black
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color darkBackground = Color(0xFF080808); // True OLED black
  static const Color darkSurface = Color(0xFF111111); // Elevated surface
  static const Color darkCard = Color(0xFF161616); // Card background
  static const Color darkBorder = Color(0xFF2A2A2A); // Subtle borders

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT MODE SPECIFIC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const Color lightBackground = Color(0xFFF9FAFB); // Gray-50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E4E7);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PREMIUM GRADIENTS — Gold luxury theme
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Primary brand gradient (Gold spectrum)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary400, primary600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold shimmer gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF5C842), Color(0xFFD4A843), Color(0xFFB8902E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient (Green spectrum)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34D399), success500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning gradient (Amber to Orange)
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning500, Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Error gradient (Red spectrum)
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFF87171), error500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Hero gradient — deep black to dark purple (Cred-style)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF080808),
      Color(0xFF1A0938),
      Color(0xFF080808),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass morphism gradient overlay
  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.08),
      Colors.white.withOpacity(0.03),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Typography scale using Plus Jakarta Sans
class AppTypography {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DISPLAY STYLES (Headlines, Heroes)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// XXL Display (56px) - Splash screens, major marketing moments
  static const TextStyle displayXXL = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// XL Display (48px) - Primary headlines
  static const TextStyle displayXL = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// L Display (40px) - Section headers
  static const TextStyle displayL = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HEADLINE STYLES (Page Titles)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// XL Headline (32px) - Screen titles
  static const TextStyle headlineXL = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// L Headline (28px) - Card headers
  static const TextStyle headlineL = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// M Headline (24px) - Section headers
  static const TextStyle headlineM = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TITLE STYLES (Card Titles, List Headers)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// XL Title (22px)
  static const TextStyle titleXL = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// L Title (20px)
  static const TextStyle titleL = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// M Title (18px)
  static const TextStyle titleM = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BODY STYLES (Paragraphs, Content)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// L Body (17px) - Primary content, questions
  static const TextStyle bodyL = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.1,
  );

  /// M Body (15px) - Standard content
  static const TextStyle bodyM = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.1,
  );

  /// S Body (13px) - Supporting text
  static const TextStyle bodyS = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LABEL STYLES (Buttons, Inputs, Captions)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// M Label (14px) - Button text, form labels
  static const TextStyle labelM = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
  );

  /// S Label (12px) - Captions, metadata
  static const TextStyle labelS = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
  );

  /// XS Label (11px) - Tiny captions, badges
  static const TextStyle labelXS = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.4,
  );
}

/// Spacing system based on strict 8pt grid
class AppSpacing {
  static const double xs = 4; // Tight spacing (icon padding)
  static const double s = 8; // Compact spacing (chip padding)
  static const double m = 12; // Standard spacing (button vertical)
  static const double l = 16; // Comfortable spacing (card internal)
  static const double xl = 20; // Generous spacing (section gaps)
  static const double xxl = 24; // Large spacing (card external)
  static const double x3l = 32; // Extra large (major sections)
  static const double x4l = 40; // Hero sections
  static const double x5l = 48; // Page margins
  static const double x6l = 56; // Large hero gaps
  static const double x7l = 64; // Maximum spacing
  static const double x8l = 80; // Splash screen spacing
  static const double x9l = 96; // Extra-large sections
}

/// Border radius tokens for consistency
class AppRadius {
  static const double xs = 8; // Chips, badges, small pills
  static const double s = 12; // Buttons, inputs, standard elements
  static const double m = 16; // Cards, modals, standard containers
  static const double l = 20; // Bottom sheets, feature cards
  static const double xl = 28; // Hero cards, emphasize elements
  static const double round = 999; // Fully circular elements
}

/// Elevation system using premium shadows (not Material elevation)
class AppShadows {
  /// XS Shadow - Subtle depth (chips, badges)
  static List<BoxShadow> get xs => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// S Shadow - Minor elevation (buttons)
  static List<BoxShadow> get s => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// M Shadow - Standard cards
  static List<BoxShadow> get m => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// L Shadow - Elevated cards, modals
  static List<BoxShadow> get l => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// XL Shadow - Floating action button, hero elements
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  /// 2XL Shadow - Maximum depth
  static List<BoxShadow> get xxl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ];

  /// Colored shadow for brand elements (primary)
  static List<BoxShadow> get brandPrimary => [
        BoxShadow(
          color: AppColors.primary500.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Colored shadow for success states
  static List<BoxShadow> get success => [
        BoxShadow(
          color: AppColors.success500.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// Glass morphism effect
  static List<BoxShadow> get glass => [
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

/// Animation duration constants
class AppDurations {
  static const Duration instant = Duration(milliseconds: 100); // Micro-feedback
  static const Duration fast = Duration(milliseconds: 200); // Toggles, hovers
  static const Duration normal =
      Duration(milliseconds: 300); // Transitions, slides
  static const Duration slow = Duration(milliseconds: 500); // Page transitions
  static const Duration dramatic =
      Duration(milliseconds: 800); // Hero animations
}

/// Animation curve constants (premium easing)
class AppCurves {
  static const Curve easeOutExpo = Curves.easeOutExpo; // Dramatic slowdown
  static const Curve easeOutCubic = Curves.easeOutCubic; // Smooth deceleration
  static const Curve easeInOutBack = Curves.easeInOutBack; // Bouncy feel
  static const Curve elasticOut = Curves.elasticOut; // Playful spring
  static const Curve easeInOut = Curves.easeInOut; // Balanced
  static const Curve decelerate = Curves.decelerate; // Natural motion
}

/// Responsive breakpoints
class AppBreakpoints {
  static const double mobile = 600; // < 600px = mobile
  static const double tablet = 1024; // 600-1024px = tablet
  // > 1024px = desktop
}
