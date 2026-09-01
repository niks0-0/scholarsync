import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:scholarsync/features/dashboard/domain/models/attendance_summary.dart';
import 'package:scholarsync/features/dashboard/domain/models/today_schedule_summary.dart';
import 'package:scholarsync/features/dashboard/presentation/dashboard_provider.dart';

void main() {
  late DashboardProvider dashboardProvider;
  late MockDashboardRepository mockRepo;

  setUp(() {
    mockRepo = MockDashboardRepository();
    dashboardProvider = DashboardProvider(repository: mockRepo);
  });

  group('Dashboard Summary Models & Business Logic Tests', () {
    test('TodayScheduleSummary model serialization works', () {
      const schedule = TodayScheduleSummary(
        id: '1',
        subject: 'Algorithms',
        startTime: '09:00 AM',
        endTime: '10:00 AM',
        room: 'Lab 1',
        faculty: 'Dr. Smith',
        status: ClassStatus.current,
      );

      final json = schedule.toJson();
      final parsed = TodayScheduleSummary.fromJson(json);

      expect(parsed.id, equals('1'));
      expect(parsed.subject, equals('Algorithms'));
      expect(parsed.status, equals(ClassStatus.current));
    });

    test('AttendanceSummary calculates warning state correctly', () {
      const normalAttendance = AttendanceSummary(
        overallPercentage: 80.0,
        attendedClasses: 8,
        totalClasses: 10,
        requiredPercentage: 75.0,
      );
      expect(normalAttendance.isWarning, isFalse);

      const warningAttendance = AttendanceSummary(
        overallPercentage: 65.0,
        attendedClasses: 6,
        totalClasses: 10,
        requiredPercentage: 75.0,
      );
      expect(warningAttendance.isWarning, isTrue);
    });

    test('Greeting text adapts to local time', () {
      final morning = DateTime(2026, 8, 14, 9, 0);
      final afternoon = DateTime(2026, 8, 14, 14, 0);
      final evening = DateTime(2026, 8, 14, 19, 0);

      expect(DashboardProvider.getGreetingText(morning), equals('Good Morning'));
      expect(DashboardProvider.getGreetingText(afternoon), equals('Good Afternoon'));
      expect(DashboardProvider.getGreetingText(evening), equals('Good Evening'));
    });
  });

  group('DashboardProvider Async Data Fetching Tests', () {
    test('loadDashboard populates all summaries independently', () async {
      await dashboardProvider.loadDashboard('test_uid_123');

      expect(dashboardProvider.schedule.length, equals(3));
      expect(dashboardProvider.attendance, isNotNull);
      expect(dashboardProvider.attendance!.overallPercentage, equals(82.5));
      expect(dashboardProvider.assignments.length, equals(2));
      expect(dashboardProvider.events.length, equals(2));
      expect(dashboardProvider.reminders.length, equals(2));
      expect(dashboardProvider.announcements.length, equals(2));
      expect(dashboardProvider.communityPreview, isNotNull);
    });

    test('toggleReminder updates reminder completion state', () async {
      await dashboardProvider.loadDashboard('test_uid_123');
      final firstReminder = dashboardProvider.reminders.first;

      await dashboardProvider.toggleReminder('test_uid_123', firstReminder.id, true);

      final updated = dashboardProvider.reminders.firstWhere((r) => r.id == firstReminder.id);
      expect(updated.isCompleted, isTrue);
    });

    test('toggleAssignment updates assignment completion state', () async {
      await dashboardProvider.loadDashboard('test_uid_123');
      final firstAsg = dashboardProvider.assignments.first;

      await dashboardProvider.toggleAssignment('test_uid_123', firstAsg.id, true);

      final updated = dashboardProvider.assignments.firstWhere((a) => a.id == firstAsg.id);
      expect(updated.isCompleted, isTrue);
    });
  });
}
