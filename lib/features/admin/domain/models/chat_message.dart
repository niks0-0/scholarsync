class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName,
    required this.content,
    this.attachmentUrl,
    this.attachmentType,
    this.isPinned = false,
    this.createdAt,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String? senderName;
  final String content;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isPinned;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String?,
      content: json['content'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      isPinned: (json['is_pinned'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'is_pinned': isPinned,
    };
  }

  ChatMessage copyWith({
    String? content,
    String? attachmentUrl,
    String? attachmentType,
    bool? isPinned,
    String? senderName,
  }) {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
    );
  }
}
