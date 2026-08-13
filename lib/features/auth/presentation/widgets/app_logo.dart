import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

/// ScholarSync brand mark.
/// Shows an animated book icon with the app name wordmark.
class AppLogo extends StatefulWidget {
  const AppLogo({
    super.key,
    this.size = LogoSize.medium,
    this.showTagline = false,
    this.animate = false,
  });

  final LogoSize size;
  final bool showTagline;
  final bool animate;

  @override
  State<AppLogo> createState() => _AppLogoState();
}

enum LogoSize { small, medium, large }

class _AppLogoState extends State<AppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _iconSize {
    switch (widget.size) {
      case LogoSize.small:
        return AppDimensions.logoIconSize;
      case LogoSize.medium:
        return AppDimensions.logoIconSizeLg;
      case LogoSize.large:
        return AppDimensions.logoIconSizeXl;
    }
  }

  double get _appNameFontSize {
    switch (widget.size) {
      case LogoSize.small:
        return 18;
      case LogoSize.medium:
        return 24;
      case LogoSize.large:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon Container ───────────────────────────────────────────────
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: _iconSize * 0.55,
                color: AppColors.textOnPrimary,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            // ── App Name ─────────────────────────────────────────────────────
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Scholar',
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: _appNameFontSize,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Sync',
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: _appNameFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Tagline ───────────────────────────────────────────────────────
            if (widget.showTagline) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                AppStrings.appTagline,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

