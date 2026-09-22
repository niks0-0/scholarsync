import 'package:flutter/material.dart';

/// Available leaderboard categories in ScholarSync.
enum LeaderboardType {
  academic,
  productivity,
  community,
  notes,
  attendance,
  improvement,
  college,
  department,
}

extension LeaderboardTypeExt on LeaderboardType {
  String get label {
    switch (this) {
      case LeaderboardType.academic:
        return 'Academic';
      case LeaderboardType.productivity:
        return 'Productivity';
      case LeaderboardType.community:
        return 'Community';
      case LeaderboardType.notes:
        return 'Notes';
      case LeaderboardType.attendance:
        return 'Attendance';
      case LeaderboardType.improvement:
        return 'Improvement';
      case LeaderboardType.college:
        return 'College';
      case LeaderboardType.department:
        return 'Department';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaderboardType.academic:
        return Icons.school_rounded;
      case LeaderboardType.productivity:
        return Icons.timer_rounded;
      case LeaderboardType.community:
        return Icons.forum_rounded;
      case LeaderboardType.notes:
        return Icons.menu_book_rounded;
      case LeaderboardType.attendance:
        return Icons.fact_check_rounded;
      case LeaderboardType.improvement:
        return Icons.trending_up_rounded;
      case LeaderboardType.college:
        return Icons.account_balance_rounded;
      case LeaderboardType.department:
        return Icons.domain_rounded;
    }
  }
}

/// Timeframe filters.
enum TimeframeFilter {
  daily,
  weekly,
  monthly,
  semester,
  allTime,
}

extension TimeframeFilterExt on TimeframeFilter {
  String get label {
    switch (this) {
      case TimeframeFilter.daily:
        return 'Daily';
      case TimeframeFilter.weekly:
        return 'Weekly';
      case TimeframeFilter.monthly:
        return 'Monthly';
      case TimeframeFilter.semester:
        return 'Semester';
      case TimeframeFilter.allTime:
        return 'All Time';
    }
  }
}

/// Scope filters.
enum LeaderboardScope {
  global,
  college,
  department,
}

extension LeaderboardScopeExt on LeaderboardScope {
  String get label {
    switch (this) {
      case LeaderboardScope.global:
        return 'Global';
      case LeaderboardScope.college:
        return 'My College';
      case LeaderboardScope.department:
        return 'My Dept';
    }
  }
}

/// Badge tiers.
enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  legend,
}

/// A badge earned by a student.
class BadgeItem {
  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.iconName,
    this.dateEarned,
  });

  final String id;
  final String title;
  final String description;
  final BadgeTier tier;
  final String iconName;
  final DateTime? dateEarned;

  factory BadgeItem.fromJson(Map<String, dynamic> json) {
    return BadgeItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tier: BadgeTier.values.firstWhere(
        (t) => t.name == (json['tier'] as String? ?? 'bronze'),
        orElse: () => BadgeTier.bronze,
      ),
      iconName: json['icon_name'] as String? ?? 'military_tech',
      dateEarned: json['date_earned'] != null
          ? DateTime.tryParse(json['date_earned'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'tier': tier.name,
        'icon_name': iconName,
        'date_earned': dateEarned?.toIso8601String(),
      };
}

/// A single student entry in the leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.score,
    required this.rank,
    this.previousRank,
    this.avatarUrl,
    this.badgeTitle = 'Scholar',
    this.badgeTier = BadgeTier.bronze,
    this.collegeName = 'Campus',
    this.departmentName = 'General',
    this.semester = 1,
    this.streakDays = 0,
    this.isCurrentUser = false,
  });

  final String id;
  final String userId;
  final String displayName;
  final int score;
  final int rank;
  final int? previousRank;
  final String? avatarUrl;
  final String badgeTitle;
  final BadgeTier badgeTier;
  final String collegeName;
  final String departmentName;
  final int semester;
  final int streakDays;
  final bool isCurrentUser;

  int get points => score;
  String get tier => badgeTitle;

  int get rankDelta {
    if (previousRank == null) return 0;
    return previousRank! - rank; // positive means climbed up
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {String? currentUid}) {
    final uid = json['user_id'] as String? ?? json['id'] as String? ?? '';
    return LeaderboardEntry(
      id: json['id'] as String? ?? uid,
      userId: uid,
      displayName: json['display_name'] as String? ?? 'Scholar',
      score: (json['score'] as num?)?.toInt() ?? (json['points'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      previousRank: (json['previous_rank'] as num?)?.toInt(),
      avatarUrl: json['avatar_url'] as String?,
      badgeTitle: json['badge_title'] as String? ?? 'Scholar',
      badgeTier: BadgeTier.values.firstWhere(
        (t) => t.name == (json['badge_tier'] as String? ?? 'bronze'),
        orElse: () => BadgeTier.bronze,
      ),
      collegeName: json['college_name'] as String? ?? 'Campus',
      departmentName: json['department_name'] as String? ?? 'General',
      semester: (json['semester'] as num?)?.toInt() ?? 1,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      isCurrentUser: currentUid != null && currentUid == uid,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'display_name': displayName,
        'score': score,
        'rank': rank,
        'previous_rank': previousRank,
        'avatar_url': avatarUrl,
        'badge_title': badgeTitle,
        'badge_tier': badgeTier.name,
        'college_name': collegeName,
        'department_name': departmentName,
        'semester': semester,
        'streak_days': streakDays,
      };
}
