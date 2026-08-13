import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/repositories/storage_repository.dart';

/// Implementation of [StorageRepository] backed by Supabase Storage (`avatars` bucket).
///
/// All paths follow the clean user-scoped structure `avatars/{firebaseUid}/{fileName}`.
/// Enforces Storage RLS policies using the authenticated Firebase JWT.
class SupabaseStorageRepository implements StorageRepository {
  const SupabaseStorageRepository();

  static const String _bucketName = 'avatars';

  StorageFileApi get _storage =>
      SupabaseService.instance.client.storage.from(_bucketName);

  String _getScopedPath(String firebaseUid, String fileName) {
    final cleanFileName = fileName.startsWith('/') ? fileName.substring(1) : fileName;
    return '$firebaseUid/$cleanFileName';
  }

  @override
  Future<String> uploadAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final path = _getScopedPath(firebaseUid, fileName);
      await _storage.uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: false,
        ),
      );
      return path;
    } catch (e) {
      debugPrint('SupabaseStorageRepository.uploadAvatar error: $e');
      rethrow;
    }
  }

  @override
  Future<String> replaceAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final path = _getScopedPath(firebaseUid, fileName);
      await _storage.uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: true,
        ),
      );
      return path;
    } catch (e) {
      debugPrint('SupabaseStorageRepository.replaceAvatar error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  }) async {
    try {
      final path = _getScopedPath(firebaseUid, fileName);
      await _storage.remove([path]);
    } catch (e) {
      debugPrint('SupabaseStorageRepository.deleteAvatar error: $e');
      rethrow;
    }
  }

  @override
  Future<String> getSignedAvatarUrl({
    required String firebaseUid,
    String fileName = 'profile.jpg',
    int expiresInSeconds = 3600,
  }) async {
    try {
      final path = _getScopedPath(firebaseUid, fileName);
      final signedUrl = await _storage.createSignedUrl(
        path,
        expiresInSeconds,
      );
      return signedUrl;
    } catch (e) {
      debugPrint('SupabaseStorageRepository.getSignedAvatarUrl error: $e');
      rethrow;
    }
  }

  @override
  Future<Uint8List> downloadAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  }) async {
    try {
      final path = _getScopedPath(firebaseUid, fileName);
      final bytes = await _storage.download(path);
      return bytes;
    } catch (e) {
      debugPrint('SupabaseStorageRepository.downloadAvatar error: $e');
      rethrow;
    }
  }
}
