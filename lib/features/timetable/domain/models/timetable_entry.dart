import '../../../academic_catalog/domain/models/subject.dart';

enum TimetableClassStatus { completed, current, upcoming }

/// Canonical Timetable Entry domain entity stored in Supabase `public.timetable_entries`.
class TimetableEntry {
  const TimetableEntry({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.building,
    this.facultyName,
    this.mode = 'Offline',
    this.meetingUrl,
    this.classType = 'Lecture',
    this.notes,
    this.reminderMinutes = 15,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.subject,
  });

  final String id;
  final String userId;
  final String subjectId;

  /// Weekday integer (1 = Monday, 2 = Tuesday, ..., 7 = Sunday).
  final int weekday;

  /// Start time string in 24-hour HH:mm format (e.g. "09:00").
  final String startTime;

  /// End time string in 24-hour HH:mm format (e.g. "10:30").
  final String endTime;

  final String room;
  final String? building;
  final String? facultyName;

  /// "Offline", "Online", "Hybrid"
  final String mode;

  final String? meetingUrl;

  /// "Lecture", "Lab", "Tutorial", "Seminar", "Workshop", "Custom"
  final String classType;

  final String? notes;
  final int reminderMinutes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Populated canonical Subject entity from Academic Catalog.
  final Subject? subject;

  String get subjectName => subject?.subjectName ?? 'Academic Class';
  String get subjectCode => subject?.subjectCode ?? 'SUB101';
  String get shortName => subject?.shortName ?? 'SUB';

  int get durationMinutes {
    try {
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();
      final startTotal = startParts[0] * 60 + startParts[1];
      final endTotal = endParts[0] * 60 + endParts[1];
      return endTotal - startTotal;
    } catch (_) {
      return 60;
    }
  }

  /// Calculates status (`completed`, `current`, `upcoming`) relative to local time and day.
  TimetableClassStatus calculateStatus([DateTime? referenceTime]) {
    final now = referenceTime ?? DateTime.now();

    if (now.weekday != weekday) {
      return now.weekday > weekday ? TimetableClassStatus.completed : TimetableClassStatus.upcoming;
    }

    try {
      final currentMinutes = now.hour * 60 + now.minute;
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();

      final startMinutes = startParts[0] * 60 + startParts[1];
      final endMinutes = endParts[0] * 60 + endParts[1];

      if (currentMinutes < startMinutes) {
        return TimetableClassStatus.upcoming;
      } else if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return TimetableClassStatus.current;
      } else {
        return TimetableClassStatus.completed;
      }
    } catch (_) {
      return TimetableClassStatus.upcoming;
    }
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json, {Subject? subject}) {
    return TimetableEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subjectId: json['subject_id'] as String,
      weekday: json['weekday'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String,
      building: json['building'] as String?,
      facultyName: json['faculty_name'] as String?,
      mode: (json['mode'] as String?) ?? 'Offline',
      meetingUrl: json['meeting_url'] as String?,
      classType: (json['class_type'] as String?) ?? 'Lecture',
      notes: json['notes'] as String?,
      reminderMinutes: (json['reminder_minutes'] as int?) ?? 15,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      subject: subject ?? (json['subjects'] != null ? Subject.fromJson(json['subjects'] as Map<String, dynamic>) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'building': building,
      'faculty_name': facultyName,
      'mode': mode,
      'meeting_url': meetingUrl,
      'class_type': classType,
      'notes': notes,
      'reminder_minutes': reminderMinutes,
      'is_active': isActive,
    };
  }

  TimetableEntry copyWith({
    String? subjectId,
    int? weekday,
    String? startTime,
    String? endTime,
    String? room,
    String? building,
    String? facultyName,
    String? mode,
    String? meetingUrl,
    String? classType,
    String? notes,
    int? reminderMinutes,
    bool? isActive,
    Subject? subject,
  }) {
    return TimetableEntry(
      id: id,
      userId: userId,
      subjectId: subjectId ?? this.subjectId,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      building: building ?? this.building,
      facultyName: facultyName ?? this.facultyName,
      mode: mode ?? this.mode,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      classType: classType ?? this.classType,
      notes: notes ?? this.notes,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      subject: subject ?? this.subject,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
