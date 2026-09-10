class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.location,
    required this.eventDate,
    this.bannerUrl,
    this.organizerId,
    this.organizerName,
    this.status = 'approved', // 'pending', 'approved', 'rejected'
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String category; // 'hackathon', 'workshop', 'seminar', 'cultural', 'sports'
  final String? location;
  final DateTime eventDate;
  final String? bannerUrl;
  final String? organizerId;
  final String? organizerName;
  final String status;
  final DateTime? createdAt;

  factory CampusEvent.fromJson(Map<String, dynamic> json) {
    return CampusEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: (json['event_type'] ?? json['category']) as String? ?? 'workshop',
      location: json['location'] as String?,
      eventDate: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'] as String) ?? DateTime.now()
          : (json['event_date'] != null
              ? DateTime.tryParse(json['event_date'] as String) ?? DateTime.now()
              : DateTime.now()),
      bannerUrl: json['banner_url'] as String?,
      organizerId: (json['created_by'] ?? json['organizer_id']) as String?,
      organizerName: json['organizer'] != null && json['organizer'] is Map
          ? (json['organizer'] as Map)['full_name'] as String?
          : json['organizer_name'] as String?,
      status: json['status'] as String? ?? 'approved',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      if (description != null && description!.isNotEmpty) 'description': description,
      'event_type': category,
      if (location != null && location!.isNotEmpty) 'location': location,
      'start_time': eventDate.toIso8601String(),
      'end_time': eventDate.add(const Duration(hours: 3)).toIso8601String(),
      if (bannerUrl != null && bannerUrl!.isNotEmpty) 'banner_url': bannerUrl,
      if (organizerId != null && organizerId!.isNotEmpty) 'created_by': organizerId,
      'status': status,
    };
  }

  CampusEvent copyWith({
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? eventDate,
    String? bannerUrl,
    String? status,
    String? organizerName,
  }) {
    return CampusEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      organizerId: organizerId,
      organizerName: organizerName ?? this.organizerName,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
