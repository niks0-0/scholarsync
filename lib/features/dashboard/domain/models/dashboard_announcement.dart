/// Model for Announcements Dashboard card.
class DashboardAnnouncement {
  const DashboardAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.priority = 'normal',
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String priority;
  final bool isPinned;

  factory DashboardAnnouncement.fromJson(Map<String, dynamic> json) {
    return DashboardAnnouncement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: (json['priority'] as String?) ?? 'normal',
      isPinned: (json['is_pinned'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'is_pinned': isPinned,
    };
  }
}
