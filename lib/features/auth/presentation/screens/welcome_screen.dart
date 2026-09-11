import 'dart:async';
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
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_mesh_background.dart';
import '../widgets/error_message.dart';
import '../widgets/quick_persona_sheet.dart';
import '../widgets/social_login_button.dart';

/// State-of-the-Art Luxury AMOLED Welcome / Onboarding Screen.
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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _pageTimer;
  String? _errorMessage;

  final List<({IconData icon, String title, String subtitle, Color color, List<String> tags})> _features = [
    (
      icon: Icons.auto_stories_rounded,
      title: 'Smart Academic Hub',
      subtitle: 'Curated semester notes, syllabus, PYQs & verified class documents.',
      color: const Color(0xFF38BDF8),
      tags: ['Notes Catalog', 'PYQ Bank', 'Syllabus'],
    ),
    (
      icon: Icons.calendar_month_rounded,
      title: 'Timetable & Attendance',
      subtitle: 'Intelligent schedule planner with 75% threshold safety alerts.',
      color: const Color(0xFF22D3EE),
      tags: ['Live Schedule', 'Safe Attendance', 'Alerts'],
    ),
    (
      icon: Icons.forum_rounded,
      title: 'Safe Campus Lounges',
      subtitle: 'Moderated peer-to-peer real-time chat with end-to-end security.',
      color: const Color(0xFF818CF8),
      tags: ['Study Groups', 'Anti-Spam', 'Real-Time'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _pageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _features.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _pageTimer?.cancel();
    _pageController.dispose();
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
      await context.read<NotificationProvider>().syncDeviceToken(user.uid);

      if (!mounted) return;
      final isOnboardingDone = profileProvider.profile?.onboardingCompleted ?? false;
      if (isOnboardingDone) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
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
    final size = MediaQuery.sizeOf(context);
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.authHorizontalPadding,
                      vertical: AppDimensions.spacingMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Top Bar with Logo & Demo Switcher ───────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const AppLogo(size: LogoSize.small, animate: false),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.appName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _openPersonaSheet,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                      'Quick Demo',
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
                          const SizedBox(height: AppDimensions.spacingMd),
                          ErrorMessage(
                            message: _errorMessage!,
                            onDismiss: () => setState(() => _errorMessage = null),
                          ),
                        ],

                        const Spacer(flex: 1),

                        // ── Hero Carousel Glass Card ────────────────────────────
                        SizedBox(
                          height: size.height * 0.32,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) => setState(() => _currentPage = index),
                            itemCount: _features.length,
                            itemBuilder: (context, index) {
                              final item = _features[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: AuthGlassCard(
                                  padding: const EdgeInsets.all(20),
                                  hasActiveGlow: _currentPage == index,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.color.withValues(alpha: 0.15),
                                          border: Border.all(color: item.color.withValues(alpha: 0.4), width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: item.color.withValues(alpha: 0.25),
                                              blurRadius: 18,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(item.icon, color: item.color, size: 28),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.subtitle,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.white.withValues(alpha: 0.7),
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        children: item.tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.06),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: item.color,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Carousel Indicator Dots ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_features.length, (index) {
                            final isActive = _currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 22 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),

                        const Spacer(flex: 1),

                        // ── Main Headline ───────────────────────────────────────
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.6,
                              height: 1.25,
                            ),
                            children: [
                              const TextSpan(text: 'Elevate Your '),
                              TextSpan(
                                text: 'Campus Journey\n',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: 'All academics, attendance & peers in one unified hub.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.65),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // ── Action Buttons ──────────────────────────────────────
                        // 1. Get Started Primary Button with Electric Cyan Gradient
                        Container(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightMd,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                blurRadius: 16,
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
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Started — It\'s Free',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 2. Sign In Frosted Secondary Button
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightMd,
                          child: OutlinedButton(
                            onPressed: auth.isLoading ? null : () => context.push('/login'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF141418),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF27272A), width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                            ),
                            child: const Text(
                              'Sign In to Account',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 3. Google One-Tap
                        SocialLoginButton(
                          provider: SocialProvider.google,
                          onPressed: auth.isLoading ? null : _signInWithGoogle,
                          isLoading: auth.isLoading,
                        ),

                        const SizedBox(height: AppDimensions.spacingSm),
                      ],
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
}
