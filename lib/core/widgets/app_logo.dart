import 'package:flutter/material.dart';

enum LogoSize { small, medium, large }
enum LogoVariant { full, compact, icon }

/// Centralized Official ScholarSync Brand Logo Widget.
/// Renders the approved ScholarSync branding assets faithfully across light and dark contexts.
class AppLogo extends StatefulWidget {
  const AppLogo({
    super.key,
    this.size = LogoSize.medium,
    this.variant = LogoVariant.full,
    this.isDark,
    this.width,
    this.height,
    this.showTagline = true,
    this.animate = false,
  });

  final LogoSize size;
  final LogoVariant variant;
  final bool? isDark;
  final double? width;
  final double? height;
  final bool showTagline;
  final bool animate;

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
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

  double get _defaultWidth {
    if (widget.width != null) return widget.width!;
    switch (widget.size) {
      case LogoSize.small:
        return widget.variant == LogoVariant.icon ? 36 : 130;
      case LogoSize.medium:
        return widget.variant == LogoVariant.icon ? 56 : 200;
      case LogoSize.large:
        return widget.variant == LogoVariant.icon ? 84 : 280;
    }
  }

  String _getAssetPath(bool isDarkMode) {
    switch (widget.variant) {
      case LogoVariant.full:
        return isDarkMode
            ? 'assets/branding/scholarsync_logo_dark.png'
            : 'assets/branding/scholarsync_logo_light.png';
      case LogoVariant.compact:
        return isDarkMode
            ? 'assets/branding/scholarsync_wordmark_dark.png'
            : 'assets/branding/scholarsync_wordmark_light.png';
      case LogoVariant.icon:
        return isDarkMode
            ? 'assets/branding/scholarsync_icon_dark.png'
            : 'assets/branding/scholarsync_icon_light.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool darkMode =
        widget.isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final String assetPath = _getAssetPath(darkMode);
    final double targetWidth = _defaultWidth;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: targetWidth,
            maxHeight: widget.height ?? double.infinity,
          ),
          child: Image.asset(
            assetPath,
            width: targetWidth,
            height: widget.height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'SCHOLARSYNC',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: targetWidth * 0.1,
                  color: darkMode ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
