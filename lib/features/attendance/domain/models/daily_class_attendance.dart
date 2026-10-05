/// Status of an individual lecture session on a given date.
enum AttendanceStatus {
  unmarked,
  present,
  absent,
  cancelled,
  proxy;

  String get displayName {
    switch (this) {
      case AttendanceStatus.unmarked:
        return 'Not Marked';
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.cancelled:
        return 'Cancelled';
      case AttendanceStatus.proxy:
        return 'Proxy / Substitute';
    }
  }
}

/// A specific date's lecture occurrence derived from the student's timetable.
class DailyClassAttendance {
  const DailyClassAttendance({
    required this.id,
    required this.date,
    required this.timetableEntryId,
    required this.weekday,
    required this.originalSubjectId,
    required this.originalSubjectCode,
    required this.originalSubjectName,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.faculty,
    this.status = AttendanceStatus.unmarked,
    this.proxySubjectId,
    this.proxySubjectCode,
    this.proxySubjectName,
    this.proxyFaculty,
    this.cancellationReason,
    this.notes,
    this.isExtra = false,
    this.markedAt,
  });

  final String id;
  final DateTime date;
  final String timetableEntryId;
  final int weekday;

  final String originalSubjectId;
  final String originalSubjectCode;
  final String originalSubjectName;

  final String startTime;
  final String endTime;
  final String room;
  final String? faculty;

  final AttendanceStatus status;

  /// Populated when [status] is [AttendanceStatus.proxy]
  final String? proxySubjectId;
  final String? proxySubjectCode;
  final String? proxySubjectName;
  final String? proxyFaculty;

  /// Populated when [status] is [AttendanceStatus.cancelled]
  final String? cancellationReason;

  final String? notes;
  final bool isExtra;
  final DateTime? markedAt;

  /// The effective subject that receives attendance credit for this session
  String get effectiveSubjectId =>
      (status == AttendanceStatus.proxy && proxySubjectId != null)
          ? proxySubjectId!
          : originalSubjectId;

  String get effectiveSubjectCode =>
      (status == AttendanceStatus.proxy && proxySubjectCode != null)
          ? proxySubjectCode!
          : originalSubjectCode;

  String get effectiveSubjectName =>
      (status == AttendanceStatus.proxy && proxySubjectName != null)
          ? proxySubjectName!
          : originalSubjectName;

  DailyClassAttendance copyWith({
    String? id,
    DateTime? date,
    String? timetableEntryId,
    int? weekday,
    String? originalSubjectId,
    String? originalSubjectCode,
    String? originalSubjectName,
    String? startTime,
    String? endTime,
    String? room,
    String? faculty,
    AttendanceStatus? status,
    String? proxySubjectId,
    String? proxySubjectCode,
    String? proxySubjectName,
    String? proxyFaculty,
    String? cancellationReason,
    String? notes,
    bool? isExtra,
    DateTime? markedAt,
  }) {
    return DailyClassAttendance(
      id: id ?? this.id,
      date: date ?? this.date,
      timetableEntryId: timetableEntryId ?? this.timetableEntryId,
      weekday: weekday ?? this.weekday,
      originalSubjectId: originalSubjectId ?? this.originalSubjectId,
      originalSubjectCode: originalSubjectCode ?? this.originalSubjectCode,
      originalSubjectName: originalSubjectName ?? this.originalSubjectName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      faculty: faculty ?? this.faculty,
      status: status ?? this.status,
      proxySubjectId: proxySubjectId ?? this.proxySubjectId,
      proxySubjectCode: proxySubjectCode ?? this.proxySubjectCode,
      proxySubjectName: proxySubjectName ?? this.proxySubjectName,
      proxyFaculty: proxyFaculty ?? this.proxyFaculty,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
      isExtra: isExtra ?? this.isExtra,
      markedAt: markedAt ?? this.markedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'timetable_entry_id': timetableEntryId,
      'weekday': weekday,
      'original_subject_id': originalSubjectId,
      'original_subject_code': originalSubjectCode,
      'original_subject_name': originalSubjectName,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'faculty': faculty,
      'status': status.name,
      'proxy_subject_id': proxySubjectId,
      'proxy_subject_code': proxySubjectCode,
      'proxy_subject_name': proxySubjectName,
      'proxy_faculty': proxyFaculty,
      'cancellation_reason': cancellationReason,
      'notes': notes,
      'is_extra': isExtra,
      'marked_at': markedAt?.toIso8601String(),
    };
  }

  factory DailyClassAttendance.fromJson(Map<String, dynamic> json) {
    return DailyClassAttendance(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      timetableEntryId: (json['timetable_entry_id'] as String?) ?? '',
      weekday: (json['weekday'] as int?) ?? 1,
      originalSubjectId: (json['original_subject_id'] as String?) ?? '',
      originalSubjectCode: (json['original_subject_code'] as String?) ?? 'SUB',
      originalSubjectName:
          (json['original_subject_name'] as String?) ?? 'Subject',
      startTime: (json['start_time'] as String?) ?? '09:00',
      endTime: (json['end_time'] as String?) ?? '10:00',
      room: (json['room'] as String?) ?? 'Hall',
      faculty: json['faculty'] as String?,
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AttendanceStatus.unmarked,
      ),
      proxySubjectId: json['proxy_subject_id'] as String?,
      proxySubjectCode: json['proxy_subject_code'] as String?,
      proxySubjectName: json['proxy_subject_name'] as String?,
      proxyFaculty: json['proxy_faculty'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      notes: json['notes'] as String?,
      isExtra: (json['is_extra'] as bool?) ?? false,
      markedAt: json['marked_at'] != null
          ? DateTime.tryParse(json['marked_at'] as String)
          : null,
    );
  }
}
