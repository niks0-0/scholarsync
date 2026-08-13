import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

enum SocialProvider { google, apple }

/// Social login button (Google or Apple).
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
  });

  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;

  String get _label {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.apple:
        return 'Continue with Apple';
    }
  }

  IconData get _icon {
    switch (provider) {
      case SocialProvider.google:
        return Icons.g_mobiledata_rounded;
      case SocialProvider.apple:
        return Icons.apple_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: AppDimensions.buttonHeightMd,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(
            color: colorScheme.outline,
            width: AppDimensions.buttonBorderWidth,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.radiusMd),
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSurface),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icon,
                    size: AppDimensions.iconXl,
                    color: provider == SocialProvider.google
                        ? const Color(0xFF4285F4)
                        : colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Text(
                    _label,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

