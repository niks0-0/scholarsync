import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Frosted Obsidian Glassmorphism Container with 1px Titanium Border Rim Lighting.
class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spacingXl),
    this.margin,
    this.borderRadius = AppDimensions.radiusXl,
    this.hasActiveGlow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool hasActiveGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: hasActiveGlow
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.5),
            blurRadius: hasActiveGlow ? 24 : 16,
            spreadRadius: hasActiveGlow ? 1 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0E).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: hasActiveGlow
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : const Color(0xFF27272A),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
