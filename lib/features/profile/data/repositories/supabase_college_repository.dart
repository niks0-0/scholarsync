import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/college.dart';
import '../../domain/repositories/college_repository.dart';

/// Implementation of [CollegeRepository] using Supabase PostgREST.
class SupabaseCollegeRepository implements CollegeRepository {
  const SupabaseCollegeRepository();

  static const String _tableName = 'colleges';

  @override
  Future<List<College>> getColleges() async {
    try {
      final response = await SupabaseService.instance.client
          .from(_tableName)
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => College.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SupabaseCollegeRepository.getColleges error: $e');
      rethrow;
    }
  }

  @override
  Future<List<College>> searchColleges(String query) async {
    try {
      if (query.trim().isEmpty) return getColleges();

      final response = await SupabaseService.instance.client
          .from(_tableName)
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => College.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SupabaseCollegeRepository.searchColleges error: $e');
      rethrow;
    }
  }
}
