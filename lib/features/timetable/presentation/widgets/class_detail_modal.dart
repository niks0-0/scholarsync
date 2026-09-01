import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/timetable_entry.dart';
import '../timetable_provider.dart';
import 'add_edit_class_sheet.dart';

class ClassDetailModal extends StatelessWidget {
  const ClassDetailModal({
    super.key,
    required this.entry,
    required this.firebaseUid,
  });

  final TimetableEntry entry;
  final String firebaseUid;

  void _showEditSheet(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditClassSheet(
        firebaseUid: firebaseUid,
        entryToEdit: entry,
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context) {
    int selectedDay = entry.weekday;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Duplicate Class to Day'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select target weekday for duplication:'),
                  const SizedBox(height: 12),
                  DropdownButton<int>(
                    value: selectedDay,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Monday')),
                      DropdownMenuItem(value: 2, child: Text('Tuesday')),
                      DropdownMenuItem(value: 3, child: Text('Wednesday')),
                      DropdownMenuItem(value: 4, child: Text('Thursday')),
                      DropdownMenuItem(value: 5, child: Text('Friday')),
                      DropdownMenuItem(value: 6, child: Text('Saturday')),
                      DropdownMenuItem(value: 7, child: Text('Sunday')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDay = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<TimetableProvider>().duplicateClassEntry(firebaseUid, entry.id, selectedDay);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Duplicate'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Class Entry?'),
          content: Text('Are you sure you want to remove "${entry.subjectName}" (${entry.startTime} - ${entry.endTime}) from your timetable?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<TimetableProvider>().deleteClassEntry(firebaseUid, entry.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

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
                  entry.subjectCode,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.classType,
                  style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Duplicate Class',
                onPressed: () => _showDuplicateDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Class',
                onPressed: () => _showEditSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                tooltip: 'Delete Class',
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            entry.subjectName,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),
          const Divider(),
          const SizedBox(height: AppDimensions.spacingLg),

          // Details List
          _buildDetailRow(context, 'Timing', '${entry.startTime} - ${entry.endTime} (${entry.durationMinutes} minutes)', Icons.schedule_rounded),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Location / Room', '${entry.room}${entry.building != null ? " (${entry.building})" : ""}', Icons.location_on_outlined),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Faculty / Professor', entry.facultyName ?? 'Department Assigned', Icons.person_rounded),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Delivery Mode', entry.mode, entry.mode == 'Online' ? Icons.laptop_mac_rounded : Icons.class_outlined),
          if (entry.meetingUrl != null && entry.meetingUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Online Meeting Link', entry.meetingUrl!, Icons.link_rounded),
          ],
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Notes & Preparation', entry.notes!, Icons.notes_rounded),
          ],

          const SizedBox(height: AppDimensions.spacingXxl),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}
