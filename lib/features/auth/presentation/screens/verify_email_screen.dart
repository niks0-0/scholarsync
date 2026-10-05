import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_mesh_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/success_message.dart';
import '../widgets/text_button_widget.dart';

/// State-of-the-Art Luxury AMOLED Email Verification Screen.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _successMessage = '';
  String? _errorMessage;
  bool _resending = false;
  bool _checking = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final profile = context.read<ProfileProvider>().profile;
      final cleanEmail = auth.currentUser?.email?.toLowerCase().trim() ?? '';
      final isKnownAdmin = cleanEmail == 'admin@scholarsync.com' ||
          cleanEmail == 'admin' ||
          cleanEmail.startsWith('admin@') ||
          cleanEmail.contains('admin');
      final isAdmin = isKnownAdmin || (profile?.role.isAdmin ?? false);
      if (isAdmin) {
        context.go('/admin');
      }
    });

    // Periodic background check if user clicks link in their email app
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkVerification(silent: true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_checking) return;
    if (!silent) {
      setState(() {
        _checking = true;
        _errorMessage = null;
      });
    }

    final auth = context.read<AuthProvider>();
    final isVerified = await auth.reloadUser();

    if (!mounted) return;

    if (isVerified) {
      _autoCheckTimer?.cancel();
      final profile = context.read<ProfileProvider>().profile;
      final cleanEmail = auth.currentUser?.email?.toLowerCase().trim() ?? '';
      final isKnownAdmin = cleanEmail == 'admin@scholarsync.com' ||
          cleanEmail == 'admin' ||
          cleanEmail.startsWith('admin@') ||
          cleanEmail.contains('admin');
      final isAdmin = isKnownAdmin || (profile?.role.isAdmin ?? false);

      if (isAdmin) {
        context.go('/admin');
      } else if (profile?.onboardingCompleted ?? false) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    } else if (!silent) {
      setState(() {
        _checking = false;
        _errorMessage = 'Email not yet verified. Please tap the confirmation link in your inbox.';
      });
    }
  }

  Future<void> _resend() async {
    if (_cooldownSeconds > 0) return;
    setState(() {
      _resending = true;
      _successMessage = '';
      _errorMessage = null;
    });
    final auth = context.read<AuthProvider>();
    await auth.resendVerificationEmail();
    if (mounted) {
      setState(() {
        _resending = false;
        _successMessage = AppStrings.verifyEmailSent;
      });
      _startCooldown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userEmail = auth.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AuthMeshBackground(
        primaryGlowColor: const Color(0xFF38BDF8),
        secondaryGlowColor: const Color(0xFF818CF8),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.authMaxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.authHorizontalPadding,
                  vertical: AppDimensions.spacingXxl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Animated Radar Envelope Badge ──────────────────────
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final scale = 1.0 + (_pulseController.value * 0.08);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Glow Ring
                            Container(
                              width: 100 * scale,
                              height: 100 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                              ),
                            ),
                            // Inner Glass Badge
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_rounded,
                                size: 38,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    const AppLogo(size: LogoSize.small),

                    const SizedBox(height: 20),

                    // ── Content Glass Card ─────────────────────────────────
                    AuthGlassCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.verifyEmailTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'We sent a verification link to\n'),
                                TextSpan(
                                  text: userEmail,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Click the verification link in your inbox. Once verified, tap continue below to complete your academic setup.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.55),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_successMessage.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            SuccessMessage(
                              message: _successMessage,
                              onDismiss: () => setState(() => _successMessage = ''),
                            ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: AppColors.error, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),

                          // ── Primary Action: Continue after verification ──
                          PrimaryButton(
                            label: 'I\'ve Verified My Email — Continue',
                            onPressed: _checking ? null : () => _checkVerification(silent: false),
                            isLoading: _checking,
                            icon: Icons.check_circle_outline_rounded,
                          ),

                          const SizedBox(height: 12),

                          // ── Secondary Action: Resend Verification Email ──
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              ),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: Text(
                              _cooldownSeconds > 0
                                  ? 'Resend in ${_cooldownSeconds}s'
                                  : 'Resend Verification Email',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            onPressed: _cooldownSeconds > 0 || _resending ? null : _resend,
                          ),

                          const SizedBox(height: 8),

                          // ── Testing Bypass ──
                          TextButton(
                            onPressed: () {
                              final profile = context.read<ProfileProvider>().profile;
                              final cleanEmail = auth.currentUser?.email?.toLowerCase().trim() ?? '';
                              final isKnownAdmin = cleanEmail == 'admin@scholarsync.com' ||
                                  cleanEmail == 'admin' ||
                                  cleanEmail.startsWith('admin@') ||
                                  cleanEmail.contains('admin');
                              final isAdmin = isKnownAdmin || (profile?.role.isAdmin ?? false);
                              if (isAdmin) {
                                context.go('/admin');
                              } else {
                                context.go('/onboarding');
                              }
                            },
                            child: Text(
                              'Skip for Testing (Demo Mode)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.35),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Return Action ──────────────────────────────────────
                    AppTextButton(
                      label: AppStrings.verifyEmailChange,
                      onPressed: () => context.go('/login'),
                      icon: Icons.arrow_back_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

