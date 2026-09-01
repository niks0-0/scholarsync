import 'package:flutter/foundation.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/profile/domain/models/college.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';
import 'package:scholarsync/features/profile/domain/models/user_role.dart';
import '../data/repositories/supabase_admin_repository.dart';
import '../domain/models/admin_analytics.dart';
import '../domain/models/announcement.dart';
import '../domain/models/study_note.dart';
import '../domain/models/moderation_report.dart';
import '../domain/models/audit_log_entry.dart';
import '../domain/models/chat_room.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/academic_calendar_event.dart';
import '../domain/models/campus_event.dart';
import '../domain/models/marketplace_listing.dart';
import '../domain/models/student_club.dart';
import '../domain/models/community_post.dart';
import '../domain/repositories/admin_repository.dart';

/// State Notifier managing administrative operations, moderation, and dashboard state.
class AdminProvider extends ChangeNotifier {
  AdminProvider({AdminRepository? repository})
      : _repository = repository ?? const SupabaseAdminRepository();

  final AdminRepository _repository;

  // ── State Variables ────────────────────────────────────────────────────────
  AdminAnalytics _analytics = const AdminAnalytics();
  List<Subject> _subjects = [];
  List<College> _colleges = [];
  List<Announcement> _announcements = [];
  List<UserProfile> _students = [];
  List<StudyNote> _notes = [];
  List<ModerationReport> _reports = [];
  final List<AuditLogEntry> _auditLogs = [];

  // Phase 3 State
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _activeRoomMessages = [];
  List<AcademicCalendarEvent> _calendarEvents = [];
  List<CampusEvent> _campusEvents = [];
  List<MarketplaceListing> _marketplaceListings = [];
  List<StudentClub> _clubs = [];
  List<CommunityPost> _communityPosts = [];

  bool _isLoading = false;
  String? _errorMessage;

  int _selectedTabIndex = 0;
  String? _selectedBranchFilter;
  int? _selectedSemesterFilter;
  String _searchQuery = '';
  String? _selectedNoteStatusFilter = 'pending';
  String? _selectedReportStatusFilter = 'pending';

  // ── Getters ────────────────────────────────────────────────────────────────
  AdminAnalytics get analytics => _analytics;
  List<Subject> get subjects => _subjects;
  List<College> get colleges => _colleges;
  List<Announcement> get announcements => _announcements;
  List<UserProfile> get students => _students;
  List<StudyNote> get notes => _notes;
  List<ModerationReport> get reports => _reports;
  List<AuditLogEntry> get auditLogs => _auditLogs;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get activeRoomMessages => _activeRoomMessages;
  List<AcademicCalendarEvent> get calendarEvents => _calendarEvents;
  List<CampusEvent> get campusEvents => _campusEvents;
  List<MarketplaceListing> get marketplaceListings => _marketplaceListings;
  List<StudentClub> get clubs => _clubs;
  List<CommunityPost> get communityPosts => _communityPosts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;
  String? get selectedBranchFilter => _selectedBranchFilter;
  int? get selectedSemesterFilter => _selectedSemesterFilter;
  String get searchQuery => _searchQuery;
  String? get selectedNoteStatusFilter => _selectedNoteStatusFilter;
  String? get selectedReportStatusFilter => _selectedReportStatusFilter;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setBranchFilter(String? branch) {
    _selectedBranchFilter = branch;
    loadSubjects();
  }

  void setSemesterFilter(int? semester) {
    _selectedSemesterFilter = semester;
    loadSubjects();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadSubjects();
  }

  void setNoteStatusFilter(String? status) {
    _selectedNoteStatusFilter = status;
    loadNotes();
  }

  void setReportStatusFilter(String? status) {
    _selectedReportStatusFilter = status;
    loadModerationReports();
  }

  void clearFilters() {
    _selectedBranchFilter = null;
    _selectedSemesterFilter = null;
    _searchQuery = '';
    _selectedNoteStatusFilter = 'pending';
    _selectedReportStatusFilter = 'pending';
    loadSubjects();
  }

  // ── Data Fetching ──────────────────────────────────────────────────────────

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadAnalytics(),
        loadSubjects(),
        loadColleges(),
        loadAnnouncements(),
        loadStudents(),
        loadNotes(),
        loadModerationReports(),
        loadChatRooms(),
        loadCalendarEvents(),
        loadCampusEvents(),
        loadMarketplaceListings(),
        loadClubs(),
        loadCommunityPosts(),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to load master console data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnalytics() async {
    try {
      _analytics = await _repository.fetchAnalyticsSummary();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading admin analytics: $e');
    }
  }

