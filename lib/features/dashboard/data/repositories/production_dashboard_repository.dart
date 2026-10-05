import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../attendance/domain/repositories/attendance_repository.dart';
import '../../../calendar/domain/repositories/calendar_repository.dart';
import '../../../timetable/domain/models/timetable_entry.dart';
import '../../../timetable/domain/repositories/timetable_repository.dart';
import '../../domain/models/assignment_summary.dart';
import '../../domain/models/attendance_summary.dart';
import '../../domain/models/community_preview_summary.dart';
import '../../domain/models/dashboard_announcement.dart';
import '../../domain/models/event_summary.dart';
import '../../domain/models/reminder_summary.dart';
import '../../domain/models/today_schedule_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Production implementation of [DashboardRepository] that aggregates live data
/// from the student's real [TimetableRepository], [AttendanceRepository],
/// [CalendarRepository], and locally persisted student tasks.
class ProductionDashboardRepository implements DashboardRepository {
  const ProductionDashboardRepository({
    required this.timetableRepository,
    required this.attendanceRepository,
    required this.calendarRepository,
  });

  final TimetableRepository timetableRepository;
  final AttendanceRepository attendanceRepository;
  final CalendarRepository calendarRepository;

  @override
  Future<List<TodayScheduleSummary>> getTodaySchedule(String firebaseUid) async {
    try {
      final entries = await timetableRepository.getTodaySchedule(firebaseUid);
      final now = DateTime.now();

      return entries.map((entry) {
        final status = entry.calculateStatus(now);
        ClassStatus mappedStatus;
        switch (status) {
          case TimetableClassStatus.current:
            mappedStatus = ClassStatus.current;
            break;
          case TimetableClassStatus.completed:
            mappedStatus = ClassStatus.completed;
            break;
          case TimetableClassStatus.upcoming:
            mappedStatus = ClassStatus.upcoming;
            break;
        }

        return TodayScheduleSummary(
          id: entry.id,
          subject: entry.subjectName,
          startTime: entry.startTime,
          endTime: entry.endTime,
          room: entry.room,
          faculty: entry.facultyName ?? 'Faculty',
          isOnline: entry.mode.toLowerCase() == 'online',
          status: mappedStatus,
        );
      }).toList();
    } catch (e) {
      debugPrint('ProductionDashboardRepository.getTodaySchedule error: $e');
      return [];
    }
  }

  @override
  Future<AttendanceSummary> getAttendanceSummary(String firebaseUid) async {
    try {
      final list = await attendanceRepository.getAttendanceList(firebaseUid);
      if (list.isEmpty) {
        return const AttendanceSummary(
          overallPercentage: 100.0,
          attendedClasses: 0,
          totalClasses: 0,
          requiredPercentage: 75.0,
          statusMessage: 'Ready to track — 0 classes logged',
        );
      }

      int attended = 0;
      int total = 0;
      for (final item in list) {
        attended += item.attendedClasses;
        total += item.totalClasses;
      }

      final percentage = total == 0 ? 100.0 : (attended / total) * 100.0;
      final isWarning = percentage < 75.0;

      return AttendanceSummary(
        overallPercentage: double.parse(percentage.toStringAsFixed(1)),
        attendedClasses: attended,
        totalClasses: total,
        requiredPercentage: 75.0,
        statusMessage: isWarning
            ? 'Attendance alert: Below 75% target'
            : 'Good standing: Above 75% threshold',
      );
    } catch (e) {
      debugPrint('ProductionDashboardRepository.getAttendanceSummary error: $e');
      return const AttendanceSummary(
        overallPercentage: 100.0,
        attendedClasses: 0,
        totalClasses: 0,
      );
    }
  }

  @override
  Future<List<AssignmentSummary>> getUpcomingAssignments(String firebaseUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'scholarsync_assignments_$firebaseUid';
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((e) => AssignmentSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading assignments: $e');
    }

    return [];
  }

  @override
  Future<List<EventSummary>> getUpcomingEvents(String firebaseUid) async {
    try {
      final events = await calendarRepository.getAcademicCalendarEvents();
      final now = DateTime.now();

      final upcoming = events
          .where((e) => e.startDate.isAfter(now.subtract(const Duration(days: 1))))
          .take(5);

      return upcoming.map((e) {
        EventType type = EventType.exam;
        final t = e.eventType.toLowerCase();
        if (t.contains('workshop') || t.contains('seminar')) {
          type = EventType.workshop;
        } else if (t.contains('holiday')) {
          type = EventType.holiday;
        } else if (t.contains('deadline')) {
          type = EventType.deadline;
        }

        return EventSummary(
          id: e.id,
          title: e.title,
          eventDate: e.startDate,
          time: 'All Day',
          location: e.description ?? 'Main Campus',
          eventType: type,
        );
      }).toList();
    } catch (e) {
      debugPrint('ProductionDashboardRepository.getUpcomingEvents error: $e');
      return [];
    }
  }

  @override
  Future<List<ReminderSummary>> getReminders(String firebaseUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'scholarsync_reminders_$firebaseUid';
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((e) => ReminderSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error reading reminders: $e');
    }

    return [];
  }

  @override
  Future<List<DashboardAnnouncement>> getAnnouncements(String firebaseUid) async {
    return [
      DashboardAnnouncement(
        id: 'anc-welcome',
        title: 'Welcome to ScholarSync',
        content: 'Your academic workspace is fully configured. Check your daily schedule and attendance.',
        timestamp: DateTime.now(),
        priority: 'high',
        isPinned: true,
      ),
    ];
  }

  @override
  Future<CommunityPreviewSummary> getCommunityPreview(String firebaseUid) async {
    return const CommunityPreviewSummary(
      recentSubjectActivity: 'Campus Academic Forum',
      recentDiscussionTitle: 'Semester schedule & lecture updates available',
      unreadCount: 0,
      authorName: 'Academic Community',
    );
  }

  @override
  Future<void> toggleReminderCompletion(
      String firebaseUid, String reminderId, bool isCompleted) async {
    try {
      final reminders = await getReminders(firebaseUid);
      final updated = reminders.map((r) {
        if (r.id == reminderId) return r.copyWith(isCompleted: isCompleted);
        return r;
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'scholarsync_reminders_$firebaseUid',
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
    }
  }

  @override
  Future<void> toggleAssignmentCompletion(
      String firebaseUid, String assignmentId, bool isCompleted) async {
    try {
      final assignments = await getUpcomingAssignments(firebaseUid);
      final updated = assignments.map((a) {
        if (a.id == assignmentId) return a.copyWith(isCompleted: isCompleted);
        return a;
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'scholarsync_assignments_$firebaseUid',
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error toggling assignment: $e');
    }
  }
}
