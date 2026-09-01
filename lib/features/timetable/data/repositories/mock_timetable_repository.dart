import '../../../academic_catalog/domain/models/subject.dart';
import '../../domain/models/timetable_entry.dart';
import '../../domain/repositories/timetable_repository.dart';

class MockTimetableRepository implements TimetableRepository {
  MockTimetableRepository() {
    _sampleEntries = [
      TimetableEntry(
        id: 'tt-1',
        userId: 'uid_test_123',
        subjectId: 'sub-1',
        weekday: DateTime.now().weekday,
        startTime: '09:00',
        endTime: '10:30',
        room: 'Lab 302',
        building: 'Tech Block A',
        facultyName: 'Dr. Robert Smith',
        mode: 'Offline',
        classType: 'Lab',
        notes: 'Bring laptop with C++ IDE installed.',
        reminderMinutes: 15,
        subject: const Subject(
          id: 'sub-1',
          branch: 'Computer Science & Engineering',
          semester: 4,
          subjectCode: 'CS401',
          subjectName: 'Data Structures & Algorithms',
          shortName: 'DSA',
          credits: 4,
          facultyName: 'Dr. Robert Smith',
          practical: true,
          theory: true,
        ),
      ),
      TimetableEntry(
        id: 'tt-2',
        userId: 'uid_test_123',
        subjectId: 'sub-2',
        weekday: DateTime.now().weekday,
        startTime: '11:00',
        endTime: '12:30',
        room: 'Hall A',
        building: 'Science Block B',
        facultyName: 'Prof. Anita Sharma',
        mode: 'Offline',
        classType: 'Lecture',
        notes: 'Chapter 4 SQL Normalization.',
        reminderMinutes: 15,
        subject: const Subject(
          id: 'sub-2',
          branch: 'Computer Science & Engineering',
          semester: 4,
          subjectCode: 'CS402',
          subjectName: 'Database Management Systems',
          shortName: 'DBMS',
          credits: 4,
          facultyName: 'Prof. Anita Sharma',
          practical: true,
          theory: true,
        ),
      ),
      TimetableEntry(
        id: 'tt-3',
        userId: 'uid_test_123',
        subjectId: 'sub-3',
        weekday: DateTime.now().weekday,
        startTime: '14:00',
        endTime: '15:30',
        room: 'Room 204',
        building: 'Tech Block A',
        facultyName: 'Dr. Michael Chen',
        mode: 'Online',
        meetingUrl: 'https://meet.google.com/abc-defg-hij',
        classType: 'Seminar',
        notes: 'Agile development methodologies.',
        reminderMinutes: 15,
        subject: const Subject(
          id: 'sub-3',
          branch: 'Computer Science & Engineering',
          semester: 4,
          subjectCode: 'CS403',
          subjectName: 'Software Engineering & Architecture',
          shortName: 'SE',
          credits: 3,
          facultyName: 'Dr. Michael Chen',
          practical: false,
          theory: true,
        ),
      ),
    ];
  }

  late List<TimetableEntry> _sampleEntries;

  @override
  Future<List<TimetableEntry>> getWeeklySchedule(String firebaseUid) async {
    return _sampleEntries.where((e) => e.userId == firebaseUid || firebaseUid.isNotEmpty).toList();
  }

  @override
  Future<List<TimetableEntry>> getTodaySchedule(String firebaseUid, {int? weekday}) async {
    final targetDay = weekday ?? DateTime.now().weekday;
    return _sampleEntries.where((e) => e.weekday == targetDay).toList();
  }

  @override
  Future<TimetableEntry?> getCurrentClass(String firebaseUid) async {
    final today = await getTodaySchedule(firebaseUid);
    final now = DateTime.now();
    for (final e in today) {
      if (e.calculateStatus(now) == TimetableClassStatus.current) return e;
    }
    return null;
  }

  @override
  Future<TimetableEntry?> getNextClass(String firebaseUid) async {
    final today = await getTodaySchedule(firebaseUid);
    final now = DateTime.now();
    for (final e in today) {
      if (e.calculateStatus(now) == TimetableClassStatus.upcoming) return e;
    }
    return null;
  }

  @override
  Future<TimetableEntry> createEntry(TimetableEntry entry) async {
    _sampleEntries.add(entry);
    return entry;
  }

  @override
  Future<TimetableEntry> updateEntry(TimetableEntry entry) async {
    final index = _sampleEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _sampleEntries[index] = entry;
    }
    return entry;
  }

  @override
  Future<void> deleteEntry(String firebaseUid, String entryId) async {
    _sampleEntries.removeWhere((e) => e.id == entryId);
  }

  @override
  Future<TimetableEntry> duplicateEntry(String firebaseUid, String entryId, int targetWeekday) async {
    final existing = _sampleEntries.firstWhere((e) => e.id == entryId);
    final dup = existing.copyWith(
      weekday: targetWeekday,
    );
    _sampleEntries.add(dup);
    return dup;
  }

  @override
  Future<List<TimetableEntry>> searchTimetable(String firebaseUid, String query) async {
    final q = query.trim().toLowerCase();
    return _sampleEntries.where((e) {
      return e.subjectName.toLowerCase().contains(q) ||
          e.subjectCode.toLowerCase().contains(q) ||
          e.room.toLowerCase().contains(q);
    }).toList();
  }
}
