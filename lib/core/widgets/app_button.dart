import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, text, tonal }
enum AppButtonSize { small, medium, large }

/// Clean Modern Minimalist Button Widget for ScholarSync.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSm;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMd;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLg;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 14.5;
      case AppButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget childContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? AppColors.textOnPrimary
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        if (!isLoading && suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(suffixIcon, size: 18),
        ],
      ],
    );

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            elevation: 0,
          ),
          child: childContent,
        );
        break;

      case AppButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: isDark
                ? const Color(0xFF1E2028)
                : const Color(0xFFE2E8F0),
            foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            elevation: 0,
          ),
          child: childContent,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
            side: BorderSide(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          child: childContent,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
          ),
          child: childContent,
        );
        break;

      case AppButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            foregroundColor: theme.colorScheme.primary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          child: childContent,
        );
        break;
    }

    return button;
  }
}
