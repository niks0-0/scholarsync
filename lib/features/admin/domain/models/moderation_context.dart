import 'chat_message.dart';

/// Contextual Moderation Data holding the reported message and surrounding thread messages.
class ModerationContext {
  const ModerationContext({
    required this.reportId,
    required this.reason,
    required this.status,
    this.reporterId,
    this.reportedUserId,
    required this.roomId,
    required this.roomName,
    required this.targetMessage,
    this.previousMessages = const [],
    this.nextMessages = const [],
  });

  final String reportId;
  final String reason;
  final String status;
  final String? reporterId;
  final String? reportedUserId;
  final String roomId;
  final String roomName;
  final ChatMessage targetMessage;
  final List<ChatMessage> previousMessages;
  final List<ChatMessage> nextMessages;

  factory ModerationContext.fromJson(Map<String, dynamic> json) {
    final targetRaw = json['target_message'] as Map<String, dynamic>? ?? {};
    final prevRaw = json['previous_messages'] as List<dynamic>? ?? [];
    final nextRaw = json['next_messages'] as List<dynamic>? ?? [];

    return ModerationContext(
      reportId: json['report_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      reporterId: json['reporter_id'] as String?,
      reportedUserId: json['reported_user_id'] as String?,
      roomId: json['room_id'] as String? ?? '',
      roomName: json['room_name'] as String? ?? 'Academic Channel',
      targetMessage: ChatMessage.fromJson(targetRaw),
      previousMessages: prevRaw.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList(),
      nextMessages: nextRaw.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
