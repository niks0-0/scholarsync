import 'dart:math' as math;

/// Point action categories for gamification.
enum PointActionType {
  studySession,
  dailyGoal,
  weeklyGoal,
  assignmentSubmitted,
  earlySubmissionBonus,
  attendanceRecorded,
  attendanceBonusElite,
  helpfulPost,
  helpfulComment,
  acceptedAnswer,
  notesUploaded,
  verifiedNotesBonus,
  notesDownloaded,
  notesBookmarked,
  fiveStarRating,
  eventParticipation,
  volunteerBonus,
}

/// Point values and anti-cheat rule validator.
class PointsEngine {
  const PointsEngine._();

  /// Default point table configured for ScholarSync.
  static const Map<PointActionType, int> defaultPoints = {
    PointActionType.studySession: 10,
    PointActionType.dailyGoal: 20,
    PointActionType.weeklyGoal: 100,
    PointActionType.assignmentSubmitted: 30,
    PointActionType.earlySubmissionBonus: 20,
    PointActionType.attendanceRecorded: 5,
    PointActionType.attendanceBonusElite: 15,
    PointActionType.helpfulPost: 25,
    PointActionType.helpfulComment: 10,
    PointActionType.acceptedAnswer: 40,
    PointActionType.notesUploaded: 25,
    PointActionType.verifiedNotesBonus: 40,
    PointActionType.notesDownloaded: 1,
    PointActionType.notesBookmarked: 2,
    PointActionType.fiveStarRating: 5,
    PointActionType.eventParticipation: 20,
    PointActionType.volunteerBonus: 50,
  };

  /// Daily max point cap per user to prevent automated point farming.
  static const int dailyPointCap = 500;

  /// Cooldown in seconds between repeated actions of the same type.
  static const int actionCooldownSeconds = 30;

  /// Returns point value for a specific action.
  static int getPointsFor(PointActionType action) {
    return defaultPoints[action] ?? 0;
  }

  /// Calculates badge tier based on total points.
  static String calculateBadgeTier(int totalPoints) {
    if (totalPoints >= 5000) return 'legend';
    if (totalPoints >= 2500) return 'diamond';
    if (totalPoints >= 1200) return 'platinum';
    if (totalPoints >= 600) return 'gold';
    if (totalPoints >= 200) return 'silver';
    return 'bronze';
  }

  /// Calculates progress towards next tier.
  static double calculateLevelProgress(int totalPoints) {
    if (totalPoints >= 5000) return 1.0;
    if (totalPoints >= 2500) return (totalPoints - 2500) / 2500.0;
    if (totalPoints >= 1200) return (totalPoints - 1200) / 1300.0;
    if (totalPoints >= 600) return (totalPoints - 600) / 600.0;
    if (totalPoints >= 200) return (totalPoints - 200) / 400.0;
    return math.min(1.0, totalPoints / 200.0);
  }

  /// Returns points needed for next tier.
  static int pointsToNextTier(int totalPoints) {
    if (totalPoints >= 5000) return 0;
    if (totalPoints >= 2500) return 5000 - totalPoints;
    if (totalPoints >= 1200) return 2500 - totalPoints;
    if (totalPoints >= 600) return 1200 - totalPoints;
    if (totalPoints >= 200) return 600 - totalPoints;
    return 200 - totalPoints;
  }
}
