import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final actions = [
      _QuickActionItem(
        icon: Icons.assignment_add,
        label: 'Add Assignment',
        route: '/activities',
      ),
      _QuickActionItem(
        icon: Icons.add_alarm_rounded,
        label: 'Add Reminder',
        route: '/timetable',
      ),
      _QuickActionItem(
        icon: Icons.note_add_outlined,
        label: 'Add Note',
        route: '/activities',
      ),
      _QuickActionItem(
        icon: Icons.calendar_view_week_rounded,
        label: 'Open Timetable',
        route: '/timetable',
      ),
      _QuickActionItem(
        icon: Icons.fact_check_outlined,
        label: 'Open Attendance',
        route: '/timetable',
      ),
      _QuickActionItem(
        icon: Icons.calendar_month_rounded,
        label: 'Open Calendar',
        route: '/calendar',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppDimensions.spacingSm,
            crossAxisSpacing: AppDimensions.spacingSm,
            childAspectRatio: 1.05,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final item = actions[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(item.route),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: AppColors.primary, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
