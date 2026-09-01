import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../dashboard_provider.dart';

class CompactStatisticsCard extends StatelessWidget {
  const CompactStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = context.watch<DashboardProvider>();

    final attendancePct = dashboard.attendance?.overallPercentage ?? 82.5;
    final pendingAssignments = dashboard.assignments.where((a) => !a.isCompleted).length;
    final todayLectures = dashboard.schedule.length;
    final upcomingEvents = dashboard.events.length;

    final stats = [
      _StatItem('Attendance', '${attendancePct.toStringAsFixed(0)}%', Icons.pie_chart_rounded, AppColors.success),
      _StatItem('Pending Tasks', '$pendingAssignments', Icons.assignment_late_outlined, AppColors.primary),
      _StatItem('Today Classes', '$todayLectures', Icons.schedule_rounded, Colors.orange),
      _StatItem('Upcoming Events', '$upcomingEvents', Icons.event_available_rounded, Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic Overview Statistics',
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
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.spacingSm,
            crossAxisSpacing: AppDimensions.spacingSm,
            childAspectRatio: 2.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          item.label,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}
