import 'package:flutter/material.dart';

/// Centralized design token registry for ScholarSync.
/// All widgets must reference these tokens — never hardcode colors.
abstract final class AppColors {
  // ── Brand Palette ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFFD84D); // Warm Yellow
  static const Color secondary = Color(0xFF00C2A8); // Teal
  static const Color accent = Color(0xFFFF6B6B); // Coral

  // ── Surface ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F0);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2F2F2F);
  static const Color textSecondary = Color(0xFF6F6F6F);
  static const Color textDisabled = Color(0xFFADADAD);
  static const Color textOnPrimary = Color(0xFF2F2F2F); // dark text on yellow
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Border ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderFocused = Color(0xFFFFD84D);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Dark Mode Overrides ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);

  // ── Shadow ───────────────────────────────────────────────────────────────
  static const Color shadow = Color(0x14000000); // 8% black
  static const Color shadowMedium = Color(0x1F000000); // 12% black

  // ─── ColorScheme Factories ────────────────────────────────────────────────

  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: accent,
        onTertiary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        outline: border,
        error: error,
        onError: Colors.white,
      );

  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: accent,
        onTertiary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        error: error,
        onError: Colors.white,
      );
}

