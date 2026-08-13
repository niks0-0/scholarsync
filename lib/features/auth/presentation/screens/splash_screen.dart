import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/notification_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';

/// Animated splash screen shown at app launch.
/// Auto-navigates to /welcome after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _controller.forward();

    // Auto-navigate after logo animation settles (check auth state)
    Future.delayed(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();

      if (auth.isAuthenticated && auth.currentUser != null) {
        final user = auth.currentUser!;
        await profileProvider.syncProfile(
          firebaseUid: user.uid,
          email: user.email ?? '',
          fullName: user.displayNameOrEmail,
          avatarUrl: user.photoUrl,
          authProvider: 'google.com',
        );
        if (!mounted) return;

        // Sync FCM device token to Supabase public.user_devices
        await context.read<NotificationProvider>().syncDeviceToken(user.uid);

        if (!mounted) return;
        context.go('/home');
      } else {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo Icon ──────────────────────────────────────────────────
                Container(
                  width: AppDimensions.logoIconSizeXl + 16,
                  height: AppDimensions.logoIconSizeXl + 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: AppDimensions.logoIconSizeXl * 0.6,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXxl),

                // ── App Name ───────────────────────────────────────────────────
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Scholar',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      TextSpan(
                        text: 'Sync',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB8F5EE),
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingSm),

                Text(
                  AppStrings.appTagline,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingGiant),

                // ── Loading dots ───────────────────────────────────────────────
                const _PulsingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            final double delay = i * 0.15;
            final double t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final double opacity = Curves.easeInOut.transform(t);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4 + opacity * 0.6),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

