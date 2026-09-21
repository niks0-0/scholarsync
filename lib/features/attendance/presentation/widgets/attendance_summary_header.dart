import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';

class AttendanceSummaryHeader extends StatelessWidget {
  const AttendanceSummaryHeader({
    super.key,
    required this.overallPercentage,
    required this.totalAttended,
    required this.totalClasses,
    required this.atRiskCount,
    required this.onOpenCalculator,
  });

  final double overallPercentage;
  final int totalAttended;
  final int totalClasses;
  final int atRiskCount;
  final VoidCallback onOpenCalculator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSafe = overallPercentage >= 75.0;
    final statusColor = isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.0,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Radial / Circular Gauge
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: (overallPercentage / 100.0).clamp(0.0, 1.0),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? const Color(0xFF27272A)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${overallPercentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Overall statistics summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSafe ? 'Attendance Satisfied' : 'Attendance At Risk',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        InkWell(
                          onTap: onOpenCalculator,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calculate_outlined, size: 13, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Calculator',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mandatory minimum requirement is 75% for exam eligibility.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Metrics pills
                    Row(
                      children: [
                        _buildStatPill(
                          context,
                          label: 'Attended',
                          value: '$totalAttended/$totalClasses',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildStatPill(
                          context,
                          label: 'At Risk',
                          value: '$atRiskCount subjects',
                          isAlert: atRiskCount > 0,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(
    BuildContext context, {
    required String label,
    required String value,
    required bool isDark,
    bool isAlert = false,
  }) {
    final theme = Theme.of(context);
    final alertColor = const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAlert
            ? alertColor.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: isAlert
                  ? alertColor
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isAlert
                  ? alertColor
                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
