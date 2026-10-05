import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../storage/data/repositories/supabase_storage_repository.dart';
import '../../storage/domain/repositories/storage_repository.dart';
import '../data/repositories/supabase_profile_repository.dart';
import '../domain/models/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    UserProfile? initialProfile,
    ProfileRepository? repository,
    StorageRepository? storageRepository,
  })  : _profile = initialProfile,
        _repository = repository ?? const SupabaseProfileRepository(),
        _storageRepository = storageRepository ?? const SupabaseStorageRepository() {
    if (_profile != null) {
      recordActiveDay();
    }
    _listenToAuthChanges();
  }

  final ProfileRepository _repository;
  final StorageRepository _storageRepository;
  StreamSubscription<User?>? _authSubscription;

  void _listenToAuthChanges() {
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        if (_profile == null || _profile!.id != user.uid) {
          await loadProfile(user.uid);
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

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

  /// Directly updates the active in-memory user profile and notifies listeners.
  void setProfile(UserProfile profile) {
    _profile = profile;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Records daily user activity and increments activeDays if this is a new calendar day.
  Future<void> recordActiveDay() async {
    if (_profile == null) return;
    final now = DateTime.now();
    final last = _profile!.lastActiveAt;
    final isNewDay = last == null ||
        last.year != now.year ||
        last.month != now.month ||
        last.day != now.day;

    if (isNewDay) {
      final currentDays = _profile!.activeDays;
      final updated = _profile!.copyWith(
        activeDays: currentDays <= 0 ? 1 : currentDays + 1,
        lastActiveAt: now,
      );
      _profile = updated;
      notifyListeners();
      try {
        await _repository.updateProfile(updated);
      } catch (e) {
        debugPrint('Active days sync note: $e');
      }
    }
  }

  /// Loads profile from local cache or Supabase for [firebaseUid].
  Future<UserProfile?> loadProfile(String firebaseUid) async {
    if (_profile != null && _profile!.id == firebaseUid) return _profile;
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.getProfile(firebaseUid);
      if (result != null) {
        _profile = result;
        _isLoading = false;
        notifyListeners();
        recordActiveDay();
        return result;
      }
    } catch (e) {
      debugPrint('ProfileProvider.loadProfile error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return null;
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
      recordActiveDay();
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
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('scholarsync_last_active_uid');
    }).catchError((_) {});
  }
}
