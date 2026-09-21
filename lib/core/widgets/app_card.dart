import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Clean Modern Minimalist Surface Card for ScholarSync.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg);
    final defaultBorderColor = borderColor ??
        (isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0));
    final defaultBgColor = backgroundColor ??
        (isDark ? const Color(0xFF121215) : Colors.white);

    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: defaultBgColor,
        borderRadius: defaultBorderRadius,
        border: Border.all(color: defaultBorderColor, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: defaultBorderRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
