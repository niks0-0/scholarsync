import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/app_dimensions.dart';

/// Material 3 ThemeData factories for ScholarSync.
abstract final class AppTheme {
  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => _build(
        colorScheme: AppColors.lightColorScheme,
        textTheme: AppTypography.lightTextTheme,
        brightness: Brightness.light,
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => _build(
        colorScheme: AppColors.darkColorScheme,
        textTheme: AppTypography.darkTextTheme,
        brightness: Brightness.dark,
      );

  // ── Builder ───────────────────────────────────────────────────────────────
  static ThemeData _build({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Brightness brightness,
  }) {
    final bool isLight = brightness == Brightness.light;
    final Color bgColor =
        isLight ? AppColors.background : AppColors.darkBackground;
    final Color surfaceColor =
        isLight ? AppColors.surface : AppColors.darkSurface;
    final Color borderColor =
        isLight ? AppColors.border : AppColors.darkBorder;
    final Color textPrimary =
        isLight ? AppColors.textPrimary : AppColors.darkTextPrimary;
    final Color textSecondary =
        isLight ? AppColors.textSecondary : AppColors.darkTextSecondary;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      textTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: AppDimensions.elevationNone,
        scrolledUnderElevation: AppDimensions.elevationXs,
        shadowColor: AppColors.shadow,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: textPrimary),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.radiusMd),
            ),
          ),
          elevation: AppDimensions.elevationNone,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXxl,
            vertical: AppDimensions.spacingMd,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
          side: BorderSide(color: borderColor, width: AppDimensions.buttonBorderWidth),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.radiusMd),
            ),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXxl,
            vertical: AppDimensions.spacingMd,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: AppDimensions.spacingXs,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.radiusSm),
            ),
          ),
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.surfaceVariant : AppColors.darkSurfaceVariant,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingLg,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimensions.radiusMd),
          ),
          borderSide: BorderSide(color: borderColor, width: AppDimensions.textFieldBorderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimensions.radiusMd),
          ),
          borderSide: BorderSide(color: borderColor, width: AppDimensions.textFieldBorderWidth),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusMd),
          ),
          borderSide: BorderSide(
            color: AppColors.secondary,
            width: AppDimensions.textFieldFocusedBorderWidth,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusMd),
          ),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.textFieldBorderWidth,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusMd),
          ),
          borderSide: BorderSide(
            color: AppColors.error,
            width: AppDimensions.textFieldFocusedBorderWidth,
          ),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
        suffixIconColor: textSecondary,
        prefixIconColor: textSecondary,
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: AppDimensions.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimensions.radiusLg),
          ),
          side: BorderSide(color: borderColor, width: AppDimensions.cardBorderWidth),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.spacingXxl,
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? AppColors.surfaceVariant : AppColors.darkSurfaceVariant,
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppColors.textPrimary : AppColors.darkSurfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusMd)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── ProgressIndicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: CircleBorder(),
        elevation: AppDimensions.elevationMd,
      ),

      // ── Icon ───────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: textSecondary,
        size: AppDimensions.iconLg,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: AppDimensions.iconLg,
      ),

      // ── Page Transitions ───────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

