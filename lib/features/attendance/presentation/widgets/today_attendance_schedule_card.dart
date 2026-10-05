import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../academic_catalog/presentation/academic_catalog_provider.dart';
import '../../../auth/auth_provider.dart';
import '../../../timetable/presentation/timetable_provider.dart';
import '../../../timetable/presentation/widgets/upload_timetable_sheet.dart';
import '../../domain/models/daily_class_attendance.dart';
import '../attendance_provider.dart';

class _SubjectItem {
  final String id;
  final String code;
  final String name;
  final String? faculty;

  const _SubjectItem({
    required this.id,
    required this.code,
    required this.name,
    this.faculty,
  });
}

class TodayAttendanceScheduleCard extends StatelessWidget {
  const TodayAttendanceScheduleCard({super.key});

  List<_SubjectItem> _getCombinedSubjectOptions(
    BuildContext context,
    AttendanceProvider attendanceProvider,
  ) {
    final catalog = context.read<AcademicCatalogProvider>().curriculumSubjects;
    final trackedSubjects = attendanceProvider.subjects;

    final Map<String, _SubjectItem> subjectMap = {};
    for (final s in trackedSubjects) {
      subjectMap[s.id] = _SubjectItem(
        id: s.id,
        code: s.subjectCode,
        name: s.subjectName,
      );
    }
    for (final c in catalog) {
      if (!subjectMap.containsKey(c.id)) {
        subjectMap[c.id] = _SubjectItem(
          id: c.id,
          code: c.subjectCode,
          name: c.subjectName,
          faculty: c.facultyName,
        );
      }
    }
    return subjectMap.values.toList();
  }

