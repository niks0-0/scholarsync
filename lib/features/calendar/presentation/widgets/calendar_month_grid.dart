import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.events,
    required this.onSelectDate,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<AcademicCalendarEvent> events;
  final ValueChanged<DateTime> onSelectDate;

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    
    // ISO weekday: Monday = 1, Sunday = 7
    final startWeekday = firstDayOfMonth.weekday; // 1 to 7
    final prevMonthDays = DateTime(focusedMonth.year, focusedMonth.month, 0).day;

    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    final selectedClean = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Build grid cells (42 cells: 6 weeks x 7 days)
    final List<Widget> dayCells = [];

    // Weekday headers
    final headerRow = Row(
      children: _weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );

    // Days from previous month
    for (int i = startWeekday - 1; i > 0; i--) {
      final day = prevMonthDays - i + 1;
      final date = DateTime(focusedMonth.year, focusedMonth.month - 1, day);
      dayCells.add(_buildDateCell(
        context,
        date: date,
        dayNumber: day,
        isCurrentMonth: false,
        isToday: date == todayClean,
        isSelected: date == selectedClean,
      ));
    }

    // Days of current month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      dayCells.add(_buildDateCell(
        context,
        date: date,
        dayNumber: day,
        isCurrentMonth: true,
        isToday: date == todayClean,
        isSelected: date == selectedClean,
      ));
    }

    // Days from next month to complete the grid (multiples of 7)
    final remainingCells = (7 - (dayCells.length % 7)) % 7;
    for (int day = 1; day <= remainingCells; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month + 1, day);
      dayCells.add(_buildDateCell(
        context,
        date: date,
        dayNumber: day,
        isCurrentMonth: false,
        isToday: date == todayClean,
        isSelected: date == selectedClean,
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          headerRow,
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.85,
            children: dayCells,
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell(
    BuildContext context, {
    required DateTime date,
    required int dayNumber,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get events matching this date
    final dateClean = DateTime(date.year, date.month, date.day);
    final matchingEvents = events.where((e) {
      final start = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      if (e.endDate == null) return start == dateClean;
      final end = DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day);
      return !dateClean.isBefore(start) && !dateClean.isAfter(end);
    }).toList();

    return GestureDetector(
      onTap: () => onSelectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$dayNumber',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: (isToday || isSelected) ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? Colors.black
                      : (!isCurrentMonth
                          ? (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                ),
              ),
              const SizedBox(height: 2),
              // Event Dots
              if (matchingEvents.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: matchingEvents.take(3).map((e) {
                    return Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.black
                            : _getEventColor(e.eventType),
                      ),
                    );
                  }).toList(),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'exam':
        return const Color(0xFFEF4444); // Crimson
      case 'holiday':
        return const Color(0xFF10B981); // Emerald
      case 'deadline':
        return const Color(0xFFF59E0B); // Amber
      case 'event':
      default:
        return const Color(0xFF818CF8); // Indigo
    }
  }
}
