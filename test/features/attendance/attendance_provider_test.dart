import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/attendance/domain/models/daily_class_attendance.dart';
import 'package:scholarsync/features/attendance/domain/models/subject_attendance.dart';
import 'package:scholarsync/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:scholarsync/features/attendance/presentation/attendance_provider.dart';
import 'package:scholarsync/features/timetable/domain/models/timetable_entry.dart';

class MockAttendanceRepository implements AttendanceRepository {
  List<SubjectAttendance> items = [
    const SubjectAttendance(
      id: 'sub-1',
      subjectCode: 'CS301',
      subjectName: 'Data Structures',
      attendedClasses: 30,
      totalClasses: 35,
      targetPercentage: 75.0,
    ),
    const SubjectAttendance(
      id: 'sub-2',
      subjectCode: 'CS302',
      subjectName: 'Computer Networks',
      attendedClasses: 18,
      totalClasses: 30,
      targetPercentage: 75.0,
    ),
  ];

  List<DailyClassAttendance> dailyItems = [];

  @override
  Future<List<SubjectAttendance>> getAttendanceList(String userId) async {
    return List.from(items);
  }

  @override
  Future<void> saveAttendanceList(
      String userId, List<SubjectAttendance> list) async {
    items = List.from(list);
  }

  @override
  Future<List<DailyClassAttendance>> getDailyAttendanceList(String userId) async {
    return List.from(dailyItems);
  }

  @override
  Future<void> saveDailyAttendanceList(
      String userId, List<DailyClassAttendance> list) async {
    dailyItems = List.from(list);
  }

  @override
  Future<void> markAttendance({
    required String userId,
    required String subjectId,
    required bool isPresent,
  }) async {
    // mock
  }

  @override
  Future<void> resetSubjectAttendance(String userId, String subjectId) async {
    // mock
  }
}

