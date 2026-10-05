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

      final list = (response as List)
          .map((json) => College.fromJson(json as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('SupabaseCollegeRepository.getColleges error (falling back to standard colleges): $e');
    }
    return _getFallbackColleges();
  }

  @override
  Future<List<College>> searchColleges(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return getColleges();

    try {
      final response = await SupabaseService.instance.client
          .from(_tableName)
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      final list = (response as List)
          .map((json) => College.fromJson(json as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('SupabaseCollegeRepository.searchColleges error: $e');
    }

    final fallbacks = _getFallbackColleges();
    return fallbacks.where((c) {
      return c.name.toLowerCase().contains(cleanQuery) ||
          c.code.toLowerCase().contains(cleanQuery) ||
          (c.city != null && c.city!.toLowerCase().contains(cleanQuery));
    }).toList();
  }

  static List<College> _getFallbackColleges() {
    return const [
      College(
        id: 'col-mitwpu',
        name: 'MIT World Peace University (MIT-WPU)',
        code: 'MIT-WPU',
        city: 'Pune',
        category: 'Tier 1 / Autonomous',
      ),
      College(
        id: 'col-coep',
        name: 'COEP Technological University (College of Engineering Pune)',
        code: 'COEP',
        city: 'Pune',
        category: 'Autonomous State University',
      ),
      College(
        id: 'col-pict',
        name: 'Pune Institute of Computer Technology (PICT)',
        code: 'PICT',
        city: 'Pune',
        category: 'Affiliated',
      ),
      College(
        id: 'col-vit-pune',
        name: 'Vishwakarma Institute of Technology (VIT)',
        code: 'VIT-PUNE',
        city: 'Pune',
        category: 'Autonomous',
      ),
      College(
        id: 'col-vjti',
        name: 'Veermata Jijabai Technological Institute (VJTI)',
        code: 'VJTI',
        city: 'Mumbai',
        category: 'Autonomous State Institute',
      ),
      College(
        id: 'col-iitb',
        name: 'Indian Institute of Technology Bombay (IIT Bombay)',
        code: 'IITB',
        city: 'Mumbai',
        category: 'Institute of National Importance',
      ),
      College(
        id: 'col-dtu',
        name: 'Delhi Technological University (DTU)',
        code: 'DTU',
        city: 'New Delhi',
        category: 'State University',
      ),
      College(
        id: 'col-bits',
        name: 'Birla Institute of Technology and Science (BITS Pilani)',
        code: 'BITS',
        city: 'Pilani',
        category: 'Deemed University',
      ),
      College(
        id: 'col-nitk',
        name: 'National Institute of Technology Karnataka (NITK Surathkal)',
        code: 'NITK',
        city: 'Mangaluru',
        category: 'NIT',
      ),
      College(
        id: 'col-gtu',
        name: 'Gujarat Technological University (GTU)',
        code: 'GTU',
        city: 'Ahmedabad',
        category: 'State Technological University',
      ),
      College(
        id: 'col-anna',
        name: 'Anna University College of Engineering Guindy',
        code: 'CEG-AU',
        city: 'Chennai',
        category: 'State University',
      ),
      College(
        id: 'col-vit-vellore',
        name: 'Vellore Institute of Technology (VIT)',
        code: 'VIT',
        city: 'Vellore',
        category: 'Deemed University',
      ),
    ];
  }

  @override
  Future<College> createCollege(College college) async {
    try {
      final client = SupabaseService.instance.client;
      final payload = college.toJson();
      if (payload['id'] == null || (payload['id'] as String).isEmpty || (payload['id'] as String).startsWith('manual_')) {
        payload.remove('id');
      }

      final res = await client.from(_tableName).insert(payload).select().single();
      return College.fromJson(res);
    } catch (e) {
      debugPrint('SupabaseCollegeRepository.createCollege fallback: $e');
      return college;
    }
  }
}
