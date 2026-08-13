import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Implementation of [ProfileRepository] using Supabase PostgREST.
///
/// Uses the Firebase Auth UID (`profiles.id`) as the primary key.
/// All queries pass through RLS policy `id = firebase_uid()`.
class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository();

  static const String _tableName = 'profiles';

  @override
  Future<UserProfile?> getProfile(String firebaseUid) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_tableName)
          .select()
          .eq('id', firebaseUid)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('SupabaseProfileRepository.getProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_tableName)
          .insert(profile.toJson())
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('SupabaseProfileRepository.createProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_tableName)
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('SupabaseProfileRepository.updateProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile> ensureProfileExists({
    required String firebaseUid,
    required String email,
    required String fullName,
    String? avatarUrl,
    String authProvider = 'google.com',
  }) async {
    // 1. Try to fetch existing profile
    final existing = await getProfile(firebaseUid);
    if (existing != null) {
      return existing;
    }

    // 2. Profile missing -> Create new profile
    final newProfile = UserProfile(
      id: firebaseUid,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      authProvider: authProvider,
    );

    try {
      return await createProfile(newProfile);
    } catch (e) {
      // Handle potential race condition / duplicate key
      debugPrint('Profile creation race condition check, retrying fetch...');
      final reFetched = await getProfile(firebaseUid);
      if (reFetched != null) return reFetched;
      rethrow;
    }
  }
}
