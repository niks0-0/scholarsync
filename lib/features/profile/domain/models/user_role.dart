/// Role-Based Access Control (RBAC) user roles for ScholarSync.
enum UserRole {
  student,
  admin,
  superAdmin;

  /// Parse from string stored in Supabase profiles `role` column.
  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
      case 'owner':
        return UserRole.superAdmin;
      case 'admin':
      case 'administrator':
      case 'app_admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  /// String value to persist in database.
  String toDbValue() {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.student:
        return 'student';
    }
  }

  /// Display name for UI badges.
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'App Owner';
      case UserRole.admin:
        return 'App Admin';
      case UserRole.student:
        return 'Student';
    }
  }

  /// Returns true if user is an application administrator/owner.
  bool get isAdmin => this == UserRole.admin || this == UserRole.superAdmin;

  /// Returns true if user has master management permissions.
  bool get canManageCurriculum => isAdmin;
}
