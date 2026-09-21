import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';

class EventDetailModal extends StatelessWidget {
  const EventDetailModal({
    super.key,
    required this.event,
  });

  final AcademicCalendarEvent event;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final start = event.startDate;
    final end = event.endDate;
    final dateStr = end == null || (start.year == end.year && start.month == end.month && start.day == end.day)
        ? '${_monthNames[start.month - 1]} ${start.day}, ${start.year}'
        : '${_monthNames[start.month - 1]} ${start.day} – ${_monthNames[end.month - 1]} ${end.day}, ${end.year}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header: Category Pill & Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.eventType.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            event.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Date Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          if (event.description != null && event.description!.isNotEmpty) ...[
            Text(
              'About this Event',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Target Branch / Semester
          if (event.targetBranch != null || event.targetSemester != null) ...[
            Text(
              'Target Audience',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (event.targetBranch != null)
                  Chip(
                    label: Text(event.targetBranch!),
                    avatar: const Icon(Icons.school_outlined, size: 16),
                  ),
                if (event.targetSemester != null)
                  Chip(
                    label: Text('Semester ${event.targetSemester}'),
                    avatar: const Icon(Icons.layers_outlined, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder set for this academic event!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Set Reminder Alert'),
            ),
          ),
        ],
      ),
    );
  }
}
