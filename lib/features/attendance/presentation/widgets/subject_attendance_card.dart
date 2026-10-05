import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/daily_class_attendance.dart';
import '../../domain/models/subject_attendance.dart';

class SubjectAttendanceCard extends StatelessWidget {
  const SubjectAttendanceCard({
    super.key,
    required this.subject,
    this.todayStatus,
    this.onMarkPresent,
    this.onMarkAbsent,
    this.onUndo,
  });

  final SubjectAttendance subject;
  final AttendanceStatus? todayStatus;
  final VoidCallback? onMarkPresent;
  final VoidCallback? onMarkAbsent;
  final VoidCallback? onUndo;

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
              Flexible(
                child: Text(
                  '${subject.attendedClasses} of ${subject.totalClasses} attended',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSafe ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                      size: 13,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        isSafe
                            ? (safeBunks > 0
                                ? 'Can miss $safeBunks class${safeBunks == 1 ? '' : 'es'}'
                                : 'On margin (75%)')
                            : 'Attend next $requiredClasses class${requiredClasses == 1 ? '' : 'es'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Action Buttons: + Present, - Absent, Undo
          Row(
            children: [
              // Present Button (Selected if todayStatus == present)
              Expanded(
                child: FilledButton.icon(
                  onPressed: onMarkPresent,
                  icon: Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: todayStatus == AttendanceStatus.present ? Colors.white : const Color(0xFF10B981),
                  ),
                  label: Text(
                    todayStatus == AttendanceStatus.present ? 'Present ✓' : 'Present',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: todayStatus == AttendanceStatus.present
                        ? const Color(0xFF10B981)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    foregroundColor: todayStatus == AttendanceStatus.present
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    side: BorderSide(
                      color: todayStatus == AttendanceStatus.present
                          ? const Color(0xFF10B981)
                          : const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Absent Button (Selected if todayStatus == absent)
              Expanded(
                child: FilledButton.icon(
                  onPressed: onMarkAbsent,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: todayStatus == AttendanceStatus.absent ? Colors.white : const Color(0xFFEF4444),
                  ),
                  label: Text(
                    todayStatus == AttendanceStatus.absent ? 'Absent ✗' : 'Absent',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: todayStatus == AttendanceStatus.absent
                        ? const Color(0xFFEF4444)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    foregroundColor: todayStatus == AttendanceStatus.absent
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    side: BorderSide(
                      color: todayStatus == AttendanceStatus.absent
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Undo Button
              IconButton(
                onPressed: onUndo,
                icon: const Icon(Icons.undo_rounded, size: 18),
                tooltip: 'Reset today attendance',
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
