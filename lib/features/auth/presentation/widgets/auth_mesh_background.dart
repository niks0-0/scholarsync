import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Ambient Animated Mesh Glow Background for Luxury AMOLED ScholarSync Auth Screens.
class AuthMeshBackground extends StatefulWidget {
  const AuthMeshBackground({
    super.key,
    required this.child,
    this.primaryGlowColor,
    this.secondaryGlowColor,
  });

  final Widget child;
  final Color? primaryGlowColor;
  final Color? secondaryGlowColor;

  @override
  State<AuthMeshBackground> createState() => _AuthMeshBackgroundState();
}

class _AuthMeshBackgroundState extends State<AuthMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryGlowColor ?? AppColors.primary;
    final secondaryColor = widget.secondaryGlowColor ?? AppColors.secondary;

    return Stack(
      children: [
        // 100% Pure AMOLED Pitch Black Base
        Container(color: const Color(0xFF000000)),

        // Animated Ambient Glowing Mesh Orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final dx1 = math.sin(t * math.pi) * 40;
            final dy1 = math.cos(t * math.pi) * 30;
            final dx2 = -math.cos(t * math.pi) * 50;
            final dy2 = -math.sin(t * math.pi) * 40;

            return Stack(
              children: [
                // Top-Right Cyan Glow Orb
                Positioned(
                  top: -80 + dy1,
                  right: -60 + dx1,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.18),
                          primaryColor.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Bottom-Left Indigo Violet Glow Orb
                Positioned(
                  bottom: -100 + dy2,
                  left: -80 + dx2,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          secondaryColor.withValues(alpha: 0.14),
                          secondaryColor.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Center Subtle Cyan Ambient Highlight
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.8],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Screen Content Foreground
        widget.child,
      ],
    );
  }
}
