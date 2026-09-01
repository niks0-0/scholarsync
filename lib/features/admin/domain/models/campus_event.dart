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
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'workshop',
      location: json['location'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      bannerUrl: json['banner_url'] as String?,
      organizerId: json['organizer_id'] as String?,
      organizerName: json['organizer_name'] as String?,
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
      'description': description,
      'category': category,
      'location': location,
      'event_date': eventDate.toIso8601String(),
      'banner_url': bannerUrl,
      'organizer_id': organizerId,
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
