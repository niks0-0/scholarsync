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

/// In-memory mock implementation of [AdminRepository] for testing.
class MockAdminRepository implements AdminRepository {
  MockAdminRepository({
    List<Subject>? subjects,
    List<College>? colleges,
    List<Announcement>? announcements,
    List<UserProfile>? students,
    List<StudyNote>? notes,
    List<ModerationReport>? reports,
    List<AuditLogEntry>? auditLogs,
    List<ChatRoom>? chatRooms,
    List<ChatMessage>? chatMessages,
    List<AcademicCalendarEvent>? calendarEvents,
    List<CampusEvent>? campusEvents,
    List<MarketplaceListing>? marketplaceListings,
    List<StudentClub>? clubs,
    List<CommunityPost>? communityPosts,
  })  : _subjects = subjects ??
            [
              const Subject(
                id: 'sub-1',
                branch: 'Computer Science & Engineering',
                semester: 4,
                subjectCode: 'CS401',
                subjectName: 'Design & Analysis of Algorithms',
                shortName: 'DAA',
                credits: 4,
                facultyName: 'Dr. Alan Turing',
                theory: true,
                practical: true,
              ),
              const Subject(
                id: 'sub-2',
                branch: 'Computer Science & Engineering',
                semester: 4,
                subjectCode: 'CS402',
                subjectName: 'Database Management Systems',
                shortName: 'DBMS',
                credits: 4,
                facultyName: 'Prof. Edgar Codd',
                theory: true,
                practical: true,
              ),
            ],
        _colleges = colleges ??
            [
              const College(
                id: 'col-1',
                name: 'MIT World Peace University',
                code: 'MIT-WPU',
              ),
              const College(
                id: 'col-2',
                name: 'College of Engineering Pune',
                code: 'COEP',
              ),
            ],
        _announcements = announcements ??
            [
              Announcement(
                id: 'ann-1',
                title: 'Campus Tech Symposium 2026',
                content: 'All MCA and Engineering students are invited.',
                createdBy: 'App Master Admin',
                isUrgent: false,
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
            ],
        _students = students ??
            [
              const UserProfile(
                id: 'student-1',
                email: 'nilay@scholarsync.com',
                fullName: 'Nilay Student',
                role: UserRole.student,
                branch: 'Computer Science & Engineering',
                semester: 4,
                rollNumber: 'CS2201',
                enrollmentNumber: 'EN1001',
                onboardingCompleted: true,
              ),
              const UserProfile(
                id: 'student-2',
                email: 'alex@scholarsync.com',
                fullName: 'Alex Student',
                role: UserRole.student,
                branch: 'Information Technology',
                semester: 2,
                rollNumber: 'IT2305',
                enrollmentNumber: 'EN1002',
                onboardingCompleted: true,
              ),
            ],
        _notes = notes ??
            [
              StudyNote(
                id: 'note-1',
                title: 'DAA Unit 1 Lecture Notes',
                subjectId: 'sub-1',
                subjectName: 'Design & Analysis of Algorithms',
                uploaderId: 'student-1',
                uploaderName: 'Nilay Student',
                fileUrl: 'https://example.com/daa_unit1.pdf',
                status: 'pending',
                createdAt: DateTime.now(),
              ),
            ],
        _reports = reports ??
            [
              ModerationReport(
                id: 'rep-1',
                reportedUserId: 'student-2',
                reportedUserName: 'Alex Student',
                entityType: 'note',
                entityId: 'note-1',
                reason: 'Duplicate upload',
                priority: 'medium',
                status: 'pending',
                createdAt: DateTime.now(),
              ),
            ],
        _auditLogs = auditLogs ??
            [
              AuditLogEntry(
                id: 'audit-1',
                adminId: 'admin-1',
                action: 'created_subject',
                targetType: 'subject',
                targetId: 'sub-1',
                createdAt: DateTime.now(),
              ),
            ],
        _chatRooms = chatRooms ??
            [
              const ChatRoom(
                id: 'room-1',
                name: 'Design & Analysis of Algorithms',
                type: 'subject',
                subjectId: 'sub-1',
                subjectName: 'Design & Analysis of Algorithms',
              ),
            ],
        _chatMessages = chatMessages ??
            [
              ChatMessage(
                id: 'msg-1',
                roomId: 'room-1',
                senderId: 'student-1',
                senderName: 'Nilay Student',
                content: 'Welcome to the DAA discussion room!',
                createdAt: DateTime.now(),
              ),
            ],
        _calendarEvents = calendarEvents ??
            [
              AcademicCalendarEvent(
                id: 'cal-1',
                title: 'Midterm Examinations',
                eventType: 'exam',
                startDate: DateTime.now().add(const Duration(days: 10)),
                endDate: DateTime.now().add(const Duration(days: 15)),
              ),
            ],
        _campusEvents = campusEvents ??
            [
              CampusEvent(
                id: 'evt-1',
                title: 'National Level Hackathon 2026',
                category: 'hackathon',
                location: 'Main Auditorium',
                eventDate: DateTime.now().add(const Duration(days: 20)),
                status: 'approved',
              ),
            ],
        _marketplaceListings = marketplaceListings ??
            [
              MarketplaceListing(
                id: 'item-1',
                sellerId: 'student-1',
                sellerName: 'Nilay Student',
                title: 'CLRS Algorithms 3rd Edition',
                price: 450.0,
                category: 'books',
                status: 'active',
                createdAt: DateTime.now(),
              ),
            ],
        _clubs = clubs ??
            [
              const StudentClub(
                id: 'club-1',
                name: 'Google Developer Student Club',
                description: 'Campus tech and open-source community',
                category: 'technical',
                memberCount: 120,
                status: 'active',
              ),
            ],
        _communityPosts = communityPosts ??
            [
              CommunityPost(
                id: 'post-1',
                authorId: 'student-1',
                authorName: 'Nilay Student',
                title: 'Best resources for Dynamic Programming?',
                content: 'Looking for curated practice sheets for upcoming campus interviews.',
                category: 'doubt',
                upvotesCount: 15,
                commentsCount: 4,
                status: 'active',
                createdAt: DateTime.now(),
              ),
            ];

  final List<Subject> _subjects;
  final List<College> _colleges;
  final List<Announcement> _announcements;
  final List<UserProfile> _students;
  final List<StudyNote> _notes;
  final List<ModerationReport> _reports;
  final List<AuditLogEntry> _auditLogs;
  final List<ChatRoom> _chatRooms;
  final List<ChatMessage> _chatMessages;
  final List<AcademicCalendarEvent> _calendarEvents;
  final List<CampusEvent> _campusEvents;
  final List<MarketplaceListing> _marketplaceListings;
  final List<StudentClub> _clubs;
  final List<CommunityPost> _communityPosts;

  @override
  Future<AdminAnalytics> fetchAnalyticsSummary() async {
    final Map<String, int> branchMap = {};
    for (final s in _students) {
      if (s.branch != null) {
        branchMap[s.branch!] = (branchMap[s.branch!] ?? 0) + 1;
      }
    }

    return AdminAnalytics(
      totalStudents: _students.length,
      activeStudents: _students.length,
      totalSubjects: _subjects.length,
      totalColleges: _colleges.length,
      totalAnnouncements: _announcements.length,
      pendingNotes: _notes.where((n) => n.status == 'pending').length,
      pendingReports: _reports.where((r) => r.status == 'pending').length,
      totalEvents: _campusEvents.length,
      totalMarketplace: _marketplaceListings.length,
      studentsByBranch: branchMap,
      recentRegistrations: List.from(_students),
    );
  }

  @override
  Future<List<Subject>> fetchAllSubjects({
    String? branch,
    int? semester,
    String? query,
  }) async {
    return _subjects.where((s) {
      if (branch != null && branch.isNotEmpty && s.branch != branch) return false;
      if (semester != null && semester > 0 && s.semester != semester) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        return s.subjectName.toLowerCase().contains(q) ||
            s.subjectCode.toLowerCase().contains(q) ||
            s.shortName.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Future<Subject> createSubject(Subject subject) async {
    final newSubject = Subject(
      id: 'sub-${_subjects.length + 1}',
      branch: subject.branch,
      semester: subject.semester,
      subjectCode: subject.subjectCode,
      subjectName: subject.subjectName,
      shortName: subject.shortName,
      credits: subject.credits,
      facultyName: subject.facultyName,
      theory: subject.theory,
      practical: subject.practical,
    );
    _subjects.add(newSubject);
    return newSubject;
  }

  @override
  Future<Subject> updateSubject(Subject subject) async {
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
      return subject;
    }
    throw Exception('Subject not found');
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    _subjects.removeWhere((s) => s.id == subjectId);
  }

  @override
  Future<List<College>> fetchAllColleges() async => List.from(_colleges);

  @override
  Future<College> createCollege(College college) async {
    final newCollege = College(
      id: 'col-${_colleges.length + 1}',
      name: college.name,
      code: college.code,
    );
    _colleges.add(newCollege);
    return newCollege;
  }

  @override
  Future<College> updateCollege(College college) async {
    final index = _colleges.indexWhere((c) => c.id == college.id);
    if (index != -1) {
      _colleges[index] = college;
      return college;
    }
    throw Exception('College not found');
  }

  @override
  Future<void> deleteCollege(String collegeId) async {
    _colleges.removeWhere((c) => c.id == collegeId);
  }

  @override
  Future<List<Announcement>> fetchAnnouncements() async => List.from(_announcements);

  @override
  Future<Announcement> publishAnnouncement(Announcement announcement) async {
    final newAnnouncement = Announcement(
      id: 'ann-${_announcements.length + 1}',
      title: announcement.title,
      content: announcement.content,
      createdBy: announcement.createdBy,
      isUrgent: announcement.isUrgent,
      targetBranch: announcement.targetBranch,
      targetSemester: announcement.targetSemester,
      createdAt: DateTime.now(),
    );
    _announcements.insert(0, newAnnouncement);
    return newAnnouncement;
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    _announcements.removeWhere((a) => a.id == announcementId);
  }

  @override
  Future<List<UserProfile>> fetchStudents({
    String? collegeId,
    String? branch,
    int? semester,
    String? query,
  }) async {
    return _students.where((s) {
      if (collegeId != null && s.collegeId != collegeId) return false;
      if (branch != null && s.branch != branch) return false;
      if (semester != null && s.semester != semester) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        return s.fullName.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            (s.rollNumber?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    final index = _students.indexWhere((s) => s.id == userId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(role: newRole);
    }
  }

  @override
  Future<void> toggleUserSuspension(String userId, bool isSuspended, {String? reason}) async {
    final index = _students.indexWhere((s) => s.id == userId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(
        isSuspended: isSuspended,
        suspensionReason: reason,
      );
    }
  }

  @override
  Future<List<StudyNote>> fetchNotes({String? status, String? query}) async {
    return _notes.where((n) {
      if (status != null && status.isNotEmpty && n.status != status) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        return n.title.toLowerCase().contains(q) ||
            (n.description?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  @override
  Future<void> moderateNote(String noteId, String targetStatus, {String? reason}) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        status: targetStatus,
        rejectionReason: reason,
      );
    }
  }

  @override
  Future<int> bulkModerateNotes(List<String> noteIds, String targetStatus, {String? reason}) async {
    int count = 0;
    for (final id in noteIds) {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          status: targetStatus,
          rejectionReason: reason,
        );
        count++;
      }
    }
    return count;
  }

  @override
  Future<List<ModerationReport>> fetchModerationReports({String? status, String? entityType}) async {
    return _reports.where((r) {
      if (status != null && status.isNotEmpty && r.status != status) return false;
      if (entityType != null && entityType.isNotEmpty && r.entityType != entityType) return false;
      return true;
    }).toList();
  }

  @override
  Future<bool> resolveModerationReport(String reportId, String action, String notes) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(
        status: 'resolved',
        resolutionAction: action,
        resolutionNotes: notes,
        resolvedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<List<AuditLogEntry>> fetchAuditLogs({int limit = 50}) async => List.from(_auditLogs);

  // ── Phase 3 Mock Implementations ───────────────────────────────────────────

  @override
  Future<List<ChatRoom>> fetchChatRooms({String? type}) async {
    return _chatRooms.where((r) {
      if (type != null && type.isNotEmpty && r.type != type) return false;
      return !r.isArchived;
    }).toList();
  }

  @override
  Future<ChatRoom> createChatRoom(ChatRoom room) async {
    final newRoom = ChatRoom(
      id: 'room-${_chatRooms.length + 1}',
      name: room.name,
      type: room.type,
      subjectId: room.subjectId,
      subjectName: room.subjectName,
      createdAt: DateTime.now(),
    );
    _chatRooms.add(newRoom);
    return newRoom;
  }

  @override
  Future<void> deleteChatRoom(String roomId) async {
    _chatRooms.removeWhere((r) => r.id == roomId);
  }

  @override
  Future<List<ChatMessage>> fetchChatMessages(String roomId, {int limit = 50}) async {
    return _chatMessages.where((m) => m.roomId == roomId).toList();
  }

  @override
  Future<void> deleteChatMessage(String messageId) async {
    _chatMessages.removeWhere((m) => m.id == messageId);
  }

  @override
  Future<List<AcademicCalendarEvent>> fetchCalendarEvents({String? eventType}) async {
    return _calendarEvents.where((e) {
      if (eventType != null && eventType.isNotEmpty && e.eventType != eventType) return false;
      return true;
    }).toList();
  }

  @override
  Future<AcademicCalendarEvent> createCalendarEvent(AcademicCalendarEvent event) async {
    final newEvent = AcademicCalendarEvent(
      id: 'cal-${_calendarEvents.length + 1}',
      title: event.title,
      description: event.description,
      eventType: event.eventType,
      startDate: event.startDate,
      endDate: event.endDate,
      targetBranch: event.targetBranch,
      targetSemester: event.targetSemester,
      createdAt: DateTime.now(),
    );
    _calendarEvents.add(newEvent);
    return newEvent;
  }

  @override
  Future<void> deleteCalendarEvent(String eventId) async {
    _calendarEvents.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<List<CampusEvent>> fetchCampusEvents({String? status, String? category}) async {
    return _campusEvents.where((e) {
      if (status != null && status.isNotEmpty && e.status != status) return false;
      if (category != null && category.isNotEmpty && e.category != category) return false;
      return true;
    }).toList();
  }

  @override
  Future<CampusEvent> createCampusEvent(CampusEvent event) async {
    final newEvent = CampusEvent(
      id: 'evt-${_campusEvents.length + 1}',
      title: event.title,
      description: event.description,
      location: event.location,
      category: event.category,
      eventDate: event.eventDate,
      status: event.status,
      createdAt: DateTime.now(),
    );
    _campusEvents.add(newEvent);
    return newEvent;
  }

  @override
  Future<void> updateCampusEventStatus(String eventId, String status) async {
    final index = _campusEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _campusEvents[index] = _campusEvents[index].copyWith(status: status);
    }
  }

  @override
  Future<void> deleteCampusEvent(String eventId) async {
    _campusEvents.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<List<MarketplaceListing>> fetchMarketplaceListings({String? status, String? category}) async {
    return _marketplaceListings.where((l) {
      if (status != null && status.isNotEmpty && l.status != status) return false;
      if (category != null && category.isNotEmpty && l.category != category) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> updateMarketplaceListingStatus(String listingId, String status) async {
    final index = _marketplaceListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _marketplaceListings[index] = _marketplaceListings[index].copyWith(status: status);
    }
  }

  @override
  Future<void> deleteMarketplaceListing(String listingId) async {
    _marketplaceListings.removeWhere((l) => l.id == listingId);
  }

  @override
  Future<List<StudentClub>> fetchClubs({String? status}) async {
    return _clubs.where((c) {
      if (status != null && status.isNotEmpty && c.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Future<StudentClub> createClub(StudentClub club) async {
    final newClub = StudentClub(
      id: 'club-${_clubs.length + 1}',
      name: club.name,
      description: club.description,
      category: club.category,
      status: club.status,
      createdAt: DateTime.now(),
    );
    _clubs.add(newClub);
    return newClub;
  }

  @override
  Future<void> updateClubStatus(String clubId, String status) async {
    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index != -1) {
      _clubs[index] = _clubs[index].copyWith(status: status);
    }
  }

  @override
  Future<void> deleteClub(String clubId) async {
    _clubs.removeWhere((c) => c.id == clubId);
  }

  @override
  Future<List<CommunityPost>> fetchCommunityPosts({String? status, String? category}) async {
    return _communityPosts.where((p) {
      if (status != null && status.isNotEmpty && p.status != status) return false;
      if (category != null && category.isNotEmpty && p.category != category) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> updateCommunityPostStatus(String postId, String status) async {
    final index = _communityPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _communityPosts[index] = _communityPosts[index].copyWith(status: status);
    }
  }

  @override
  Future<void> togglePinCommunityPost(String postId, bool isPinned) async {
    final index = _communityPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _communityPosts[index] = _communityPosts[index].copyWith(isPinned: isPinned);
    }
  }

  @override
  Future<void> deleteCommunityPost(String postId) async {
    _communityPosts.removeWhere((p) => p.id == postId);
  }
}
