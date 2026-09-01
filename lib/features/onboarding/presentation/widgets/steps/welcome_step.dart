import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/auth_provider.dart';
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
    final user = auth.currentUser;
    final profile = profileProvider.profile;

    final displayName = profile?.fullName ?? user?.displayNameOrEmail ?? 'Student';
    final avatarUrl = profile?.avatarUrl ?? user?.photoUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingLg),
          // User Avatar / Logo Badge
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.transparent,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S',
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
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
            'Your Smart Academic Companion',
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
                  subtitle: 'Stay on top of your lectures and exam dates.',
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                _buildFeatureRow(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Attendance Tracker',
                  subtitle: 'Monitor attendance percentages effortlessly.',
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                _buildFeatureRow(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Assignments & Deadlines',
                  subtitle: 'Never miss a submission date again.',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxxl),

          PrimaryButton(
            label: 'Get Started with Setup',
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
                style: textTheme.bodyLarge?.copyWith(
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
