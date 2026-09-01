import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
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
}
