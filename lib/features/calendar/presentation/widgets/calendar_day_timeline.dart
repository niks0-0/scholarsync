import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';
import '../../../timetable/domain/models/timetable_entry.dart';
import '../../../timetable/presentation/timetable_provider.dart';

class CalendarDayTimeline extends StatelessWidget {
  const CalendarDayTimeline({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final List<AcademicCalendarEvent> events;
  final ValueChanged<AcademicCalendarEvent> onEventTap;

  static const List<String> _weekdayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timetable = context.watch<TimetableProvider>();

    // Filter timetable classes for the selected weekday
    final weekday = selectedDate.weekday; // 1 = Monday, 7 = Sunday
    final List<TimetableEntry> dayClasses =
        timetable.weeklySchedule.where((e) => e.weekday == weekday).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weekdayNames[weekday - 1]}, ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dayClasses.length} Scheduled Classes • ${events.length} Academic Events',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Day Schedule',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Academic Events on this date (if any)
        if (events.isNotEmpty) ...[
          Text(
            'Institutional Events & Deadlines',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...events.map((e) => _buildEventItem(context, e)),
          const SizedBox(height: 16),
        ],

        // Timetable Classes Timeline
        Text(
          'Class Schedule (08:00 – 18:00)',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),

        if (dayClasses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.weekend_rounded,
                  size: 40,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'No classes scheduled for this day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enjoy your free time or focus on revision.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...dayClasses.map((c) => _buildClassTimelineItem(context, c)),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, AcademicCalendarEvent event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (event.description != null && event.description!.isNotEmpty)
                    Text(
                      event.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTimelineItem(BuildContext context, TimetableEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  entry.startTime,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  entry.endTime,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Class details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.subjectName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (entry.subjectCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.subjectCode,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (entry.room.isNotEmpty) ...[
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.room,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (entry.facultyName != null) ...[
                      Icon(
                        Icons.person_outline_rounded,
                        size: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.facultyName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
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
