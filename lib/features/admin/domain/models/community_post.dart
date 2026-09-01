class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    this.authorName,
    required this.title,
    required this.content,
    this.category = 'general', // 'general', 'doubt', 'notes_share', 'career', 'project'
    this.tags = const [],
    this.isPinned = false,
    this.isLocked = false,
    this.upvotesCount = 0,
    this.commentsCount = 0,
    this.status = 'active', // 'active', 'flagged', 'hidden', 'deleted'
    this.createdAt,
  });

  final String id;
  final String authorId;
  final String? authorName;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final bool isPinned;
  final bool isLocked;
  final int upvotesCount;
  final int commentsCount;
  final String status;
  final DateTime? createdAt;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String?,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isPinned: (json['is_pinned'] as bool?) ?? false,
      isLocked: (json['is_locked'] as bool?) ?? false,
      upvotesCount: (json['upvotes_count'] as int?) ?? 0,
      commentsCount: (json['comments_count'] as int?) ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'author_id': authorId,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'is_pinned': isPinned,
      'is_locked': isLocked,
      'status': status,
    };
  }

  CommunityPost copyWith({
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    bool? isPinned,
    bool? isLocked,
    int? upvotesCount,
    int? commentsCount,
    String? status,
    String? authorName,
  }) {
    return CommunityPost(
      id: id,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      upvotesCount: upvotesCount ?? this.upvotesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
