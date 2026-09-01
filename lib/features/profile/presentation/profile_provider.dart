import 'package:flutter/foundation.dart';
import '../../storage/data/repositories/supabase_storage_repository.dart';
import '../../storage/domain/repositories/storage_repository.dart';
import '../data/repositories/supabase_profile_repository.dart';
import '../domain/models/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    ProfileRepository? repository,
    StorageRepository? storageRepository,
  })  : _repository = repository ?? const SupabaseProfileRepository(),
        _storageRepository = storageRepository ?? const SupabaseStorageRepository();

  final ProfileRepository _repository;
  final StorageRepository _storageRepository;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Fetches or creates the user profile in Supabase for [firebaseUid].
  Future<UserProfile?> syncProfile({
    required String firebaseUid,
    required String email,
    required String fullName,
    String? avatarUrl,
    String authProvider = 'google.com',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.ensureProfileExists(
        firebaseUid: firebaseUid,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        authProvider: authProvider,
      );
      _profile = result;
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to sync profile with Supabase. Form data is preserved for retry.');
      _setLoading(false);
      return null;
    }
  }

  /// Uploads avatar image bytes to Supabase Storage and returns signed public URL.
  Future<String?> uploadAvatar({
    required String firebaseUid,
    required Uint8List bytes,
  }) async {
    try {
      final path = await _storageRepository.replaceAvatar(
        firebaseUid: firebaseUid,
        fileBytes: bytes,
        fileName: 'profile.jpg',
        mimeType: 'image/jpeg',
      );
      final signedUrl = await _storageRepository.getSignedAvatarUrl(
        firebaseUid: firebaseUid,
        fileName: 'profile.jpg',
      );
      return signedUrl.isNotEmpty ? signedUrl : path;
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      return null;
    }
  }

  /// Updates the user's profile information.
  Future<UserProfile?> updateProfile(UserProfile updated) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.updateProfile(updated);
      _profile = result;
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Failed to update profile: Please check connection and try again.');
      _setLoading(false);
      return null;
    }
  }

  /// Clears profile state on sign out.
  void clear() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
