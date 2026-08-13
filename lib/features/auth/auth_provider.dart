import 'dart:async';
import 'package:flutter/foundation.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'domain/enums/auth_failure.dart';
import 'domain/models/auth_user.dart';
import 'domain/repositories/auth_repository.dart';

/// Unified application authentication state machine.
///
/// Firebase Authentication is the sole source of truth for user sessions.
enum ApplicationAuthState {
  /// No Firebase user signed in.
  unauthenticated,

  /// Firebase sign-in / authentication in progress.
  authenticating,

  /// Firebase user authenticated, ID token available.
  authenticated,

  /// Fetching/syncing profile from Supabase PostgreSQL.
  loadingProfile,

  /// Firebase user authenticated AND Supabase profile loaded.
  authenticatedWithProfile,

  /// Error during authentication or session restoration.
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? authRepository})
      : _repository = authRepository ?? FirebaseAuthRepository() {
    _initStream();
  }

  final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _authSubscription;

  ApplicationAuthState _state = ApplicationAuthState.unauthenticated;
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicationAuthState get state => _state;
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  /// True if a Firebase user is authenticated.
  bool get isAuthenticated =>
      _state == ApplicationAuthState.authenticated ||
      _state == ApplicationAuthState.authenticatedWithProfile ||
      _state == ApplicationAuthState.loadingProfile;

  void _initStream() {
    _currentUser = _repository.currentUser;
    _state = _currentUser != null
        ? ApplicationAuthState.authenticated
        : ApplicationAuthState.unauthenticated;
    notifyListeners();

    _authSubscription = _repository.authStateChanges.listen((authUser) {
      _currentUser = authUser;
      if (authUser != null) {
        _state = ApplicationAuthState.authenticated;
      } else {
        _state = ApplicationAuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // ── State Updates ────────────────────────────────────────────────────────

  void setAppState(ApplicationAuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _state = ApplicationAuthState.authenticating;
    }
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    if (message != null) {
      _state = ApplicationAuthState.error;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = _currentUser != null
        ? ApplicationAuthState.authenticated
        : ApplicationAuthState.unauthenticated;
    notifyListeners();
  }

  // ── Auth Actions ─────────────────────────────────────────────────────────

  /// Sign in with Google via Firebase Authentication.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.signInWithGoogle();
      _isLoading = false;
      _state = ApplicationAuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      if (e.failure != AuthFailure.cancelled) {
        _setError(e.message);
      } else {
        _state = ApplicationAuthState.unauthenticated;
        notifyListeners();
      }
      return false;
    } catch (e) {
      _isLoading = false;
      _setError('Google Sign-In failed. Please try again.');
      return false;
    }
  }

  /// Sign in with Email and Password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.signInWithEmail(email: email, password: password);
      _isLoading = false;
      _state = ApplicationAuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _setError(e.message);
      return false;
    } catch (e) {
      _isLoading = false;
      _setError(AuthFailure.unknown.message);
      return false;
    }
  }

  /// Register with Email, Full Name, and Password.
  Future<bool> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );
      _isLoading = false;
      _state = ApplicationAuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _setError(e.message);
      return false;
    } catch (e) {
      _isLoading = false;
      _setError(AuthFailure.unknown.message);
      return false;
    }
  }

  /// Send password reset link.
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError(AuthFailure.unknown.message);
      return false;
    }
  }

  /// Resend verification email.
  Future<bool> resendVerificationEmail() async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.sendEmailVerification();
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError(AuthFailure.unknown.message);
      return false;
    }
  }

  /// Get Firebase ID Token (JWT).
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _repository.getIdToken(forceRefresh: forceRefresh);
    } catch (e) {
      return null;
    }
  }

  /// Sign out from Firebase Auth.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _repository.signOut();
    } finally {
      _state = ApplicationAuthState.unauthenticated;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
