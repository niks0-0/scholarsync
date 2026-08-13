import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/notification_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/error_message.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/social_login_button.dart';

/// Production Welcome / Onboarding screen.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _errorMessage = null);
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final success = await auth.signInWithGoogle();

    if (!mounted) return;

    if (!success) {
      if (auth.error != null && auth.error != 'Sign-in was cancelled.') {
        setState(() => _errorMessage = auth.error!);
      }
      return;
    }

    final user = auth.currentUser;
    if (user != null) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.authHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.spacingLg),

                  if (_errorMessage != null) ...[
                    ErrorMessage(
                      message: _errorMessage!,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                  ],

                  // ── Hero Illustration ─────────────────────────────────────────
                  _HeroIllustration(size: size),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // ── Logo ──────────────────────────────────────────────────────
                  const AppLogo(size: LogoSize.medium, animate: false),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // ── Headline & Copy ───────────────────────────────────────────
                  Text(
                    AppStrings.welcomeTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.spacingXxs),

                  Text(
                    AppStrings.welcomeTagline,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.spacingSm),

                  Text(
                    AppStrings.welcomeSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // ── Feature Pills ─────────────────────────────────────────────
                  _FeaturePills(),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // ── CTAs ──────────────────────────────────────────────────────
                  PrimaryButton(
                    label: AppStrings.welcomeGetStarted,
                    onPressed: auth.isLoading ? null : () => context.push('/register'),
                    icon: Icons.arrow_forward_rounded,
                  ),

                  const SizedBox(height: AppDimensions.spacingSm),

                  SecondaryButton(
                    label: AppStrings.welcomeSignIn,
                    onPressed: auth.isLoading ? null : () => context.push('/login'),
                  ),

                  const SizedBox(height: AppDimensions.spacingSm),

                  SocialLoginButton(
                    provider: SocialProvider.google,
                    onPressed: auth.isLoading ? null : _signInWithGoogle,
                    isLoading: auth.isLoading,
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size.height * 0.20,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _IconBadge(
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.secondary,
                  label: 'Schedule',
                ),
                SizedBox(width: AppDimensions.spacingMd),
                _IconBadge(
                  icon: Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  label: 'Study',
                  large: true,
                ),
                SizedBox(width: AppDimensions.spacingMd),
                _IconBadge(
                  icon: Icons.people_rounded,
                  color: AppColors.accent,
                  label: 'Connect',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    required this.label,
    this.large = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double size = large ? 52 : 40;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Icon(icon, color: color, size: size * 0.5),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeaturePills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.check_circle_rounded, 'Smart Scheduling'),
      (Icons.trending_up_rounded, 'Track Progress'),
      (Icons.notifications_active_rounded, 'Smart Alerts'),
    ];

    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingXs,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return _Pill(icon: f.$1, label: f.$2);
      }).toList(),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
