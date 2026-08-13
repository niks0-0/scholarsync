import '../models/user_profile.dart';

/// Contract for profile operations in Supabase.
abstract class ProfileRepository {
  /// Fetches the profile for the given [firebaseUid]. Returns null if not found.
  Future<UserProfile?> getProfile(String firebaseUid);

  /// Creates a new profile in Supabase `public.profiles`.
  Future<UserProfile> createProfile(UserProfile profile);

  /// Updates an existing profile in Supabase `public.profiles`.
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Ensures a profile exists for the Firebase user:
  /// - If missing, creates the profile using Firebase user information.
  /// - If existing, returns the existing profile.
  /// Never creates duplicates.
  Future<UserProfile> ensureProfileExists({
    required String firebaseUid,
    required String email,
    required String fullName,
    String? avatarUrl,
    String authProvider = 'google.com',
  });
}
