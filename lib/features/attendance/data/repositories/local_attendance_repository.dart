import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/subject_attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

class LocalAttendanceRepository implements AttendanceRepository {
  const LocalAttendanceRepository();

  static const _storagePrefix = 'scholarsync_attendance_';

  @override
  Future<List<SubjectAttendance>> getAttendanceList(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      final jsonString = prefs.getString(key);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((e) => SubjectAttendance.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('LocalAttendanceRepository read error: $e');
    }

    // Default pre-seeded curriculum subjects for students
    final initialList = _getDefaultSubjects();
    await saveAttendanceList(userId, initialList);
    return initialList;
  }

  @override
  Future<void> saveAttendanceList(
      String userId, List<SubjectAttendance> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint('LocalAttendanceRepository save error: $e');
    }
  }

  @override
  Future<void> markAttendance({
    required String userId,
    required String subjectId,
    required bool isPresent,
  }) async {
    final list = await getAttendanceList(userId);
    final updatedList = list.map((item) {
      if (item.id == subjectId) {
        return item.copyWith(
          attendedClasses:
              isPresent ? item.attendedClasses + 1 : item.attendedClasses,
          totalClasses: item.totalClasses + 1,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();

    await saveAttendanceList(userId, updatedList);
  }

  @override
  Future<void> resetSubjectAttendance(String userId, String subjectId) async {
    final list = await getAttendanceList(userId);
    final updatedList = list.map((item) {
      if (item.id == subjectId) {
        return item.copyWith(
          attendedClasses: 0,
          totalClasses: 0,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();

    await saveAttendanceList(userId, updatedList);
  }

  List<SubjectAttendance> _getDefaultSubjects() {
    return [
      const SubjectAttendance(
        id: 'cs-301',
        subjectCode: 'CS301',
        subjectName: 'Data Structures & Algorithms',
        attendedClasses: 28,
        totalClasses: 32,
        targetPercentage: 75.0,
      ),
      const SubjectAttendance(
        id: 'cs-302',
        subjectCode: 'CS302',
        subjectName: 'Operating Systems',
        attendedClasses: 22,
        totalClasses: 30,
        targetPercentage: 75.0,
      ),
      const SubjectAttendance(
        id: 'cs-303',
        subjectCode: 'CS303',
        subjectName: 'Database Management Systems',
        attendedClasses: 26,
        totalClasses: 31,
        targetPercentage: 75.0,
      ),
      const SubjectAttendance(
        id: 'cs-304',
        subjectCode: 'CS304',
        subjectName: 'Computer Networks',
        attendedClasses: 19,
        totalClasses: 28,
        targetPercentage: 75.0,
      ),
      const SubjectAttendance(
        id: 'cs-305',
        subjectCode: 'CS305',
        subjectName: 'Software Engineering',
        attendedClasses: 25,
        totalClasses: 29,
        targetPercentage: 75.0,
      ),
    ];
  }
}
