import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../auth_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/text_button_widget.dart';
import '../widgets/error_message.dart';
import '../widgets/success_message.dart';
import '../widgets/auth_scaffold.dart';

/// Forgot password screen — email input to receive reset link.
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
                tooltip: 'Back to sign in',
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
            // ── Lock icon ──────────────────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXxl),

            Text(
              AppStrings.forgotPasswordTitle,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            Text(
              AppStrings.forgotPasswordSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
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

            const SizedBox(height: AppDimensions.spacingXxl),

            LoadingButton(
              label: AppStrings.forgotPasswordButton,
              onPressed: _submit,
              isLoading: auth.isLoading,
              icon: Icons.send_rounded,
            ),

            const SizedBox(height: AppDimensions.spacingXxl),

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
    );
  }
}

