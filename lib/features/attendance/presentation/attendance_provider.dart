import 'package:flutter/foundation.dart';
import '../../timetable/domain/models/timetable_entry.dart';
import '../data/repositories/local_attendance_repository.dart';
import '../domain/models/daily_class_attendance.dart';
import '../domain/models/subject_attendance.dart';
import '../domain/repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider({AttendanceRepository? repository})
      : _repository = repository ?? const LocalAttendanceRepository();

  final AttendanceRepository _repository;

  List<SubjectAttendance> _subjects = [];
  List<DailyClassAttendance> _dailyRecords = [];
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  bool _isLoading = false;
  String? _error;
  String _currentUserId = '';

  List<SubjectAttendance> get subjects => _subjects;
  List<DailyClassAttendance> get dailyRecords => _dailyRecords;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns true only if [_selectedDate] matches the current calendar day.
  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  int get totalAttended =>
      _subjects.fold(0, (sum, s) => sum + s.attendedClasses);

  int get totalClasses =>
      _subjects.fold(0, (sum, s) => sum + s.totalClasses);

  double get overallPercentage {
    if (totalClasses == 0) return 100.0;
    return (totalAttended / totalClasses) * 100.0;
  }

  bool get isOverallSafe => overallPercentage >= 75.0;

  int get atRiskCount => _subjects.where((s) => !s.isSafe).length;
  int get safeCount => _subjects.where((s) => s.isSafe).length;

  /// Returns the current AttendanceStatus for a given subject on today's date, or null.
  AttendanceStatus? getTodayStatusForSubject(String subjectId) {
    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);

    final session = _dailyRecords.lastWhere(
      (r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate == normalizedToday &&
            (r.effectiveSubjectId == subjectId || r.originalSubjectId == subjectId) &&
            r.status != AttendanceStatus.unmarked;
      },
      orElse: () => DailyClassAttendance(
        id: '',
        date: normalizedToday,
        timetableEntryId: '',
        weekday: 1,
        originalSubjectId: '',
        originalSubjectCode: '',
        originalSubjectName: '',
        startTime: '',
        endTime: '',
        room: '',
        status: AttendanceStatus.unmarked,
      ),
    );

    return session.status != AttendanceStatus.unmarked ? session.status : null;
  }

  /// Returns all lecture records scheduled or recorded for [_selectedDate].
  List<DailyClassAttendance> get todayClasses {
    final normalized = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final classes = _dailyRecords.where((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate == normalized;
    }).toList();

    classes.sort((a, b) => a.startTime.compareTo(b.startTime));
    return classes;
  }

  void setSelectedDate(DateTime date, [List<TimetableEntry>? schedule]) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    if (schedule != null) {
      syncTodayClasses(schedule, _selectedDate);
    } else {
      notifyListeners();
    }
  }

  Future<void> loadAttendance(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subjects = await _repository.getAttendanceList(userId);
      _dailyRecords = await _repository.getDailyAttendanceList(userId);
    } catch (e) {
      _error = 'Failed to load attendance records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Syncs master weekly timetable with today's date lecture sessions.
  void syncTodayClasses(List<TimetableEntry> weeklySchedule, [DateTime? targetDate]) {
    final date = targetDate ?? _selectedDate;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final weekday = date.weekday;

    final todayEntries = weeklySchedule.where((e) => e.weekday == weekday && e.isActive).toList();

    bool changed = false;

    for (final entry in todayEntries) {
      // Check if session record already exists for this date and timetable slot
      final exists = _dailyRecords.any((r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate == normalizedDate && r.timetableEntryId == entry.id;
      });

      if (!exists) {
        final newRecord = DailyClassAttendance(
          id: 'att_${normalizedDate.millisecondsSinceEpoch}_${entry.id}',
          date: normalizedDate,
          timetableEntryId: entry.id,
          weekday: entry.weekday,
          originalSubjectId: entry.subjectId,
          originalSubjectCode: entry.subjectCode,
          originalSubjectName: entry.subjectName,
          startTime: entry.startTime,
          endTime: entry.endTime,
          room: entry.room,
          faculty: entry.facultyName,
          status: AttendanceStatus.unmarked,
        );
        _dailyRecords.add(newRecord);
        changed = true;

        // Auto-register subject in attendance tracker if not present
        if (!_subjects.any((s) => s.id == entry.subjectId || s.subjectCode == entry.subjectCode)) {
          _subjects.add(
            SubjectAttendance(
              id: entry.subjectId,
              subjectCode: entry.subjectCode,
              subjectName: entry.subjectName,
              attendedClasses: 0,
              totalClasses: 0,
              targetPercentage: 75.0,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      }
    }

    if (changed) {
      _saveAll();
      notifyListeners();
    }
  }

  /// 1-Tap "Mark All for Today" as Present (Restricted strictly to the present date)
  Future<void> markAllTodayPresent(List<TimetableEntry> weeklySchedule) async {
    if (!isSelectedDateToday) {
      _error = 'Attendance can only be marked for the present date.';
      notifyListeners();
      return;
    }

    syncTodayClasses(weeklySchedule, _selectedDate);

    final currentToday = todayClasses;
    for (final classSession in currentToday) {
      if (classSession.status != AttendanceStatus.cancelled &&
          classSession.status != AttendanceStatus.present) {
        await markClassSession(
          recordId: classSession.id,
          newStatus: AttendanceStatus.present,
        );
      }
    }
  }

  /// Marks an individual class session (Present, Absent, Cancelled, Proxy).
  /// Strictly restricted to the present date.
  Future<void> markClassSession({
    required String recordId,
    required AttendanceStatus newStatus,
    String? proxySubjectId,
    String? proxySubjectCode,
    String? proxySubjectName,
    String? proxyFaculty,
    String? cancellationReason,
    String? notes,
  }) async {
    final index = _dailyRecords.indexWhere((r) => r.id == recordId);
    if (index == -1) return;

    final current = _dailyRecords[index];
    final now = DateTime.now();
    final isPresentDate = current.date.year == now.year &&
        current.date.month == now.month &&
        current.date.day == now.day;

    if (!isPresentDate) {
      _error = 'Attendance records can only be marked, unmarked, or updated for the present date.';
      notifyListeners();
      return;
    }

    final oldStatus = current.status;
    final oldEffectiveSubjectId = current.effectiveSubjectId;

    // 1. Revert previous status effect on subject tracker
    if (oldStatus == AttendanceStatus.present) {
      _adjustSubjectCount(oldEffectiveSubjectId, attendedDelta: -1, totalDelta: -1);
    } else if (oldStatus == AttendanceStatus.absent) {
      _adjustSubjectCount(oldEffectiveSubjectId, attendedDelta: 0, totalDelta: -1);
    }

    // 2. Compute new effective subject ID
    final effectiveProxyId = proxySubjectId ?? current.proxySubjectId;
    final effectiveProxyCode = proxySubjectCode ?? current.proxySubjectCode;
    final effectiveProxyName = proxySubjectName ?? current.proxySubjectName;

    final newEffectiveSubjectId = (newStatus == AttendanceStatus.proxy && effectiveProxyId != null)
        ? effectiveProxyId
        : current.originalSubjectId;

    // 3. Apply new status effect on target subject tracker
    if (newStatus == AttendanceStatus.present || (newStatus == AttendanceStatus.proxy && oldStatus != AttendanceStatus.present)) {
      // Auto-register proxy subject if needed
      if (newStatus == AttendanceStatus.proxy && effectiveProxyId != null && effectiveProxyCode != null) {
        _ensureSubjectRegistered(effectiveProxyId, effectiveProxyCode, effectiveProxyName ?? 'Proxy Subject');
      }
      _adjustSubjectCount(newEffectiveSubjectId, attendedDelta: 1, totalDelta: 1);
    } else if (newStatus == AttendanceStatus.absent) {
      _adjustSubjectCount(newEffectiveSubjectId, attendedDelta: 0, totalDelta: 1);
    }
    // Cancelled status: does NOT increment attended or total. Student is not penalized!

    // 4. Update the daily record
    _dailyRecords[index] = current.copyWith(
      status: newStatus,
      proxySubjectId: newStatus == AttendanceStatus.proxy ? effectiveProxyId : current.proxySubjectId,
      proxySubjectCode: newStatus == AttendanceStatus.proxy ? effectiveProxyCode : current.proxySubjectCode,
      proxySubjectName: newStatus == AttendanceStatus.proxy ? effectiveProxyName : current.proxySubjectName,
      proxyFaculty: proxyFaculty ?? current.proxyFaculty,
      cancellationReason: newStatus == AttendanceStatus.cancelled ? cancellationReason : current.cancellationReason,
      notes: notes ?? current.notes,
      markedAt: DateTime.now(),
    );

    notifyListeners();
    await _saveAll();
  }

  /// Sets a lecture session as a Proxy / Substitute lecture.
  Future<void> setProxyForSession({
    required String recordId,
    required String proxySubjectId,
    required String proxySubjectCode,
    required String proxySubjectName,
    String? proxyFaculty,
    required bool isPresent,
  }) async {
    await markClassSession(
      recordId: recordId,
      newStatus: isPresent ? AttendanceStatus.proxy : AttendanceStatus.absent,
      proxySubjectId: proxySubjectId,
      proxySubjectCode: proxySubjectCode,
      proxySubjectName: proxySubjectName,
      proxyFaculty: proxyFaculty,
      notes: 'Substitute lecture by $proxyFaculty',
    );
  }

  /// Cancels a lecture session with reason (0 penalty for student).
  Future<void> cancelClassSession({
    required String recordId,
    required String reason,
  }) async {
    await markClassSession(
      recordId: recordId,
      newStatus: AttendanceStatus.cancelled,
      cancellationReason: reason,
    );
  }

  /// Adds an altered or extra lecture for today's date.
  Future<void> addExtraClassToday({
    required String subjectId,
    required String subjectCode,
    required String subjectName,
    required String startTime,
    required String endTime,
    required String room,
    String? faculty,
    required bool isPresent,
  }) async {
    if (!isSelectedDateToday) {
      _error = 'Extra lectures can only be logged for the present date.';
      notifyListeners();
      return;
    }

    final normalizedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final extraId = 'extra_${normalizedDate.millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

    final extraRecord = DailyClassAttendance(
      id: extraId,
      date: normalizedDate,
      timetableEntryId: '',
      weekday: normalizedDate.weekday,
      originalSubjectId: subjectId,
      originalSubjectCode: subjectCode,
      originalSubjectName: subjectName,
      startTime: startTime,
      endTime: endTime,
      room: room,
      faculty: faculty,
      status: isPresent ? AttendanceStatus.present : AttendanceStatus.absent,
      isExtra: true,
      markedAt: DateTime.now(),
    );

    _dailyRecords.add(extraRecord);
    _ensureSubjectRegistered(subjectId, subjectCode, subjectName);
    _adjustSubjectCount(subjectId, attendedDelta: isPresent ? 1 : 0, totalDelta: 1);

    notifyListeners();
    await _saveAll();
  }

  void _ensureSubjectRegistered(String id, String code, String name) {
    if (!_subjects.any((s) => s.id == id || s.subjectCode == code)) {
      _subjects.add(
        SubjectAttendance(
          id: id,
          subjectCode: code,
          subjectName: name,
          attendedClasses: 0,
          totalClasses: 0,
          targetPercentage: 75.0,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  void _adjustSubjectCount(String subjectId, {required int attendedDelta, required int totalDelta}) {
    final idx = _subjects.indexKey(subjectId);
    if (idx != -1) {
      final cur = _subjects[idx];
      final newAttended = (cur.attendedClasses + attendedDelta).clamp(0, 9999);
      final newTotal = (cur.totalClasses + totalDelta).clamp(newAttended, 9999);

      _subjects[idx] = cur.copyWith(
        attendedClasses: newAttended,
        totalClasses: newTotal,
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<void> _saveAll() async {
    final uid = _currentUserId.isNotEmpty ? _currentUserId : 'guest_user';
    await _repository.saveAttendanceList(uid, _subjects);
    await _repository.saveDailyAttendanceList(uid, _dailyRecords);
  }

  /// Marks attendance for a subject for today.
  /// If today already has an active daily session for this subject, toggles/updates
  /// the existing session status instead of inflating totalClasses!
  /// If no session exists yet, creates one session for today.
  Future<void> markClass({
    required String subjectId,
    required bool isPresent,
  }) async {
    if (!isSelectedDateToday) {
      _error = 'Attendance can only be marked for the present date.';
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);

    // Check if there is an existing daily session for this subject today
    final todaySessionIndex = _dailyRecords.indexWhere((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate == normalizedToday &&
          (r.effectiveSubjectId == subjectId || r.originalSubjectId == subjectId);
    });

    if (todaySessionIndex != -1) {
      // Toggle or update the existing session today
      final existingSession = _dailyRecords[todaySessionIndex];
      final targetStatus = isPresent ? AttendanceStatus.present : AttendanceStatus.absent;

      // If already has this status, nothing to change
      if (existingSession.status == targetStatus) {
        return;
      }

      await markClassSession(
        recordId: existingSession.id,
        newStatus: targetStatus,
      );
    } else {
      // Create a new daily session for today and mark it
      final subIndex = _subjects.indexKey(subjectId);
      final sub = subIndex != -1 ? _subjects[subIndex] : null;
      final subjectCode = sub?.subjectCode ?? 'SUBJ';
      final subjectName = sub?.subjectName ?? 'Subject';

      final newRecordId = 'att_${normalizedToday.millisecondsSinceEpoch}_${subjectId}_${DateTime.now().microsecondsSinceEpoch}';
      final newRecord = DailyClassAttendance(
        id: newRecordId,
        date: normalizedToday,
        timetableEntryId: '',
        weekday: normalizedToday.weekday,
        originalSubjectId: subjectId,
        originalSubjectCode: subjectCode,
        originalSubjectName: subjectName,
        startTime: '09:00',
        endTime: '10:00',
        room: 'Lecture Hall',
        status: isPresent ? AttendanceStatus.present : AttendanceStatus.absent,
        markedAt: DateTime.now(),
      );

      _dailyRecords.add(newRecord);
      _adjustSubjectCount(subjectId, attendedDelta: isPresent ? 1 : 0, totalDelta: 1);
      notifyListeners();
      await _saveAll();
    }
  }

  /// Undoes/unmarks the last marked record for this subject today.
  Future<void> undoMarkClass({required String subjectId}) async {
    if (!isSelectedDateToday) {
      _error = 'Attendance can only be modified for the present date.';
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);

    final todaySessionIndex = _dailyRecords.lastIndexWhere((r) {
      final rDate = DateTime(r.date.year, r.date.month, r.date.day);
      return rDate == normalizedToday &&
          (r.effectiveSubjectId == subjectId || r.originalSubjectId == subjectId) &&
          r.status != AttendanceStatus.unmarked;
    });

    if (todaySessionIndex != -1) {
      final session = _dailyRecords[todaySessionIndex];
      final oldStatus = session.status;
      final oldSubjectId = session.effectiveSubjectId;

      // Revert count
      if (oldStatus == AttendanceStatus.present || oldStatus == AttendanceStatus.proxy) {
        _adjustSubjectCount(oldSubjectId, attendedDelta: -1, totalDelta: -1);
      } else if (oldStatus == AttendanceStatus.absent) {
        _adjustSubjectCount(oldSubjectId, attendedDelta: 0, totalDelta: -1);
      }

      _dailyRecords[todaySessionIndex] = session.copyWith(
        status: AttendanceStatus.unmarked,
        markedAt: null,
      );

      notifyListeners();
      await _saveAll();
    }
  }

  Future<void> addSubject(SubjectAttendance subject) async {
    final uid = _currentUserId.isNotEmpty ? _currentUserId : 'guest_user';
    _subjects.add(subject);
    notifyListeners();
    await _repository.saveAttendanceList(uid, _subjects);
  }

  Future<void> deleteSubject(String subjectId) async {
    final uid = _currentUserId.isNotEmpty ? _currentUserId : 'guest_user';
    _subjects.removeWhere((s) => s.id == subjectId);
    notifyListeners();
    await _repository.saveAttendanceList(uid, _subjects);
  }
}

extension on List<SubjectAttendance> {
  int indexKey(String id) {
    for (int i = 0; i < length; i++) {
      if (this[i].id == id) return i;
    }
    return -1;
  }
}

