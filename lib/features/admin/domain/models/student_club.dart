class StudentClub {
  const StudentClub({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.leadId,
    this.leadName,
    this.bannerUrl,
    this.memberCount = 0,
    this.status = 'active', // 'active', 'pending_approval', 'suspended'
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String category; // 'technical', 'cultural', 'sports', 'social'
  final String? leadId;
  final String? leadName;
  final String? bannerUrl;
  final int memberCount;
  final String status;
  final DateTime? createdAt;

  factory StudentClub.fromJson(Map<String, dynamic> json) {
    return StudentClub(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'technical',
      leadId: json['lead_id'] as String?,
      leadName: json['lead_name'] as String?,
      bannerUrl: json['banner_url'] as String?,
      memberCount: (json['member_count'] as int?) ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'category': category,
      'lead_id': leadId,
      'banner_url': bannerUrl,
      'member_count': memberCount,
      'status': status,
    };
  }

  StudentClub copyWith({
    String? name,
    String? description,
    String? category,
    String? leadId,
    String? leadName,
    String? bannerUrl,
    int? memberCount,
    String? status,
  }) {
    return StudentClub(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      memberCount: memberCount ?? this.memberCount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
