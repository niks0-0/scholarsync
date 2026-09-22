import '../../../profile/domain/models/college.dart';
import '../models/academic_master_data.dart';
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

  // ── Master Academic Directory Operations ───────────────────────────────────

  /// Fetches all registered States and Union Territories.
  Future<List<AcademicState>> getStates();

  /// Fetches Universities, optionally filtered by [stateId].
  Future<List<University>> getUniversities({String? stateId});

  /// Fetches Colleges, optionally filtered by [stateId] or [universityId].
  Future<List<College>> getColleges({String? stateId, String? universityId});

  /// Fetches all major Academic Streams (Engineering, Science, etc.).
  Future<List<AcademicStream>> getStreams();

  /// Fetches Courses / Degree Programs, optionally filtered by [streamId].
  Future<List<AcademicCourse>> getCourses({String? streamId});

  /// Fetches Academic Branches, optionally filtered by [streamId].
  Future<List<AcademicBranch>> getBranches({String? streamId});

  /// Fetches Academic Semesters.
  Future<List<AcademicSemester>> getSemesters();

  /// Persists student academic profile relations to `student_academic_profile`.
  Future<void> saveStudentAcademicProfile({
    required String userId,
    String? stateId,
    String? universityId,
    String? collegeId,
    String? streamId,
    String? courseId,
    String? branchId,
    String? semesterId,
    String? rollNumber,
    String? enrollmentNumber,
    String? division,
  });

  /// Auto-enrolls the student in active curriculum subjects matching their academic profile.
  Future<List<Subject>> autoEnrollSemesterSubjects({
    required String userId,
    String? universityId,
    String? collegeId,
    String? courseId,
    String? branchId,
    required String branchName,
    required int semesterNumber,
  });
}

