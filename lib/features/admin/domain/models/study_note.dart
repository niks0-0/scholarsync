class StudyNote {
  const StudyNote({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    this.subjectName,
    required this.uploaderId,
    this.uploaderName,
    required this.fileUrl,
    this.fileType = 'PDF',
    this.fileSizeBytes = 0,
    this.status = 'pending',
    this.rejectionReason,
    this.downloadsCount = 0,
    this.ratingsAvg = 5.0,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String title;
  final String? description;
  final String subjectId;
  final String? subjectName;
  final String uploaderId;
  final String? uploaderName;
  final String fileUrl;
  final String fileType;
  final int fileSizeBytes;
  final String status; // pending, approved, rejected, flagged
  final String? rejectionReason;
  final int downloadsCount;
  final double ratingsAvg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  factory StudyNote.fromJson(Map<String, dynamic> json) {
    return StudyNote(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Note',
      description: json['description'] as String?,
      subjectId: json['subject_id'] as String? ?? '',
      subjectName: json['subjects'] != null && json['subjects'] is Map
          ? (json['subjects'] as Map<String, dynamic>)['name'] as String?
          : null,
      uploaderId: json['uploader_id'] as String? ?? '',
      uploaderName: json['profiles'] != null && json['profiles'] is Map
          ? (json['profiles'] as Map<String, dynamic>)['full_name'] as String?
          : null,
      fileUrl: json['file_url'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'PDF',
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      downloadsCount: (json['downloads_count'] as num?)?.toInt() ?? 0,
      ratingsAvg: (json['ratings_avg'] as num?)?.toDouble() ?? 5.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'uploader_id': uploaderId,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'status': status,
      'rejection_reason': rejectionReason,
      'downloads_count': downloadsCount,
      'ratings_avg': ratingsAvg,
      'is_deleted': isDeleted,
    };
  }

  StudyNote copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    String? uploaderId,
    String? uploaderName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    String? status,
    String? rejectionReason,
    int? downloadsCount,
    double? ratingsAvg,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return StudyNote(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      downloadsCount: downloadsCount ?? this.downloadsCount,
      ratingsAvg: ratingsAvg ?? this.ratingsAvg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
