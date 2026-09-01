import 'package:flutter/foundation.dart';
import '../data/repositories/mock_dashboard_repository.dart';
import '../domain/models/assignment_summary.dart';
import '../domain/models/attendance_summary.dart';
import '../domain/models/community_preview_summary.dart';
import '../domain/models/dashboard_announcement.dart';
import '../domain/models/event_summary.dart';
import '../domain/models/reminder_summary.dart';
import '../domain/models/today_schedule_summary.dart';
import '../domain/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? MockDashboardRepository();

  final DashboardRepository _repository;

  // Independent Per-Widget Data States
  List<TodayScheduleSummary> _schedule = [];
  bool _isScheduleLoading = false;
  String? _scheduleError;

  AttendanceSummary? _attendance;
  bool _isAttendanceLoading = false;
  String? _attendanceError;

  List<AssignmentSummary> _assignments = [];
  bool _isAssignmentsLoading = false;
  String? _assignmentsError;

  List<EventSummary> _events = [];
  bool _isEventsLoading = false;
  String? _eventsError;

  List<ReminderSummary> _reminders = [];
  bool _isRemindersLoading = false;
  String? _remindersError;

  List<DashboardAnnouncement> _announcements = [];
  bool _isAnnouncementsLoading = false;
  String? _announcementsError;

  CommunityPreviewSummary? _communityPreview;
  bool _isCommunityLoading = false;
  String? _communityError;

  String? _lastSyncedTime;
  String? get lastSyncedTime => _lastSyncedTime;

  // Getters
  List<TodayScheduleSummary> get schedule => _schedule;
  bool get isScheduleLoading => _isScheduleLoading;
  String? get scheduleError => _scheduleError;

  AttendanceSummary? get attendance => _attendance;
  bool get isAttendanceLoading => _isAttendanceLoading;
  String? get attendanceError => _attendanceError;

  List<AssignmentSummary> get assignments => _assignments;
  bool get isAssignmentsLoading => _isAssignmentsLoading;
  String? get assignmentsError => _assignmentsError;

  List<EventSummary> get events => _events;
  bool get isEventsLoading => _isEventsLoading;
  String? get eventsError => _eventsError;

  List<ReminderSummary> get reminders => _reminders;
  bool get isRemindersLoading => _isRemindersLoading;
  String? get remindersError => _remindersError;

  List<DashboardAnnouncement> get announcements => _announcements;
  bool get isAnnouncementsLoading => _isAnnouncementsLoading;
  String? get announcementsError => _announcementsError;

  CommunityPreviewSummary? get communityPreview => _communityPreview;
  bool get isCommunityLoading => _isCommunityLoading;
  String? get communityError => _communityError;

  /// Time-based greeting helper.
  static String getGreetingText([DateTime? time]) {
    final now = time ?? DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Initial load for dashboard summaries.
  Future<void> loadDashboard(String firebaseUid) async {
    await Future.wait([
      fetchTodaySchedule(firebaseUid),
      fetchAttendanceSummary(firebaseUid),
      fetchUpcomingAssignments(firebaseUid),
      fetchUpcomingEvents(firebaseUid),
      fetchReminders(firebaseUid),
      fetchAnnouncements(firebaseUid),
      fetchCommunityPreview(firebaseUid),
    ]);
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    _lastSyncedTime = '$hour:$min $period';
    notifyListeners();
  }

  /// Refreshes all dashboard summaries independently.
  Future<void> refreshAll(String firebaseUid) async {
    await loadDashboard(firebaseUid);
  }

  // ── Independent Fetchers ──────────────────────────────────────────────────

  Future<void> fetchTodaySchedule(String firebaseUid) async {
    _isScheduleLoading = true;
    _scheduleError = null;
    notifyListeners();
    try {
      _schedule = await _repository.getTodaySchedule(firebaseUid);
    } catch (e) {
      _scheduleError = 'Failed to load today schedule';
    } finally {
      _isScheduleLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceSummary(String firebaseUid) async {
    _isAttendanceLoading = true;
    _attendanceError = null;
    notifyListeners();
    try {
      _attendance = await _repository.getAttendanceSummary(firebaseUid);
    } catch (e) {
      _attendanceError = 'Failed to load attendance summary';
    } finally {
      _isAttendanceLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUpcomingAssignments(String firebaseUid) async {
    _isAssignmentsLoading = true;
    _assignmentsError = null;
    notifyListeners();
    try {
      _assignments = await _repository.getUpcomingAssignments(firebaseUid);
    } catch (e) {
      _assignmentsError = 'Failed to load upcoming assignments';
    } finally {
      _isAssignmentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUpcomingEvents(String firebaseUid) async {
    _isEventsLoading = true;
    _eventsError = null;
    notifyListeners();
    try {
      _events = await _repository.getUpcomingEvents(firebaseUid);
    } catch (e) {
      _eventsError = 'Failed to load upcoming events';
    } finally {
      _isEventsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReminders(String firebaseUid) async {
    _isRemindersLoading = true;
    _remindersError = null;
    notifyListeners();
    try {
      _reminders = await _repository.getReminders(firebaseUid);
    } catch (e) {
      _remindersError = 'Failed to load reminders';
    } finally {
      _isRemindersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnnouncements(String firebaseUid) async {
    _isAnnouncementsLoading = true;
    _announcementsError = null;
    notifyListeners();
    try {
      _announcements = await _repository.getAnnouncements(firebaseUid);
    } catch (e) {
      _announcementsError = 'Failed to load announcements';
    } finally {
      _isAnnouncementsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommunityPreview(String firebaseUid) async {
    _isCommunityLoading = true;
    _communityError = null;
    notifyListeners();
    try {
      _communityPreview = await _repository.getCommunityPreview(firebaseUid);
    } catch (e) {
      _communityError = 'Failed to load community preview';
    } finally {
      _isCommunityLoading = false;
      notifyListeners();
    }
  }

  // ── Card Quick Actions ────────────────────────────────────────────────────

  Future<void> toggleReminder(String firebaseUid, String reminderId, bool isCompleted) async {
    try {
      await _repository.toggleReminderCompletion(firebaseUid, reminderId, isCompleted);
      _reminders = _reminders.map((r) {
        if (r.id == reminderId) return r.copyWith(isCompleted: isCompleted);
        return r;
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to toggle reminder completion: $e');
    }
  }

  Future<void> toggleAssignment(String firebaseUid, String assignmentId, bool isCompleted) async {
    try {
      await _repository.toggleAssignmentCompletion(firebaseUid, assignmentId, isCompleted);
      _assignments = _assignments.map((a) {
        if (a.id == assignmentId) return a.copyWith(isCompleted: isCompleted);
        return a;
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to toggle assignment completion: $e');
    }
  }
}
