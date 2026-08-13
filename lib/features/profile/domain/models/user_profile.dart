/// Application user profile model stored in Supabase `public.profiles`.
///
/// Note: [id] is the Firebase Auth UID (text primary key), NOT a UUID.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.authProvider = 'google.com',
    this.onboardingCompleted = false,
    this.collegeId,
    this.branch,
    this.semester,
    this.division,
    this.createdAt,
    this.updatedAt,
  });

  /// Permanent application user identity (Firebase Auth UID = JWT sub).
  final String id;

  /// User email address.
  final String email;

  /// User's full name.
  final String fullName;

  /// Optional avatar URL.
  final String? avatarUrl;

  /// Authentication provider (e.g. 'google.com', 'password').
  final String authProvider;

  /// Whether onboarding steps are completed.
  final bool onboardingCompleted;

  /// Foreign key reference to colleges table.
  final String? collegeId;

  /// Academic branch (e.g. Computer Engineering).
  final String? branch;

  /// Current semester number (1–8).
  final int? semester;

  /// Section/Division (e.g. 'A').
  final String? division;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      authProvider: (json['auth_provider'] as String?) ?? 'google.com',
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
      collegeId: json['college_id'] as String?,
      branch: json['branch'] as String?,
      semester: json['semester'] as int?,
      division: json['division'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'auth_provider': authProvider,
      'onboarding_completed': onboardingCompleted,
      'college_id': collegeId,
      'branch': branch,
      'semester': semester,
      'division': division,
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? avatarUrl,
    String? authProvider,
    bool? onboardingCompleted,
    String? collegeId,
    String? branch,
    int? semester,
    String? division,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      collegeId: collegeId ?? this.collegeId,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      division: division ?? this.division,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserProfile(id: $id, email: $email, fullName: $fullName)';
}
