import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/password_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/loading_button.dart';
import '../widgets/error_message.dart';
import '../widgets/success_message.dart';
import '../widgets/auth_scaffold.dart';

/// Reset password screen — new password + confirm.
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
    // TODO(Phase 2): Call Firebase confirmPasswordReset
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _successMessage = AppStrings.resetPasswordSuccess;
    });
    // Navigate to login after brief delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AuthScaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
                tooltip: 'Back',
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Shield icon ────────────────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 32,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXxl),

            Text(
              AppStrings.resetPasswordTitle,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            Text(
              AppStrings.resetPasswordSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXxxl),

            if (_errorMessage.isNotEmpty) ...[
              ErrorMessage(
                message: _errorMessage,
                onDismiss: () => setState(() => _errorMessage = ''),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],

            if (_successMessage.isNotEmpty) ...[
              SuccessMessage(
                message: _successMessage,
                onDismiss: () => setState(() => _successMessage = ''),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],

            PasswordField(
              label: AppStrings.fieldNewPassword,
              hint: AppStrings.fieldNewPasswordHint,
              controller: _passwordController,
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.next,
              validator: AppValidators.newPassword,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_confirmFocus),
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            PasswordStrengthIndicator(password: _passwordValue),

            const SizedBox(height: AppDimensions.authFormSpacing),

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

            const SizedBox(height: AppDimensions.spacingXxl),

            LoadingButton(
              label: AppStrings.resetPasswordButton,
              onPressed: _submit,
              isLoading: _isLoading,
              icon: Icons.check_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

