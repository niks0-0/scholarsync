import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../profile/domain/models/college.dart';
import '../../domain/models/academic_master_data.dart';
import '../../domain/models/subject.dart';
import '../../domain/repositories/academic_catalog_repository.dart';

/// Supabase PostgREST implementation of [AcademicCatalogRepository].
class SupabaseAcademicCatalogRepository implements AcademicCatalogRepository {
  const SupabaseAcademicCatalogRepository();

  @override
  Future<List<Subject>> getSubjectsForBranchAndSemester({
    String? collegeId,
    required String branch,
    required int semester,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      var query = client
          .from('subjects')
          .select()
          .eq('branch', branch)
          .eq('semester', semester)
          .eq('is_active', true);

      if (collegeId != null && collegeId.isNotEmpty) {
        query = query.eq('college_id', collegeId);
      }

      final List<dynamic> response = await query.order('display_order', ascending: true);
      return response.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching subjects for branch/semester: $e');
      return [];
    }
  }

  @override
  Future<List<Subject>> getEnrolledSubjectsForUser(String firebaseUid) async {
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> userSubjects = await client
          .from('user_subjects')
          .select('subject_id')
          .eq('user_id', firebaseUid)
          .eq('is_enrolled', true);

      if (userSubjects.isEmpty) return [];

      final subjectIds = userSubjects.map((row) => row['subject_id'] as String).toList();

      final List<dynamic> subjectsData = await client
          .from('subjects')
          .select()
          .filter('id', 'in', subjectIds)
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return subjectsData.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching user enrolled subjects: $e');
      return [];
    }
  }

  @override
  Future<List<Subject>> searchSubjects(
    String query, {
    String? branch,
    int? semester,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      var request = client.from('subjects').select().eq('is_active', true);

      if (branch != null && branch.isNotEmpty) {
        request = request.eq('branch', branch);
      }
      if (semester != null && semester > 0) {
        request = request.eq('semester', semester);
      }

      if (query.trim().isNotEmpty) {
        final q = '%${query.trim()}%';
        request = request.or('subject_name.ilike.$q,subject_code.ilike.$q,short_name.ilike.$q');
      }

      final List<dynamic> response = await request.order('display_order', ascending: true);
      return response.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error searching subjects: $e');
      return [];
    }
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.from('subjects').select().eq('id', id).single();
      return Subject.fromJson(response);
    } catch (e) {
      debugPrint('Error getting subject by ID: $e');
      return null;
    }
  }

  @override
  Future<void> enrollUserInSubject({
    required String firebaseUid,
    required String subjectId,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('user_subjects').upsert({
        'user_id': firebaseUid,
        'subject_id': subjectId,
        'is_enrolled': true,
      }, onConflict: 'user_id, subject_id');
    } catch (e) {
      debugPrint('Error enrolling user in subject: $e');
      rethrow;
    }
  }

  @override
  Future<void> unenrollUserFromSubject({
    required String firebaseUid,
    required String subjectId,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      await client
          .from('user_subjects')
          .delete()
          .eq('user_id', firebaseUid)
          .eq('subject_id', subjectId);
    } catch (e) {
      debugPrint('Error unenrolling user from subject: $e');
      rethrow;
    }
  }

  // ── Master Academic Directory Operations ───────────────────────────────────

  @override
  Future<List<AcademicState>> getStates() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.from('states').select().order('name', ascending: true);
      return (response as List)
          .map((json) => AcademicState.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching states: $e');
      return [];
    }
  }

  @override
  Future<List<University>> getUniversities({String? stateId}) async {
    try {
      final client = SupabaseService.instance.client;
      var query = client.from('universities').select();
      if (stateId != null && stateId.isNotEmpty) {
        query = query.eq('state_id', stateId);
      }
      final response = await query.order('name', ascending: true);
      return (response as List)
          .map((json) => University.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching universities: $e');
      return [];
    }
  }

  @override
  Future<List<College>> getColleges({String? stateId, String? universityId}) async {
    try {
      final client = SupabaseService.instance.client;
      var query = client.from('colleges').select();
      if (stateId != null && stateId.isNotEmpty) {
        query = query.eq('state_id', stateId);
      }
      if (universityId != null && universityId.isNotEmpty) {
        query = query.eq('university_id', universityId);
      }
      final response = await query.order('name', ascending: true);
      return (response as List)
          .map((json) => College.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching colleges: $e');
      return [];
    }
  }

  @override
  Future<List<AcademicStream>> getStreams() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client.from('streams').select().order('name', ascending: true);
      return (response as List)
          .map((json) => AcademicStream.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching streams: $e');
      return [];
    }
  }

  @override
  Future<List<AcademicCourse>> getCourses({String? streamId}) async {
    try {
      final client = SupabaseService.instance.client;
      var query = client.from('courses').select();
      if (streamId != null && streamId.isNotEmpty) {
        query = query.eq('stream_id', streamId);
      }
      final response = await query.order('name', ascending: true);
      return (response as List)
          .map((json) => AcademicCourse.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      return [];
    }
  }

  @override
  Future<List<AcademicBranch>> getBranches({String? streamId}) async {
    try {
      final client = SupabaseService.instance.client;
      var query = client.from('branches').select();
      if (streamId != null && streamId.isNotEmpty) {
        query = query.eq('stream_id', streamId);
      }
      final response = await query.order('name', ascending: true);
      return (response as List)
          .map((json) => AcademicBranch.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      return [];
    }
  }

  @override
  Future<List<AcademicSemester>> getSemesters() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client
          .from('semesters')
          .select()
          .order('semester_number', ascending: true);
      return (response as List)
          .map((json) => AcademicSemester.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching semesters: $e');
      return [];
    }
  }

  @override
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
  }) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('student_academic_profile').upsert({
        'user_id': userId,
        'state_id': ?stateId,
        'university_id': ?universityId,
        'college_id': ?collegeId,
        'stream_id': ?streamId,
        'course_id': ?courseId,
        'branch_id': ?branchId,
        'semester_id': ?semesterId,
        if (rollNumber != null && rollNumber.isNotEmpty) 'roll_number': rollNumber,
        if (enrollmentNumber != null && enrollmentNumber.isNotEmpty)
          'enrollment_number': enrollmentNumber,
        if (division != null && division.isNotEmpty) 'division': division,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('Error saving student_academic_profile: $e');
      // Gracefully continue so user is not blocked
    }
  }

  @override
  Future<List<Subject>> autoEnrollSemesterSubjects({
    required String userId,
    String? universityId,
    String? collegeId,
    String? courseId,
    String? branchId,
    required String branchName,
    required int semesterNumber,
  }) async {
    final client = SupabaseService.instance.client;
    List<Subject> subjects = [];

    // 1. First check semester_subjects mapping
    try {
      if (courseId != null || branchId != null || universityId != null) {
        var query = client.from('semester_subjects').select('subject_id, subjects(*)');
        if (universityId != null) query = query.eq('university_id', universityId);
        if (courseId != null) query = query.eq('course_id', courseId);
        if (branchId != null) query = query.eq('branch_id', branchId);

        final response = await query;
        for (final row in (response as List)) {
          if (row['subjects'] != null) {
            subjects.add(Subject.fromJson(row['subjects'] as Map<String, dynamic>));
          }
        }
      }
    } catch (e) {
      debugPrint('semester_subjects query fallback: $e');
    }

    // 2. Fallback to catalog subjects matching branch and semester
    if (subjects.isEmpty) {
      subjects = await getSubjectsForBranchAndSemester(
        collegeId: collegeId,
        branch: branchName,
        semester: semesterNumber,
      );
    }

    // 3. Auto-enroll student into these subjects
    for (final subject in subjects) {
      try {
        await enrollUserInSubject(firebaseUid: userId, subjectId: subject.id);
      } catch (e) {
        debugPrint('Auto-enroll error for subject ${subject.id}: $e');
      }
    }

    return subjects;
  }
}
