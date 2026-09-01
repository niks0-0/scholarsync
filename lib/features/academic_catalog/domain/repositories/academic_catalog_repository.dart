import '../models/subject.dart';

/// Centralized repository contract for Academic Catalog and Subject Assignment operations.
abstract class AcademicCatalogRepository {
  /// Fetches active curriculum subjects for a given [branch] and [semester].
  Future<List<Subject>> getSubjectsForBranchAndSemester({
    String? collegeId,
    required String branch,
    required int semester,
  });

  /// Fetches all enrolled subjects for a student by [firebaseUid].
  Future<List<Subject>> getEnrolledSubjectsForUser(String firebaseUid);

  /// Searches subjects by name, short name, or subject code with optional filtering.
  Future<List<Subject>> searchSubjects(
    String query, {
    String? branch,
    int? semester,
  });

  /// Fetches a single subject by its canonical UUID [id].
  Future<Subject?> getSubjectById(String id);

  /// Enrolls a student in a canonical subject.
  Future<void> enrollUserInSubject({
    required String firebaseUid,
    required String subjectId,
  });

  /// Unenrolls a student from a subject.
  Future<void> unenrollUserFromSubject({
    required String firebaseUid,
    required String subjectId,
  });
}
