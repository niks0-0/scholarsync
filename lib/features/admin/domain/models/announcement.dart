/// Domain entity for campus and departmental announcements.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    this.targetCollegeId,
    this.targetBranch,
    this.targetSemester,
    this.isUrgent = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String createdBy;
  final String? targetCollegeId;
  final String? targetBranch;
  final int? targetSemester;
  final bool isUrgent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdBy: (json['created_by'] as String?) ?? 'Admin',
      targetCollegeId: json['target_college_id'] as String?,
      targetBranch: json['target_branch'] as String?,
      targetSemester: json['target_semester'] as int?,
      isUrgent: (json['is_urgent'] as bool?) ?? false,
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
      'title': title,
      'content': content,
      'created_by': createdBy,
      'target_college_id': targetCollegeId,
      'target_branch': targetBranch,
      'target_semester': targetSemester,
      'is_urgent': isUrgent,
    };
  }

  Announcement copyWith({
    String? title,
    String? content,
    String? createdBy,
    String? targetCollegeId,
    String? targetBranch,
    int? targetSemester,
    bool? isUrgent,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdBy: createdBy ?? this.createdBy,
      targetCollegeId: targetCollegeId ?? this.targetCollegeId,
      targetBranch: targetBranch ?? this.targetBranch,
      targetSemester: targetSemester ?? this.targetSemester,
      isUrgent: isUrgent ?? this.isUrgent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
