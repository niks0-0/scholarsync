import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/subject_attendance.dart';

class BunkCalculatorSheet extends StatefulWidget {
  const BunkCalculatorSheet({
    super.key,
    required this.subjects,
  });

  final List<SubjectAttendance> subjects;

  @override
  State<BunkCalculatorSheet> createState() => _BunkCalculatorSheetState();
}

class _BunkCalculatorSheetState extends State<BunkCalculatorSheet> {
  late SubjectAttendance? _selectedSubject;
  int _classesToMiss = 0;
  int _classesToAttend = 0;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.subjects.isNotEmpty ? widget.subjects.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_selectedSubject == null) {
      return const SizedBox.shrink();
    }

    // Projected calculations
    final currentAttended = _selectedSubject!.attendedClasses;
    final currentTotal = _selectedSubject!.totalClasses;

    final projectedAttended = currentAttended + _classesToAttend;
    final projectedTotal = currentTotal + _classesToAttend + _classesToMiss;
    final projectedPercentage = projectedTotal == 0
        ? 100.0
        : (projectedAttended / projectedTotal) * 100.0;

    final isProjectedSafe = projectedPercentage >= 75.0;
    final statusColor =
        isProjectedSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          const SizedBox(height: 16),

          // Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe Bunk Simulator',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
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

          // Subject picker dropdown
          DropdownButtonFormField<SubjectAttendance>(
            initialValue: _selectedSubject,
            decoration: InputDecoration(
              labelText: 'Select Subject',
              prefixIcon: const Icon(Icons.book_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            dropdownColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            items: widget.subjects.map((sub) {
              return DropdownMenuItem(
                value: sub,
                child: Text('${sub.subjectCode} — ${sub.subjectName}',
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (sub) {
              if (sub != null) {
                setState(() {
                  _selectedSubject = sub;
                  _classesToMiss = 0;
                  _classesToAttend = 0;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Current vs Projected Display Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Current',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedSubject!.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_selectedSubject!.attendedClasses}/${_selectedSubject!.totalClasses}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                Column(
                  children: [
                    Text(
                      'Projected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${projectedPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      '$projectedAttended/$projectedTotal',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Steppers
          _buildStepperRow(
            context,
            label: 'Classes to Skip / Bunk',
            value: _classesToMiss,
            color: const Color(0xFFEF4444),
            onDecrement: () {
              if (_classesToMiss > 0) setState(() => _classesToMiss--);
            },
            onIncrement: () {
              setState(() => _classesToMiss++);
            },
          ),
          const SizedBox(height: 12),
          _buildStepperRow(
            context,
            label: 'Classes to Attend',
            value: _classesToAttend,
            color: const Color(0xFF10B981),
            onDecrement: () {
              if (_classesToAttend > 0) setState(() => _classesToAttend--);
            },
            onIncrement: () {
              setState(() => _classesToAttend++);
            },
          ),
          const SizedBox(height: 16),

          // Simulation summary verdict
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isProjectedSafe ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isProjectedSafe
                        ? 'Safe! Attendance stays above the 75% threshold.'
                        : 'Alert! Projected attendance drops below 75% requirement.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton.outlined(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_rounded, size: 16),
              visualDensity: VisualDensity.compact,
            ),
            Container(
              width: 36,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: value > 0
                      ? color
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
              ),
            ),
            IconButton.outlined(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_rounded, size: 16),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }
}
