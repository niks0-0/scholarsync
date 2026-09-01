import '../models/timetable_entry.dart';

/// Centralized repository contract for Timetable & Schedule Management operations.
abstract class TimetableRepository {
  /// Fetches full weekly academic schedule for student by [firebaseUid].
  Future<List<TimetableEntry>> getWeeklySchedule(String firebaseUid);

  /// Fetches schedule for a specific weekday (1 = Mon to 7 = Sun) or today.
  Future<List<TimetableEntry>> getTodaySchedule(String firebaseUid, {int? weekday});

  /// Returns the current ongoing lecture for today if active.
  Future<TimetableEntry?> getCurrentClass(String firebaseUid);

  /// Returns the next upcoming lecture for today.
  Future<TimetableEntry?> getNextClass(String firebaseUid);

  /// Creates a new timetable entry for the student.
  Future<TimetableEntry> createEntry(TimetableEntry entry);

  /// Updates an existing timetable entry.
  Future<TimetableEntry> updateEntry(TimetableEntry entry);

  /// Deletes a timetable entry.
  Future<void> deleteEntry(String firebaseUid, String entryId);

  /// Duplicates an existing timetable entry to a target weekday.
  Future<TimetableEntry> duplicateEntry(String firebaseUid, String entryId, int targetWeekday);

  /// Searches timetable entries by subject, faculty, room, or notes.
  Future<List<TimetableEntry>> searchTimetable(String firebaseUid, String query);
}
