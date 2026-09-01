import 'package:flutter/foundation.dart';
import 'package:scholarsync/core/services/supabase_service.dart';
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
import '../../domain/repositories/admin_repository.dart';

/// Supabase PostgREST & RPC implementation of [AdminRepository].
class SupabaseAdminRepository implements AdminRepository {
  const SupabaseAdminRepository();

  @override
  Future<AdminAnalytics> fetchAnalyticsSummary() async {
    try {
      final client = SupabaseService.instance.client;

      // Call our high-performance RPC function
      final dynamic res = await client.rpc('get_admin_master_analytics');
      if (res != null && res is Map<String, dynamic>) {
        return AdminAnalytics.fromJson(res);
      }

      // Fallback manual count if RPC is unavailable
      final studentsRes = await client.from('profiles').select('id, branch, semester');
      final subjectsRes = await client.from('subjects').select('id');
      final collegesRes = await client.from('colleges').select('id');
      final announcementsRes = await client.from('announcements').select('id');

      final List<dynamic> studentsList = studentsRes;
      final int totalStudents = studentsList.length;
      final int totalSubjects = (subjectsRes as List<dynamic>).length;
      final int totalColleges = (collegesRes as List<dynamic>).length;
      final int totalAnnouncements = (announcementsRes as List<dynamic>).length;

      final Map<String, int> branchCounts = {};
      final Map<int, int> semesterCounts = {};

      for (final s in studentsList) {
        final b = (s['branch'] as String?)?.trim();
        if (b != null && b.isNotEmpty) {
          branchCounts[b] = (branchCounts[b] ?? 0) + 1;
        }
        final sem = s['semester'] as int?;
        if (sem != null && sem > 0) {
          semesterCounts[sem] = (semesterCounts[sem] ?? 0) + 1;
        }
      }

      final List<dynamic> recentRes = await client
          .from('profiles')
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      final List<UserProfile> recentProfiles =
          recentRes.map((json) => UserProfile.fromJson(json as Map<String, dynamic>)).toList();

      return AdminAnalytics(
        totalStudents: totalStudents,
        activeStudents: totalStudents,
        totalSubjects: totalSubjects,
        totalColleges: totalColleges,
        totalAnnouncements: totalAnnouncements,
        studentsByBranch: branchCounts,
        studentsBySemester: semesterCounts,
        recentRegistrations: recentProfiles,
      );
    } catch (e) {
      debugPrint('Error fetching admin analytics: $e');
      return const AdminAnalytics();
    }
  }

