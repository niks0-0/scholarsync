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

    // Show persistent saving dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF141418),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 20),
                Text(
                  'Finalizing Academic Identity...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Saving your verified profile and preparing your personal campus feed.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
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
        // Guarantee in-memory profile completion state
        final completedProfile = updatedProfile.copyWith(onboardingCompleted: true);
        profileProvider.setProfile(completedProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Welcome to ScholarSync! Your academic profile is ready.'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        // Smoothly route to home
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
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving onboarding: $e'),
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
                _buildSummaryRow(
                  context,
                  'Verification:',
                  onboarding.isEmailVerified
                      ? '✓ Instant Email Verified'
                      : (onboarding.idCardBytes != null
                          ? '🛡️ Queued for Admin Review'
                          : 'Pending Verification'),
                ),
                _buildSummaryRow(
                  context,
                  'Legal Terms:',
                  onboarding.legalUndertakingAccepted ? '✓ Self-Concern Guaranteed' : 'Pending',
                ),
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
