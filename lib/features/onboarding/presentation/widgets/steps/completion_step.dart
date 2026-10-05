import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../auth/auth_provider.dart';
import '../../../../auth/presentation/widgets/app_text_field.dart';
import '../../../../auth/presentation/widgets/password_field.dart';
import '../../../../auth/presentation/widgets/password_strength_indicator.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../../../notifications/presentation/notification_provider.dart';
import '../../../../profile/domain/models/user_profile.dart';
import '../../../../profile/domain/repositories/profile_repository.dart';
import '../../../../profile/presentation/profile_provider.dart';
import '../../onboarding_provider.dart';

class CompletionStep extends StatefulWidget {
  const CompletionStep({super.key, required this.onPrevious});
  final VoidCallback onPrevious;

  @override
  State<CompletionStep> createState() => _CompletionStepState();
}

class _CompletionStepState extends State<CompletionStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(
      () => setState(() => _passwordValue = _passwordController.text),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleFinish(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final profileRepo = context.read<ProfileRepository>();

    // --- Email flow: register first ---
    if (!onboarding.isGoogleUser) {
      if (!_formKey.currentState!.validate()) return;

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: _LoadingDialog(message: 'Creating your account...'),
        ),
      );

      final success = await auth.registerWithEmail(
        fullName: onboarding.fullName,
        email: email,
        password: password,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Registration failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final user = auth.currentUser!;
      try {
        await profileProvider
            .syncProfile(
              firebaseUid: user.uid,
              email: user.email ?? email,
              fullName: onboarding.fullName,
              avatarUrl: null,
              authProvider: 'password',
            )
            .timeout(const Duration(seconds: 4));
      } catch (_) {}

      try {
        await auth.resendVerificationEmail().timeout(const Duration(seconds: 3));
      } catch (_) {}

      if (!context.mounted) return;
      try {
        await context.read<NotificationProvider>().syncDeviceToken(user.uid).timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    // --- Common: save full academic profile ---
    if (!context.mounted) return;
    final user = auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please sign in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentProfile = profileProvider.profile ??
        UserProfile(
          id: user.uid,
          email: user.email ?? '',
          fullName: onboarding.fullName.isNotEmpty ? onboarding.fullName : user.displayNameOrEmail,
          authProvider: onboarding.isGoogleUser ? 'google.com' : 'password',
        );

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: _LoadingDialog(
          message: 'Setting Up ScholarSync...',
          items: [
            'Creating student profile & avatar',
            'Persisting master academic identity',
            'Auto-enrolling semester subjects',
            'Configuring notification reminders & theme',
            'Preparing personal student workspace',
          ],
        ),
      ),
    );

    try {
      final updatedProfile = await onboarding.completeOnboarding(
        currentProfile: currentProfile,
        profileRepository: profileRepo,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (updatedProfile != null) {
        profileProvider.setProfile(updatedProfile.copyWith(onboardingCompleted: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Welcome to ScholarSync! Your workspace is ready.')),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        if (onboarding.isGoogleUser) {
          context.go('/home');
        } else {
          context.go('/verify-email');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(onboarding.error ?? 'Failed to finalize profile. Please retry.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();
    final isGoogle = onboarding.isGoogleUser;

    final hasMin = _passwordValue.length >= 8;
    final hasUpper = _passwordValue.contains(RegExp(r'[A-Z]'));
    final hasNum = _passwordValue.contains(RegExp(r'[0-9]'));
    final hasSpecial = _passwordValue.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 2),
                  ),
                  child: const Icon(Icons.task_alt_rounded, size: 48, color: AppColors.success),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  isGoogle ? 'Final Review & Confirmation' : 'Create Your Account',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  isGoogle
                      ? 'Review your collected student information before initializing your workspace.'
                      : 'Set your email and password to secure your ScholarSync account.',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Email/Password form for non-Google users ───────────────────────
          if (!isGoogle) ...[
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: AppValidators.email,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      label: 'Password',
                      hint: 'Create a strong password',
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      validator: AppValidators.password,
                    ),
                    const SizedBox(height: 8),
                    PasswordStrengthIndicator(password: _passwordValue),
                    if (_passwordValue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip('8+ Chars', hasMin),
                          _chip('Uppercase', hasUpper),
                          _chip('Number', hasNum),
                          _chip('Symbol', hasSpecial),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    PasswordField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      controller: _confirmController,
                      textInputAction: TextInputAction.done,
                      validator: AppValidators.confirmPassword(_passwordController.text),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXxl),
          ],

          // ── Review cards ───────────────────────────────────────────────────
          _buildReviewSection(
            context,
            title: 'Account & Profile',
            icon: Icons.person_rounded,
            onEdit: () => onboarding.setStep(3),
            children: [
              _buildSummaryRow(context, 'Full Name:', onboarding.fullName),
              if (onboarding.bio.isNotEmpty)
                _buildSummaryRow(context, 'Student Bio:', onboarding.bio),
              if (onboarding.selectedInterests.isNotEmpty)
                _buildSummaryRow(context, 'Interests:', onboarding.selectedInterests.join(', ')),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          _buildReviewSection(
            context,
            title: 'Academic Institution',
            icon: Icons.account_balance_rounded,
            onEdit: () => onboarding.setStep(1),
            children: [
              _buildSummaryRow(context, 'College:', onboarding.selectedCollege?.name ?? 'Custom Institution'),
              if (onboarding.selectedState != null)
                _buildSummaryRow(context, 'State:', onboarding.selectedState!.name),
              if (onboarding.selectedUniversity != null)
                _buildSummaryRow(context, 'University:', onboarding.selectedUniversity!.name),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          _buildReviewSection(
            context,
            title: 'Curriculum Identity',
            icon: Icons.school_rounded,
            onEdit: () => onboarding.setStep(2),
            children: [
              _buildSummaryRow(context, 'Branch:', onboarding.branch),
              _buildSummaryRow(context, 'Academic Year:', onboarding.academicYear),
              _buildSummaryRow(context, 'Semester:', 'Semester ${onboarding.semester}'),
              _buildSummaryRow(context, 'Division:', 'Division ${onboarding.division}'),
              if (onboarding.rollNumber.isNotEmpty)
                _buildSummaryRow(context, 'Roll Number:', onboarding.rollNumber),
              if (onboarding.enrollmentNumber.isNotEmpty)
                _buildSummaryRow(context, 'Enrollment #:', onboarding.enrollmentNumber),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          _buildReviewSection(
            context,
            title: 'Preferences & Legal',
            icon: Icons.shield_rounded,
            onEdit: () => onboarding.setStep(4),
            children: [
              _buildSummaryRow(
                context,
                'Notifications:',
                onboarding.notificationsEnabled ? 'Enabled (${onboarding.reminderPreference})' : 'Disabled',
              ),
              _buildSummaryRow(context, 'App Theme:', onboarding.themePreference),
              _buildSummaryRow(
                context,
                'Verification:',
                onboarding.isEmailVerified
                    ? 'Instant Email Verified'
                    : (onboarding.idCardBytes != null ? 'ID Card Uploaded' : 'Pending'),
              ),
              _buildSummaryRow(
                context,
                'Legal Terms:',
                onboarding.legalUndertakingAccepted ? 'Guarantee Accepted' : 'Pending',
              ),
            ],
          ),

          if (onboarding.error != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      onboarding.error!,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingXxxl),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    onboarding.previousStep();
                    widget.onPrevious();
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: PrimaryButton(
                  label: isGoogle ? 'Complete Setup & Launch' : 'Create Account & Launch',
                  isLoading: onboarding.isLoading,
                  onPressed: () => _handleFinish(context),
                  icon: Icons.rocket_launch_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool passed) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: passed ? AppColors.success.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: passed ? AppColors.success.withValues(alpha: 0.5) : const Color(0xFF27272A),
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

  Widget _buildReviewSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppDimensions.spacingLg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple loading dialog used in both registration and profile-save phases.
class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog({required this.message, this.items});
  final String message;
  final List<String>? items;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F1218),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: Color(0xFF27272A)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (items != null) ...[
              const SizedBox(height: 12),
              ...items!.map(
                (label) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
