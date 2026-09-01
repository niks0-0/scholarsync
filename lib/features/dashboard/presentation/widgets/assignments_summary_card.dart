import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../domain/models/assignment_summary.dart';
import '../dashboard_provider.dart';
import 'dashboard_skeleton_loader.dart';

class AssignmentsSummaryCard extends StatelessWidget {
  const AssignmentsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = context.watch<DashboardProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUser?.uid ?? '';

    if (dashboard.isAssignmentsLoading) {
      return const DashboardSkeletonLoader(height: 150);
    }

    final assignments = dashboard.assignments;

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
                  const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Assignments',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${assignments.where((a) => !a.isCompleted).length} Pending',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          if (dashboard.assignmentsError != null) ...[
            Text(dashboard.assignmentsError!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
          ] else if (assignments.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_rounded, size: 36, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      'No upcoming assignments due.',
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
              itemCount: assignments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return _buildAssignmentTile(context, dashboard, uid, assignment);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(
    BuildContext context,
    DashboardProvider dashboard,
    String uid,
    AssignmentSummary assignment,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Color priorityColor;
    switch (assignment.priority) {
      case AssignmentPriority.urgent:
        priorityColor = AppColors.error;
        break;
      case AssignmentPriority.high:
        priorityColor = Colors.orange;
        break;
      case AssignmentPriority.medium:
        priorityColor = AppColors.primary;
        break;
      case AssignmentPriority.low:
        priorityColor = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Checkbox.adaptive(
            value: assignment.isCompleted,
            activeColor: AppColors.success,
            onChanged: (val) {
              if (val != null) {
                dashboard.toggleAssignment(uid, assignment.id, val);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: assignment.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                    decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        assignment.subject,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        assignment.priority.name.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
