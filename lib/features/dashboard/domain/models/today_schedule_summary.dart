enum ClassStatus { upcoming, current, completed }

/// Summary model representing a single class schedule item for today's timetable.
class TodayScheduleSummary {
  const TodayScheduleSummary({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.faculty,
    this.isOnline = false,
    this.status = ClassStatus.upcoming,
  });

  final String id;
  final String subject;
  final String startTime;
  final String endTime;
  final String room;
  final String faculty;
  final bool isOnline;
  final ClassStatus status;

  factory TodayScheduleSummary.fromJson(Map<String, dynamic> json) {
    return TodayScheduleSummary(
      id: json['id'] as String,
      subject: json['subject'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String,
      faculty: json['faculty'] as String,
      isOnline: (json['is_online'] as bool?) ?? false,
      status: _parseStatus(json['status'] as String?),
    );
  }

  static ClassStatus _parseStatus(String? val) {
    switch (val?.toLowerCase()) {
      case 'current':
        return ClassStatus.current;
      case 'completed':
        return ClassStatus.completed;
      case 'upcoming':
      default:
        return ClassStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'faculty': faculty,
      'is_online': isOnline,
      'status': status.name,
    };
  }
}
