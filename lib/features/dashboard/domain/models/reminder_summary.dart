/// Summary model for Reminders Dashboard card.
class ReminderSummary {
  const ReminderSummary({
    required this.id,
    required this.title,
    required this.reminderTime,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String reminderTime;
  final bool isCompleted;

  factory ReminderSummary.fromJson(Map<String, dynamic> json) {
    return ReminderSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      reminderTime: json['reminder_time'] as String,
      isCompleted: (json['is_completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reminder_time': reminderTime,
      'is_completed': isCompleted,
    };
  }

  ReminderSummary copyWith({bool? isCompleted}) {
    return ReminderSummary(
      id: id,
      title: title,
      reminderTime: reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
