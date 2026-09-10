class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    this.subjectId,
    this.subjectName,
    this.collegeId,
    this.branch,
    this.semester,
    this.batch,
    this.isArchived = false,
    this.isLocked = false,
    this.lockedBy,
    this.lockReason,
    this.lockedAt,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String name;
  final String type; // 'subject', 'batch', 'club', 'broadcast', 'public'
  final String? subjectId;
  final String? subjectName;
  final String? collegeId;
  final String? branch;
  final int? semester;
  final String? batch;
  final bool isArchived;
  final bool isLocked;
  final String? lockedBy;
  final String? lockReason;
  final DateTime? lockedAt;
  final String? createdBy;
  final DateTime? createdAt;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'subject',
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      collegeId: json['college_id'] as String?,
      branch: json['branch'] as String?,
      semester: json['semester'] as int?,
      batch: json['batch'] as String?,
      isArchived: (json['is_archived'] as bool?) ?? false,
      isLocked: (json['is_locked'] as bool?) ?? false,
      lockedBy: json['locked_by'] as String?,
      lockReason: json['lock_reason'] as String?,
      lockedAt: json['locked_at'] != null ? DateTime.tryParse(json['locked_at'] as String) : null,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'type': type,
      if (subjectId != null && subjectId!.trim().isNotEmpty) 'subject_id': subjectId,
      if (collegeId != null && collegeId!.trim().isNotEmpty) 'college_id': collegeId,
      if (branch != null && branch!.trim().isNotEmpty) 'branch': branch,
      if (semester != null) 'semester': semester,
      if (batch != null && batch!.trim().isNotEmpty) 'batch': batch,
      'is_archived': isArchived,
      'is_locked': isLocked,
      if (lockReason != null) 'lock_reason': lockReason,
      if (createdBy != null && createdBy!.trim().isNotEmpty) 'created_by': createdBy,
    };
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    String? type,
    String? subjectId,
    String? subjectName,
    String? collegeId,
    String? branch,
    int? semester,
    String? batch,
    bool? isArchived,
    bool? isLocked,
    String? lockedBy,
    String? lockReason,
    DateTime? lockedAt,
    String? createdBy,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      collegeId: collegeId ?? this.collegeId,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      batch: batch ?? this.batch,
      isArchived: isArchived ?? this.isArchived,
      isLocked: isLocked ?? this.isLocked,
      lockedBy: lockedBy ?? this.lockedBy,
      lockReason: lockReason ?? this.lockReason,
      lockedAt: lockedAt ?? this.lockedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
    );
  }
}
