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
import '../widgets/quick_persona_sheet.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        if (auth.isAuthenticated) {
          auth.signOut();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openPersonaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickPersonaSheet(
        onSelectCredentials: (email, password, label) async {
          final auth = context.read<AuthProvider>();
          final profileProvider = context.read<ProfileProvider>();

          final success = await auth.signInWithEmail(email: email, password: password);
          if (!mounted) return;

          if (success) {
            final user = auth.currentUser;
            if (user != null) {
              await profileProvider.syncProfile(
                firebaseUid: user.uid,
                email: user.email ?? email,
                fullName: user.displayNameOrEmail,
                avatarUrl: user.photoUrl,
                authProvider: 'password',
              );
              if (!mounted) return;
              await context.read<NotificationProvider>().syncDeviceToken(user.uid);
            }
            if (!mounted) return;
            if (profileProvider.profile?.role.isAdmin ?? false) {
              context.go('/admin');
            } else {
              context.go('/home');
            }
          } else {
            setState(() => _errorMessage = auth.error ?? 'Demo sign-in failed');
          }
        },
      ),
    );
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
                          // ── Top Header Row ────────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: _openPersonaSheet,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        '⚡ Quick Demo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            ErrorMessage(
                              message: _errorMessage!,
                              onDismiss: () => setState(() => _errorMessage = null),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ── Logo Header ────────────────────────────────────────
                          const AppLogo(
                            size: LogoSize.large,
                            animate: true,
                          ),

                          const SizedBox(height: 20),

                          // ── Title & App Details ────────────────────────────────
                          const Text(
                            'ScholarSync',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

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

                          // ── Next / Get Started Button (Leads to Registration) ─
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
                              onPressed: auth.isLoading ? null : () => context.push('/register'),
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
                                  Text(
                                    'Next — Get Started',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Existing User Sign In Link ─────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                              InkWell(
                                onTap: () => context.push('/login'),
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
