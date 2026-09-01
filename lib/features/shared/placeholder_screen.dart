import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';

/// Generic placeholder screen for upcoming student modules (Calendar, Community, Resources),
/// replacing temporary development test suites with a clean, branded preview interface.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    String subtitle;

    switch (title.toLowerCase()) {
      case 'calendar':
        icon = Icons.calendar_month_rounded;
        subtitle = 'Academic Event Calendar & Exam Schedule preview is active. Sync your timetable and deadlines below.';
        break;
      case 'community':
        icon = Icons.groups_rounded;
        subtitle = 'Student Community & Discussion Forums are arriving in Phase 17. Connect with peers from your branch.';
        break;
      case 'resources':
        icon = Icons.folder_shared_rounded;
        subtitle = 'Subject Notes, Syllabus Repositories & Study Materials catalog preview.';
        break;
      default:
        icon = Icons.auto_awesome_rounded;
        subtitle = 'ScholarSync student workspace module.';
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingXxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  icon,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              Text(
                '$title Workspace',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // Quick Access Action Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Quick Academic Shortcuts',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Wrap(
                      spacing: AppDimensions.spacingMd,
                      runSpacing: AppDimensions.spacingMd,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.push('/timetable'),
                          icon: const Icon(Icons.schedule_rounded),
                          label: const Text('Open Timetable'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/activities'),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('Academic Catalog'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('Home Dashboard'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
