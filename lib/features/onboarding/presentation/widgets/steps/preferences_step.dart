import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/services/theme_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/widgets/primary_button.dart';
import '../../onboarding_provider.dart';

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
          Text(
            'Application Preferences',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Configure your default notification reminders and app appearance.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Notification Toggle
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Receive reminders for class timetables & deadlines',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: onboarding.notificationsEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => onboarding.setNotificationsEnabled(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Default Class Reminder Behavior
          Text(
            'Class & Assignment Reminder Window',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
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

          // Theme Preference (Integrates with existing ThemeService)
          Text(
            'Theme Preference',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  avatar: const Icon(Icons.brightness_auto_rounded, size: 18),
                  label: const Text('System'),
                  selected: themeService.mode == ThemeMode.system,
                  onSelected: (_) => themeService.setThemeMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: ChoiceChip(
                  avatar: const Icon(Icons.light_mode_rounded, size: 18),
                  label: const Text('Light'),
                  selected: themeService.mode == ThemeMode.light,
                  onSelected: (_) => themeService.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: ChoiceChip(
                  avatar: const Icon(Icons.dark_mode_rounded, size: 18),
                  label: const Text('Dark'),
                  selected: themeService.mode == ThemeMode.dark,
                  onSelected: (_) => themeService.setThemeMode(ThemeMode.dark),
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
