import 'package:scholarsync/features/profile/domain/models/user_profile.dart';

/// Aggregated metrics and analytics for administrative visibility.
class AdminAnalytics {
  const AdminAnalytics({
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.totalSubjects = 0,
    this.totalColleges = 0,
    this.totalAnnouncements = 0,
    this.pendingNotes = 0,
    this.pendingReports = 0,
    this.totalEvents = 0,
    this.totalMarketplace = 0,
    this.studentsByBranch = const {},
    this.studentsBySemester = const {},
    this.recentRegistrations = const [],
  });

  final int totalStudents;
  final int activeStudents;
  final int totalSubjects;
  final int totalColleges;
  final int totalAnnouncements;
  final int pendingNotes;
  final int pendingReports;
  final int totalEvents;
  final int totalMarketplace;
  final Map<String, int> studentsByBranch;
  final Map<int, int> studentsBySemester;
  final List<UserProfile> recentRegistrations;

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    // Parse branch counts
    final branchRaw = json['students_by_branch'] as Map<String, dynamic>? ?? {};
    final branchMap = branchRaw.map((k, v) => MapEntry(k, (v as num).toInt()));

    // Parse semester counts if present
    final semRaw = json['students_by_semester'] as Map<String, dynamic>? ?? {};
    final semMap = semRaw.map((k, v) => MapEntry(int.tryParse(k) ?? 1, (v as num).toInt()));

    // Parse recent signups
    final signupsRaw = json['recent_signups'] as List<dynamic>? ?? [];
    final signupsList = signupsRaw
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();

    return AdminAnalytics(
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      activeStudents: (json['active_students'] as num?)?.toInt() ?? 0,
      totalSubjects: (json['total_subjects'] as num?)?.toInt() ?? 0,
      totalColleges: (json['total_colleges'] as num?)?.toInt() ?? 0,
      totalAnnouncements: (json['total_announcements'] as num?)?.toInt() ?? 0,
      pendingNotes: (json['pending_notes'] as num?)?.toInt() ?? 0,
      pendingReports: (json['pending_reports'] as num?)?.toInt() ?? 0,
      totalEvents: (json['total_events'] as num?)?.toInt() ?? 0,
      totalMarketplace: (json['total_marketplace'] as num?)?.toInt() ?? 0,
      studentsByBranch: branchMap,
      studentsBySemester: semMap,
      recentRegistrations: signupsList,
    );
  }

  AdminAnalytics copyWith({
    int? totalStudents,
    int? activeStudents,
    int? totalSubjects,
    int? totalColleges,
    int? totalAnnouncements,
    int? pendingNotes,
    int? pendingReports,
    int? totalEvents,
    int? totalMarketplace,
    Map<String, int>? studentsByBranch,
    Map<int, int>? studentsBySemester,
    List<UserProfile>? recentRegistrations,
  }) {
    return AdminAnalytics(
      totalStudents: totalStudents ?? this.totalStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      totalSubjects: totalSubjects ?? this.totalSubjects,
      totalColleges: totalColleges ?? this.totalColleges,
      totalAnnouncements: totalAnnouncements ?? this.totalAnnouncements,
      pendingNotes: pendingNotes ?? this.pendingNotes,
      pendingReports: pendingReports ?? this.pendingReports,
      totalEvents: totalEvents ?? this.totalEvents,
      totalMarketplace: totalMarketplace ?? this.totalMarketplace,
      studentsByBranch: studentsByBranch ?? this.studentsByBranch,
      studentsBySemester: studentsBySemester ?? this.studentsBySemester,
      recentRegistrations: recentRegistrations ?? this.recentRegistrations,
    );
  }
}
