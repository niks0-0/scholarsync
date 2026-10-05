import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/auth_provider.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../../../profile/domain/models/user_profile.dart';
import '../../../../profile/domain/repositories/profile_repository.dart';
import '../../../../profile/presentation/profile_provider.dart';
import '../../onboarding_provider.dart';

class CompletionStep extends StatelessWidget {
  const CompletionStep({
    super.key,
    required this.onPrevious,
  });

  final VoidCallback onPrevious;

  Future<void> _handleFinish(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final profileRepo = context.read<ProfileRepository>();

    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please sign in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = auth.currentUser!;
    final currentProfile = profileProvider.profile ??
        UserProfile(
          id: user.uid,
          email: user.email ?? '',
          fullName: onboarding.fullName.isNotEmpty ? onboarding.fullName : user.displayNameOrEmail,
          authProvider: 'password',
        );

    // Show step-by-step animated setup progression dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: Dialog(
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
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Setting Up ScholarSync...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _buildProgressItem('Creating student profile & avatar'),
                _buildProgressItem('Persisting master academic identity'),
                _buildProgressItem('Auto-enrolling semester subjects'),
                _buildProgressItem('Configuring notification reminders & theme'),
                _buildProgressItem('Preparing personal student workspace'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final updatedProfile = await onboarding.completeOnboarding(
        currentProfile: currentProfile,
        profileRepository: profileRepo,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog

      if (updatedProfile != null) {
        final completedProfile = updatedProfile.copyWith(onboardingCompleted: true);
        profileProvider.setProfile(completedProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Welcome to ScholarSync! Your student workspace is ready.'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        context.go('/home');
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
          SnackBar(
            content: Text('Error saving onboarding: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildProgressItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();

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
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  'Final Review & Verification',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Review your collected student information before initializing your workspace.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // ── Card 1: Account & Profile ─────────────────────────────────────
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

          // ── Card 2: Academic Institution ──────────────────────────────────
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

          // ── Card 3: Curriculum Identity ───────────────────────────────────
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

          // ── Card 4: Preferences & Legal ───────────────────────────────────
          _buildReviewSection(
            context,
            title: 'Preferences & Legal',
            icon: Icons.shield_rounded,
            onEdit: () => onboarding.setStep(4),
            children: [
              _buildSummaryRow(context, 'Notifications:', onboarding.notificationsEnabled ? 'Enabled (${onboarding.reminderPreference})' : 'Disabled'),
              _buildSummaryRow(context, 'App Theme:', onboarding.themePreference),
              _buildSummaryRow(
                context,
                'Verification:',
                onboarding.isEmailVerified
                    ? '✓ Instant Email Verified'
                    : (onboarding.idCardBytes != null ? '🛡️ ID Card Uploaded (Pending Review)' : 'Pending'),
              ),
              _buildSummaryRow(
                context,
                'Legal Terms:',
                onboarding.legalUndertakingAccepted ? '✓ Guarantee Accepted' : 'Pending',
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
                    onPrevious();
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: PrimaryButton(
                  label: 'Complete Setup & Launch',
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
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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
