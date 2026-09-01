/// Canonical Academic Subject domain entity stored in Supabase `public.subjects`.
class Subject {
  const Subject({
    required this.id,
    this.collegeId,
    required this.branch,
    required this.semester,
    required this.subjectCode,
    required this.subjectName,
    required this.shortName,
    this.credits = 3,
    this.facultyName,
    this.practical = false,
    this.theory = true,
    this.displayOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Canonical subject UUID.
  final String id;

  /// Foreign key reference to public.colleges (optional).
  final String? collegeId;

  /// Academic branch (e.g. Computer Science & Engineering).
  final String branch;

  /// Semester number (1–8).
  final int semester;

  /// Subject official code (e.g. CS401).
  final String subjectCode;

  /// Official subject name (e.g. Data Structures & Algorithms).
  final String subjectName;

  /// Abbreviated short name (e.g. DSA).
  final String shortName;

  /// Number of academic credit points.
  final int credits;

  /// Faculty / Professor name teaching the course.
  final String? facultyName;

  /// Whether course includes practical lab component.
  final bool practical;

  /// Whether course includes theory lecture component.
  final bool theory;

  /// Ordering integer for UI display.
  final int displayOrder;

  /// Active status flag.
  final bool isActive;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      collegeId: json['college_id'] as String?,
      branch: json['branch'] as String,
      semester: json['semester'] as int,
      subjectCode: json['subject_code'] as String,
      subjectName: json['subject_name'] as String,
      shortName: json['short_name'] as String,
      credits: (json['credits'] as int?) ?? 3,
      facultyName: json['faculty_name'] as String?,
      practical: (json['practical'] as bool?) ?? false,
      theory: (json['theory'] as bool?) ?? true,
      displayOrder: (json['display_order'] as int?) ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
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
      'college_id': collegeId,
      'branch': branch,
      'semester': semester,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'short_name': shortName,
      'credits': credits,
      'faculty_name': facultyName,
      'practical': practical,
      'theory': theory,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  Subject copyWith({
    String? collegeId,
    String? branch,
    int? semester,
    String? subjectCode,
    String? subjectName,
    String? shortName,
    int? credits,
    String? facultyName,
    bool? practical,
    bool? theory,
    int? displayOrder,
    bool? isActive,
  }) {
    return Subject(
      id: id,
      collegeId: collegeId ?? this.collegeId,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      shortName: shortName ?? this.shortName,
      credits: credits ?? this.credits,
      facultyName: facultyName ?? this.facultyName,
      practical: practical ?? this.practical,
      theory: theory ?? this.theory,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Subject(id: $id, code: $subjectCode, name: $subjectName, branch: $branch, semester: $semester)';
}
