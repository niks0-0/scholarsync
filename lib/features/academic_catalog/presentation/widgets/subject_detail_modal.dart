import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/subject.dart';

class SubjectDetailModal extends StatelessWidget {
  const SubjectDetailModal({
    super.key,
    required this.subject,
    required this.isEnrolled,
    required this.onToggleEnrollment,
  });

  final Subject subject;
  final bool isEnrolled;
  final VoidCallback onToggleEnrollment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Text(
                  subject.subjectCode,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                '${subject.credits} Academic Credits',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            subject.subjectName,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          Text(
            '${subject.branch} • Semester ${subject.semester}',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
          ),

          const SizedBox(height: AppDimensions.spacingLg),
          const Divider(),
          const SizedBox(height: AppDimensions.spacingLg),

          // Details List
          _buildDetailRow(context, 'Short Code Name', subject.shortName, Icons.bookmark_border_rounded),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Faculty / Lecturer', subject.facultyName ?? 'Department Assigned', Icons.person_rounded),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Course Structure', '${subject.theory ? "Theory Lecture" : ""}${subject.theory && subject.practical ? " + " : ""}${subject.practical ? "Practical Lab" : ""}', Icons.class_outlined),

          const SizedBox(height: AppDimensions.spacingXxl),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    onToggleEnrollment();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(isEnrolled ? Icons.remove_circle_outline_rounded : Icons.check_circle_outline_rounded),
                  label: Text(isEnrolled ? 'Unenroll' : 'Enroll Subject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnrolled ? AppColors.error : AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}
