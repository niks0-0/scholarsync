import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/timetable/data/repositories/mock_timetable_repository.dart';
import 'package:scholarsync/features/timetable/domain/models/timetable_entry.dart';
import 'package:scholarsync/features/timetable/presentation/timetable_provider.dart';

void main() {
  late MockTimetableRepository mockRepo;
  late TimetableProvider provider;

  setUp(() {
    mockRepo = MockTimetableRepository();
    provider = TimetableProvider(repository: mockRepo);
  });

  group('TimetableEntry Model & Business Logic Tests', () {
    test('TimetableEntry json serialization works correctly', () {
      final json = {
        'id': 'tt-101',
        'user_id': 'uid_123',
        'subject_id': 'sub-1',
        'weekday': 1,
        'start_time': '09:00',
        'end_time': '10:30',
        'room': 'Lab 302',
        'building': 'Tech Block A',
        'faculty_name': 'Dr. Robert Smith',
        'mode': 'Offline',
        'class_type': 'Lab',
        'reminder_minutes': 15,
        'is_active': true,
      };

      final entry = TimetableEntry.fromJson(json);

      expect(entry.id, equals('tt-101'));
      expect(entry.userId, equals('uid_123'));
      expect(entry.startTime, equals('09:00'));
      expect(entry.endTime, equals('10:30'));
      expect(entry.durationMinutes, equals(90));
      expect(entry.room, equals('Lab 302'));
    });

    test('TimetableClassStatus calculates current, upcoming, and completed correctly', () {
      final refTime = DateTime(2026, 8, 15, 10, 0); // 10:00 AM on Saturday (weekday 6)

      final currentEntry = TimetableEntry(
        id: '1',
        userId: 'u',
        subjectId: 's',
        weekday: 6,
        startTime: '09:30',
        endTime: '11:00',
        room: 'R1',
      );

      final upcomingEntry = TimetableEntry(
        id: '2',
        userId: 'u',
        subjectId: 's',
        weekday: 6,
        startTime: '11:30',
        endTime: '13:00',
        room: 'R2',
      );

      final completedEntry = TimetableEntry(
        id: '3',
        userId: 'u',
        subjectId: 's',
        weekday: 6,
        startTime: '08:00',
        endTime: '09:30',
        room: 'R3',
      );

      expect(currentEntry.calculateStatus(refTime), equals(TimetableClassStatus.current));
      expect(upcomingEntry.calculateStatus(refTime), equals(TimetableClassStatus.upcoming));
      expect(completedEntry.calculateStatus(refTime), equals(TimetableClassStatus.completed));
    });
  });

  group('TimetableProvider Validation & CRUD Tests', () {
    test('validateClassTimes rejects invalid start/end time ranges', () {
      final error1 = TimetableProvider.validateClassTimes('10:30', '09:00');
      final error2 = TimetableProvider.validateClassTimes('10:00', '10:00');
      final valid = TimetableProvider.validateClassTimes('09:00', '10:30');

      expect(error1, isNotNull);
      expect(error1, contains('strictly earlier'));
      expect(error2, isNotNull);
      expect(valid, isNull);
    });

    test('loadWeeklySchedule populates weekly entries from repository', () async {
      await provider.loadWeeklySchedule('uid_test_123');

      expect(provider.status, equals(TimetableStateStatus.loaded));
      expect(provider.weeklySchedule.length, equals(3));
    });

    test('createClassEntry validates and saves new class entry', () async {
      await provider.loadWeeklySchedule('uid_test_123');
      final newEntry = TimetableEntry(
        id: 'tt-new',
        userId: 'uid_test_123',
        subjectId: 'sub-4',
        weekday: 1,
        startTime: '08:00',
        endTime: '09:30',
        room: 'Room 101',
        subject: const Subject(
          id: 'sub-4',
          branch: 'Computer Science & Engineering',
          semester: 4,
          subjectCode: 'CS404',
          subjectName: 'Computer Networks',
          shortName: 'CN',
        ),
      );

      final result = await provider.createClassEntry(newEntry);

      expect(result, isTrue);
      expect(provider.weeklySchedule.length, equals(4));
    });

    test('deleteClassEntry removes entry from schedule', () async {
      await provider.loadWeeklySchedule('uid_test_123');
      await provider.deleteClassEntry('uid_test_123', 'tt-1');

      expect(provider.weeklySchedule.any((e) => e.id == 'tt-1'), isFalse);
    });
  });
}
