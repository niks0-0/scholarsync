import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/notification_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';
import '../widgets/app_logo.dart';

/// Clean, minimal, and fast-loading official Splash Screen for ScholarSync.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _introController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _introController.forward();

    // Session validation and route dispatch
    Future.delayed(const Duration(milliseconds: 1800), () async {
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
        await context.read<NotificationProvider>().syncDeviceToken(user.uid);

        if (!mounted) return;
        final profile = profileProvider.profile;
        if (profile?.role.isAdmin ?? false) {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } else {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoWidth = (size.width * 0.72).clamp(240.0, 340.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // ── Centered Official Full Brand Logo ──────────────────────
                  AppLogo(
                    variant: LogoVariant.full,
                    width: logoWidth,
                    isDark: isDark,
                  ),

                  const Spacer(flex: 2),

                  // ── Minimal Loading Indicator ──────────────────────────────
                  SizedBox(
                    width: 32,
                    height: 2.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFF1E2028),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
