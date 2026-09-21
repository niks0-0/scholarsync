import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/subject_attendance.dart';

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({
    super.key,
    required this.onAdd,
  });

  final ValueChanged<SubjectAttendance> onAdd;

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _attendedController = TextEditingController(text: '0');
  final _totalController = TextEditingController(text: '0');

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _attendedController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final attended = int.tryParse(_attendedController.text.trim()) ?? 0;
    final total = int.tryParse(_totalController.text.trim()) ?? 0;

    final subject = SubjectAttendance(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      subjectCode: _codeController.text.trim().toUpperCase(),
      subjectName: _nameController.text.trim(),
      attendedClasses: attended,
      totalClasses: total < attended ? attended : total,
      targetPercentage: 75.0,
      lastUpdated: DateTime.now(),
    );

    widget.onAdd(subject);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Add Subject to Track',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _codeController,
                  label: 'Subject Code',
                  hint: 'e.g. CS306',
                  prefixIcon: Icons.tag_rounded,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _nameController,
                  label: 'Subject Name',
                  hint: 'e.g. Artificial Intelligence',
                  prefixIcon: Icons.menu_book_rounded,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _attendedController,
                        label: 'Attended Classes',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _totalController,
                        label: 'Total Classes',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Add Subject',
          onPressed: _submit,
          variant: AppButtonVariant.primary,
          size: AppButtonSize.small,
          isFullWidth: false,
        ),
      ],
    );
  }
}
