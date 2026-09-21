import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../calendar_provider.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.focusedMonth,
    required this.viewMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onViewModeChanged,
  });

  final DateTime focusedMonth;
  final CalendarViewMode viewMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<CalendarViewMode> onViewModeChanged;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final monthStr = '${_monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

    return Column(
      children: [
        Row(
          children: [
            // Month & Year title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthStr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Academic Session 2026–2027',
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

            // Navigation Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: 'Previous Month',
                  visualDensity: VisualDensity.compact,
                ),
                OutlinedButton(
                  onPressed: onToday,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                  child: const Text('Today', style: TextStyle(fontSize: 12)),
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: 'Next Month',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // View Mode Toggle Segment
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _buildViewTab(
                context,
                title: 'Month Grid',
                mode: CalendarViewMode.month,
                isSelected: viewMode == CalendarViewMode.month,
              ),
              _buildViewTab(
                context,
                title: 'Week View',
                mode: CalendarViewMode.week,
                isSelected: viewMode == CalendarViewMode.week,
              ),
              _buildViewTab(
                context,
                title: 'Day Schedule',
                mode: CalendarViewMode.day,
                isSelected: viewMode == CalendarViewMode.day,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewTab(
    BuildContext context, {
    required String title,
    required CalendarViewMode mode,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => onViewModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
