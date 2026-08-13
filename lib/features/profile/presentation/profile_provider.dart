import 'package:flutter/foundation.dart';
import '../data/repositories/supabase_profile_repository.dart';
import '../domain/models/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ProfileRepository? repository})
      : _repository = repository ?? const SupabaseProfileRepository();

  final ProfileRepository _repository;

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
      _setError('Failed to sync profile with Supabase: $e');
      _setLoading(false);
      return null;
    }
  }

  /// Updates the user's profile information.
  Future<bool> updateProfile(UserProfile updated) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.updateProfile(updated);
      _profile = result;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
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
