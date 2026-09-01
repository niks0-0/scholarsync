import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../dashboard_provider.dart';
import 'dashboard_skeleton_loader.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = context.watch<DashboardProvider>();

    if (dashboard.isAttendanceLoading) {
      return const DashboardSkeletonLoader(height: 140);
    }

    final attendance = dashboard.attendance;

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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Attendance Summary',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                tooltip: 'Open Attendance',
                onPressed: () => context.push('/attendance'),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          if (dashboard.attendanceError != null) ...[
            Text(dashboard.attendanceError!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
          ] else if (attendance != null) ...[
            Row(
              children: [
                // Circular Progress Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: attendance.overallPercentage / 100,
                        strokeWidth: 7,
                        backgroundColor: colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          attendance.isWarning ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                    Text(
                      '${attendance.overallPercentage.toStringAsFixed(1)}%',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: attendance.isWarning ? AppColors.error : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppDimensions.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classes Attended: ${attendance.attendedClasses} / ${attendance.totalClasses}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendance.statusMessage,
                        style: textTheme.bodySmall?.copyWith(
                          color: attendance.isWarning ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Text('No attendance data available.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
