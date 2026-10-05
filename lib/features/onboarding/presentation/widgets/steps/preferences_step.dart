import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/theme_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';
import '../onboarding_classification_badge.dart';

class PreferencesStep extends StatelessWidget {
  const PreferencesStep({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  static const List<String> reminderOptions = [
    '5 minutes before',
    '15 minutes before',
    '30 minutes before',
    '1 hour before',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final onboarding = context.watch<OnboardingProvider>();
    final themeService = context.watch<ThemeService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Preferences',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const OnboardingClassificationBadge(level: ClassificationLevel.recommended),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Configure default notification reminder windows and application color theme.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Just-In-Time Push Notification Permission Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Push Notifications',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: onboarding.notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) async {
                        onboarding.setNotificationsEnabled(val);
                        if (val) {
                          await NotificationService.instance.initialize();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Just-In-Time Purpose: Receive 15-min class reminders, lecture room changes, assignment deadline alerts, and official college broadcasts.',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Default Class Reminder Behavior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class & Assignment Reminder Window',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const OnboardingClassificationBadge(level: ClassificationLevel.recommended),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: reminderOptions.map((opt) {
              final isSelected = onboarding.reminderPreference == opt;
              return ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => onboarding.setReminderPreference(opt),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Theme Preference
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Appearance Theme',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const OnboardingClassificationBadge(level: ClassificationLevel.optional),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  avatar: const Icon(Icons.brightness_auto_rounded, size: 18),
                  label: const Text('System'),
                  selected: themeService.mode == ThemeMode.system,
                  onSelected: (_) {
                    themeService.setThemeMode(ThemeMode.system);
                    onboarding.setThemePreference('System');
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: ChoiceChip(
                  avatar: const Icon(Icons.light_mode_rounded, size: 18),
                  label: const Text('Light'),
                  selected: themeService.mode == ThemeMode.light,
                  onSelected: (_) {
                    themeService.setThemeMode(ThemeMode.light);
                    onboarding.setThemePreference('Light');
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: ChoiceChip(
                  avatar: const Icon(Icons.dark_mode_rounded, size: 18),
                  label: const Text('Dark'),
                  selected: themeService.mode == ThemeMode.dark,
                  onSelected: (_) {
                    themeService.setThemeMode(ThemeMode.dark);
                    onboarding.setThemePreference('Dark');
                  },
                ),
              ),
            ],
          ),

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
                  label: 'Continue',
                  onPressed: () {
                    if (onboarding.nextStep()) {
                      onNext();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
