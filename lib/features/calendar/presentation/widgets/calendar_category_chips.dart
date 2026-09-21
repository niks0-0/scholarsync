import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CalendarCategoryChips extends StatelessWidget {
  const CalendarCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  static const _categories = [
    ('all', 'All Events', Icons.grid_view_rounded, AppColors.primary),
    ('exam', 'Exams', Icons.assignment_late_rounded, Color(0xFFEF4444)),
    ('deadline', 'Deadlines', Icons.timer_outlined, Color(0xFFF59E0B)),
    ('holiday', 'Holidays', Icons.beach_access_rounded, Color(0xFF10B981)),
    ('event', 'Campus Events', Icons.celebration_rounded, Color(0xFF818CF8)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = selectedCategory == cat.$1;
          final color = cat.$4;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                cat.$3,
                size: 15,
                color: isSelected ? Colors.white : color,
              ),
              label: Text(cat.$2),
              selected: isSelected,
              onSelected: (_) => onSelectCategory(cat.$1),
              backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              selectedColor: color,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? color
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }
}
