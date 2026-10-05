import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/profile/domain/models/college.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';
import 'package:scholarsync/features/profile/domain/models/user_role.dart';
import '../../domain/models/admin_analytics.dart';
import '../../domain/models/announcement.dart';
import '../../domain/models/study_note.dart';
import '../../domain/models/moderation_report.dart';
import '../../domain/models/audit_log_entry.dart';
import '../../domain/models/chat_room.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/academic_calendar_event.dart';
import '../../domain/models/campus_event.dart';
import '../../domain/models/marketplace_listing.dart';
import '../../domain/models/student_club.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/moderation_context.dart';
import '../../domain/models/chat_member.dart';
import '../../domain/repositories/admin_repository.dart';
import 'supabase_admin_repository.dart';
import 'mock_admin_repository.dart';

/// Hybrid resilient repository that attempts remote Supabase operations
/// and automatically falls back to [MockAdminRepository] on network failures,
/// DNS resolution errors, or empty states.
class ResilientAdminRepository implements AdminRepository {
  ResilientAdminRepository({
    AdminRepository? primary,
    AdminRepository? fallback,
  })  : primary = primary ?? const SupabaseAdminRepository(),
        fallback = fallback ?? MockAdminRepository();

  final AdminRepository primary;
  final AdminRepository fallback;

  @override
  Future<AdminAnalytics> fetchAnalyticsSummary() async {
    try {
      final summary = await primary.fetchAnalyticsSummary().timeout(const Duration(seconds: 4));
      if (summary.totalSubjects > 0 || summary.totalColleges > 0 || summary.totalStudents > 0) {
        return summary;
      }
    } catch (e) {
      debugPrint('ResilientAdminRepository.fetchAnalyticsSummary primary note: $e');
    }

    try {
      final students = await fetchStudents();
      final subjects = await fetchAllSubjects();
      final colleges = await fetchAllColleges();
      final announcements = await fetchAnnouncements();
      final notes = await fetchNotes(status: 'pending');
      final reports = await fetchModerationReports();

      final Map<String, int> branchCounts = {};
      final Map<int, int> semesterCounts = {};

      for (final s in students) {
        final b = s.branch?.trim();
        if (b != null && b.isNotEmpty) {
          branchCounts[b] = (branchCounts[b] ?? 0) + 1;
        }
        final sem = s.semester;
        if (sem != null && sem > 0) {
          semesterCounts[sem] = (semesterCounts[sem] ?? 0) + 1;
        }
      }

      return AdminAnalytics(
        totalStudents: students.length,
        activeStudents: students.where((s) => !s.isSuspended).length,
        totalSubjects: subjects.length,
        totalColleges: colleges.length,
        totalAnnouncements: announcements.length,
        pendingNotes: notes.length,
        pendingReports: reports.length,
        studentsByBranch: branchCounts,
        studentsBySemester: semesterCounts,
        recentRegistrations: students.take(10).toList(),
      );
    } catch (e) {
      debugPrint('ResilientAdminRepository.fetchAnalyticsSummary aggregation error: $e');
      return const AdminAnalytics();
    }
  }

  @override
  Future<List<Subject>> fetchAllSubjects({String? branch, int? semester, String? query}) async {
    try {
      final res = await primary
          .fetchAllSubjects(branch: branch, semester: semester, query: query)
          .timeout(const Duration(seconds: 4));
      if (res.isEmpty && branch == null && semester == null && (query == null || query.isEmpty)) {
        return await fallback.fetchAllSubjects(branch: branch, semester: semester, query: query);
      }
      return res;
    } catch (e) {
      debugPrint('ResilientAdminRepository.fetchAllSubjects fallback: $e');
      return await fallback.fetchAllSubjects(branch: branch, semester: semester, query: query);
    }
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    try {
      return await primary.createSubject(subject).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.createSubject fallback: $e');
      return await fallback.createSubject(subject);
    }
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    try {
      return await primary.updateSubject(subject).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.updateSubject fallback: $e');
      return await fallback.updateSubject(subject);
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      await primary.deleteSubject(subjectId).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.deleteSubject fallback: $e');
      await fallback.deleteSubject(subjectId);
    }
  }

