import 'package:flutter/foundation.dart';
import '../data/repositories/supabase_timetable_repository.dart';
import '../domain/models/timetable_entry.dart';
import '../domain/repositories/timetable_repository.dart';

enum TimetableStateStatus { initial, loading, loaded, saving, error }

class TimetableProvider extends ChangeNotifier {
  TimetableProvider({TimetableRepository? repository})
      : _repository = repository ?? const SupabaseTimetableRepository();

  final TimetableRepository _repository;

  TimetableStateStatus _status = TimetableStateStatus.initial;
  String? _error;

  int _selectedWeekday = DateTime.now().weekday;
  List<TimetableEntry> _weeklySchedule = [];
  String _searchQuery = '';
  String _modeFilter = 'All';

  TimetableStateStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == TimetableStateStatus.loading;
  int get selectedWeekday => _selectedWeekday;
  List<TimetableEntry> get weeklySchedule => _weeklySchedule;
  String get searchQuery => _searchQuery;
  String get modeFilter => _modeFilter;

  /// Schedule entries for the currently selected weekday.
  List<TimetableEntry> get selectedDaySchedule {
    final filtered = _weeklySchedule.where((e) => e.weekday == _selectedWeekday).toList();
    if (_searchQuery.isEmpty && _modeFilter == 'All') return filtered;

    return filtered.where((e) {
      final matchesQuery = _searchQuery.isEmpty ||
          e.subjectName.toLowerCase().contains(_searchQuery) ||
          e.subjectCode.toLowerCase().contains(_searchQuery) ||
          e.room.toLowerCase().contains(_searchQuery) ||
          (e.facultyName?.toLowerCase().contains(_searchQuery) ?? false);

      final matchesMode = _modeFilter == 'All' || e.mode == _modeFilter;
      return matchesQuery && matchesMode;
    }).toList();
  }

  /// Current ongoing class for today.
  TimetableEntry? get currentClass {
    final now = DateTime.now();
    for (final e in selectedDaySchedule) {
      if (e.calculateStatus(now) == TimetableClassStatus.current) return e;
    }
    return null;
  }

  /// Next upcoming class for today.
  TimetableEntry? get nextClass {
    final now = DateTime.now();
    for (final e in selectedDaySchedule) {
      if (e.calculateStatus(now) == TimetableClassStatus.upcoming) return e;
    }
    return null;
  }

  List<TimetableEntry> get remainingClasses {
    final now = DateTime.now();
    return selectedDaySchedule.where((e) => e.calculateStatus(now) != TimetableClassStatus.completed).toList();
  }

  List<TimetableEntry> get completedClasses {
    final now = DateTime.now();
    return selectedDaySchedule.where((e) => e.calculateStatus(now) == TimetableClassStatus.completed).toList();
  }

  void setSelectedWeekday(int day) {
    _selectedWeekday = day;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q.trim().toLowerCase();
    notifyListeners();
  }

  void setModeFilter(String mode) {
    _modeFilter = mode;
    notifyListeners();
  }

  /// Loads student's complete weekly academic schedule.
  Future<void> loadWeeklySchedule(String firebaseUid) async {
    _status = TimetableStateStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _weeklySchedule = await _repository.getWeeklySchedule(firebaseUid);
      _status = TimetableStateStatus.loaded;
    } catch (e) {
      _error = 'Failed to load timetable schedule.';
      _status = TimetableStateStatus.error;
    }
    notifyListeners();
  }

  /// Validates start and end time strings ("HH:mm"). Returns error string or null if valid.
  static String? validateClassTimes(String startTime, String endTime) {
    try {
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();
      final startTotal = startParts[0] * 60 + startParts[1];
      final endTotal = endParts[0] * 60 + endParts[1];

      if (startTotal >= endTotal) {
        return 'Start time must be strictly earlier than End time.';
      }
      return null;
    } catch (_) {
      return 'Invalid time format. Use HH:mm format.';
    }
  }

  /// Creates a new timetable entry.
  Future<bool> createClassEntry(TimetableEntry entry) async {
    final validation = validateClassTimes(entry.startTime, entry.endTime);
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return false;
    }

    _status = TimetableStateStatus.saving;
    notifyListeners();

    try {
      final created = await _repository.createEntry(entry);
      _weeklySchedule.add(created);
      _status = TimetableStateStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save timetable entry: $e';
      _status = TimetableStateStatus.loaded;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing timetable entry.
  Future<bool> updateClassEntry(TimetableEntry entry) async {
    final validation = validateClassTimes(entry.startTime, entry.endTime);
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return false;
    }

    _status = TimetableStateStatus.saving;
    notifyListeners();

    try {
      final updated = await _repository.updateEntry(entry);
      final index = _weeklySchedule.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _weeklySchedule[index] = updated;
      }
      _status = TimetableStateStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update timetable entry: $e';
      _status = TimetableStateStatus.loaded;
      notifyListeners();
      return false;
    }
  }

  /// Deletes a timetable entry.
  Future<void> deleteClassEntry(String firebaseUid, String entryId) async {
    try {
      await _repository.deleteEntry(firebaseUid, entryId);
      _weeklySchedule.removeWhere((e) => e.id == entryId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting class entry: $e');
    }
  }

  /// Duplicates a class entry to another weekday.
  Future<void> duplicateClassEntry(String firebaseUid, String entryId, int targetWeekday) async {
    try {
      final dup = await _repository.duplicateEntry(firebaseUid, entryId, targetWeekday);
      _weeklySchedule.add(dup);
      notifyListeners();
    } catch (e) {
      debugPrint('Error duplicating class entry: $e');
    }
  }
}
