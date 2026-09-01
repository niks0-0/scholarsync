import '../../domain/models/assignment_summary.dart';
import '../../domain/models/attendance_summary.dart';
import '../../domain/models/community_preview_summary.dart';
import '../../domain/models/dashboard_announcement.dart';
import '../../domain/models/event_summary.dart';
import '../../domain/models/reminder_summary.dart';
import '../../domain/models/today_schedule_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Isolated mock implementation of [DashboardRepository] for development and UI integration.
class MockDashboardRepository implements DashboardRepository {
  List<ReminderSummary> _mockReminders = [
    const ReminderSummary(
      id: 'rem-1',
      title: 'Submit Machine Learning lab report',
      reminderTime: '5:00 PM Today',
    ),
    const ReminderSummary(
      id: 'rem-2',
      title: 'Prepare presentation slides for Seminar',
      reminderTime: 'Tomorrow 10:00 AM',
    ),
  ];

  List<AssignmentSummary> _mockAssignments = [
    AssignmentSummary(
      id: 'asg-1',
      title: 'Data Structures Tree Traversal Implementation',
      subject: 'Data Structures & Algorithms',
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      priority: AssignmentPriority.urgent,
      status: AssignmentStatus.dueToday,
    ),
    AssignmentSummary(
      id: 'asg-2',
      title: 'DBMS SQL Query Optimization Worksheet',
      subject: 'Database Systems',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: AssignmentPriority.high,
      status: AssignmentStatus.upcoming,
    ),
  ];

  @override
  Future<List<TodayScheduleSummary>> getTodaySchedule(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const TodayScheduleSummary(
        id: 'cls-1',
        subject: 'Data Structures & Algorithms',
        startTime: '09:00 AM',
        endTime: '10:30 AM',
        room: 'Lab 302',
        faculty: 'Dr. Robert Smith',
        status: ClassStatus.completed,
      ),
      const TodayScheduleSummary(
        id: 'cls-2',
        subject: 'Database Management Systems',
        startTime: '11:00 AM',
        endTime: '12:30 PM',
        room: 'Hall A',
        faculty: 'Prof. Anita Sharma',
        status: ClassStatus.current,
      ),
      const TodayScheduleSummary(
        id: 'cls-3',
        subject: 'Software Engineering',
        startTime: '02:00 PM',
        endTime: '03:30 PM',
        room: 'Room 204',
        faculty: 'Dr. Michael Chen',
        isOnline: true,
        status: ClassStatus.upcoming,
      ),
    ];
  }

  @override
  Future<AttendanceSummary> getAttendanceSummary(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const AttendanceSummary(
      overallPercentage: 82.5,
      attendedClasses: 66,
      totalClasses: 80,
      requiredPercentage: 75.0,
      statusMessage: 'Attendance requirement satisfied (75% min)',
    );
  }

  @override
  Future<List<AssignmentSummary>> getUpcomingAssignments(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.from(_mockAssignments);
  }

  @override
  Future<List<EventSummary>> getUpcomingEvents(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      EventSummary(
        id: 'evt-1',
        title: 'Mid-Semester Examinations',
        eventDate: DateTime.now().add(const Duration(days: 5)),
        time: '09:30 AM',
        location: 'Main Exam Center',
        eventType: EventType.exam,
      ),
      EventSummary(
        id: 'evt-2',
        title: 'AI & Cloud Computing Workshop',
        eventDate: DateTime.now().add(const Duration(days: 12)),
        time: '02:00 PM',
        location: 'Auditorium 1',
        eventType: EventType.workshop,
      ),
    ];
  }

  @override
  Future<List<ReminderSummary>> getReminders(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockReminders);
  }

  @override
  Future<List<DashboardAnnouncement>> getAnnouncements(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      DashboardAnnouncement(
        id: 'anc-1',
        title: 'Revised Academic Calendar for Fall Semester',
        content: 'Please review the updated mid-term dates and project presentation deadlines.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        priority: 'high',
        isPinned: true,
      ),
      DashboardAnnouncement(
        id: 'anc-2',
        title: 'Library Extended Hours During Exam Week',
        content: 'The Central Library will remain open until 2:00 AM for study sessions.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        priority: 'normal',
      ),
    ];
  }

  @override
  Future<CommunityPreviewSummary> getCommunityPreview(String firebaseUid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const CommunityPreviewSummary(
      recentSubjectActivity: 'Computer Science Study Group',
      recentDiscussionTitle: 'Best approaches for Graph Traversal Optimization?',
      unreadCount: 3,
      authorName: 'Alex Mercer',
    );
  }

  @override
  Future<void> toggleReminderCompletion(String firebaseUid, String reminderId, bool isCompleted) async {
    _mockReminders = _mockReminders.map((r) {
      if (r.id == reminderId) return r.copyWith(isCompleted: isCompleted);
      return r;
    }).toList();
  }

  @override
  Future<void> toggleAssignmentCompletion(String firebaseUid, String assignmentId, bool isCompleted) async {
    _mockAssignments = _mockAssignments.map((a) {
      if (a.id == assignmentId) return a.copyWith(isCompleted: isCompleted);
      return a;
    }).toList();
  }
}
