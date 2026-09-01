import '../models/assignment_summary.dart';
import '../models/attendance_summary.dart';
import '../models/community_preview_summary.dart';
import '../models/dashboard_announcement.dart';
import '../models/event_summary.dart';
import '../models/reminder_summary.dart';
import '../models/today_schedule_summary.dart';

/// Clean contract for Dashboard summary data requests.
///
/// Serves as an integration layer connecting the Home Dashboard UI to future module repositories.
abstract class DashboardRepository {
  Future<List<TodayScheduleSummary>> getTodaySchedule(String firebaseUid);
  Future<AttendanceSummary> getAttendanceSummary(String firebaseUid);
  Future<List<AssignmentSummary>> getUpcomingAssignments(String firebaseUid);
  Future<List<EventSummary>> getUpcomingEvents(String firebaseUid);
  Future<List<ReminderSummary>> getReminders(String firebaseUid);
  Future<List<DashboardAnnouncement>> getAnnouncements(String firebaseUid);
  Future<CommunityPreviewSummary> getCommunityPreview(String firebaseUid);
  Future<void> toggleReminderCompletion(String firebaseUid, String reminderId, bool isCompleted);
  Future<void> toggleAssignmentCompletion(String firebaseUid, String assignmentId, bool isCompleted);
}
