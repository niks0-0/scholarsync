import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/notification_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_mesh_background.dart';
import '../widgets/error_message.dart';
import '../widgets/social_login_button.dart';

/// Clean, Modern & AMOLED-Optimized Welcome Screen.
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
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Don't sign out here — splash already handles routing returning users to /home.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting) return;
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      final auth = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();
      final success = await auth.signInWithGoogle();
      if (!mounted) return;
      if (!success) {
        if (auth.error != null && auth.error != 'Sign-in was cancelled.') {
          setState(() => _errorMessage = auth.error);
        }
        return;
      }
      final user = auth.currentUser;
      if (user != null) {
        try {
          await profileProvider
              .syncProfile(
                firebaseUid: user.uid,
                email: user.email ?? '',
                fullName: user.displayNameOrEmail,
                avatarUrl: user.photoUrl,
                authProvider: 'google.com',
              )
              .timeout(const Duration(seconds: 3));
        } catch (_) {}
        if (!mounted) return;
        try {
          await context.read<NotificationProvider>().syncDeviceToken(user.uid).timeout(const Duration(seconds: 2));
        } catch (_) {}
        if (!mounted) return;
        final profile = profileProvider.profile;
        final cleanEmail = (user.email ?? '').trim().toLowerCase();
        final isAdmin = cleanEmail.contains('admin') ||
            cleanEmail.startsWith('admin@') ||
            (profile?.role.isAdmin ?? false);
        if (isAdmin) {
          context.go('/admin');
        } else if (profile?.onboardingCompleted ?? false) {
          context.go('/home');
        } else {
          // Google user — skip to step 1 (college) since Google gives us the name
          context.go('/onboarding');
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AuthMeshBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimensions.authMaxWidth),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.authHorizontalPadding,
                        vertical: AppDimensions.spacingLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_errorMessage != null) ...[
                            ErrorMessage(
                              message: _errorMessage!,
                              onDismiss: () => setState(() => _errorMessage = null),
                            ),
                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 20),

                          // ── Logo Header ────────────────────────────────────────
                          const AppLogo(
                            size: LogoSize.large,
                            animate: true,
                          ),

                          const SizedBox(height: 16),


                          Text(
                            'Your unified student & academic hub.\nTrack attendance, access notes, timetable & campus community.',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 28),

                          // ── Feature Details Card ───────────────────────────────
                          AuthGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  icon: Icons.calendar_month_rounded,
                                  color: const Color(0xFF38BDF8),
                                  title: 'Timetable & Attendance Safety',
                                  subtitle: '75% attendance threshold alerts & lecture schedules.',
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(color: Color(0xFF27272A), height: 1),
                                ),
                                _buildDetailRow(
                                  icon: Icons.auto_stories_rounded,
                                  color: const Color(0xFF22D3EE),
                                  title: 'Academic Resources & Notes',
                                  subtitle: 'Curated semester notes, PYQs & syllabus bank.',
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(color: Color(0xFF27272A), height: 1),
                                ),
                                _buildDetailRow(
                                  icon: Icons.forum_rounded,
                                  color: const Color(0xFF818CF8),
                                  title: 'Campus Student Lounges',
                                  subtitle: 'Peer-to-peer discussions & verified student forums.',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Clear Action Prompt ────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Choose how you would like to proceed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Option 1: New User -> Onboarding ───────────────────
                          Container(
                            width: double.infinity,
                            height: AppDimensions.buttonHeightLg,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: (_isSubmitting || auth.isLoading) ? null : () => context.go('/onboarding'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "I'm New — Get Started",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.5,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Option 2: Registered User -> Login ─────────────────
                          Container(
                            width: double.infinity,
                            height: AppDimensions.buttonHeightLg,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              color: const Color(0xFF141418),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.2,
                              ),
                            ),
                            child: OutlinedButton(
                              onPressed: (_isSubmitting || auth.isLoading) ? null : () => context.push('/login'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded, size: 20, color: AppColors.primary),
                                  SizedBox(width: 10),
                                  Text(
                                    'Already Registered? Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.5,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── OR divider ─────────────────────────────────────────
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFF27272A))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFF27272A))),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Google One-Tap (fast-path for new & returning) ─────
                          SocialLoginButton(
                            provider: SocialProvider.google,
                            onPressed: _signInWithGoogle,
                            isLoading: _isSubmitting || auth.isLoading,
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
