import 'package:flutter/foundation.dart';
import '../../admin/domain/models/academic_calendar_event.dart';
import '../data/repositories/supabase_calendar_repository.dart';
import '../domain/repositories/calendar_repository.dart';

enum CalendarViewMode { month, week, day }

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({CalendarRepository? repository})
      : _repository = repository ?? const SupabaseCalendarRepository() {
    _initializeDates();
  }

  final CalendarRepository _repository;

  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  CalendarViewMode _viewMode = CalendarViewMode.month;
  String _selectedCategory = 'all';

  List<AcademicCalendarEvent> _events = [];
  bool _isLoading = false;
  String? _error;

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  CalendarViewMode get viewMode => _viewMode;
  String get selectedCategory => _selectedCategory;
  List<AcademicCalendarEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initializeDates() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  Future<void> loadEvents({String? branch, int? semester}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _repository.getAcademicCalendarEvents(
        branch: branch,
        semester: semester,
        eventType: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      _events = fetched;
    } catch (e) {
      _error = 'Failed to load calendar events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    if (_focusedMonth.year != date.year || _focusedMonth.month != date.month) {
      _focusedMonth = DateTime(date.year, date.month, 1);
    }
    notifyListeners();
  }

  void setFocusedMonth(DateTime month) {
    _focusedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    notifyListeners();
  }

  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    notifyListeners();
  }

  void jumpToToday() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
    notifyListeners();
  }

  void setViewMode(CalendarViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void filterCategory(String category) {
    _selectedCategory = category;
    loadEvents();
  }

  List<AcademicCalendarEvent> getEventsForDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return _events.where((event) {
      final start = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      if (event.endDate == null) {
        return start == target;
      }
      final end = DateTime(
        event.endDate!.year,
        event.endDate!.month,
        event.endDate!.day,
      );
      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();
  }

  Future<void> addEvent(AcademicCalendarEvent event) async {
    try {
      final saved = await _repository.addPersonalEvent(event);
      _events.add(saved);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save event: $e';
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _repository.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete event: $e';
      notifyListeners();
    }
  }
}
