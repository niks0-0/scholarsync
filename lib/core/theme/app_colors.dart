import 'package:flutter/material.dart';

/// Centralized design token registry for ScholarSync (Monochrome Obsidian & AMOLED Edition).
/// All widgets reference these tokens — never hardcode colors.
abstract final class AppColors {
  // ── Brand Palette (Option 6: Obsidian & Ice Blue) ──────────────────────────
  static const Color primary = Color(0xFF38BDF8); // Electric Ice Blue
  static const Color secondary = Color(0xFF818CF8); // Indigo Cyan
  static const Color accent = Color(0xFF22D3EE); // Neon Cyan Glow

  // ── Light Surface ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Crisp Slate White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Soft Zinc Slate

  // ── Light Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF09090B); // Deep Obsidian Black
  static const Color textSecondary = Color(0xFF64748B); // Slate Muted
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFF000000); // Black text on ice blue
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF38BDF8);

  // ── Semantic Alerts ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF38BDF8); // Ice Blue
  static const Color infoLight = Color(0xFFE0F2FE);

  // ── Dark Mode Overrides (True AMOLED Pure Black & Obsidian) ────────────────
  static const Color darkBackground = Color(0xFF000000); // 100% True AMOLED Pitch Black
  static const Color darkSurface = Color(0xFF0C0C0E); // Deep Obsidian Card
  static const Color darkSurfaceVariant = Color(0xFF18181B); // Dark Zinc Charcoal
  static const Color darkBorder = Color(0xFF27272A); // Subtle Titanium Edge
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp Diamond White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate Muted
  static const Color darkTextOnPrimary = Color(0xFF000000);

  // ── Shadow ─────────────────────────────────────────────────────────────────
  static const Color shadow = Color(0x14000000); // 8% black
  static const Color shadowMedium = Color(0x1F000000); // 12% black

  // ─── ColorScheme Factories ──────────────────────────────────────────────────

  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: accent,
        onTertiary: Colors.black,
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
        onPrimary: darkTextOnPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: accent,
        onTertiary: Colors.black,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        error: error,
        onError: Colors.white,
      );
}
