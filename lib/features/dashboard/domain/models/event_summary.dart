enum EventType { exam, holiday, workshop, deadline, cultural }

/// Summary model for Event & Calendar Dashboard card.
class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.time,
    required this.location,
    this.eventType = EventType.exam,
  });

  final String id;
  final String title;
  final DateTime eventDate;
  final String time;
  final String location;
  final EventType eventType;

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      time: json['time'] as String,
      location: json['location'] as String,
      eventType: _parseEventType(json['event_type'] as String?),
    );
  }

  static EventType _parseEventType(String? val) {
    switch (val?.toLowerCase()) {
      case 'holiday':
        return EventType.holiday;
      case 'workshop':
        return EventType.workshop;
      case 'deadline':
        return EventType.deadline;
      case 'cultural':
        return EventType.cultural;
      case 'exam':
      default:
        return EventType.exam;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'event_date': eventDate.toIso8601String(),
      'time': time,
      'location': location,
      'event_type': eventType.name,
    };
  }
}
