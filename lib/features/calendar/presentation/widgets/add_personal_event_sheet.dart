import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';

class AddPersonalEventSheet extends StatefulWidget {
  const AddPersonalEventSheet({
    super.key,
    required this.initialDate,
    required this.onEventAdded,
  });

  final DateTime initialDate;
  final ValueChanged<AcademicCalendarEvent> onEventAdded;

  @override
  State<AddPersonalEventSheet> createState() => _AddPersonalEventSheetState();
}

class _AddPersonalEventSheetState extends State<AddPersonalEventSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  String _eventType = 'deadline';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final event = AcademicCalendarEvent(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      eventType: _eventType,
      startDate: _selectedDate,
      createdAt: DateTime.now(),
    );

    widget.onEventAdded(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'Add Personal Schedule Event',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              // Title input
              AppTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'e.g. Operating Systems Assignment 2',
                prefixIcon: Icons.edit_outlined,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _eventType,
                decoration: InputDecoration(
                  labelText: 'Event Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                dropdownColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'deadline', child: Text('Assignment / Deadline')),
                  DropdownMenuItem(value: 'exam', child: Text('Quiz / Examination')),
                  DropdownMenuItem(value: 'event', child: Text('Personal Study Session')),
                  DropdownMenuItem(value: 'holiday', child: Text('Personal Leave / Holiday')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _eventType = val);
                },
              ),
              const SizedBox(height: 12),

              // Description input
              AppTextField(
                controller: _descController,
                label: 'Description (Optional)',
                hint: 'Additional notes or room info',
                maxLines: 2,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 20),

              // Submit Button
              AppButton(
                text: 'Save to Calendar',
                onPressed: _submit,
                variant: AppButtonVariant.primary,
                prefixIcon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
