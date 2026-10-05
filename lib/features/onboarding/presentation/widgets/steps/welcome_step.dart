import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/student_avatar.dart';
import '../../../../auth/auth_provider.dart';
import '../../../../auth/presentation/widgets/app_logo.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../../../profile/presentation/profile_provider.dart';
import '../../onboarding_provider.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final user = auth.currentUser;
    final profile = profileProvider.profile;

    final displayName = profile?.fullName ?? user?.displayNameOrEmail ?? 'Student';
    final avatarUrl = profile?.avatarUrl ?? user?.photoUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        children: [
          const AppLogo(variant: LogoVariant.full, width: 180),
          const SizedBox(height: AppDimensions.spacingXl),

          // Resume Draft Banner if local draft exists
          if (onboarding.hasDraftLoaded) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your ScholarSync setup is in progress. Continue where you left off?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      onboarding.clearDraftLocal();
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
          ],

          // User Avatar / Logo Badge
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: StudentAvatar(
              radius: 46,
              avatarUrl: avatarUrl,
              name: displayName,
              borderWidth: 2,
              borderColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          Text(
            'Welcome to ScholarSync, $displayName! 👋',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            'Your Professional Student Workspace',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _buildFeatureRow(
                  context,
                  icon: Icons.calendar_today_rounded,
                  title: 'Timetable & Class Schedules',
                  subtitle: 'Single source of truth for recurring academic classes.',
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                _buildFeatureRow(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Attendance Guard & Threshold Alerts',
                  subtitle: 'Track lecture attendance and receive warning notices.',
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                _buildFeatureRow(
                  context,
                  icon: Icons.menu_book_rounded,
                  title: 'Verified Course Notes Repository',
                  subtitle: 'Access college syllabus notes and exam preparation materials.',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxxl),

          PrimaryButton(
            label: onboarding.hasDraftLoaded ? 'Continue Guided Setup' : 'Get Started with Setup',
            onPressed: () {
              context.read<OnboardingProvider>().nextStep();
              onNext();
            },
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
