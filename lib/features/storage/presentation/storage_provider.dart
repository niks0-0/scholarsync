import 'package:flutter/foundation.dart';
import '../data/repositories/supabase_storage_repository.dart';
import '../domain/repositories/storage_repository.dart';

class StorageProvider extends ChangeNotifier {
  StorageProvider({StorageRepository? repository})
      : _repository = repository ?? const SupabaseStorageRepository();

  final StorageRepository _repository;

  bool _isLoading = false;
  String? _error;
  String? _currentAvatarUrl;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentAvatarUrl => _currentAvatarUrl;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Uploads avatar for [firebaseUid] and retrieves the signed URL.
  Future<String?> uploadAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.uploadAvatar(
        firebaseUid: firebaseUid,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      final signedUrl = await _repository.getSignedAvatarUrl(
        firebaseUid: firebaseUid,
        fileName: fileName,
      );

      _currentAvatarUrl = signedUrl;
      _setLoading(false);
      return signedUrl;
    } catch (e) {
      _setError('Failed to upload avatar: $e');
      _setLoading(false);
      return null;
    }
  }

  /// Replaces avatar for [firebaseUid] and retrieves the updated signed URL.
  Future<String?> replaceAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.replaceAvatar(
        firebaseUid: firebaseUid,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      final signedUrl = await _repository.getSignedAvatarUrl(
        firebaseUid: firebaseUid,
        fileName: fileName,
      );

      _currentAvatarUrl = signedUrl;
      _setLoading(false);
      return signedUrl;
    } catch (e) {
      _setError('Failed to replace avatar: $e');
      _setLoading(false);
      return null;
    }
  }

  /// Deletes avatar file for [firebaseUid].
  Future<bool> deleteAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.deleteAvatar(
        firebaseUid: firebaseUid,
        fileName: fileName,
      );

      _currentAvatarUrl = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete avatar: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Fetches signed avatar URL for [firebaseUid].
  Future<String?> getSignedAvatarUrl({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  }) async {
    try {
      final signedUrl = await _repository.getSignedAvatarUrl(
        firebaseUid: firebaseUid,
        fileName: fileName,
      );
      _currentAvatarUrl = signedUrl;
      notifyListeners();
      return signedUrl;
    } catch (e) {
      return null;
    }
  }

  void clear() {
    _currentAvatarUrl = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
