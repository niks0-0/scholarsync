import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/enums/auth_failure.dart';

/// Raw Firebase + Google Sign-In service.
///
/// This is the ONLY place in the app that directly interacts with
/// [FirebaseAuth] and [GoogleSignIn]. All other layers use [FirebaseAuthRepository].
///
/// NEVER call this service from widgets — always go through [AuthProvider]
/// and [FirebaseAuthRepository].
class FirebaseAuthService {
  static const String _webClientId =
      '127188603534-r2vlthlmlkqnbngbsmi2118ccd6nsip9.apps.googleusercontent.com';

  FirebaseAuthService()
      : _firebaseAuth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn(
          clientId: kIsWeb ? _webClientId : null,
          serverClientId: _webClientId,
          scopes: ['email', 'profile'],
        );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // ── Current User ──────────────────────────────────────────────────────────

  /// Returns the currently signed-in Firebase user, or null if not signed in.
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Returns the current user mapped to [AuthUser], or null.
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? _mapFirebaseUser(user) : null;
  }

  // ── Auth State Stream ─────────────────────────────────────────────────────

  /// Stream of [AuthUser?] that fires whenever the Firebase auth state changes.
  /// Emits null when signed out, [AuthUser] when signed in.
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUser(user) : null;
    });
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  /// Sign in with Google via Firebase Authentication.
  ///
  /// Flow:
  /// 1. Launch Google account picker via [GoogleSignIn]
  /// 2. Obtain [GoogleSignInAuthentication] with idToken + accessToken
  /// 3. Create [GoogleAuthProvider.credential]
  /// 4. Sign in to Firebase with the credential
  /// 5. Return [AuthUser] from the resulting [User]
  ///
  /// Throws [AuthException] on failure.
  Future<AuthUser> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        if (userCredential.user == null) {
          throw const AuthException(AuthFailure.unknown);
        }
        return _mapFirebaseUser(userCredential.user!);
      } else {
        final googleAccount = await _googleSignIn.signIn();

        if (googleAccount == null) {
          // User closed the Google picker without selecting an account.
          throw const AuthException(AuthFailure.cancelled);
        }

        final googleAuth = await googleAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        if (userCredential.user == null) {
          throw const AuthException(AuthFailure.unknown);
        }

        return _mapFirebaseUser(userCredential.user!);
      }
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException in signInWithGoogle: [${e.code}] ${e.message}');
      final mappedFailure = _mapFirebaseCode(e.code);
      throw AuthException(
        mappedFailure,
        originalError: e,
        customMessage: mappedFailure == AuthFailure.unknown && e.message != null
            ? e.message
            : null,
      );
    } catch (e, stack) {
      debugPrint('Error in signInWithGoogle: $e\n$stack');
      final message = e.toString().toLowerCase();
      if (message.contains('network') || message.contains('socket')) {
        throw AuthException(AuthFailure.networkError, originalError: e);
      }
      if (message.contains('cancel') ||
          message.contains('popup_closed') ||
          message.contains('sign_in_canceled')) {
        throw const AuthException(AuthFailure.cancelled);
      }
      throw AuthException(
        AuthFailure.unknown,
        originalError: e,
        customMessage: e.toString(),
      );
    }
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  /// Sign in with email and password.
  /// Throws [AuthException] on failure.
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException(AuthFailure.unknown);
      }
      return _mapFirebaseUser(credential.user!);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code), originalError: e);
    }
  }

  /// Create a new account with email and password.
  /// Throws [AuthException] on failure.
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException(AuthFailure.unknown);
      }
      // Update display name if provided
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      }
      return _mapFirebaseUser(_firebaseAuth.currentUser ?? credential.user!);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code), originalError: e);
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  /// Send a password reset email.
  /// Throws [AuthException] on failure.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code), originalError: e);
    }
  }

  // ── Email Verification ────────────────────────────────────────────────────

  /// Send email verification to the currently signed-in user.
  /// Throws [AuthException] on failure.
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException(AuthFailure.unknown);
      await user.sendEmailVerification();
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code), originalError: e);
    }
  }

  // ── ID Token ──────────────────────────────────────────────────────────────

  /// Returns the current Firebase ID token (JWT).
  ///
  /// Set [forceRefresh] to true to always fetch a fresh token from Firebase
  /// (useful before sending the token to a backend like Supabase).
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseCode(e.code), originalError: e);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  /// Sign out from both Firebase Auth and Google Sign-In.
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Session Restoration ───────────────────────────────────────────────────

  /// Reload the current user from Firebase to get the latest data.
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Maps a [User] (Firebase SDK) to [AuthUser] (domain model).
  AuthUser _mapFirebaseUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
    );
  }

  /// Maps Firebase error codes to [AuthFailure] enum values.
  AuthFailure _mapFirebaseCode(String code) {
    switch (code) {
      case 'network-request-failed':
        return AuthFailure.networkError;
      case 'user-not-found':
        return AuthFailure.userNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthFailure.invalidCredential;
      case 'email-already-in-use':
        return AuthFailure.emailAlreadyInUse;
      case 'invalid-email':
        return AuthFailure.invalidEmail;
      case 'weak-password':
        return AuthFailure.weakPassword;
      case 'user-disabled':
        return AuthFailure.userDisabled;
      case 'account-exists-with-different-credential':
        return AuthFailure.accountExistsWithDifferentCredential;
      case 'too-many-requests':
        return AuthFailure.tooManyRequests;
      case 'operation-not-allowed':
        return AuthFailure.operationNotAllowed;
      case 'unauthorized-domain':
        return AuthFailure.unauthorizedDomain;
      case 'provider-already-linked':
      default:
        return AuthFailure.unknown;
    }
  }
}
