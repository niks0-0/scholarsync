import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';

class CalendarWeekStrip extends StatelessWidget {
  const CalendarWeekStrip({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final List<AcademicCalendarEvent> events;
  final ValueChanged<DateTime> onSelectDate;

  static const List<String> _weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine the Monday of the selected week
    final currentWeekday = selectedDate.weekday; // 1 = Mon, 7 = Sun
    final monday = selectedDate.subtract(Duration(days: currentWeekday - 1));
    final weekDays = List.generate(7, (index) => monday.add(Duration(days: index)));

    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    final selectedClean = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((date) {
          final dateClean = DateTime(date.year, date.month, date.day);
          final isSelected = dateClean == selectedClean;
          final isToday = dateClean == todayClean;

          final hasEvents = events.any((e) {
            final start = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
            if (e.endDate == null) return start == dateClean;
            final end = DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day);
            return !dateClean.isBefore(start) && !dateClean.isAfter(end);
          });

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelectDate(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday
                          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _weekdayNames[date.weekday - 1],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.black
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${date.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.black
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasEvents
                            ? (isSelected ? Colors.black : AppColors.secondary)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
