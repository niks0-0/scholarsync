import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Inline text link button used within body copy.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.underline = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool underline;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color effectiveColor = color ?? AppColors.secondary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        minimumSize: const Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXs,
          vertical: AppDimensions.spacingXxs,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppDimensions.iconSm, color: effectiveColor),
                const SizedBox(width: AppDimensions.spacingXs),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: effectiveColor,
                    fontWeight: FontWeight.w600,
                    decoration: underline ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: effectiveColor,
                  ),
                ),
              ],
            )
          : Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
                decoration: underline ? TextDecoration.underline : TextDecoration.none,
                decorationColor: effectiveColor,
              ),
            ),
    );
  }
}