void main() {
  group('SubjectAttendance Model Formula Tests', () {
    test('Calculates percentage correctly', () {
      const sub = SubjectAttendance(
        id: '1',
        subjectCode: 'CS101',
        subjectName: 'Test',
        attendedClasses: 24,
        totalClasses: 30,
      );
      expect(sub.percentage, 80.0);
      expect(sub.isSafe, true);
    });

    test('Safe bunk count calculates remaining skippable classes for 75%', () {
      // 30 / 35 = 85.7%. With 75% target:
      // max total = 30 / 0.75 = 40.
      // safe bunks = 40 - 35 = 5 classes.
      const sub = SubjectAttendance(
        id: '1',
        subjectCode: 'CS101',
        subjectName: 'Test',
        attendedClasses: 30,
        totalClasses: 35,
        targetPercentage: 75.0,
      );
      expect(sub.safeBunksCount, 5);
      expect(sub.requiredClassesCount, 0);
    });

    test('Required classes count calculates needed classes to hit 75%', () {
      // 18 / 30 = 60%. Below 75%.
      // numerator = (0.75 * 30) - 18 = 22.5 - 18 = 4.5
      // denominator = 0.25 -> 4.5 / 0.25 = 18 classes needed.
      const sub = SubjectAttendance(
        id: '2',
        subjectCode: 'CS102',
        subjectName: 'Test',
        attendedClasses: 18,
        totalClasses: 30,
        targetPercentage: 75.0,
      );
      expect(sub.isSafe, false);
      expect(sub.safeBunksCount, 0);
      expect(sub.requiredClassesCount, 18);
    });
  });

  group('AttendanceProvider Tests', () {
    late AttendanceProvider provider;
    late MockAttendanceRepository mockRepo;

    setUp(() {
      mockRepo = MockAttendanceRepository();
      provider = AttendanceProvider(repository: mockRepo);
    });

    test('Loads attendance and computes metrics correctly', () async {
      await provider.loadAttendance('user-123');

      expect(provider.subjects.length, 2);
      expect(provider.totalAttended, 48);
      expect(provider.totalClasses, 65);
      expect(provider.safeCount, 1);
      expect(provider.atRiskCount, 1);
      expect(provider.overallPercentage, closeTo(73.84, 0.1));
    });

    test('markClass updates attendance and triggers notifyListeners', () async {
      await provider.loadAttendance('user-123');

      await provider.markClass(subjectId: 'sub-2', isPresent: true);
      final updated = provider.subjects.firstWhere((s) => s.id == 'sub-2');

      expect(updated.attendedClasses, 19);
      expect(updated.totalClasses, 31);
    });

    test('undoMarkClass reverts last marked class', () async {
      await provider.loadAttendance('user-123');

      await provider.markClass(subjectId: 'sub-2', isPresent: true);
      await provider.undoMarkClass(subjectId: 'sub-2');

      final updated = provider.subjects.firstWhere((s) => s.id == 'sub-2');
      expect(updated.attendedClasses, 18);
      expect(updated.totalClasses, 30);
    });

    test('syncTodayClasses populates daily sessions from master timetable', () async {
      await provider.loadAttendance('user-123');

      final today = provider.selectedDate;
      final sampleSchedule = [
        TimetableEntry(
          id: 'tt-1',
          userId: 'user-123',
          subjectId: 'sub-1',
          weekday: today.weekday,
          startTime: '09:00',
          endTime: '10:30',
          room: 'Lab 101',
        ),
        TimetableEntry(
          id: 'tt-2',
          userId: 'user-123',
          subjectId: 'sub-2',
          weekday: today.weekday,
          startTime: '11:00',
          endTime: '12:30',
          room: 'Hall A',
        ),
      ];

      provider.syncTodayClasses(sampleSchedule);

      expect(provider.todayClasses.length, 2);
      expect(provider.todayClasses.first.originalSubjectId, 'sub-1');
      expect(provider.todayClasses.first.status, AttendanceStatus.unmarked);
    });

    test('markAllTodayPresent marks all classes and increments subject attendance', () async {
      await provider.loadAttendance('user-123');

      final today = provider.selectedDate;
      final sampleSchedule = [
        TimetableEntry(
          id: 'tt-1',
          userId: 'user-123',
          subjectId: 'sub-1',
          weekday: today.weekday,
          startTime: '09:00',
          endTime: '10:30',
          room: 'Lab 101',
        ),
      ];

      await provider.markAllTodayPresent(sampleSchedule);

      final session = provider.todayClasses.first;
      expect(session.status, AttendanceStatus.present);

      final updatedSub = provider.subjects.firstWhere((s) => s.id == 'sub-1');
      expect(updatedSub.attendedClasses, 31);
      expect(updatedSub.totalClasses, 36);
    });

    test('cancelClassSession excludes lecture from total count without penalizing student', () async {
      await provider.loadAttendance('user-123');

      final today = provider.selectedDate;
      final sampleSchedule = [
        TimetableEntry(
          id: 'tt-1',
          userId: 'user-123',
          subjectId: 'sub-1',
          weekday: today.weekday,
          startTime: '09:00',
          endTime: '10:30',
          room: 'Lab 101',
        ),
      ];

      provider.syncTodayClasses(sampleSchedule);
      final session = provider.todayClasses.first;

      await provider.cancelClassSession(
        recordId: session.id,
        reason: 'Professor absent',
      );

      final updatedSession = provider.todayClasses.first;
      expect(updatedSession.status, AttendanceStatus.cancelled);
      expect(updatedSession.cancellationReason, 'Professor absent');

      final sub = provider.subjects.firstWhere((s) => s.id == 'sub-1');
      // Attended and total remain untouched!
      expect(sub.attendedClasses, 30);
      expect(sub.totalClasses, 35);
    });

    test('setProxyForSession credits substitute subject rather than scheduled subject', () async {
      await provider.loadAttendance('user-123');

      final today = provider.selectedDate;
      final sampleSchedule = [
        TimetableEntry(
          id: 'tt-1',
          userId: 'user-123',
          subjectId: 'sub-1',
          weekday: today.weekday,
          startTime: '09:00',
          endTime: '10:30',
          room: 'Lab 101',
        ),
      ];

      provider.syncTodayClasses(sampleSchedule);
      final session = provider.todayClasses.first;

      await provider.setProxyForSession(
        recordId: session.id,
        proxySubjectId: 'sub-2',
        proxySubjectCode: 'CS302',
        proxySubjectName: 'Computer Networks',
        proxyFaculty: 'Prof. Miller',
        isPresent: true,
      );

      final updatedSession = provider.todayClasses.first;
      expect(updatedSession.status, AttendanceStatus.proxy);
      expect(updatedSession.effectiveSubjectId, 'sub-2');

      // sub-1 should NOT have changed
      final sub1 = provider.subjects.firstWhere((s) => s.id == 'sub-1');
      expect(sub1.attendedClasses, 30);
      expect(sub1.totalClasses, 35);

      // sub-2 (proxy) should have received the credit!
      final sub2 = provider.subjects.firstWhere((s) => s.id == 'sub-2');
      expect(sub2.attendedClasses, 19);
      expect(sub2.totalClasses, 31);
    });

    test('attendance modification is blocked for past or future dates', () async {
      await provider.loadAttendance('user-123');

      // Default is today
      expect(provider.isSelectedDateToday, isTrue);

      // Select a past date
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      provider.setSelectedDate(pastDate);
      expect(provider.isSelectedDateToday, isFalse);

      final initialAttended = provider.subjects.first.attendedClasses;
      final initialTotal = provider.subjects.first.totalClasses;

      // Attempt to mark manual subject
      await provider.markClass(subjectId: 'sub-1', isPresent: true);
      expect(provider.subjects.first.attendedClasses, initialAttended);
      expect(provider.subjects.first.totalClasses, initialTotal);

      // Attempt to undo
      await provider.undoMarkClass(subjectId: 'sub-1');
      expect(provider.subjects.first.attendedClasses, initialAttended);
      expect(provider.subjects.first.totalClasses, initialTotal);
    });
  });
}
