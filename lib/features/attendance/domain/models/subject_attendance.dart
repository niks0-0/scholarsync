class SubjectAttendance {
  const SubjectAttendance({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.attendedClasses,
    required this.totalClasses,
    this.targetPercentage = 75.0,
    this.lastUpdated,
  });

  final String id;
  final String subjectCode;
  final String subjectName;
  final int attendedClasses;
  final int totalClasses;
  final double targetPercentage;
  final DateTime? lastUpdated;

  double get percentage {
    if (totalClasses == 0) return 100.0;
    return (attendedClasses / totalClasses) * 100.0;
  }

  bool get isSafe => percentage >= targetPercentage;

  /// How many classes can be safely skipped while staying >= targetPercentage (e.g. 75%)
  int get safeBunksCount {
    if (!isSafe || totalClasses == 0) return 0;
    final maxTotal = attendedClasses / (targetPercentage / 100.0);
    final diff = (maxTotal - totalClasses).floor();
    return diff < 0 ? 0 : diff;
  }

  /// How many consecutive classes must be attended to reach targetPercentage
  int get requiredClassesCount {
    if (isSafe) return 0;
    final targetFraction = targetPercentage / 100.0;
    final numerator = (targetFraction * totalClasses) - attendedClasses;
    final denominator = 1.0 - targetFraction;
    if (denominator <= 0) return 0;
    final req = (numerator / denominator).ceil();
    return req < 0 ? 0 : req;
  }

  SubjectAttendance copyWith({
    int? attendedClasses,
    int? totalClasses,
    DateTime? lastUpdated,
  }) {
    return SubjectAttendance(
      id: id,
      subjectCode: subjectCode,
      subjectName: subjectName,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      totalClasses: totalClasses ?? this.totalClasses,
      targetPercentage: targetPercentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory SubjectAttendance.fromJson(Map<String, dynamic> json) {
    return SubjectAttendance(
      id: json['id'] as String,
      subjectCode: json['subject_code'] as String? ?? 'SUBJ',
      subjectName: json['subject_name'] as String? ?? 'Subject',
      attendedClasses: (json['attended_classes'] as num?)?.toInt() ?? 0,
      totalClasses: (json['total_classes'] as num?)?.toInt() ?? 0,
      targetPercentage: (json['target_percentage'] as num?)?.toDouble() ?? 75.0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'attended_classes': attendedClasses,
      'total_classes': totalClasses,
      'target_percentage': targetPercentage,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}
