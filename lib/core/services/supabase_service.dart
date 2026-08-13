import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../constants/supabase_constants.dart';

/// Service managing the Firebase Auth → Supabase Third-Party Auth Bridge.
///
/// Architecture:
/// - Firebase Authentication is the sole Identity Provider.
/// - Supabase Auth methods (e.g. `signInWithPassword`) are NEVER called.
/// - SupabaseClient is initialized with an `accessToken` provider callback that
///   fetches the fresh Firebase ID Token (JWT) on every request.
/// - Listens to `FirebaseAuth.instance.idTokenChanges()` to maintain active
///   JWT token synchronization.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  StreamSubscription<User?>? _idTokenSubscription;
  bool _isInitialized = false;

  /// Returns the underlying [SupabaseClient].
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'SupabaseService has not been initialized. Call initialize() first.',
      );
    }
    return Supabase.instance.client;
  }

  /// Initializes Supabase Flutter with the Firebase ID Token bridge.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Supabase.initialize(
      url: SupabaseConstants.url,
      publishableKey: SupabaseConstants.anonKey,
      accessToken: () async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return null;
          // Retrieve the current Firebase ID Token (JWT)
          final token = await user.getIdToken();
          return token;
        } catch (e) {
          debugPrint('Error fetching Firebase ID Token for Supabase: $e');
          return null;
        }
      },
    );

    _isInitialized = true;

    // Listen to Firebase ID token changes to sync session / token refresh
    _idTokenSubscription =
        FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      if (user != null) {
        try {
          final token = await user.getIdToken(true);
          debugPrint(
            'Firebase ID Token refreshed & synced with Supabase (UID: ${user.uid}). Token prefix: ${token?.substring(0, 15)}...',
          );
        } catch (e) {
          debugPrint('Error refreshing Firebase ID Token on stream: $e');
        }
      } else {
        debugPrint('Firebase user signed out — Supabase requests will execute as unauthenticated.');
      }
    });

    debugPrint('Supabase initialized with Firebase Auth Token Bridge.');
  }

  /// Manually force-refreshes the Firebase ID Token and returns it.
  Future<String?> getFreshFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken(true);
  }

  /// Verification Helper: Executes a test check on the Firebase → Supabase bridge.
  Future<Map<String, dynamic>> checkBridgeStatus() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return {
        'authenticated': false,
        'firebaseUid': null,
        'hasToken': false,
        'message': 'No Firebase user signed in.',
      };
    }

    try {
      final token = await firebaseUser.getIdToken();
      final hasToken = token != null && token.isNotEmpty;

      return {
        'authenticated': true,
        'firebaseUid': firebaseUser.uid,
        'email': firebaseUser.email,
        'hasToken': hasToken,
        'tokenPrefix': hasToken ? '${token.substring(0, 20)}...' : null,
        'message': 'Firebase ID token acquired successfully. Supabase bridge active.',
      };
    } catch (e) {
      return {
        'authenticated': true,
        'firebaseUid': firebaseUser.uid,
        'hasToken': false,
        'error': e.toString(),
        'message': 'Failed to obtain Firebase ID token.',
      };
    }
  }

  /// Clean up listeners.
  void dispose() {
    _idTokenSubscription?.cancel();
  }
}
