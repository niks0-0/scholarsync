import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../domain/models/reminder_summary.dart';
import '../dashboard_provider.dart';
import 'dashboard_skeleton_loader.dart';

class RemindersSummaryCard extends StatelessWidget {
  const RemindersSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = context.watch<DashboardProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.uid ?? '';

    if (dashboard.isRemindersLoading) {
      return const DashboardSkeletonLoader(height: 120);
    }

    final reminders = dashboard.reminders;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
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
                  const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Reminders',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${reminders.where((r) => !r.isCompleted).length} Active',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          if (dashboard.remindersError != null) ...[
            Text(dashboard.remindersError!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
          ] else if (reminders.isEmpty) ...[
            Text('No active reminders.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rem = reminders[index];
                return _buildReminderTile(context, dashboard, uid, rem);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    DashboardProvider dashboard,
    String uid,
    ReminderSummary rem,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Checkbox.adaptive(
            value: rem.isCompleted,
            activeColor: AppColors.success,
            onChanged: (val) {
              if (val != null) {
                dashboard.toggleReminder(uid, rem.id, val);
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rem.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rem.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                    decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  rem.reminderTime,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