  void _showProxyDialog(
    BuildContext context,
    DailyClassAttendance session,
    AttendanceProvider attendanceProvider,
  ) {
    final allOptions = _getCombinedSubjectOptions(context, attendanceProvider);
    bool isCustom = allOptions.isEmpty;
    String? selectedSubjectId = allOptions.isNotEmpty ? allOptions.first.id : null;
    final customCodeController = TextEditingController();
    final customNameController = TextEditingController();
    final facultyController = TextEditingController(text: session.faculty ?? '');
    bool isPresent = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Set Proxy / Substitute'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled Slot: ${session.originalSubjectCode} (${session.startTime} - ${session.endTime})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    const Text('Which subject took this lecture slot?'),
                    const SizedBox(height: 6),
                    if (!isCustom) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedSubjectId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: allOptions.map((sub) {
                          return DropdownMenuItem<String>(
                            value: sub.id,
                            child: Text('${sub.code} - ${sub.name}', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setDialogState(() => selectedSubjectId = val),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setDialogState(() => isCustom = true),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Enter Custom Subject', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: customCodeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Substitute Subject Code *',
                          hintText: 'e.g. CS405',
                          prefixIcon: Icon(Icons.code_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: customNameController,
                        decoration: const InputDecoration(
                          labelText: 'Substitute Subject Name',
                          hintText: 'e.g. Cyber Security Special',
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                      ),
                      if (allOptions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setDialogState(() => isCustom = false),
                            icon: const Icon(Icons.list_rounded, size: 14),
                            label: const Text('Pick from Enrolled Subjects', style: TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: facultyController,
                      decoration: const InputDecoration(
                        labelText: 'Substitute Professor (Optional)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Did you attend this proxy lecture?'),
                      value: isPresent,
                      activeColor: AppColors.success,
                      onChanged: (val) => setDialogState(() => isPresent = val ?? true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String subId;
                    String subCode;
                    String subName;

                    if (isCustom) {
                      final code = customCodeController.text.trim().toUpperCase();
                      if (code.isEmpty) return;
                      subCode = code;
                      subName = customNameController.text.trim().isNotEmpty
                          ? customNameController.text.trim()
                          : code;
                      subId = 'sub_${code.toLowerCase()}';
                    } else {
                      final chosenSub = allOptions.where((s) => s.id == selectedSubjectId).firstOrNull;
                      if (chosenSub == null) return;
                      subId = chosenSub.id;
                      subCode = chosenSub.code;
                      subName = chosenSub.name;
                    }

                    attendanceProvider.setProxyForSession(
                      recordId: session.id,
                      proxySubjectId: subId,
                      proxySubjectCode: subCode,
                      proxySubjectName: subName,
                      proxyFaculty: facultyController.text.trim().isNotEmpty
                          ? facultyController.text.trim()
                          : null,
                      isPresent: isPresent,
                    );
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Apply Proxy'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    DailyClassAttendance session,
    AttendanceProvider attendanceProvider,
  ) {
    final reasonController = TextEditingController(text: 'Professor on leave');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Cancel Lecture Slot'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancel "${session.originalSubjectName}" (${session.startTime} - ${session.endTime})?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This will exclude the lecture from your total attendance count so your percentage will NOT be penalized.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason',
                  hintText: 'e.g. Faculty absent, College event...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Back'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                attendanceProvider.cancelClassSession(
                  recordId: session.id,
                  reason: reasonController.text.trim(),
                );
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Confirm Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExtraClassDialog(BuildContext context, AttendanceProvider attendanceProvider) {
    final allOptions = _getCombinedSubjectOptions(context, attendanceProvider);
    bool isCustom = allOptions.isEmpty;
    String? selectedSubId = allOptions.isNotEmpty ? allOptions.first.id : null;
    final customCodeController = TextEditingController();
    final customNameController = TextEditingController();
    final startController = TextEditingController(text: '14:00');
    final endController = TextEditingController(text: '15:30');
    final roomController = TextEditingController(text: 'Lab 201');
    final facultyController = TextEditingController();
    bool isPresent = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Extra Lecture Today'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isCustom) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedSubId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Subject',
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                        items: allOptions.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text('${s.code} - ${s.name}', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setDialogState(() => selectedSubId = val),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setDialogState(() => isCustom = true),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Enter Custom Subject', style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: customCodeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Subject Code *',
                          hintText: 'e.g. CS405',
                          prefixIcon: Icon(Icons.code_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: customNameController,
                        decoration: const InputDecoration(
                          labelText: 'Subject Name',
                          hintText: 'e.g. Advanced Networking',
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                      ),
                      if (allOptions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setDialogState(() => isCustom = false),
                            icon: const Icon(Icons.list_rounded, size: 14),
                            label: const Text('Pick from Enrolled Subjects', style: TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startController,
                            decoration: const InputDecoration(labelText: 'Start Time (HH:mm)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: endController,
                            decoration: const InputDecoration(labelText: 'End Time (HH:mm)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomController,
                      decoration: const InputDecoration(labelText: 'Room / Hall'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: facultyController,
                      decoration: const InputDecoration(labelText: 'Faculty (Optional)'),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mark Present for this session?'),
                      value: isPresent,
                      activeColor: AppColors.success,
                      onChanged: (val) => setDialogState(() => isPresent = val ?? true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String subId;
                    String subCode;
                    String subName;

                    if (isCustom) {
                      final code = customCodeController.text.trim().toUpperCase();
                      if (code.isEmpty) return;
                      subCode = code;
                      subName = customNameController.text.trim().isNotEmpty
                          ? customNameController.text.trim()
                          : code;
                      subId = 'sub_${code.toLowerCase()}';
                    } else {
                      final chosen = allOptions.where((s) => s.id == selectedSubId).firstOrNull;
                      if (chosen == null) return;
                      subId = chosen.id;
                      subCode = chosen.code;
                      subName = chosen.name;
                    }

                    attendanceProvider.addExtraClassToday(
                      subjectId: subId,
                      subjectCode: subCode,
                      subjectName: subName,
                      startTime: startController.text.trim(),
                      endTime: endController.text.trim(),
                      room: roomController.text.trim(),
                      faculty: facultyController.text.trim().isNotEmpty
                          ? facultyController.text.trim()
                          : null,
                      isPresent: isPresent,
                    );
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Add Lecture'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final attendance = context.watch<AttendanceProvider>();
    final timetable = context.watch<TimetableProvider>();

    // Sync today's timetable slots
    final todayClasses = attendance.todayClasses;
    final allMarkedPresent = todayClasses.isNotEmpty &&
        todayClasses.every((c) => c.status == AttendanceStatus.present || c.status == AttendanceStatus.cancelled);

    final weekdaysMap = const {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    final dayName = weekdaysMap[attendance.selectedDate.weekday] ?? 'Today';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "$dayName's Schedule",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${todayClasses.length} lectures scheduled from timetable',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 1-Tap Mark All Present Button
              ElevatedButton.icon(
                onPressed: (todayClasses.isEmpty || allMarkedPresent || !attendance.isSelectedDateToday)
                    ? null
                    : () {
                        attendance.markAllTodayPresent(timetable.weeklySchedule);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Marked all scheduled classes present for today!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: const Icon(Icons.done_all_rounded, size: 15),
                label: const Text('Mark All', maxLines: 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),

          if (!attendance.isSelectedDateToday) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, size: 14, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Past/future date view is read-only. Attendance can only be marked, unmarked, or updated for the present date.',
                      style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Stream of Today's Lectures
          if (todayClasses.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_seat_outlined, size: 36, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 6),
                    Text(
                      'No classes scheduled for $dayName.',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set up your timetable or log an extra lecture for today.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            final user = context.read<AuthProvider>().currentUser;
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => UploadTimetableSheet(firebaseUid: user?.uid ?? ''),
                            );
                          },
                          icon: const Icon(Icons.upload_file_outlined, size: 15),
                          label: const Text('Import Timetable', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                        if (attendance.isSelectedDateToday)
                          ElevatedButton.icon(
                            onPressed: () => _showAddExtraClassDialog(context, attendance),
                            icon: const Icon(Icons.add, size: 15),
                            label: const Text('+ Extra Lecture', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Column(
              children: [
                for (int i = 0; i < todayClasses.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _buildLectureSessionCard(context, todayClasses[i], attendance, isDark),
                ],
              ],
            ),
          ],

          if (attendance.isSelectedDateToday) ...[
            const SizedBox(height: 12),
            // Bottom Quick Bar: Add Extra Lecture
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddExtraClassDialog(context, attendance),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Extra Lecture Today', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLectureSessionCard(
    BuildContext context,
    DailyClassAttendance session,
    AttendanceProvider attendance,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (session.status) {
      case AttendanceStatus.present:
        statusColor = const Color(0xFF10B981);
        statusLabel = 'PRESENT';
        statusIcon = Icons.check_circle_rounded;
        break;
      case AttendanceStatus.absent:
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'ABSENT';
        statusIcon = Icons.cancel_rounded;
        break;
      case AttendanceStatus.cancelled:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'CANCELLED';
        statusIcon = Icons.event_busy_rounded;
        break;
      case AttendanceStatus.proxy:
        statusColor = const Color(0xFF38BDF8);
        statusLabel = 'PROXY: ${session.proxySubjectCode ?? "SUB"}';
        statusIcon = Icons.swap_horiz_rounded;
        break;
      case AttendanceStatus.unmarked:
        statusColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        statusLabel = 'NOT MARKED';
        statusIcon = Icons.radio_button_unchecked_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: session.status == AttendanceStatus.unmarked
              ? (isDark ? AppColors.darkBorder : AppColors.border)
              : statusColor.withValues(alpha: 0.4),
          width: session.status == AttendanceStatus.unmarked ? 1.0 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Time Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${session.startTime} - ${session.endTime}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 3),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Popup Options Menu: Proxy, Cancel, Revert (only today)
              if (attendance.isSelectedDateToday)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  tooltip: 'Session options',
                  onSelected: (val) {
                    if (val == 'proxy') {
                      _showProxyDialog(context, session, attendance);
                    } else if (val == 'cancel') {
                      _showCancelDialog(context, session, attendance);
                    } else if (val == 'unmark') {
                      attendance.markClassSession(
                        recordId: session.id,
                        newStatus: AttendanceStatus.unmarked,
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'proxy',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Proxy / Substitute Lecture'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.event_busy_rounded, size: 16, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('Cancel Lecture (No Penalty)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'unmark',
                      child: Row(
                        children: [
                          Icon(Icons.restart_alt_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Reset to Unmarked'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Subject Name & Room
          Text(
            '${session.originalSubjectCode} • ${session.originalSubjectName}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${session.room}${session.faculty != null ? " • ${session.faculty}" : ""}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (session.status == AttendanceStatus.cancelled && session.cancellationReason != null) ...[
            const SizedBox(height: 4),
            Text(
              '⚠️ Cancelled: ${session.cancellationReason}',
              style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
            ),
          ],

          if (session.status == AttendanceStatus.proxy && session.proxySubjectName != null) ...[
            const SizedBox(height: 4),
            Text(
              '🔄 Substitute: ${session.proxySubjectCode} (${session.proxySubjectName})',
              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 8),

          // Action 1-Tap Buttons: Present & Absent
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: attendance.isSelectedDateToday
                      ? () {
                          attendance.markClassSession(
                            recordId: session.id,
                            newStatus: AttendanceStatus.present,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF10B981)),
                  label: const Text('Present', maxLines: 1, style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: session.status == AttendanceStatus.present
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : null,
                    side: BorderSide(
                      color: session.status == AttendanceStatus.present
                          ? const Color(0xFF10B981)
                          : const Color(0xFF10B981).withValues(alpha: 0.4),
                      width: session.status == AttendanceStatus.present ? 1.5 : 1.0,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: attendance.isSelectedDateToday
                      ? () {
                          attendance.markClassSession(
                            recordId: session.id,
                            newStatus: AttendanceStatus.absent,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
                  label: const Text('Absent', maxLines: 1, style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: session.status == AttendanceStatus.absent
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : null,
                    side: BorderSide(
                      color: session.status == AttendanceStatus.absent
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFEF4444).withValues(alpha: 0.4),
                      width: session.status == AttendanceStatus.absent ? 1.5 : 1.0,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
