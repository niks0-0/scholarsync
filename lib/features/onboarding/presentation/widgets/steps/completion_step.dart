import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/auth_provider.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
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
    final currentProfile = profileProvider.profile;

    if (currentProfile == null || auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session error. Please sign in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updatedProfile = await onboarding.completeOnboarding(
      currentProfile: currentProfile,
      profileRepository: profileRepo,
    );

    if (context.mounted) {
      if (updatedProfile != null) {
        // Refresh authenticated profile state in ProfileProvider
        await profileProvider.syncProfile(
          firebaseUid: auth.currentUser!.uid,
          email: auth.currentUser!.email ?? '',
          fullName: updatedProfile.fullName,
          avatarUrl: updatedProfile.avatarUrl,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Onboarding completed successfully! Welcome to ScholarSync.'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate to home screen
          context.go('/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(onboarding.error ?? 'Failed to complete onboarding. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                    size: 50,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  'All Set! Review Your Profile',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Verify your student profile details before finalizing onboarding.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Summary',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Divider(height: AppDimensions.spacingLg),
                _buildSummaryRow(context, 'Full Name:', onboarding.fullName),
                _buildSummaryRow(context, 'College:', onboarding.selectedCollege?.name ?? 'Not selected'),
                _buildSummaryRow(context, 'Branch:', onboarding.branch),
                _buildSummaryRow(context, 'Semester:', 'Semester ${onboarding.semester}'),
                _buildSummaryRow(context, 'Division:', 'Division ${onboarding.division}'),
                _buildSummaryRow(context, 'Reminders:', onboarding.reminderPreference),
                _buildSummaryRow(context, 'Notifications:', onboarding.notificationsEnabled ? 'Enabled' : 'Disabled'),
              ],
            ),
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
                  label: 'Finish & Go to Home',
                  isLoading: onboarding.isLoading,
                  onPressed: () => _handleFinish(context),
                  icon: Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
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
