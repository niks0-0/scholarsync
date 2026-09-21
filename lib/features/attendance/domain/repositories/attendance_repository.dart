import '../models/subject_attendance.dart';

abstract class AttendanceRepository {
  Future<List<SubjectAttendance>> getAttendanceList(String userId);

  Future<void> saveAttendanceList(String userId, List<SubjectAttendance> list);

  Future<void> markAttendance({
    required String userId,
    required String subjectId,
    required bool isPresent,
  });

  Future<void> resetSubjectAttendance(String userId, String subjectId);
}
