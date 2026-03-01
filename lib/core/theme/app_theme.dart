/// ═══════════════════════════════════════════════════════════════════════════════
/// 🎨 MOCKMATE PREMIUM THEME SYSTEM
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Material 3-based theme system with premium design tokens, sophisticated
/// component styling, and carefully crafted light/dark modes.
///
/// This theme integrates:
/// - Premium color palette from design_tokens.dart
/// - Plus Jakarta Sans typography for readability
/// - Glass morphism and gradient effects
/// - Consistent spacing using 8pt grid
/// - Professional shadows and elevation
/// - Comprehensive component theming
///
/// WHY MATERIAL 3?
/// Material 3 (Material You) is Google's latest design system with dynamic
/// color schemes, modern components, and built-in accessibility.
///
/// WHY SEPARATE THEME?
/// Centralized theming means one change updates the entire app, maintaining
/// visual consistency and reducing maintenance overhead.
///
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // THEME EXTENSIONS: Semantic Colors
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Custom semantic colors not covered by Material colorScheme

  /// Success color for positive feedback, achievements
  static const Color successColor = AppColors.success500;

  /// Warning color for cautions, alerts
  static const Color warningColor = AppColors.warning500;

  /// Info color for helpful tips, notifications
  static const Color infoColor = AppColors.info500;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TYPOGRAPHY: Premium Text Styles
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Build Material TextTheme with Plus Jakarta Sans typography
  static TextTheme _buildTextTheme(Color textColor, Color subtextColor) {
    return GoogleFonts.plusJakartaSansTextTheme(
      TextTheme(
        // Display styles (hero headlines)
        displayLarge: AppTypography.displayXL.copyWith(color: textColor),
        displayMedium: AppTypography.displayL.copyWith(color: textColor),
        displaySmall: AppTypography.headlineXL.copyWith(color: textColor),

        // Headline styles (page titles)
        headlineLarge: AppTypography.headlineL.copyWith(color: textColor),
        headlineMedium: AppTypography.headlineM.copyWith(color: textColor),
        headlineSmall: AppTypography.titleXL.copyWith(color: textColor),

        // Title styles (card headers)
        titleLarge: AppTypography.titleL.copyWith(color: textColor),
        titleMedium: AppTypography.titleM.copyWith(color: textColor),
        titleSmall: AppTypography.bodyL.copyWith(color: textColor),

        // Body styles (content, paragraphs)
        bodyLarge: AppTypography.bodyL.copyWith(color: textColor),
        bodyMedium: AppTypography.bodyM.copyWith(color: subtextColor),
        bodySmall: AppTypography.bodyS.copyWith(color: subtextColor),

        // Label styles (buttons, captions)
        labelLarge: AppTypography.labelM.copyWith(color: textColor),
        labelMedium: AppTypography.labelS.copyWith(color: subtextColor),
        labelSmall: AppTypography.labelXS.copyWith(color: subtextColor),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DARK THEME: Cred-inspired luxury dark mode (OLED black + Gold)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary500,
      primaryContainer: AppColors.primary800,
      secondary: AppColors.secondary500,
      secondaryContainer: AppColors.secondary800,
      error: AppColors.error500,
      surface: AppColors.darkSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.neutral50,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(AppColors.neutral50, AppColors.neutral400),

      // ── AppBar: Pure black, zero elevation (Cred style) ───────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.neutral50, size: 24),
        titleTextStyle: AppTypography.titleL.copyWith(
          color: AppColors.neutral50,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // ── Cards: Deep black with hairline gold-tinted border (Cred style) ───
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          side: BorderSide(
            color: AppColors.primary500.withOpacity(0.08),
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: AppSpacing.s),
      ),

      // ── Elevated Buttons: Gold + black text (Cred CTA style) ─────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: AppColors.primary500.withOpacity(0.3),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.xs,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          textStyle: AppTypography.labelM.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.15);
            }
            return null;
          }),
        ),
      ),

      // ── Outlined Buttons: Gold border ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary500,
          side: const BorderSide(color: AppColors.primary500, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.xs,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          textStyle: AppTypography.labelM,
        ),
      ),

      // ── Text Buttons: Gold accent ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary500,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          textStyle: AppTypography.labelM,
        ),
      ),

      // ── Input Fields: Cred-style dark fields with gold focus ──────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(
            color: AppColors.primary500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(color: AppColors.error500, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(color: AppColors.error500, width: 2),
        ),
        labelStyle: AppTypography.bodyM.copyWith(color: AppColors.neutral400),
        hintStyle: AppTypography.bodyM.copyWith(
          color: AppColors.neutral500,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l + 2,
        ),
      ),

      // ── Chips: Dark with gold selected state ──────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primary500.withOpacity(0.15),
        side: BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        labelStyle: AppTypography.bodyM.copyWith(color: AppColors.neutral50),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
      ),

      // ── FAB: Gold ─────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
      ),

      // ── Bottom Sheet: Deep black ───────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),

      // ── Dialog: Premium modal ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        elevation: 0,
      ),

      // ── Progress Indicators: Gold ─────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary500,
        linearTrackColor: AppColors.darkSurface,
      ),

      // ── Dividers: Very subtle ─────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: AppSpacing.l,
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: AppTypography.bodyM.copyWith(
          color: AppColors.neutral50,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LIGHT THEME: Clean, professional light mode
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary500,
      primaryContainer: AppColors.primary100,
      secondary: AppColors.secondary500,
      secondaryContainer: AppColors.secondary100,
      error: AppColors.error500,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.neutral900,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(AppColors.neutral900, AppColors.neutral600),

      // ── AppBar: Clean and minimal ─────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: AppColors.lightSurface,
        iconTheme: IconThemeData(
          color: AppColors.neutral900,
          size: 24,
        ),
        titleTextStyle: AppTypography.titleL.copyWith(
          color: AppColors.neutral900,
        ),
      ),

      // ── Cards: Elevated with subtle shadow ────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shadowColor: AppColors.neutral900.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          side: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: AppSpacing.s),
      ),

      // ── Elevated Buttons: Solid primary ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary500.withOpacity(0.3),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.xs,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          textStyle: AppTypography.labelM,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),

      // ── Outlined Buttons: Clean borders ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary500,
          side: BorderSide(
            color: AppColors.primary500.withOpacity(0.6),
            width: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.xs,
            vertical: AppSpacing.l,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          textStyle: AppTypography.labelM,
        ),
      ),

      // ── Text Buttons: Subtle but visible ──────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary500,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          textStyle: AppTypography.labelM,
        ),
      ),

      // ── Input Fields: Rounded with focus state ────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(
            color: AppColors.primary500,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(
            color: AppColors.error500,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(
            color: AppColors.error500,
            width: 2.5,
          ),
        ),
        labelStyle: AppTypography.bodyM.copyWith(
          color: AppColors.neutral600,
        ),
        hintStyle: AppTypography.bodyM.copyWith(
          color: AppColors.neutral600.withOpacity(0.6),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l + 2,
        ),
      ),

      // ── Chips: Rounded pills ──────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCard,
        selectedColor: AppColors.primary500.withOpacity(0.15),
        side: BorderSide(color: Colors.black.withOpacity(0.08)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        labelStyle: AppTypography.bodyM.copyWith(
          color: AppColors.neutral900,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
      ),

      // ── Floating Action Button ────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        elevation: 0,
      ),

      // ── Progress Indicators ───────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary500,
        linearTrackColor: AppColors.lightSurface,
      ),

      // ── Dividers ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: Colors.black.withOpacity(0.08),
        thickness: 1,
        space: AppSpacing.l,
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        contentTextStyle: AppTypography.bodyM.copyWith(
          color: AppColors.neutral50,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
