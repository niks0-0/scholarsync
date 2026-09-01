/// Summary model for Community Preview Dashboard card.
class CommunityPreviewSummary {
  const CommunityPreviewSummary({
    required this.recentSubjectActivity,
    required this.recentDiscussionTitle,
    required this.unreadCount,
    required this.authorName,
  });

  final String recentSubjectActivity;
  final String recentDiscussionTitle;
  final int unreadCount;
  final String authorName;

  factory CommunityPreviewSummary.fromJson(Map<String, dynamic> json) {
    return CommunityPreviewSummary(
      recentSubjectActivity: json['recent_subject_activity'] as String,
      recentDiscussionTitle: json['recent_discussion_title'] as String,
      unreadCount: json['unread_count'] as int,
      authorName: json['author_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recent_subject_activity': recentSubjectActivity,
      'recent_discussion_title': recentDiscussionTitle,
      'unread_count': unreadCount,
      'author_name': authorName,
    };
  }
}
