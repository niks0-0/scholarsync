import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/today_schedule_summary.dart';
import '../dashboard_provider.dart';
import 'dashboard_skeleton_loader.dart';

class TodayScheduleCard extends StatelessWidget {
  const TodayScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = context.watch<DashboardProvider>();

    if (dashboard.isScheduleLoading) {
      return const DashboardSkeletonLoader(height: 160);
    }

    final schedule = dashboard.schedule;

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
          InkWell(
            onTap: () => context.push('/timetable'),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Today's Classes",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '${schedule.length} Lectures',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          if (dashboard.scheduleError != null) ...[
            Text(dashboard.scheduleError!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
          ] else if (schedule.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available_rounded, size: 36, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      'No classes scheduled today.',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedule.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = schedule[index];
                return _buildScheduleItem(context, item);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, TodayScheduleSummary item) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Color badgeColor;
    String badgeText;

    switch (item.status) {
      case ClassStatus.current:
        badgeColor = AppColors.primary;
        badgeText = 'NOW';
        break;
      case ClassStatus.completed:
        badgeColor = AppColors.success;
        badgeText = 'COMPLETED';
        break;
      case ClassStatus.upcoming:
        badgeColor = colorScheme.onSurfaceVariant;
        badgeText = 'UPCOMING';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/timetable'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          decoration: BoxDecoration(
            color: item.status == ClassStatus.current
                ? AppColors.primary.withValues(alpha: 0.08)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: item.status == ClassStatus.current
                  ? AppColors.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
      child: Row(
        children: [
          // Time Column
          SizedBox(
            width: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.startTime,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  item.endTime,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 35, color: colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(width: AppDimensions.spacingMd),
          // Subject & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.subject,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: textTheme.labelSmall?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      item.isOnline ? Icons.computer_rounded : Icons.location_on_outlined,
                      size: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${item.room} • ${item.faculty}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
