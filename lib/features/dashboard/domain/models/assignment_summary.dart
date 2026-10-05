enum AssignmentPriority {
  low,
  medium,
  high,
  urgent;

  String get name {
    switch (this) {
      case AssignmentPriority.low:
        return 'low';
      case AssignmentPriority.medium:
        return 'medium';
      case AssignmentPriority.high:
        return 'high';
      case AssignmentPriority.urgent:
        return 'urgent';
    }
  }

  String get displayName => name.toUpperCase();
}

enum AssignmentStatus {
  overdue,
  dueToday,
  upcoming,
  completed;

  String get name {
    switch (this) {
      case AssignmentStatus.overdue:
        return 'overdue';
      case AssignmentStatus.dueToday:
        return 'dueToday';
      case AssignmentStatus.upcoming:
        return 'upcoming';
      case AssignmentStatus.completed:
        return 'completed';
    }
  }
}

/// Summary model for Assignment Dashboard card.
class AssignmentSummary {
  const AssignmentSummary({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.priority = AssignmentPriority.medium,
    this.isCompleted = false,
    this.status = AssignmentStatus.upcoming,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final AssignmentPriority priority;
  final bool isCompleted;
  final AssignmentStatus status;

  factory AssignmentSummary.fromJson(Map<String, dynamic> json) {
    return AssignmentSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      priority: _parsePriority(json['priority'] as String?),
      isCompleted: (json['is_completed'] as bool?) ?? false,
      status: _parseStatus(json['status'] as String?),
    );
  }

  static AssignmentPriority _parsePriority(String? val) {
    switch (val?.toLowerCase()) {
      case 'urgent':
        return AssignmentPriority.urgent;
      case 'high':
        return AssignmentPriority.high;
      case 'low':
        return AssignmentPriority.low;
      case 'medium':
      default:
        return AssignmentPriority.medium;
    }
  }

  static AssignmentStatus _parseStatus(String? val) {
    switch (val?.toLowerCase()) {
      case 'overdue':
        return AssignmentStatus.overdue;
      case 'duetoday':
      case 'due_today':
        return AssignmentStatus.dueToday;
      case 'completed':
        return AssignmentStatus.completed;
      case 'upcoming':
      default:
        return AssignmentStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'is_completed': isCompleted,
      'status': status.name,
    };
  }

  AssignmentSummary copyWith({bool? isCompleted}) {
    return AssignmentSummary(
      id: id,
      title: title,
      subject: subject,
      dueDate: dueDate,
      priority: priority,
      isCompleted: isCompleted ?? this.isCompleted,
      status: isCompleted == true ? AssignmentStatus.completed : status,
    );
  }
}
