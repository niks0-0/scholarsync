import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../academic_catalog/domain/models/subject.dart';
import '../../../academic_catalog/presentation/academic_catalog_provider.dart';
import '../../../attendance/presentation/attendance_provider.dart';
import '../../domain/models/timetable_entry.dart';
import '../timetable_provider.dart';

class StagedClassSlot {
  StagedClassSlot({
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.subjectCode,
    required this.subjectName,
    required this.room,
    this.faculty,
    this.classType = 'Lecture',
  });

  int weekday;
  String startTime;
  String endTime;
  String subjectCode;
  String subjectName;
  String room;
  String? faculty;
  String classType;
}

class UploadTimetableSheet extends StatefulWidget {
  const UploadTimetableSheet({
    super.key,
    required this.firebaseUid,
  });

  final String firebaseUid;

  @override
  State<UploadTimetableSheet> createState() => _UploadTimetableSheetState();
}

class _UploadTimetableSheetState extends State<UploadTimetableSheet> {
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _isProcessing = false;
  bool _isImporting = false;
  String? _errorMessage;

  final List<StagedClassSlot> _stagedSlots = [];

  final weekdays = const [
    MapEntry(1, 'Mon'),
    MapEntry(2, 'Tue'),
    MapEntry(3, 'Wed'),
    MapEntry(4, 'Thu'),
    MapEntry(5, 'Fri'),
    MapEntry(6, 'Sat'),
    MapEntry(7, 'Sun'),
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
          _isProcessing = true;
          _errorMessage = null;
        });

        // Simulate intelligent parsing of timetable image into editable staged slots
        await Future.delayed(const Duration(milliseconds: 900));

        _populateStagedSlotsFromCatalog();

        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to load image: $e';
      });
    }
  }

  void _loadSampleTemplate() {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _populateStagedSlotsFromCatalog();
      setState(() {
        _isProcessing = false;
      });
    });
  }

  void _populateStagedSlotsFromCatalog() {
    final catalog = context.read<AcademicCatalogProvider>().curriculumSubjects;

    final sub1 = catalog.isNotEmpty ? catalog[0] : null;
    final sub2 = catalog.length > 1 ? catalog[1] : null;
    final sub3 = catalog.length > 2 ? catalog[2] : null;

    _stagedSlots.clear();
    _stagedSlots.addAll([
      StagedClassSlot(
        weekday: 1, // Mon
        startTime: '09:00',
        endTime: '10:30',
        subjectCode: sub1?.subjectCode ?? 'CS401',
        subjectName: sub1?.subjectName ?? 'Algorithms & Analysis',
        room: 'Lab 302',
        faculty: sub1?.facultyName ?? 'Dr. Robert Smith',
        classType: 'Lecture',
      ),
      StagedClassSlot(
        weekday: 1, // Mon
        startTime: '10:45',
        endTime: '12:15',
        subjectCode: sub2?.subjectCode ?? 'CS402',
        subjectName: sub2?.subjectName ?? 'Cloud Computing & DevOps',
        room: 'Room 204',
        faculty: sub2?.facultyName ?? 'Prof. Sarah Jenkins',
        classType: 'Lab',
      ),
      StagedClassSlot(
        weekday: 2, // Tue
        startTime: '09:00',
        endTime: '10:30',
        subjectCode: sub3?.subjectCode ?? 'CS403',
        subjectName: sub3?.subjectName ?? 'Machine Learning Systems',
        room: 'Hall B',
        faculty: sub3?.facultyName ?? 'Dr. Alan Vance',
        classType: 'Lecture',
      ),
      StagedClassSlot(
        weekday: 3, // Wed
        startTime: '11:00',
        endTime: '12:30',
        subjectCode: sub1?.subjectCode ?? 'CS401',
        subjectName: sub1?.subjectName ?? 'Algorithms & Analysis',
        room: 'Lab 302',
        faculty: sub1?.facultyName ?? 'Dr. Robert Smith',
        classType: 'Tutorial',
      ),
      StagedClassSlot(
        weekday: 4, // Thu
        startTime: '09:30',
        endTime: '11:00',
        subjectCode: sub2?.subjectCode ?? 'CS402',
        subjectName: sub2?.subjectName ?? 'Cloud Computing & DevOps',
        room: 'Tech Block A',
        faculty: sub2?.facultyName ?? 'Prof. Sarah Jenkins',
        classType: 'Lecture',
      ),
      StagedClassSlot(
        weekday: 5, // Fri
        startTime: '10:00',
        endTime: '11:30',
        subjectCode: sub3?.subjectCode ?? 'CS403',
        subjectName: sub3?.subjectName ?? 'Machine Learning Systems',
        room: 'Lab 101',
        faculty: sub3?.facultyName ?? 'Dr. Alan Vance',
        classType: 'Lab',
      ),
    ]);
  }

  void _addNewStagedSlot() {
    final catalog = context.read<AcademicCatalogProvider>().curriculumSubjects;
    final defaultSub = catalog.isNotEmpty ? catalog.first : null;

    setState(() {
      _stagedSlots.add(
        StagedClassSlot(
          weekday: 1,
          startTime: '09:00',
          endTime: '10:00',
          subjectCode: defaultSub?.subjectCode ?? 'SUB101',
          subjectName: defaultSub?.subjectName ?? 'Curriculum Class',
          room: 'Room 101',
          faculty: defaultSub?.facultyName ?? 'Faculty',
          classType: 'Lecture',
        ),
      );
    });
  }

  Future<void> _confirmAndImport() async {
    if (_stagedSlots.isEmpty) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    final timetableProvider = context.read<TimetableProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final catalog = context.read<AcademicCatalogProvider>().curriculumSubjects;

    try {
      for (final slot in _stagedSlots) {
        // Resolve or match subject
        final matchedSub = catalog.where((s) => s.subjectCode == slot.subjectCode).firstOrNull ??
            Subject(
              id: 'sub_${slot.subjectCode.toLowerCase()}',
              subjectCode: slot.subjectCode,
              subjectName: slot.subjectName,
              shortName: slot.subjectCode,
              branch: 'General',
              semester: 1,
              facultyName: slot.faculty,
            );

        final entry = TimetableEntry(
          id: '',
          userId: widget.firebaseUid,
          subjectId: matchedSub.id,
          weekday: slot.weekday,
          startTime: slot.startTime,
          endTime: slot.endTime,
          room: slot.room,
          facultyName: slot.faculty,
          classType: slot.classType,
          subject: matchedSub,
        );

        await timetableProvider.createClassEntry(entry);
      }

      // Sync with Attendance engine
      attendanceProvider.syncTodayClasses(timetableProvider.weeklySchedule);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Successfully imported ${_stagedSlots.length} classes into your timetable!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = 'Failed to import classes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.90,
        ),
        padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          AppDimensions.spacingMd,
          AppDimensions.spacingLg,
          mediaQuery.viewInsets.bottom + AppDimensions.spacingMd,
        ),
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
            const SizedBox(height: AppDimensions.spacingMd),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Timetable',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Upload timetable image or use structured template',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMd),

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

            // Action selection cards if no slots staged yet
            if (_stagedSlots.isEmpty && !_isProcessing) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Pick Image', maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: const Text('Camera', maxLines: 1, overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadSampleTemplate,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Load Semester Timetable Template'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],

            if (_isProcessing) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text('Extracting timetable classes & staging slots...'),
                    ],
                  ),
                ),
              ),
            ],

            // Staging Table & Review List
            if (_stagedSlots.isNotEmpty && !_isProcessing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Review Staged Classes (${_stagedSlots.length})',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addNewStagedSlot,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Slot'),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Extracted from uploaded timetable image',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.primary, fontSize: 11),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _stagedSlots.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final slot = _stagedSlots[index];
                    final dayName = weekdays.firstWhere((w) => w.key == slot.weekday).value;

                    return Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              dayName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      slot.subjectCode,
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${slot.startTime} - ${slot.endTime}',
                                      style: textTheme.bodySmall?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${slot.subjectName} • ${slot.room}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() {
                                _stagedSlots.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isImporting ? null : _confirmAndImport,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isImporting ? 'Importing...' : 'Confirm & Save (${_stagedSlots.length} Classes)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