  @override
  Future<List<Subject>> fetchAllSubjects({
    String? branch,
    int? semester,
    String? query,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('subjects').select().eq('is_deleted', false);

      if (branch != null && branch.isNotEmpty) {
        req = req.eq('branch', branch);
      }
      if (semester != null && semester > 0) {
        req = req.eq('semester', semester);
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = '%${query.trim()}%';
        req = req.or('subject_name.ilike.$q,subject_code.ilike.$q,short_name.ilike.$q');
      }

      final List<dynamic> res = await req.order('semester').order('display_order');
      return res.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching all subjects: $e');
      return [];
    }
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    try {
      final client = SupabaseService.instance.client;
      final payload = subject.toJson();
      if (payload['id'] == null || (payload['id'] as String).isEmpty) {
        payload.remove('id');
      }

      final res = await client.from('subjects').insert(payload).select().single();
      return Subject.fromJson(res);
    } catch (e) {
      debugPrint('Error creating subject: $e');
      rethrow;
    }
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    try {
      final client = SupabaseService.instance.client;
      final res = await client
          .from('subjects')
          .update(subject.toJson())
          .eq('id', subject.id)
          .select()
          .single();
      return Subject.fromJson(res);
    } catch (e) {
      debugPrint('Error updating subject: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('subjects').update({'is_deleted': true, 'deleted_at': DateTime.now().toIso8601String()}).eq('id', subjectId);
    } catch (e) {
      debugPrint('Error deleting subject: $e');
      rethrow;
    }
  }

  @override
  Future<List<College>> fetchAllColleges() async {
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> res = await client.from('colleges').select().eq('is_deleted', false).order('name');
      return res.map((json) => College.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching colleges: $e');
      return [];
    }
  }

  @override
  Future<College> createCollege(College college) async {
    try {
      final client = SupabaseService.instance.client;
      final payload = college.toJson();
      if (payload['id'] == null || (payload['id'] as String).isEmpty) {
        payload.remove('id');
      }

      final res = await client.from('colleges').insert(payload).select().single();
      return College.fromJson(res);
    } catch (e) {
      debugPrint('Error creating college: $e');
      rethrow;
    }
  }

  @override
  Future<College> updateCollege(College college) async {
    try {
      final client = SupabaseService.instance.client;
      final res = await client
          .from('colleges')
          .update(college.toJson())
          .eq('id', college.id)
          .select()
          .single();
      return College.fromJson(res);
    } catch (e) {
      debugPrint('Error updating college: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCollege(String collegeId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('colleges').update({'is_deleted': true, 'deleted_at': DateTime.now().toIso8601String()}).eq('id', collegeId);
    } catch (e) {
      debugPrint('Error deleting college: $e');
      rethrow;
    }
  }

  @override
  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> res =
          await client.from('announcements').select().eq('is_deleted', false).order('created_at', ascending: false);
      return res.map((json) => Announcement.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }

  @override
  Future<Announcement> publishAnnouncement(Announcement announcement) async {
    try {
      final client = SupabaseService.instance.client;
      final payload = announcement.toJson();
      if (payload['id'] == null || (payload['id'] as String).isEmpty) {
        payload.remove('id');
      }

      final res = await client.from('announcements').insert(payload).select().single();
      return Announcement.fromJson(res);
    } catch (e) {
      debugPrint('Error publishing announcement: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('announcements').update({'is_deleted': true, 'deleted_at': DateTime.now().toIso8601String()}).eq('id', announcementId);
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserProfile>> fetchStudents({
    String? collegeId,
    String? branch,
    int? semester,
    String? query,
  }) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('profiles').select().eq('is_deleted', false);

      if (collegeId != null && collegeId.isNotEmpty) {
        req = req.eq('college_id', collegeId);
      }
      if (branch != null && branch.isNotEmpty) {
        req = req.eq('branch', branch);
      }
      if (semester != null && semester > 0) {
        req = req.eq('semester', semester);
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = '%${query.trim()}%';
        req = req.or('full_name.ilike.$q,email.ilike.$q,roll_number.ilike.$q,enrollment_number.ilike.$q');
      }

      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) => UserProfile.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
      return [];
    }
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('profiles').update({'role': newRole.toDbValue()}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleUserSuspension(String userId, bool isSuspended, {String? reason}) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('profiles').update({
        'is_suspended': isSuspended,
        'suspension_reason': isSuspended ? reason : null,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Error toggling suspension: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudyNote>> fetchNotes({String? status, String? query}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('notes').select('*, profiles(full_name), subjects(name)').eq('is_deleted', false);

      if (status != null && status.isNotEmpty) {
        req = req.eq('status', status);
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = '%${query.trim()}%';
        req = req.or('title.ilike.$q,description.ilike.$q');
      }

      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) => StudyNote.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  @override
  Future<void> moderateNote(String noteId, String targetStatus, {String? reason}) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('notes').update({
        'status': targetStatus,
        'rejection_reason': targetStatus == 'rejected' ? reason : null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', noteId);
    } catch (e) {
      debugPrint('Error moderating note: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkModerateNotes(List<String> noteIds, String targetStatus, {String? reason}) async {
    try {
      final client = SupabaseService.instance.client;
      final dynamic res = await client.rpc('bulk_moderate_notes', params: {
        'note_ids': noteIds,
        'target_status': targetStatus,
        'reason': reason,
      });
      return (res as num?)?.toInt() ?? noteIds.length;
    } catch (e) {
      debugPrint('Error in bulkModerateNotes: $e');
      rethrow;
    }
  }

  @override
  Future<List<ModerationReport>> fetchModerationReports({String? status, String? entityType}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('moderation_reports').select('*, reporter:profiles!reporter_id(full_name), reported_user:profiles!reported_user_id(full_name)');

      if (status != null && status.isNotEmpty) {
        req = req.eq('status', status);
      }
      if (entityType != null && entityType.isNotEmpty) {
        req = req.eq('entity_type', entityType);
      }

      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) => ModerationReport.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching moderation reports: $e');
      return [];
    }
  }

  @override
  Future<bool> resolveModerationReport(String reportId, String action, String notes) async {
    try {
      final client = SupabaseService.instance.client;
      final dynamic res = await client.rpc('resolve_moderation_report', params: {
        'p_report_id': reportId,
        'p_resolution_action': action,
        'p_resolution_notes': notes,
      });
      return res as bool? ?? true;
    } catch (e) {
      debugPrint('Error resolving report: $e');
      rethrow;
    }
  }

  @override
  Future<List<AuditLogEntry>> fetchAuditLogs({int limit = 50}) async {
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> res =
          await client.from('audit_logs').select().order('created_at', ascending: false).limit(limit);
      return res.map((json) => AuditLogEntry.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
      return [];
    }
  }

  // ── Phase 3 Implementations ───────────────────────────────────────────────

  @override
  Future<List<ChatRoom>> fetchChatRooms({String? type}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('chat_rooms').select('*, subject:subjects(subject_name)').eq('is_deleted', false);
      if (type != null && type.isNotEmpty) {
        req = req.eq('type', type);
      }
      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['subject'] != null && map['subject'] is Map) {
          map['subject_name'] = map['subject']['subject_name'];
        }
        return ChatRoom.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching chat rooms: $e');
      return [];
    }
  }

  @override
  Future<ChatRoom> createChatRoom(ChatRoom room) async {
    try {
      final client = SupabaseService.instance.client;
      final res = await client.from('chat_rooms').insert(room.toJson()).select().single();
      return ChatRoom.fromJson(res);
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('chat_rooms').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);
    } catch (e) {
      debugPrint('Error deleting chat room: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatMessage>> fetchChatMessages(String roomId, {int limit = 50}) async {
    try {
      final client = SupabaseService.instance.client;
      final List<dynamic> res = await client
          .from('messages')
          .select('*, sender:profiles(full_name)')
          .eq('room_id', roomId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(limit);

      return res.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['sender'] != null && map['sender'] is Map) {
          map['sender_name'] = map['sender']['full_name'];
        }
        return ChatMessage.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      return [];
    }
  }

  @override
  Future<void> deleteChatMessage(String messageId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('messages').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);
    } catch (e) {
      debugPrint('Error deleting chat message: $e');
      rethrow;
    }
  }

  @override
  Future<List<AcademicCalendarEvent>> fetchCalendarEvents({String? eventType}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('academic_calendar').select().eq('is_deleted', false);
      if (eventType != null && eventType.isNotEmpty) {
        req = req.eq('event_type', eventType);
      }
      final List<dynamic> res = await req.order('start_date', ascending: true);
      return res.map((json) => AcademicCalendarEvent.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching calendar events: $e');
      return [];
    }
  }

  @override
  Future<AcademicCalendarEvent> createCalendarEvent(AcademicCalendarEvent event) async {
    try {
      final client = SupabaseService.instance.client;
      final res = await client.from('academic_calendar').insert(event.toJson()).select().single();
      return AcademicCalendarEvent.fromJson(res);
    } catch (e) {
      debugPrint('Error creating calendar event: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCalendarEvent(String eventId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('academic_calendar').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', eventId);
    } catch (e) {
      debugPrint('Error deleting calendar event: $e');
      rethrow;
    }
  }

  @override
  Future<List<CampusEvent>> fetchCampusEvents({String? status, String? category}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('events').select('*, organizer:profiles(full_name)').eq('is_deleted', false);
      if (status != null && status.isNotEmpty) {
        req = req.eq('status', status);
      }
      if (category != null && category.isNotEmpty) {
        req = req.eq('category', category);
      }
      final List<dynamic> res = await req.order('event_date', ascending: true);
      return res.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['organizer'] != null && map['organizer'] is Map) {
          map['organizer_name'] = map['organizer']['full_name'];
        }
        return CampusEvent.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching campus events: $e');
      return [];
    }
  }

  @override
  Future<CampusEvent> createCampusEvent(CampusEvent event) async {
    try {
      final client = SupabaseService.instance.client;
      final res = await client.from('events').insert(event.toJson()).select().single();
      return CampusEvent.fromJson(res);
    } catch (e) {
      debugPrint('Error creating campus event: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCampusEventStatus(String eventId, String status) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('events').update({'status': status}).eq('id', eventId);
    } catch (e) {
      debugPrint('Error updating event status: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCampusEvent(String eventId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('events').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', eventId);
    } catch (e) {
      debugPrint('Error deleting campus event: $e');
      rethrow;
    }
  }

  @override
  Future<List<MarketplaceListing>> fetchMarketplaceListings({String? status, String? category}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('marketplace_listings').select('*, seller:profiles(full_name)').eq('is_deleted', false);
      if (status != null && status.isNotEmpty) {
        req = req.eq('status', status);
      }
      if (category != null && category.isNotEmpty) {
        req = req.eq('category', category);
      }
      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['seller'] != null && map['seller'] is Map) {
          map['seller_name'] = map['seller']['full_name'];
        }
        return MarketplaceListing.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching marketplace listings: $e');
      return [];
    }
  }

