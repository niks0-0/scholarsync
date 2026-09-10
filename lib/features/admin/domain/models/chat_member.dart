/// Chat Room Membership Model.
class ChatMember {
  const ChatMember({
    required this.id,
    required this.roomId,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.role = 'member',
    this.isMuted = false,
    this.mutedUntil,
    this.isBanned = false,
    this.bannedUntil,
    this.banReason,
    this.createdAt,
  });

  final String id;
  final String roomId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String role; // 'member', 'moderator', 'admin'
  final bool isMuted;
  final DateTime? mutedUntil;
  final bool isBanned;
  final DateTime? bannedUntil;
  final String? banReason;
  final DateTime? createdAt;

  bool get isCurrentlyMuted => isMuted && (mutedUntil == null || mutedUntil!.isAfter(DateTime.now()));
  bool get isCurrentlyBanned => isBanned && (bannedUntil == null || bannedUntil!.isAfter(DateTime.now()));

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['profiles'] != null && json['profiles'] is Map
          ? (json['profiles'] as Map)['full_name'] as String?
          : json['user_name'] as String?,
      userAvatar: json['profiles'] != null && json['profiles'] is Map
          ? (json['profiles'] as Map)['avatar_url'] as String?
          : json['user_avatar'] as String?,
      role: json['role'] as String? ?? 'member',
      isMuted: (json['is_muted'] as bool?) ?? false,
      mutedUntil: json['muted_until'] != null ? DateTime.tryParse(json['muted_until'] as String) : null,
      isBanned: (json['is_banned'] as bool?) ?? false,
      bannedUntil: json['banned_until'] != null ? DateTime.tryParse(json['banned_until'] as String) : null,
      banReason: json['ban_reason'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'room_id': roomId,
      'user_id': userId,
      'role': role,
      'is_muted': isMuted,
      if (mutedUntil != null) 'muted_until': mutedUntil!.toIso8601String(),
      'is_banned': isBanned,
      if (bannedUntil != null) 'banned_until': bannedUntil!.toIso8601String(),
      if (banReason != null) 'ban_reason': banReason,
    };
  }
}
