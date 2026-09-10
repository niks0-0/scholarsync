class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.clientMessageId,
    this.messageType = 'text',
    this.replyToId,
    this.replyToContent,
    this.replyToSenderName,
    this.attachmentUrl,
    this.attachmentType,
    this.isPinned = false,
    this.isDeleted = false,
    this.deletedBy,
    this.deletionReason,
    this.reactions = const {},
    this.userReaction,
    this.createdAt,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final String? clientMessageId;
  final String messageType; // 'text', 'image', 'file', 'system'
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderName;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isPinned;
  final bool isDeleted;
  final String? deletedBy;
  final String? deletionReason;
  final Map<String, int> reactions;
  final String? userReaction;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse reactions map if present
    Map<String, int> parsedReactions = {};
    if (json['reactions'] != null && json['reactions'] is Map) {
      (json['reactions'] as Map).forEach((key, val) {
        if (val is num) {
          parsedReactions[key.toString()] = val.toInt();
        }
      });
    }

    return ChatMessage(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      content: (json['is_deleted'] == true)
          ? '🚫 This message was deleted by a moderator.'
          : (json['content'] as String? ?? ''),
      clientMessageId: json['client_message_id'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      replyToId: json['reply_to_id'] as String?,
      replyToContent: json['reply_to_content'] as String?,
      replyToSenderName: json['reply_to_sender_name'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      isPinned: (json['is_pinned'] as bool?) ?? false,
      isDeleted: (json['is_deleted'] as bool?) ?? false,
      deletedBy: json['deleted_by'] as String?,
      deletionReason: json['deletion_reason'] as String?,
      reactions: parsedReactions,
      userReaction: json['user_reaction'] as String?,
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
      if (clientMessageId != null && clientMessageId!.isNotEmpty) 'client_message_id': clientMessageId,
      'message_type': messageType,
      if (replyToId != null && replyToId!.isNotEmpty) 'reply_to_id': replyToId,
      if (attachmentUrl != null && attachmentUrl!.isNotEmpty) 'attachment_url': attachmentUrl,
      if (attachmentType != null && attachmentType!.isNotEmpty) 'attachment_type': attachmentType,
      'is_pinned': isPinned,
      'is_deleted': isDeleted,
      if (deletionReason != null) 'deletion_reason': deletionReason,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    String? clientMessageId,
    String? messageType,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderName,
    String? attachmentUrl,
    String? attachmentType,
    bool? isPinned,
    bool? isDeleted,
    String? deletedBy,
    String? deletionReason,
    Map<String, int>? reactions,
    String? userReaction,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      messageType: messageType ?? this.messageType,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedBy: deletedBy ?? this.deletedBy,
      deletionReason: deletionReason ?? this.deletionReason,
      reactions: reactions ?? this.reactions,
      userReaction: userReaction ?? this.userReaction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
