import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_role.dart';
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
      return null;
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
      return profile;
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
      return profile;
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
    final cleanEmail = email.trim().toLowerCase();
    final isDemoAdmin = cleanEmail == 'admin@scholarsync.com';
    final isDemoStudent = cleanEmail == 'student@scholarsync.com';

    // 1. Try to fetch existing profile
    try {
      final existing = await getProfile(firebaseUid);
      if (existing != null) {
        if (isDemoAdmin && !existing.role.isAdmin) {
          final updated = existing.copyWith(
            role: UserRole.superAdmin,
            onboardingCompleted: true,
            verificationStatus: 'verified',
          );
          return await updateProfile(updated);
        }
        return existing;
      }
    } catch (_) {
      // Continue to create or return profile
    }

    // 2. Profile missing -> Create new profile directly with pre-seeded demo values
    final newProfile = UserProfile(
      id: firebaseUid,
      email: email,
      fullName: isDemoAdmin ? 'Master App Admin' : (isDemoStudent ? 'ScholarSync Student' : fullName),
      avatarUrl: avatarUrl,
      authProvider: authProvider,
      role: isDemoAdmin ? UserRole.superAdmin : UserRole.student,
      branch: isDemoStudent ? 'Computer Science & Engineering' : null,
      semester: isDemoStudent ? 4 : null,
      division: isDemoStudent ? 'A' : null,
      academicYear: isDemoStudent ? 'Second Year (SY)' : null,
      rollNumber: isDemoStudent ? '26' : null,
      enrollmentNumber: isDemoStudent ? 'CS2026026' : null,
      onboardingCompleted: isDemoAdmin || isDemoStudent,
      verificationStatus: (isDemoAdmin || isDemoStudent) ? 'verified' : 'pending_verification',
      legalAcceptedAt: (isDemoAdmin || isDemoStudent) ? DateTime.now() : null,
    );

    try {
      return await createProfile(newProfile);
    } catch (e) {
      debugPrint('Profile creation note: $e');
      return newProfile;
    }
  }
}
