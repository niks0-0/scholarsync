import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/profile/domain/models/college.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';
import 'package:scholarsync/features/profile/domain/models/user_role.dart';
import '../models/admin_analytics.dart';
import '../models/announcement.dart';
import '../models/study_note.dart';
import '../models/moderation_report.dart';
import '../models/audit_log_entry.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../models/academic_calendar_event.dart';
import '../models/campus_event.dart';
import '../models/marketplace_listing.dart';
import '../models/student_club.dart';
import '../models/community_post.dart';
import '../models/moderation_context.dart';
import '../models/chat_member.dart';

/// Abstract contract for enterprise administrative operations across ScholarSync.
abstract class AdminRepository {
  /// Fetch aggregated system analytics for the admin dashboard.
  Future<AdminAnalytics> fetchAnalyticsSummary();

  /// Fetch all curriculum subjects with optional filters.
  Future<List<Subject>> fetchAllSubjects({
    String? branch,
    int? semester,
    String? query,
  });

  /// Create a new curriculum subject.
  Future<Subject> createSubject(Subject subject);

  /// Update an existing curriculum subject.
  Future<Subject> updateSubject(Subject subject);

  /// Delete a curriculum subject by ID.
  Future<void> deleteSubject(String subjectId);

  /// Fetch all registered colleges.
  Future<List<College>> fetchAllColleges();

  /// Create a new college entry.
  Future<College> createCollege(College college);

  /// Update a college entry.
  Future<College> updateCollege(College college);

  /// Delete a college entry by ID.
  Future<void> deleteCollege(String collegeId);

  /// Fetch all campus announcements.
  Future<List<Announcement>> fetchAnnouncements();

  /// Publish a new campus/department announcement.
  Future<Announcement> publishAnnouncement(Announcement announcement);

  /// Delete an announcement by ID.
  Future<void> deleteAnnouncement(String announcementId);

  /// Fetch student directory with optional filtering.
  Future<List<UserProfile>> fetchStudents({
    String? collegeId,
    String? branch,
    int? semester,
    String? query,
  });

  /// Update a user's role (e.g. promote to admin/student).
  Future<void> updateUserRole(String userId, UserRole newRole);

  /// Suspend or reactivate a student account.
  Future<void> toggleUserSuspension(String userId, bool isSuspended, {String? reason});

  /// Create a new student profile.
  Future<UserProfile> createStudentProfile(UserProfile profile);

  /// Delete a student profile.
  Future<void> deleteStudentProfile(String userId);

  /// Fetch study notes approval queue.
  Future<List<StudyNote>> fetchNotes({String? status, String? query});

  /// Directly upload / publish a study note.
  Future<StudyNote> createStudyNote(StudyNote note);

  /// Moderate a single note (approve/reject).
  Future<void> moderateNote(String noteId, String targetStatus, {String? reason});

  /// Bulk moderate multiple notes.
  Future<int> bulkModerateNotes(List<String> noteIds, String targetStatus, {String? reason});

  /// Delete a study note.
  Future<void> deleteStudyNote(String noteId);

  /// Fetch moderation reports queue.
  Future<List<ModerationReport>> fetchModerationReports({String? status, String? entityType});

  /// Resolve a moderation report with action and audit notes.
  Future<bool> resolveModerationReport(String reportId, String action, String notes);

  /// Fetch contextual thread history for a moderation report.
  Future<ModerationContext> fetchReportContext(String reportId, {int contextCount = 3});

  /// Graduated user moderation (warn, mute, ban, suspend) with audit logging.
  Future<bool> moderateUser({
    required String userId,
    required String action,
    int? durationMinutes,
    required String reason,
    String? roomId,
  });

  /// Administrative message moderation (soft delete) with audit logging.
  Future<bool> moderateMessage({
    required String messageId,
    required String action,
    required String reason,
  });

  /// Fetch system audit trail.
  Future<List<AuditLogEntry>> fetchAuditLogs({int limit = 50});

  // ── Phase 3 Contracts: Community, Chat, Events, Calendar & Marketplace ────

  /// Fetch all active chat rooms.
  Future<List<ChatRoom>> fetchChatRooms({String? type});

  /// Create a new chat room with duplicate prevention.
  Future<ChatRoom> createChatRoom(ChatRoom room);

  /// Toggle room Safe-Lock mode (blocks new messages while preserving read access).
  Future<void> toggleRoomLock(String roomId, bool isLocked, {String? reason});

  /// Delete a chat room.
  Future<void> deleteChatRoom(String roomId);

  /// Fetch messages for a specific chat room.
  Future<List<ChatMessage>> fetchChatMessages(String roomId, {int limit = 50});

  /// Send message with server-side idempotency and rate limiting.
  Future<ChatMessage> sendChatMessage(ChatMessage message);

  /// Toggle message reaction with zero duplicates.
  Future<Map<String, dynamic>> toggleMessageReaction(String messageId, String userId, String reactionType);

  /// Fetch members of a chat room.
  Future<List<ChatMember>> fetchRoomMembers(String roomId);

  /// Administrative deletion of a message.
  Future<void> deleteChatMessage(String messageId);

  /// Fetch academic calendar events.
  Future<List<AcademicCalendarEvent>> fetchCalendarEvents({String? eventType});

  /// Create an academic calendar event.
  Future<AcademicCalendarEvent> createCalendarEvent(AcademicCalendarEvent event);

  /// Delete an academic calendar event.
  Future<void> deleteCalendarEvent(String eventId);

  /// Fetch campus events (hackathons, workshops).
  Future<List<CampusEvent>> fetchCampusEvents({String? status, String? category});

  /// Create a campus event.
  Future<CampusEvent> createCampusEvent(CampusEvent event);

  /// Update campus event approval status.
  Future<void> updateCampusEventStatus(String eventId, String status);

  /// Delete a campus event.
  Future<void> deleteCampusEvent(String eventId);

  /// Fetch marketplace listings.
  Future<List<MarketplaceListing>> fetchMarketplaceListings({String? status, String? category});

  /// Create a new marketplace listing.
  Future<MarketplaceListing> createMarketplaceListing(MarketplaceListing listing);

  /// Moderate or change status of a marketplace listing.
  Future<void> updateMarketplaceListingStatus(String listingId, String status);

  /// Delete a marketplace listing.
  Future<void> deleteMarketplaceListing(String listingId);

  /// Fetch student clubs.
  Future<List<StudentClub>> fetchClubs({String? status});

  /// Create a new student club.
  Future<StudentClub> createClub(StudentClub club);

  /// Update club status.
  Future<void> updateClubStatus(String clubId, String status);

  /// Delete a student club.
  Future<void> deleteClub(String clubId);

  /// Fetch community posts.
  Future<List<CommunityPost>> fetchCommunityPosts({String? status, String? category});

  /// Create a new community post.
  Future<CommunityPost> createCommunityPost(CommunityPost post);

  /// Moderate community post status.
  Future<void> updateCommunityPostStatus(String postId, String status);

  /// Pin/unpin community post.
  Future<void> togglePinCommunityPost(String postId, bool isPinned);

  /// Delete a community post.
  Future<void> deleteCommunityPost(String postId);
}
