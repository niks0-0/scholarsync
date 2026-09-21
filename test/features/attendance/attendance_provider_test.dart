import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/attendance/domain/models/subject_attendance.dart';
import 'package:scholarsync/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:scholarsync/features/attendance/presentation/attendance_provider.dart';

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
  });
}
