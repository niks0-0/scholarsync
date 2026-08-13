import 'dart:typed_data';

/// Reusable contract for Supabase Storage operations.
///
/// Ensures storage operations are user-scoped (`avatars/{firebaseUid}/*`)
/// and protected by Storage RLS policies.
abstract class StorageRepository {
  /// Uploads avatar image bytes to `avatars/{firebaseUid}/{fileName}`.
  /// Returns the relative path in the storage bucket.
  Future<String> uploadAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  });

  /// Replaces an existing avatar image at `avatars/{firebaseUid}/{fileName}`.
  Future<String> replaceAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  });

  /// Deletes an avatar file from `avatars/{firebaseUid}/{fileName}`.
  Future<void> deleteAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  });

  /// Obtains a signed URL for reading a private file from `avatars/{firebaseUid}/{fileName}`.
  /// [expiresInSeconds] specifies URL validity (default 1 hour).
  Future<String> getSignedAvatarUrl({
    required String firebaseUid,
    String fileName = 'profile.jpg',
    int expiresInSeconds = 3600,
  });

  /// Downloads file bytes from `avatars/{firebaseUid}/{fileName}`.
  Future<Uint8List> downloadAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  });
}
