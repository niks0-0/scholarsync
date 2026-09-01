class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    this.subjectId,
    this.subjectName,
    this.isArchived = false,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String name;
  final String type; // 'subject', 'batch', 'club', 'broadcast'
  final String? subjectId;
  final String? subjectName;
  final bool isArchived;
  final String? createdBy;
  final DateTime? createdAt;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'subject',
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      isArchived: (json['is_archived'] as bool?) ?? false,
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
      'subject_id': subjectId,
      'is_archived': isArchived,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  ChatRoom copyWith({
    String? name,
    String? type,
    String? subjectId,
    String? subjectName,
    bool? isArchived,
    String? createdBy,
  }) {
    return ChatRoom(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      isArchived: isArchived ?? this.isArchived,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
    );
  }
}