  Future<void> loadSubjects() async {
    try {
      _subjects = await _repository.fetchAllSubjects(
        branch: _selectedBranchFilter,
        semester: _selectedSemesterFilter,
        query: _searchQuery,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading subjects: $e');
    }
  }

  Future<bool> createSubject(Subject subject) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createSubject(subject);
      _subjects.insert(0, created);
      _analytics = _analytics.copyWith(totalSubjects: _analytics.totalSubjects + 1);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create subject: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(Subject subject) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateSubject(subject);
      final index = _subjects.indexWhere((s) => s.id == updated.id);
      if (index != -1) {
        _subjects[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update subject: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String subjectId) async {
    try {
      await _repository.deleteSubject(subjectId);
      _subjects.removeWhere((s) => s.id == subjectId);
      _analytics = _analytics.copyWith(totalSubjects: _analytics.totalSubjects - 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete subject: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadColleges() async {
    try {
      _colleges = await _repository.fetchAllColleges();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading colleges: $e');
    }
  }

  Future<bool> createCollege(College college) async {
    try {
      final created = await _repository.createCollege(college);
      _colleges.add(created);
      _analytics = _analytics.copyWith(totalColleges: _analytics.totalColleges + 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create college: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCollege(College college) async {
    try {
      final updated = await _repository.updateCollege(college);
      final index = _colleges.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _colleges[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update college: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCollege(String collegeId) async {
    try {
      await _repository.deleteCollege(collegeId);
      _colleges.removeWhere((c) => c.id == collegeId);
      _analytics = _analytics.copyWith(totalColleges: _analytics.totalColleges - 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete college: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAnnouncements() async {
    try {
      _announcements = await _repository.fetchAnnouncements();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading announcements: $e');
    }
  }

  Future<bool> publishAnnouncement(Announcement announcement) async {
    try {
      final created = await _repository.publishAnnouncement(announcement);
      _announcements.insert(0, created);
      _analytics = _analytics.copyWith(totalAnnouncements: _analytics.totalAnnouncements + 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to broadcast announcement: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      await _repository.deleteAnnouncement(announcementId);
      _announcements.removeWhere((a) => a.id == announcementId);
      _analytics = _analytics.copyWith(totalAnnouncements: _analytics.totalAnnouncements - 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete announcement: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadStudents({String? query}) async {
    try {
      _students = await _repository.fetchStudents(query: query);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading students: $e');
    }
  }

  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _repository.updateUserRole(userId, newRole);
      final index = _students.indexWhere((s) => s.id == userId);
      if (index != -1) {
        _students[index] = _students[index].copyWith(role: newRole);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update student role: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserSuspension(String userId, bool isSuspended, {String? reason}) async {
    try {
      await _repository.toggleUserSuspension(userId, isSuspended, reason: reason);
      final index = _students.indexWhere((s) => s.id == userId);
      if (index != -1) {
        _students[index] = _students[index].copyWith(
          isSuspended: isSuspended,
          suspensionReason: reason,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update suspension: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadNotes() async {
    try {
      _notes = await _repository.fetchNotes(
        status: _selectedNoteStatusFilter,
        query: _searchQuery,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  Future<bool> moderateNote(String noteId, String targetStatus, {String? reason}) async {
    try {
      await _repository.moderateNote(noteId, targetStatus, reason: reason);
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          status: targetStatus,
          rejectionReason: reason,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to moderate note: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadModerationReports() async {
    try {
      _reports = await _repository.fetchModerationReports(
        status: _selectedReportStatusFilter,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading moderation reports: $e');
    }
  }

  Future<bool> resolveModerationReport(String reportId, String action, String notes) async {
    try {
      final success = await _repository.resolveModerationReport(reportId, action, notes);
      if (success) {
        final index = _reports.indexWhere((r) => r.id == reportId);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(
            status: 'resolved',
            resolutionAction: action,
            resolutionNotes: notes,
            resolvedAt: DateTime.now(),
          );
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to resolve report: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Phase 3 Handlers ───────────────────────────────────────────────────────

  Future<void> loadChatRooms({String? type}) async {
    try {
      _chatRooms = await _repository.fetchChatRooms(type: type);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat rooms: $e');
    }
  }

  Future<bool> createChatRoom(ChatRoom room) async {
    try {
      final created = await _repository.createChatRoom(room);
      _chatRooms.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create chat room: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChatRoom(String roomId) async {
    try {
      await _repository.deleteChatRoom(roomId);
      _chatRooms.removeWhere((r) => r.id == roomId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete chat room: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadRoomMessages(String roomId) async {
    try {
      _activeRoomMessages = await _repository.fetchChatMessages(roomId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading room messages: $e');
    }
  }

  Future<bool> deleteChatMessage(String messageId) async {
    try {
      await _repository.deleteChatMessage(messageId);
      _activeRoomMessages.removeWhere((m) => m.id == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCalendarEvents({String? eventType}) async {
    try {
      _calendarEvents = await _repository.fetchCalendarEvents(eventType: eventType);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading calendar events: $e');
    }
  }

  Future<bool> createCalendarEvent(AcademicCalendarEvent event) async {
    try {
      final created = await _repository.createCalendarEvent(event);
      _calendarEvents.add(created);
      _calendarEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create calendar event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCalendarEvent(String eventId) async {
    try {
      await _repository.deleteCalendarEvent(eventId);
      _calendarEvents.removeWhere((e) => e.id == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete calendar event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCampusEvents({String? status, String? category}) async {
    try {
      _campusEvents = await _repository.fetchCampusEvents(status: status, category: category);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading campus events: $e');
    }
  }

  Future<bool> createCampusEvent(CampusEvent event) async {
    try {
      final created = await _repository.createCampusEvent(event);
      _campusEvents.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCampusEventStatus(String eventId, String status) async {
    try {
      await _repository.updateCampusEventStatus(eventId, status);
      final index = _campusEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _campusEvents[index] = _campusEvents[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update event status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCampusEvent(String eventId) async {
    try {
      await _repository.deleteCampusEvent(eventId);
      _campusEvents.removeWhere((e) => e.id == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMarketplaceListings({String? status, String? category}) async {
    try {
      _marketplaceListings = await _repository.fetchMarketplaceListings(status: status, category: category);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading marketplace: $e');
    }
  }

  Future<bool> updateMarketplaceListingStatus(String listingId, String status) async {
    try {
      await _repository.updateMarketplaceListingStatus(listingId, status);
      final index = _marketplaceListings.indexWhere((l) => l.id == listingId);
      if (index != -1) {
        _marketplaceListings[index] = _marketplaceListings[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMarketplaceListing(String listingId) async {
    try {
      await _repository.deleteMarketplaceListing(listingId);
      _marketplaceListings.removeWhere((l) => l.id == listingId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadClubs({String? status}) async {
    try {
      _clubs = await _repository.fetchClubs(status: status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading clubs: $e');
    }
  }

  Future<bool> createClub(StudentClub club) async {
    try {
      final created = await _repository.createClub(club);
      _clubs.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create club: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClubStatus(String clubId, String status) async {
    try {
      await _repository.updateClubStatus(clubId, status);
      final index = _clubs.indexWhere((c) => c.id == clubId);
      if (index != -1) {
        _clubs[index] = _clubs[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update club: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteClub(String clubId) async {
    try {
      await _repository.deleteClub(clubId);
      _clubs.removeWhere((c) => c.id == clubId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete club: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCommunityPosts({String? status, String? category}) async {
    try {
      _communityPosts = await _repository.fetchCommunityPosts(status: status, category: category);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading community posts: $e');
    }
  }

  Future<bool> updateCommunityPostStatus(String postId, String status) async {
    try {
      await _repository.updateCommunityPostStatus(postId, status);
      final index = _communityPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _communityPosts[index] = _communityPosts[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update post status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePinCommunityPost(String postId, bool isPinned) async {
    try {
      await _repository.togglePinCommunityPost(postId, isPinned);
      final index = _communityPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _communityPosts[index] = _communityPosts[index].copyWith(isPinned: isPinned);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to toggle pin: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCommunityPost(String postId) async {
    try {
      await _repository.deleteCommunityPost(postId);
      _communityPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete post: $e';
      notifyListeners();
      return false;
    }
  }
}
