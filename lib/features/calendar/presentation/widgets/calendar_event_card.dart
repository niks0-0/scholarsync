import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';

class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final AcademicCalendarEvent event;
  final VoidCallback onTap;

  static const List<String> _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getEventColor(event.eventType);

    final start = event.startDate;
    final end = event.endDate;
    final dateStr = end == null || (start.year == end.year && start.month == end.month && start.day == end.day)
        ? '${_monthShort[start.month - 1]} ${start.day}, ${start.year}'
        : '${_monthShort[start.month - 1]} ${start.day} – ${_monthShort[end.month - 1]} ${end.day}, ${end.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.0,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Color Strip
              Container(
                width: 5,
                color: color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryBadge(context, event.eventType, color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          event.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (event.targetBranch != null || event.targetSemester != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: [
                            if (event.targetBranch != null)
                              _buildTargetChip(context, event.targetBranch!),
                            if (event.targetSemester != null)
                              _buildTargetChip(context, 'Sem ${event.targetSemester}'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, String eventType, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        eventType.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTargetChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'exam':
        return const Color(0xFFEF4444);
      case 'holiday':
        return const Color(0xFF10B981);
      case 'deadline':
        return const Color(0xFFF59E0B);
      case 'event':
      default:
        return const Color(0xFF818CF8);
    }
  }
}