  @override
  Future<void> updateMarketplaceListingStatus(String listingId, String status) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('marketplace_listings').update({'status': status}).eq('id', listingId);
    } catch (e) {
      debugPrint('Error updating listing status: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMarketplaceListing(String listingId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('marketplace_listings').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', listingId);
    } catch (e) {
      debugPrint('Error deleting marketplace listing: $e');
      rethrow;
    }
  }

  @override
  Future<List<StudentClub>> fetchClubs({String? status}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('clubs').select('*, lead:profiles(full_name)').eq('is_deleted', false);
      if (status != null && status.isNotEmpty) {
        req = req.eq('status', status);
      }
      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['lead'] != null && map['lead'] is Map) {
          map['lead_name'] = map['lead']['full_name'];
        }
        return StudentClub.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching clubs: $e');
      return [];
    }
  }

  @override
  Future<StudentClub> createClub(StudentClub club) async {
    try {
      final client = SupabaseService.instance.client;
      final res = await client.from('clubs').insert(club.toJson()).select().single();
      return StudentClub.fromJson(res);
    } catch (e) {
      debugPrint('Error creating club: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateClubStatus(String clubId, String status) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('clubs').update({'status': status}).eq('id', clubId);
    } catch (e) {
      debugPrint('Error updating club status: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteClub(String clubId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('clubs').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', clubId);
    } catch (e) {
      debugPrint('Error deleting club: $e');
      rethrow;
    }
  }

  @override
  Future<List<CommunityPost>> fetchCommunityPosts({String? status, String? category}) async {
    try {
      final client = SupabaseService.instance.client;
      var req = client.from('community_posts').select('*, author:profiles(full_name)').eq('is_deleted', false);
      if (status != null && status.isNotEmpty) {
        req = req.eq('status', status);
      }
      if (category != null && category.isNotEmpty) {
        req = req.eq('category', category);
      }
      final List<dynamic> res = await req.order('created_at', ascending: false);
      return res.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        if (map['author'] != null && map['author'] is Map) {
          map['author_name'] = map['author']['full_name'];
        }
        return CommunityPost.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching community posts: $e');
      return [];
    }
  }

  @override
  Future<void> updateCommunityPostStatus(String postId, String status) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('community_posts').update({'status': status}).eq('id', postId);
    } catch (e) {
      debugPrint('Error updating community post status: $e');
      rethrow;
    }
  }

  @override
  Future<void> togglePinCommunityPost(String postId, bool isPinned) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('community_posts').update({'is_pinned': isPinned}).eq('id', postId);
    } catch (e) {
      debugPrint('Error toggling pin on post: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCommunityPost(String postId) async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('community_posts').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', postId);
    } catch (e) {
      debugPrint('Error deleting community post: $e');
      rethrow;
    }
  }
}
