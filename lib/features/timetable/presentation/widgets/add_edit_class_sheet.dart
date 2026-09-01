import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../academic_catalog/domain/models/subject.dart';
import '../../../academic_catalog/presentation/academic_catalog_provider.dart';
import '../../../auth/presentation/widgets/app_text_field.dart';
import '../../domain/models/timetable_entry.dart';
import '../timetable_provider.dart';

class AddEditClassSheet extends StatefulWidget {
  const AddEditClassSheet({
    super.key,
    required this.firebaseUid,
    this.entryToEdit,
    this.initialWeekday,
  });

  final String firebaseUid;
  final TimetableEntry? entryToEdit;
  final int? initialWeekday;

  @override
  State<AddEditClassSheet> createState() => _AddEditClassSheetState();
}

class _AddEditClassSheetState extends State<AddEditClassSheet> {
  final _formKey = GlobalKey<FormState>();

  Subject? _selectedSubject;
  late int _weekday;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _meetingUrlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _mode = 'Offline';
  String _classType = 'Lecture';
  int _reminderMinutes = 15;
  bool _isSaving = false;
  String? _errorMessage;

  final weekdays = const [
    MapEntry(1, 'Mon'),
    MapEntry(2, 'Tue'),
    MapEntry(3, 'Wed'),
    MapEntry(4, 'Thu'),
    MapEntry(5, 'Fri'),
    MapEntry(6, 'Sat'),
    MapEntry(7, 'Sun'),
  ];

  final modes = const ['Offline', 'Online', 'Hybrid'];
  final classTypes = const ['Lecture', 'Lab', 'Tutorial', 'Seminar', 'Workshop', 'Custom'];

  @override
  void initState() {
    super.initState();
    _weekday = widget.entryToEdit?.weekday ?? widget.initialWeekday ?? DateTime.now().weekday;

    if (widget.entryToEdit != null) {
      final e = widget.entryToEdit!;
      _selectedSubject = e.subject;
      _weekday = e.weekday;
      _startTime = _parseTimeOfDay(e.startTime);
      _endTime = _parseTimeOfDay(e.endTime);
      _roomController.text = e.room;
      _buildingController.text = e.building ?? '';
      _facultyController.text = e.facultyName ?? '';
      _mode = e.mode;
      _meetingUrlController.text = e.meetingUrl ?? '';
      _classType = e.classType;
      _notesController.text = e.notes ?? '';
      _reminderMinutes = e.reminderMinutes;
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':').map(int.parse).toList();
      return TimeOfDay(hour: parts[0], minute: parts[1]);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _roomController.dispose();
    _buildingController.dispose();
    _facultyController.dispose();
    _meetingUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubject == null) {
      setState(() => _errorMessage = 'Please select a subject from your academic catalog.');
      return;
    }

    final startStr = _formatTimeOfDay(_startTime);
    final endStr = _formatTimeOfDay(_endTime);

    final validationError = TimetableProvider.validateClassTimes(startStr, endStr);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final entry = TimetableEntry(
      id: widget.entryToEdit?.id ?? '',
      userId: widget.firebaseUid,
      subjectId: _selectedSubject!.id,
      weekday: _weekday,
      startTime: startStr,
      endTime: endStr,
      room: _roomController.text.trim(),
      building: _buildingController.text.trim().isNotEmpty ? _buildingController.text.trim() : null,
      facultyName: _facultyController.text.trim().isNotEmpty ? _facultyController.text.trim() : null,
      mode: _mode,
      meetingUrl: _meetingUrlController.text.trim().isNotEmpty ? _meetingUrlController.text.trim() : null,
      classType: _classType,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      reminderMinutes: _reminderMinutes,
      subject: _selectedSubject,
    );

    final provider = context.read<TimetableProvider>();
    bool success;
    if (widget.entryToEdit != null) {
      success = await provider.updateClassEntry(entry);
    } else {
      success = await provider.createClassEntry(entry);
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage = provider.error ?? 'Failed to save class entry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final catalogSubjects = context.watch<AcademicCatalogProvider>().curriculumSubjects;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXxl)),
      ),
      child: Column(
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

          Text(
            widget.entryToEdit != null ? 'Edit Timetable Entry' : 'Add Class to Timetable',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],

          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Selector
                    Text('Subject', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Subject>(
                      initialValue: catalogSubjects.contains(_selectedSubject) ? _selectedSubject : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select curriculum subject...',
                        prefixIcon: Icon(Icons.menu_book_rounded),
                      ),
                      items: catalogSubjects.map((s) {
                        return DropdownMenuItem<Subject>(
                          value: s,
                          child: Text('${s.subjectCode} - ${s.subjectName}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSubject = val),
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // Weekday Selector Chips
                    Text('Day of Week', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: weekdays.map((entry) {
                          final isSelected = _weekday == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(entry.value),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : colorScheme.onSurface,
                              ),
                              onSelected: (_) => setState(() => _weekday = entry.key),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // Time Pickers
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () => _pickTime(true),
                                icon: const Icon(Icons.access_time_rounded),
                                label: Text(_formatTimeOfDay(_startTime)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () => _pickTime(false),
                                icon: const Icon(Icons.access_time_filled_rounded),
                                label: Text(_formatTimeOfDay(_endTime)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // Class Type & Mode
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Class Type', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _classType,
                                items: classTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _classType = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mode', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _mode,
                                items: modes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _mode = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // Room & Building
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Room / Lab',
                            hint: 'e.g. Lab 302',
                            controller: _roomController,
                            prefixIcon: Icons.location_on_outlined,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: AppTextField(
                            label: 'Building (Optional)',
                            hint: 'e.g. Tech Block A',
                            controller: _buildingController,
                            prefixIcon: Icons.business_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    AppTextField(
                      label: 'Faculty / Professor (Optional)',
                      hint: 'e.g. Dr. Robert Smith',
                      controller: _facultyController,
                      prefixIcon: Icons.person_outline_rounded,
                    ),

                    if (_mode == 'Online' || _mode == 'Hybrid') ...[
                      const SizedBox(height: AppDimensions.spacingLg),
                      AppTextField(
                        label: 'Online Meeting URL (Optional)',
                        hint: 'e.g. https://meet.google.com/abc-defg-hij',
                        controller: _meetingUrlController,
                        prefixIcon: Icons.link_rounded,
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spacingLg),

                    AppTextField(
                      label: 'Class Notes (Optional)',
                      hint: 'Preparation notes or guidelines...',
                      controller: _notesController,
                      prefixIcon: Icons.notes_rounded,
                    ),

                    const SizedBox(height: AppDimensions.spacingXxl),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveForm,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.entryToEdit != null ? 'Update Class' : 'Add to Timetable'),
            ),
          ),
        ],
      ),
    );
  }
}
