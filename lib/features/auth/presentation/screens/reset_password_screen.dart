import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_mesh_background.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_button.dart';
import '../widgets/password_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/success_message.dart';

/// State-of-the-Art Luxury AMOLED Reset Password Screen.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  String _errorMessage = '';
  String _successMessage = '';
  bool _isLoading = false;
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() => _passwordValue = _passwordController.text);
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _successMessage = AppStrings.resetPasswordSuccess;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasMinLength = _passwordValue.length >= 8;
    final hasUppercase = _passwordValue.contains(RegExp(r'[A-Z]'));
    final hasNumber = _passwordValue.contains(RegExp(r'[0-9]'));
    final hasSpecial = _passwordValue.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AuthMeshBackground(
        primaryGlowColor: const Color(0xFF818CF8),
        secondaryGlowColor: const Color(0xFF38BDF8),
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
                      if (context.canPop())
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                          onPressed: () => context.pop(),
                          tooltip: 'Back',
                        )
                      else
                        const SizedBox(height: 20),

                      const SizedBox(height: 12),

                      // ── Shield Icon & Header ──────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(alpha: 0.25),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                size: 32,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.resetPasswordTitle,
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
                              AppStrings.resetPasswordSubtitle,
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

                            PasswordField(
                              label: AppStrings.fieldNewPassword,
                              hint: AppStrings.fieldNewPasswordHint,
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              textInputAction: TextInputAction.next,
                              validator: AppValidators.newPassword,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmFocus),
                            ),

                            const SizedBox(height: 10),

                            PasswordStrengthIndicator(password: _passwordValue),

                            if (_passwordValue.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildRequirementChip('8+ Chars', hasMinLength),
                                  _buildRequirementChip('Uppercase', hasUppercase),
                                  _buildRequirementChip('Number', hasNumber),
                                  _buildRequirementChip('Symbol', hasSpecial),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),

                            PasswordField(
                              label: AppStrings.fieldConfirmPassword,
                              hint: AppStrings.fieldConfirmPasswordHint,
                              controller: _confirmController,
                              focusNode: _confirmFocus,
                              textInputAction: TextInputAction.done,
                              validator: AppValidators.confirmPassword(_passwordController.text),
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => _submit(),
                            ),

                            const SizedBox(height: 20),

                            LoadingButton(
                              label: AppStrings.resetPasswordButton,
                              onPressed: _submit,
                              isLoading: _isLoading,
                              icon: Icons.check_rounded,
                            ),
                          ],
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

  Widget _buildRequirementChip(String label, bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: passed
            ? AppColors.success.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed
              ? AppColors.success.withValues(alpha: 0.5)
              : const Color(0xFF27272A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 11,
            color: passed ? AppColors.success : Colors.white38,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: passed ? AppColors.success : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
