class AcademicCalendarEvent {
  const AcademicCalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.eventType,
    required this.startDate,
    this.endDate,
    this.targetBranch,
    this.targetSemester,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String eventType; // 'holiday', 'exam', 'semester_start', 'semester_end', 'deadline'
  final DateTime startDate;
  final DateTime? endDate;
  final String? targetBranch;
  final int? targetSemester;
  final DateTime? createdAt;

  factory AcademicCalendarEvent.fromJson(Map<String, dynamic> json) {
    return AcademicCalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: json['event_type'] as String? ?? 'holiday',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      targetBranch: json['target_branch'] as String?,
      targetSemester: json['target_semester'] as int?,
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
      'event_type': eventType,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null)
        'end_date': endDate!.toIso8601String().split('T').first,
      'target_branch': targetBranch,
      'target_semester': targetSemester,
    };
  }

  AcademicCalendarEvent copyWith({
    String? title,
    String? description,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? targetBranch,
    int? targetSemester,
  }) {
    return AcademicCalendarEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetBranch: targetBranch ?? this.targetBranch,
      targetSemester: targetSemester ?? this.targetSemester,
      createdAt: createdAt,
    );
  }
}
