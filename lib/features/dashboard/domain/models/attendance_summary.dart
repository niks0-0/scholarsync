/// Summary model for Attendance Dashboard card.
class AttendanceSummary {
  const AttendanceSummary({
    required this.overallPercentage,
    required this.attendedClasses,
    required this.totalClasses,
    this.requiredPercentage = 75.0,
    this.statusMessage = 'Attendance status good',
  });

  final double overallPercentage;
  final int attendedClasses;
  final int totalClasses;
  final double requiredPercentage;
  final String statusMessage;

  bool get isWarning => overallPercentage < requiredPercentage;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      overallPercentage: (json['overall_percentage'] as num).toDouble(),
      attendedClasses: json['attended_classes'] as int,
      totalClasses: json['total_classes'] as int,
      requiredPercentage: (json['required_percentage'] as num?)?.toDouble() ?? 75.0,
      statusMessage: (json['status_message'] as String?) ?? 'Attendance status good',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_percentage': overallPercentage,
      'attended_classes': attendedClasses,
      'total_classes': totalClasses,
      'required_percentage': requiredPercentage,
      'status_message': statusMessage,
    };
  }
}
