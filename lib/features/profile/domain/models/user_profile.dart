import 'user_role.dart';

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
    this.role = UserRole.student,
    this.collegeId,
    this.branch,
    this.semester,
    this.division,
    this.academicYear,
    this.rollNumber,
    this.enrollmentNumber,
    this.isSuspended = false,
    this.suspensionReason,
    this.createdAt,
    this.updatedAt,
  });

  /// Permanent application user identity (Firebase Auth UID = JWT sub).
  final String id;

  /// User email address (read-only).
  final String email;

  /// User's full name.
  final String fullName;

  /// Optional avatar URL.
  final String? avatarUrl;

  /// Authentication provider (e.g. 'google.com', 'password').
  final String authProvider;

  /// Whether onboarding steps are completed.
  final bool onboardingCompleted;

  /// Role-based access level (`student`, `faculty`, `admin`, `super_admin`).
  final UserRole role;

  /// Foreign key reference to colleges table.
  final String? collegeId;

  /// Academic branch (e.g. Computer Engineering).
  final String? branch;

  /// Current semester number (1–8).
  final int? semester;

  /// Section/Division (e.g. 'A').
  final String? division;

  /// Current academic year (e.g. 'First Year', 'Second Year', 'FY', 'BE').
  final String? academicYear;

  /// Optional Roll Number.
  final String? rollNumber;

  /// Optional Enrollment Number / Student ID.
  final String? enrollmentNumber;

  /// Whether account is suspended by Admin.
  final bool isSuspended;

  /// Optional reason for administrative suspension.
  final String? suspensionReason;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      authProvider: (json['auth_provider'] as String?) ?? 'google.com',
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
      role: UserRole.fromString(json['role'] as String?),
      collegeId: json['college_id'] as String?,
      branch: json['branch'] as String?,
      semester: json['semester'] as int?,
      division: json['division'] as String?,
      academicYear: json['academic_year'] as String?,
      rollNumber: json['roll_number'] as String?,
      enrollmentNumber: json['enrollment_number'] as String?,
      isSuspended: (json['is_suspended'] as bool?) ?? false,
      suspensionReason: json['suspension_reason'] as String?,
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
      'role': role.toDbValue(),
      'college_id': collegeId,
      'branch': branch,
      'semester': semester,
      'division': division,
      'academic_year': academicYear,
      'roll_number': rollNumber,
      'enrollment_number': enrollmentNumber,
      'is_suspended': isSuspended,
      'suspension_reason': suspensionReason,
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? avatarUrl,
    String? authProvider,
    bool? onboardingCompleted,
    UserRole? role,
    String? collegeId,
    String? branch,
    int? semester,
    String? division,
    String? academicYear,
    String? rollNumber,
    String? enrollmentNumber,
    bool? isSuspended,
    String? suspensionReason,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      role: role ?? this.role,
      collegeId: collegeId ?? this.collegeId,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      division: division ?? this.division,
      academicYear: academicYear ?? this.academicYear,
      rollNumber: rollNumber ?? this.rollNumber,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
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
      'UserProfile(id: $id, email: $email, fullName: $fullName, role: ${role.name}, branch: $branch, semester: $semester)';
}
