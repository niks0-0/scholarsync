import '../models/auth_user.dart';

/// Contract for authentication repository operations.
/// Decouples the UI/AuthProvider from the underlying data source (Firebase).
abstract class AuthRepository {
  /// Stream of current authenticated user changes.
  Stream<AuthUser?> get authStateChanges;

  /// Gets the currently authenticated user, or null.
  AuthUser? get currentUser;

  /// Sign in using Google OAuth flow.
  Future<AuthUser> signInWithGoogle();

  /// Sign in using email and password.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Register a new account with email and password.
  Future<AuthUser> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  });

  /// Send password reset email.
  Future<void> sendPasswordResetEmail({required String email});

  /// Send email verification to current user.
  Future<void> sendEmailVerification();

  /// Obtains the Firebase ID Token (JWT).
  Future<String?> getIdToken({bool forceRefresh = false});

  /// Sign out the current user.
  Future<void> signOut();
}
