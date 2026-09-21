import 'package:flutter/foundation.dart';
import '../data/repositories/local_attendance_repository.dart';
import '../domain/models/subject_attendance.dart';
import '../domain/repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider({AttendanceRepository? repository})
      : _repository = repository ?? const LocalAttendanceRepository();

  final AttendanceRepository _repository;

  List<SubjectAttendance> _subjects = [];
  bool _isLoading = false;
  String? _error;
  String _currentUserId = '';

  List<SubjectAttendance> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> loadAttendance(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subjects = await _repository.getAttendanceList(userId);
    } catch (e) {
      _error = 'Failed to load attendance records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markClass({
    required String subjectId,
    required bool isPresent,
  }) async {
    if (_currentUserId.isEmpty) return;

    final index = _subjects.indexKey(subjectId);
    if (index != -1) {
      final current = _subjects[index];
      final updated = current.copyWith(
        attendedClasses: isPresent
            ? current.attendedClasses + 1
            : current.attendedClasses,
        totalClasses: current.totalClasses + 1,
        lastUpdated: DateTime.now(),
      );

      _subjects[index] = updated;
      notifyListeners();

      await _repository.saveAttendanceList(_currentUserId, _subjects);
    }
  }

  Future<void> undoMarkClass({required String subjectId}) async {
    if (_currentUserId.isEmpty) return;

    final index = _subjects.indexKey(subjectId);
    if (index != -1) {
      final current = _subjects[index];
      if (current.totalClasses > 0) {
        final updated = current.copyWith(
          attendedClasses: current.attendedClasses > 0
              ? current.attendedClasses - 1
              : 0,
          totalClasses: current.totalClasses - 1,
          lastUpdated: DateTime.now(),
        );

        _subjects[index] = updated;
        notifyListeners();

        await _repository.saveAttendanceList(_currentUserId, _subjects);
      }
    }
  }

  Future<void> addSubject(SubjectAttendance subject) async {
    if (_currentUserId.isEmpty) return;
    _subjects.add(subject);
    notifyListeners();
    await _repository.saveAttendanceList(_currentUserId, _subjects);
  }

  Future<void> deleteSubject(String subjectId) async {
    if (_currentUserId.isEmpty) return;
    _subjects.removeWhere((s) => s.id == subjectId);
    notifyListeners();
    await _repository.saveAttendanceList(_currentUserId, _subjects);
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
