/// Clean domain model representing an authenticated ScholarSync user.
///
/// This model is Firebase-agnostic — no Firebase SDK types are exposed
/// beyond this layer. The UI and business logic interact only with [AuthUser].
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.isAnonymous = false,
  });

  /// Firebase UID — stable unique identifier for the user.
  final String uid;

  /// User's email address.
  final String? email;

  /// Display name (from Google profile or set manually).
  final String? displayName;

  /// Profile photo URL (from Google profile).
  final String? photoUrl;

  /// Whether the user's email has been verified.
  final bool isEmailVerified;

  /// Whether the user signed in anonymously.
  final bool isAnonymous;

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// Initials derived from [displayName] or [email] for avatar fallback.
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  /// Display-friendly name: prefers [displayName], falls back to email prefix.
  String get displayNameOrEmail {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    return 'User';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() =>
      'AuthUser(uid: $uid, email: $email, displayName: $displayName)';
}
