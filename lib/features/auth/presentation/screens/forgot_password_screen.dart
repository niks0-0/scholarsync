import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_mesh_background.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_button.dart';
import '../widgets/success_message.dart';
import '../widgets/text_button_widget.dart';

/// State-of-the-Art Luxury AMOLED Forgot Password Screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.sendPasswordResetEmail(email: _emailController.text.trim());

    if (!mounted) return;
    if (auth.error != null) {
      setState(() => _errorMessage = auth.error!);
    } else {
      setState(() => _successMessage = AppStrings.forgotPasswordSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.authHorizontalPadding,
                  vertical: AppDimensions.spacingMd,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Back Button ───────────────────────────────────────
                      if (context.canPop())
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                          onPressed: () => context.pop(),
                          tooltip: 'Back to sign in',
                        )
                      else
                        const SizedBox(height: 20),

                      const SizedBox(height: 12),

                      // ── Header Brand & Icon ───────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.forgotPasswordTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.forgotPasswordSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.65),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Form Glass Card ───────────────────────────────────
                      AuthGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage.isNotEmpty) ...[
                              ErrorMessage(
                                message: _errorMessage,
                                onDismiss: () => setState(() => _errorMessage = ''),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_successMessage.isNotEmpty) ...[
                              SuccessMessage(
                                message: _successMessage,
                                onDismiss: () => setState(() => _successMessage = ''),
                              ),
                              const SizedBox(height: 16),
                            ],

                            AppTextField(
                              label: AppStrings.fieldEmail,
                              hint: AppStrings.fieldEmailHint,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: AppValidators.email,
                              autofillHints: const [AutofillHints.email],
                              prefixIcon: Icons.email_outlined,
                              onFieldSubmitted: (_) => _submit(),
                            ),

                            const SizedBox(height: 20),

                            LoadingButton(
                              label: AppStrings.forgotPasswordButton,
                              onPressed: _submit,
                              isLoading: auth.isLoading,
                              icon: Icons.send_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Back to Login CTA ─────────────────────────────────
                      Center(
                        child: AppTextButton(
                          label: AppStrings.forgotPasswordBackToLogin,
                          onPressed: () => context.pop(),
                          icon: Icons.arrow_back_rounded,
                        ),
                      ),
                    ],
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