  @override
  Future<List<College>> fetchAllColleges() async {
    try {
      final res = await primary.fetchAllColleges().timeout(const Duration(seconds: 4));
      if (res.isEmpty) {
        return await fallback.fetchAllColleges();
      }
      return res;
    } catch (e) {
      debugPrint('ResilientAdminRepository.fetchAllColleges fallback: $e');
      return await fallback.fetchAllColleges();
    }
  }

  @override
  Future<College> createCollege(College college) async {
    try {
      return await primary.createCollege(college).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.createCollege fallback: $e');
      return await fallback.createCollege(college);
    }
  }

  @override
  Future<College> updateCollege(College college) async {
    try {
      return await primary.updateCollege(college).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.updateCollege fallback: $e');
      return await fallback.updateCollege(college);
    }
  }

  @override
  Future<void> deleteCollege(String collegeId) async {
    try {
      await primary.deleteCollege(collegeId).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.deleteCollege fallback: $e');
      await fallback.deleteCollege(collegeId);
    }
  }

  @override
  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final res = await primary.fetchAnnouncements().timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchAnnouncements();
      return res;
    } catch (e) {
      debugPrint('ResilientAdminRepository.fetchAnnouncements fallback: $e');
      return await fallback.fetchAnnouncements();
    }
  }

  @override
  Future<Announcement> publishAnnouncement(Announcement announcement) async {
    try {
      return await primary.publishAnnouncement(announcement).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.publishAnnouncement fallback: $e');
      return await fallback.publishAnnouncement(announcement);
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await primary.deleteAnnouncement(announcementId).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.deleteAnnouncement fallback: $e');
      await fallback.deleteAnnouncement(announcementId);
    }
  }

  @override
  Future<List<UserProfile>> fetchStudents({String? collegeId, String? branch, int? semester, String? query}) async {
    List<UserProfile> students = [];
    try {
      students = await primary
          .fetchStudents(collegeId: collegeId, branch: branch, semester: semester, query: query)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('ResilientAdminRepository.fetchStudents primary note: $e');
    }

    final localStudents = await _fetchLocalRegisteredStudents(
      collegeId: collegeId,
      branch: branch,
      semester: semester,
      query: query,
    );

    if (students.isEmpty) {
      return localStudents;
    }

    final existingIds = students.map((s) => s.id).toSet();
    for (final local in localStudents) {
      if (!existingIds.contains(local.id)) {
        students.add(local);
      }
    }

    return students;
  }

  Future<List<UserProfile>> _fetchLocalRegisteredStudents({
    String? collegeId,
    String? branch,
    int? semester,
    String? query,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('scholarsync_user_profile_'));
      final List<UserProfile> list = [];
      for (final key in keys) {
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          try {
            final json = jsonDecode(raw) as Map<String, dynamic>;
            final profile = UserProfile.fromJson(json);
            if (!profile.role.isAdmin) {
              list.add(profile);
            }
          } catch (_) {}
        }
      }

      var filtered = list;
      if (collegeId != null && collegeId.isNotEmpty) {
        filtered = filtered.where((p) => p.collegeId == collegeId).toList();
      }
      if (branch != null && branch.isNotEmpty) {
        filtered = filtered.where((p) => p.branch == branch).toList();
      }
      if (semester != null && semester > 0) {
        filtered = filtered.where((p) => p.semester == semester).toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = filtered.where((p) {
          return p.fullName.toLowerCase().contains(q) ||
              p.email.toLowerCase().contains(q) ||
              (p.rollNumber != null && p.rollNumber!.toLowerCase().contains(q)) ||
              (p.enrollmentNumber != null && p.enrollmentNumber!.toLowerCase().contains(q));
        }).toList();
      }

      return filtered;
    } catch (e) {
      debugPrint('Error fetching local registered students: $e');
      return [];
    }
  }

  Future<void> _updateLocalProfileField(String userId, Map<String, dynamic> Function(Map<String, dynamic>) updater) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'scholarsync_user_profile_$userId';
      final raw = prefs.getString(key);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final updatedJson = updater(json);
        await prefs.setString(key, jsonEncode(updatedJson));
      }
    } catch (_) {}
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _updateLocalProfileField(userId, (m) => m..['role'] = newRole.name);
    try {
      await primary.updateUserRole(userId, newRole).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.updateUserRole(userId, newRole);
    }
  }

  @override
  Future<void> updateStudentVerificationStatus(String userId, String status) async {
    await _updateLocalProfileField(userId, (m) => m..['verification_status'] = status);
    try {
      await primary.updateStudentVerificationStatus(userId, status).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.updateStudentVerificationStatus(userId, status);
    }
  }

  @override
  Future<void> toggleUserSuspension(String userId, bool isSuspended, {String? reason}) async {
    await _updateLocalProfileField(userId, (m) => m..['is_suspended'] = isSuspended);
    try {
      await primary.toggleUserSuspension(userId, isSuspended, reason: reason).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.toggleUserSuspension(userId, isSuspended, reason: reason);
    }
  }

  @override
  Future<UserProfile> createStudentProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scholarsync_user_profile_${profile.id}', jsonEncode(profile.toJson()));
    } catch (_) {}
    try {
      return await primary.createStudentProfile(profile).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createStudentProfile(profile);
    }
  }

  @override
  Future<UserProfile> updateStudentProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scholarsync_user_profile_${profile.id}', jsonEncode(profile.toJson()));
    } catch (_) {}
    try {
      return await primary.updateStudentProfile(profile).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.updateStudentProfile(profile);
    }
  }

  @override
  Future<void> deleteStudentProfile(String userId) async {
    try {
      await primary.deleteStudentProfile(userId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteStudentProfile(userId);
    }
  }

  @override
  Future<List<StudyNote>> fetchNotes({String? status, String? query}) async {
    try {
      final res = await primary.fetchNotes(status: status, query: query).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchNotes(status: status, query: query);
      return res;
    } catch (e) {
      return await fallback.fetchNotes(status: status, query: query);
    }
  }

  @override
  Future<StudyNote> createStudyNote(StudyNote note) async {
    try {
      return await primary.createStudyNote(note).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createStudyNote(note);
    }
  }

  @override
  Future<void> moderateNote(String noteId, String targetStatus, {String? reason}) async {
    try {
      await primary.moderateNote(noteId, targetStatus, reason: reason).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.moderateNote(noteId, targetStatus, reason: reason);
    }
  }

  @override
  Future<int> bulkModerateNotes(List<String> noteIds, String targetStatus, {String? reason}) async {
    try {
      return await primary.bulkModerateNotes(noteIds, targetStatus, reason: reason).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.bulkModerateNotes(noteIds, targetStatus, reason: reason);
    }
  }

  @override
  Future<void> deleteStudyNote(String noteId) async {
    try {
      await primary.deleteStudyNote(noteId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteStudyNote(noteId);
    }
  }

  @override
  Future<List<ModerationReport>> fetchModerationReports({String? status, String? entityType}) async {
    try {
      final res = await primary
          .fetchModerationReports(status: status, entityType: entityType)
          .timeout(const Duration(seconds: 4));
      if (res.isEmpty) {
        return await fallback.fetchModerationReports(status: status, entityType: entityType);
      }
      return res;
    } catch (e) {
      return await fallback.fetchModerationReports(status: status, entityType: entityType);
    }
  }

  @override
  Future<bool> resolveModerationReport(String reportId, String action, String notes) async {
    try {
      return await primary.resolveModerationReport(reportId, action, notes).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.resolveModerationReport(reportId, action, notes);
    }
  }

  @override
  Future<ModerationContext> fetchReportContext(String reportId, {int contextCount = 3}) async {
    try {
      return await primary.fetchReportContext(reportId, contextCount: contextCount).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.fetchReportContext(reportId, contextCount: contextCount);
    }
  }

  @override
  Future<bool> moderateUser({
    required String userId,
    required String action,
    int? durationMinutes,
    required String reason,
    String? roomId,
  }) async {
    try {
      return await primary
          .moderateUser(userId: userId, action: action, durationMinutes: durationMinutes, reason: reason, roomId: roomId)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.moderateUser(
          userId: userId, action: action, durationMinutes: durationMinutes, reason: reason, roomId: roomId);
    }
  }

  @override
  Future<bool> moderateMessage({required String messageId, required String action, required String reason}) async {
    try {
      return await primary
          .moderateMessage(messageId: messageId, action: action, reason: reason)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.moderateMessage(messageId: messageId, action: action, reason: reason);
    }
  }

  @override
  Future<List<AuditLogEntry>> fetchAuditLogs({int limit = 50}) async {
    try {
      final res = await primary.fetchAuditLogs(limit: limit).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchAuditLogs(limit: limit);
      return res;
    } catch (e) {
      return await fallback.fetchAuditLogs(limit: limit);
    }
  }

  @override
  Future<List<ChatRoom>> fetchChatRooms({String? type}) async {
    try {
      final res = await primary.fetchChatRooms(type: type).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchChatRooms(type: type);
      return res;
    } catch (e) {
      return await fallback.fetchChatRooms(type: type);
    }
  }

  @override
  Future<ChatRoom> createChatRoom(ChatRoom room) async {
    try {
      return await primary.createChatRoom(room).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createChatRoom(room);
    }
  }

  @override
  Future<void> toggleRoomLock(String roomId, bool isLocked, {String? reason}) async {
    try {
      await primary.toggleRoomLock(roomId, isLocked, reason: reason).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.toggleRoomLock(roomId, isLocked, reason: reason);
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      await primary.deleteChatRoom(roomId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteChatRoom(roomId);
    }
  }

  @override
  Future<List<ChatMessage>> fetchChatMessages(String roomId, {int limit = 50}) async {
    try {
      final res = await primary.fetchChatMessages(roomId, limit: limit).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchChatMessages(roomId, limit: limit);
      return res;
    } catch (e) {
      return await fallback.fetchChatMessages(roomId, limit: limit);
    }
  }

  @override
  Future<ChatMessage> sendChatMessage(ChatMessage message) async {
    try {
      return await primary.sendChatMessage(message).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.sendChatMessage(message);
    }
  }

  @override
  Future<Map<String, dynamic>> toggleMessageReaction(String messageId, String userId, String reactionType) async {
    try {
      return await primary
          .toggleMessageReaction(messageId, userId, reactionType)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.toggleMessageReaction(messageId, userId, reactionType);
    }
  }

  @override
  Future<List<ChatMember>> fetchRoomMembers(String roomId) async {
    try {
      final res = await primary.fetchRoomMembers(roomId).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchRoomMembers(roomId);
      return res;
    } catch (e) {
      return await fallback.fetchRoomMembers(roomId);
    }
  }

  @override
  Future<void> deleteChatMessage(String messageId) async {
    try {
      await primary.deleteChatMessage(messageId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteChatMessage(messageId);
    }
  }

  @override
  Future<List<AcademicCalendarEvent>> fetchCalendarEvents({String? eventType}) async {
    try {
      final res = await primary.fetchCalendarEvents(eventType: eventType).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchCalendarEvents(eventType: eventType);
      return res;
    } catch (e) {
      return await fallback.fetchCalendarEvents(eventType: eventType);
    }
  }

  @override
  Future<AcademicCalendarEvent> createCalendarEvent(AcademicCalendarEvent event) async {
    try {
      return await primary.createCalendarEvent(event).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createCalendarEvent(event);
    }
  }

  @override
  Future<void> deleteCalendarEvent(String eventId) async {
    try {
      await primary.deleteCalendarEvent(eventId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteCalendarEvent(eventId);
    }
  }

  @override
  Future<List<CampusEvent>> fetchCampusEvents({String? status, String? category}) async {
    try {
      final res = await primary.fetchCampusEvents(status: status, category: category).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchCampusEvents(status: status, category: category);
      return res;
    } catch (e) {
      return await fallback.fetchCampusEvents(status: status, category: category);
    }
  }

  @override
  Future<CampusEvent> createCampusEvent(CampusEvent event) async {
    try {
      return await primary.createCampusEvent(event).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createCampusEvent(event);
    }
  }

  @override
  Future<void> updateCampusEventStatus(String eventId, String status) async {
    try {
      await primary.updateCampusEventStatus(eventId, status).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.updateCampusEventStatus(eventId, status);
    }
  }

  @override
  Future<void> deleteCampusEvent(String eventId) async {
    try {
      await primary.deleteCampusEvent(eventId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteCampusEvent(eventId);
    }
  }

  @override
  Future<List<MarketplaceListing>> fetchMarketplaceListings({String? status, String? category}) async {
    try {
      final res = await primary
          .fetchMarketplaceListings(status: status, category: category)
          .timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchMarketplaceListings(status: status, category: category);
      return res;
    } catch (e) {
      return await fallback.fetchMarketplaceListings(status: status, category: category);
    }
  }

  @override
  Future<MarketplaceListing> createMarketplaceListing(MarketplaceListing listing) async {
    try {
      return await primary.createMarketplaceListing(listing).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createMarketplaceListing(listing);
    }
  }

  @override
  Future<void> updateMarketplaceListingStatus(String listingId, String status) async {
    try {
      await primary.updateMarketplaceListingStatus(listingId, status).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.updateMarketplaceListingStatus(listingId, status);
    }
  }

  @override
  Future<void> deleteMarketplaceListing(String listingId) async {
    try {
      await primary.deleteMarketplaceListing(listingId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteMarketplaceListing(listingId);
    }
  }

  @override
  Future<List<StudentClub>> fetchClubs({String? status}) async {
    try {
      final res = await primary.fetchClubs(status: status).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchClubs(status: status);
      return res;
    } catch (e) {
      return await fallback.fetchClubs(status: status);
    }
  }

  @override
  Future<StudentClub> createClub(StudentClub club) async {
    try {
      return await primary.createClub(club).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createClub(club);
    }
  }

  @override
  Future<void> updateClubStatus(String clubId, String status) async {
    try {
      await primary.updateClubStatus(clubId, status).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.updateClubStatus(clubId, status);
    }
  }

  @override
  Future<void> deleteClub(String clubId) async {
    try {
      await primary.deleteClub(clubId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteClub(clubId);
    }
  }

  @override
  Future<List<CommunityPost>> fetchCommunityPosts({String? status, String? category}) async {
    try {
      final res = await primary.fetchCommunityPosts(status: status, category: category).timeout(const Duration(seconds: 4));
      if (res.isEmpty) return await fallback.fetchCommunityPosts(status: status, category: category);
      return res;
    } catch (e) {
      return await fallback.fetchCommunityPosts(status: status, category: category);
    }
  }

  @override
  Future<CommunityPost> createCommunityPost(CommunityPost post) async {
    try {
      return await primary.createCommunityPost(post).timeout(const Duration(seconds: 4));
    } catch (e) {
      return await fallback.createCommunityPost(post);
    }
  }

  @override
  Future<void> updateCommunityPostStatus(String postId, String status) async {
    try {
      await primary.updateCommunityPostStatus(postId, status).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.updateCommunityPostStatus(postId, status);
    }
  }

  @override
  Future<void> togglePinCommunityPost(String postId, bool isPinned) async {
    try {
      await primary.togglePinCommunityPost(postId, isPinned).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.togglePinCommunityPost(postId, isPinned);
    }
  }

  @override
  Future<void> deleteCommunityPost(String postId) async {
    try {
      await primary.deleteCommunityPost(postId).timeout(const Duration(seconds: 4));
    } catch (e) {
      await fallback.deleteCommunityPost(postId);
    }
  }
}
