import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
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
  bool _resending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cooldownTimer?.cancel();
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

  Future<void> _resend() async {
    if (_cooldownSeconds > 0) return;
    setState(() {
      _resending = true;
      _successMessage = '';
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
                          Text(
                            AppStrings.verifyEmailSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.verifyEmailInstruction,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.55),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_successMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            SuccessMessage(
                              message: _successMessage,
                              onDismiss: () => setState(() => _successMessage = ''),
                            ),
                          ],
                          const SizedBox(height: 22),
                          PrimaryButton(
                            label: _cooldownSeconds > 0
                                ? 'Resend in ${_cooldownSeconds}s'
                                : AppStrings.verifyEmailResend,
                            onPressed: _cooldownSeconds > 0 ? null : _resend,
                            isLoading: _resending,
                            icon: Icons.send_rounded,
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
