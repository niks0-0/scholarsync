import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/timetable_entry.dart';
import '../../domain/repositories/timetable_repository.dart';

/// Supabase PostgREST implementation of [TimetableRepository].
class SupabaseTimetableRepository implements TimetableRepository {
  const SupabaseTimetableRepository();

  @override
  Future<List<TimetableEntry>> getWeeklySchedule(String firebaseUid) async {
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> response = await client
          .from('timetable_entries')
          .select('*, subjects(*)')
          .eq('user_id', firebaseUid)
          .eq('is_active', true)
          .order('weekday', ascending: true)
          .order('start_time', ascending: true);

      return response.map((json) => TimetableEntry.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching weekly schedule from Supabase: $e');
      return [];
    }
  }

  @override
  Future<List<TimetableEntry>> getTodaySchedule(String firebaseUid, {int? weekday}) async {
    final targetDay = weekday ?? DateTime.now().weekday;
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> response = await client
          .from('timetable_entries')
          .select('*, subjects(*)')
          .eq('user_id', firebaseUid)
          .eq('weekday', targetDay)
          .eq('is_active', true)
          .order('start_time', ascending: true);

      return response.map((json) => TimetableEntry.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching today schedule from Supabase: $e');
      return [];
    }
  }

  @override
  Future<TimetableEntry?> getCurrentClass(String firebaseUid) async {
    final todaySchedule = await getTodaySchedule(firebaseUid);
    final now = DateTime.now();
    for (final entry in todaySchedule) {
      if (entry.calculateStatus(now) == TimetableClassStatus.current) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<TimetableEntry?> getNextClass(String firebaseUid) async {
    final todaySchedule = await getTodaySchedule(firebaseUid);
    final now = DateTime.now();
    for (final entry in todaySchedule) {
      if (entry.calculateStatus(now) == TimetableClassStatus.upcoming) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<TimetableEntry> createEntry(TimetableEntry entry) async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client
          .from('timetable_entries')
          .insert(entry.toJson())
          .select('*, subjects(*)')
          .single();

      return TimetableEntry.fromJson(response);
    } catch (e) {
      debugPrint('Error creating timetable entry: $e');
      rethrow;
    }
  }

  @override
  Future<TimetableEntry> updateEntry(TimetableEntry entry) async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client
          .from('timetable_entries')
          .update(entry.toJson())
          .eq('id', entry.id)
          .eq('user_id', entry.userId)
          .select('*, subjects(*)')
          .single();

      return TimetableEntry.fromJson(response);
    } catch (e) {
      debugPrint('Error updating timetable entry: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEntry(String firebaseUid, String entryId) async {
    try {
      final client = SupabaseService.instance.client;
      await client
          .from('timetable_entries')
          .delete()
          .eq('id', entryId)
          .eq('user_id', firebaseUid);
    } catch (e) {
      debugPrint('Error deleting timetable entry: $e');
      rethrow;
    }
  }

  @override
  Future<TimetableEntry> duplicateEntry(String firebaseUid, String entryId, int targetWeekday) async {
    final client = SupabaseService.instance.client;
    final existingData = await client
        .from('timetable_entries')
        .select()
        .eq('id', entryId)
        .single();

    final Map<String, dynamic> dupJson = Map.from(existingData);
    dupJson.remove('id');
    dupJson.remove('created_at');
    dupJson.remove('updated_at');
    dupJson['weekday'] = targetWeekday;

    final response = await client
        .from('timetable_entries')
        .insert(dupJson)
        .select('*, subjects(*)')
        .single();

    return TimetableEntry.fromJson(response);
  }

  @override
  Future<List<TimetableEntry>> searchTimetable(String firebaseUid, String query) async {
    final weekly = await getWeeklySchedule(firebaseUid);
    if (query.trim().isEmpty) return weekly;
    final q = query.trim().toLowerCase();

    return weekly.where((entry) {
      return entry.subjectName.toLowerCase().contains(q) ||
          entry.subjectCode.toLowerCase().contains(q) ||
          entry.room.toLowerCase().contains(q) ||
          (entry.facultyName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
