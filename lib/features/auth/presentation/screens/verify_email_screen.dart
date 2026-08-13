import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_button_widget.dart';
import '../widgets/success_message.dart';
import '../widgets/auth_scaffold.dart';

/// Verify email screen — shown after registration.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _successMessage = '';
  bool _resending = false;

  Future<void> _resend() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AuthScaffold(
      centerContent: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Envelope icon ─────────────────────────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              size: 40,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          const AppLogo(size: LogoSize.small),

          const SizedBox(height: AppDimensions.spacingXxxl),

          Text(
            AppStrings.verifyEmailTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            AppStrings.verifyEmailSubtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            AppStrings.verifyEmailInstruction,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingXxxl),

          if (_successMessage.isNotEmpty) ...[
            SuccessMessage(
              message: _successMessage,
              onDismiss: () => setState(() => _successMessage = ''),
            ),
            const SizedBox(height: AppDimensions.spacingXxl),
          ],

          PrimaryButton(
            label: AppStrings.verifyEmailResend,
            onPressed: _resend,
            isLoading: _resending,
            icon: Icons.send_rounded,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          AppTextButton(
            label: AppStrings.verifyEmailChange,
            onPressed: () => context.go('/register'),
          ),
        ],
      ),
    );
  }
}

