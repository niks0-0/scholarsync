import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/subject_attendance.dart';

class SubjectAttendanceCard extends StatelessWidget {
  const SubjectAttendanceCard({
    super.key,
    required this.subject,
    required this.onMarkPresent,
    required this.onMarkAbsent,
    required this.onUndo,
  });

  final SubjectAttendance subject;
  final VoidCallback onMarkPresent;
  final VoidCallback onMarkAbsent;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSafe = subject.isSafe;
    final color = isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final safeBunks = subject.safeBunksCount;
    final requiredClasses = subject.requiredClassesCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Subject Code, Name & Percentage Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subject.subjectCode,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.subjectName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${subject.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (subject.percentage / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark
                  ? const Color(0xFF27272A)
                  : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),

          // Counts and Safe-Bunk Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subject.attendedClasses} of ${subject.totalClasses} attended',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isSafe ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                    size: 13,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSafe
                        ? (safeBunks > 0
                            ? 'Can miss $safeBunks class${safeBunks == 1 ? '' : 'es'}'
                            : 'On the margin (75%)')
                        : 'Attend next $requiredClasses class${requiredClasses == 1 ? '' : 'es'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Action Buttons: + Present, - Absent, Undo
          Row(
            children: [
              // Present Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMarkPresent,
                  icon: const Icon(Icons.check_rounded, size: 16, color: Color(0xFF10B981)),
                  label: const Text('Present'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Absent Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMarkAbsent,
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Absent'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Undo Button
              IconButton(
                onPressed: onUndo,
                icon: const Icon(Icons.undo_rounded, size: 18),
                tooltip: 'Undo last record',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
