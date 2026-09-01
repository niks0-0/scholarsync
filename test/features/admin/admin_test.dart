import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/admin/data/repositories/mock_admin_repository.dart';
import 'package:scholarsync/features/admin/domain/models/announcement.dart';
import 'package:scholarsync/features/admin/domain/models/study_note.dart';
import 'package:scholarsync/features/admin/domain/models/moderation_report.dart';
import 'package:scholarsync/features/admin/domain/models/chat_room.dart';
import 'package:scholarsync/features/admin/domain/models/academic_calendar_event.dart';
import 'package:scholarsync/features/admin/domain/models/campus_event.dart';
import 'package:scholarsync/features/admin/domain/models/student_club.dart';
import 'package:scholarsync/features/admin/presentation/admin_provider.dart';
import 'package:scholarsync/features/profile/domain/models/college.dart';
import 'package:scholarsync/features/profile/domain/models/user_role.dart';

void main() {
  group('Admin & RBAC Unit Tests', () {
    test('UserRole enum parsing and permission checks', () {
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('super_admin'), equals(UserRole.superAdmin));
      expect(UserRole.fromString('owner'), equals(UserRole.superAdmin));
      expect(UserRole.fromString('student'), equals(UserRole.student));
      expect(UserRole.fromString(null), equals(UserRole.student));

      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.superAdmin.isAdmin, isTrue);
      expect(UserRole.student.isAdmin, isFalse);

      expect(UserRole.admin.canManageCurriculum, isTrue);
      expect(UserRole.superAdmin.canManageCurriculum, isTrue);
      expect(UserRole.student.canManageCurriculum, isFalse);
    });

    test('Announcement model serialization and copyWith', () {
      final now = DateTime.now();
      final announcement = Announcement(
        id: 'ann-1',
        title: 'Mid-term Notice',
        content: 'Midterms begin next week.',
        createdBy: 'App Owner',
        isUrgent: true,
        targetBranch: 'Computer Science & Engineering',
        createdAt: now,
      );

      final json = announcement.toJson();
      expect(json['id'], equals('ann-1'));
      expect(json['title'], equals('Mid-term Notice'));
      expect(json['is_urgent'], isTrue);

      final copy = announcement.copyWith(title: 'Updated Notice', isUrgent: false);
      expect(copy.title, equals('Updated Notice'));
      expect(copy.isUrgent, isFalse);
      expect(copy.content, equals('Midterms begin next week.'));
    });

    test('StudyNote model serialization and copyWith', () {
      final note = StudyNote(
        id: 'note-1',
        title: 'DAA Unit 1',
        subjectId: 'sub-1',
        uploaderId: 'u-1',
        fileUrl: 'https://example.com/file.pdf',
        status: 'pending',
      );

      expect(note.status, equals('pending'));
      final copy = note.copyWith(status: 'approved');
      expect(copy.status, equals('approved'));
    });

    test('ModerationReport model serialization and copyWith', () {
      final report = ModerationReport(
        id: 'rep-1',
        reportedUserId: 'u-2',
        entityType: 'note',
        entityId: 'note-1',
        reason: 'Duplicate note',
        priority: 'high',
        status: 'pending',
      );

      expect(report.priority, equals('high'));
      expect(report.status, equals('pending'));
      final resolved = report.copyWith(status: 'resolved', resolutionAction: 'deleted_content');
      expect(resolved.status, equals('resolved'));
      expect(resolved.resolutionAction, equals('deleted_content'));
    });
  });

  group('MockAdminRepository CRUD Tests', () {
    late MockAdminRepository repository;

    setUp(() {
      repository = MockAdminRepository();
    });

    test('fetchAnalyticsSummary calculates accurate metrics', () async {
      final analytics = await repository.fetchAnalyticsSummary();
      expect(analytics.totalStudents, equals(2));
      expect(analytics.totalSubjects, equals(2));
      expect(analytics.totalColleges, equals(2));
      expect(analytics.totalAnnouncements, equals(1));
      expect(analytics.pendingNotes, equals(1));
      expect(analytics.pendingReports, equals(1));
    });

    test('Subject CRUD lifecycle', () async {
      const newSubject = Subject(
        id: '',
        branch: 'Computer Science & Engineering',
        semester: 4,
        subjectCode: 'CS403',
        subjectName: 'Computer Networks',
        shortName: 'CN',
      );
      final created = await repository.createSubject(newSubject);
      expect(created.subjectCode, equals('CS403'));

      final list = await repository.fetchAllSubjects(branch: 'Computer Science & Engineering');
      expect(list.any((s) => s.subjectCode == 'CS403'), isTrue);

      final updated = await repository.updateSubject(created.copyWith(subjectName: 'Advanced CN'));
      expect(updated.subjectName, equals('Advanced CN'));

      await repository.deleteSubject(created.id);
      final afterDelete = await repository.fetchAllSubjects();
      expect(afterDelete.any((s) => s.id == created.id), isFalse);
    });

    test('College CRUD lifecycle', () async {
      const newCollege = College(id: '', name: 'VJTI Mumbai', code: 'VJTI');
      final created = await repository.createCollege(newCollege);
      expect(created.code, equals('VJTI'));

      final colleges = await repository.fetchAllColleges();
      expect(colleges.any((c) => c.code == 'VJTI'), isTrue);

      await repository.deleteCollege(created.id);
      final afterDelete = await repository.fetchAllColleges();
      expect(afterDelete.any((c) => c.id == created.id), isFalse);
    });

    test('Announcement publishing and deletion', () async {
      final ann = Announcement(
        id: '',
        title: 'Holiday',
        content: 'Campus closed tomorrow',
        createdBy: 'App Owner',
      );
      final created = await repository.publishAnnouncement(ann);
      expect(created.title, equals('Holiday'));

      final list = await repository.fetchAnnouncements();
      expect(list.any((a) => a.title == 'Holiday'), isTrue);

      await repository.deleteAnnouncement(created.id);
      final afterDelete = await repository.fetchAnnouncements();
      expect(afterDelete.any((a) => a.id == created.id), isFalse);
    });

    test('Student search and role update', () async {
      final searchResult = await repository.fetchStudents(query: 'Nilay');
      expect(searchResult.length, equals(1));
      expect(searchResult.first.fullName, equals('Nilay Student'));

      await repository.updateUserRole('student-2', UserRole.superAdmin);
      final updatedStudents = await repository.fetchStudents();
      final alex = updatedStudents.firstWhere((s) => s.id == 'student-2');
      expect(alex.role, equals(UserRole.superAdmin));
    });

    test('Study note moderation and reports resolution', () async {
      final notes = await repository.fetchNotes(status: 'pending');
      expect(notes.length, equals(1));

      await repository.moderateNote('note-1', 'approved');
      final approvedNotes = await repository.fetchNotes(status: 'approved');
      expect(approvedNotes.length, equals(1));

      final success = await repository.resolveModerationReport('rep-1', 'warned', 'User warned');
      expect(success, isTrue);
    });
  });

  group('AdminProvider State Management Tests', () {
    late MockAdminRepository repository;
    late AdminProvider provider;

    setUp(() {
      repository = MockAdminRepository();
      provider = AdminProvider(repository: repository);
    });

    test('loadAllAdminData initializes all state slices', () async {
      await provider.loadAllAdminData();
      expect(provider.analytics.totalStudents, equals(2));
      expect(provider.subjects.length, equals(2));
      expect(provider.colleges.length, equals(2));
      expect(provider.announcements.length, equals(1));
      expect(provider.students.length, equals(2));
      expect(provider.notes.length, equals(1));
      expect(provider.reports.length, equals(1));
    });

    test('createSubject adds subject and refreshes metrics', () async {
      await provider.loadAllAdminData();

      const newSubject = Subject(
        id: '',
        branch: 'Computer Science & Engineering',
        semester: 4,
        subjectCode: 'CS404',
        subjectName: 'Software Engineering',
        shortName: 'SE',
      );

      final success = await provider.createSubject(newSubject);
      expect(success, isTrue);
      expect(provider.subjects.any((s) => s.subjectCode == 'CS404'), isTrue);
      expect(provider.analytics.totalSubjects, equals(3));
    });

    test('moderateNote updates local note state', () async {
      await provider.loadAllAdminData();

      final success = await provider.moderateNote('note-1', 'approved');
      expect(success, isTrue);
      final note = provider.notes.firstWhere((n) => n.id == 'note-1');
      expect(note.status, equals('approved'));
    });

    test('resolveModerationReport updates report state', () async {
      await provider.loadAllAdminData();

      final success = await provider.resolveModerationReport('rep-1', 'suspended', 'Suspended for violation');
      expect(success, isTrue);
      final report = provider.reports.firstWhere((r) => r.id == 'rep-1');
      expect(report.status, equals('resolved'));
    });

    test('ChatRoom & ChatMessage creation and deletion', () async {
      await provider.loadAllAdminData();
      expect(provider.chatRooms.length, equals(1));

      const newRoom = ChatRoom(
        id: 'room-2',
        name: 'Web Technologies',
        type: 'subject',
      );
      final success = await provider.createChatRoom(newRoom);
      expect(success, isTrue);
      expect(provider.chatRooms.length, equals(2));

      await provider.loadRoomMessages('room-1');
      expect(provider.activeRoomMessages.length, equals(1));

      final delMsg = await provider.deleteChatMessage('msg-1');
      expect(delMsg, isTrue);
      expect(provider.activeRoomMessages.isEmpty, isTrue);
    });

    test('AcademicCalendarEvent & CampusEvent lifecycle', () async {
      await provider.loadAllAdminData();
      expect(provider.calendarEvents.length, equals(1));
      expect(provider.campusEvents.length, equals(1));

      final newCal = AcademicCalendarEvent(
        id: 'cal-2',
        title: 'Spring Break',
        eventType: 'holiday',
        startDate: DateTime.now().add(const Duration(days: 30)),
      );
      await provider.createCalendarEvent(newCal);
      expect(provider.calendarEvents.length, equals(2));

      final newEvt = CampusEvent(
        id: 'evt-2',
        title: 'Flutter Workshop',
        category: 'workshop',
        eventDate: DateTime.now().add(const Duration(days: 40)),
        status: 'pending',
      );
      await provider.createCampusEvent(newEvt);
      expect(provider.campusEvents.length, equals(2));

      await provider.updateCampusEventStatus('evt-2', 'approved');
      expect(provider.campusEvents.firstWhere((e) => e.id == 'evt-2').status, equals('approved'));
    });

    test('Marketplace, Clubs and Community posts state management', () async {
      await provider.loadAllAdminData();
      expect(provider.marketplaceListings.length, equals(1));
      expect(provider.clubs.length, equals(1));
      expect(provider.communityPosts.length, equals(1));

      await provider.updateMarketplaceListingStatus('item-1', 'flagged');
      expect(provider.marketplaceListings.firstWhere((l) => l.id == 'item-1').status, equals('flagged'));

      const newClub = StudentClub(
        id: 'club-2',
        name: 'ACM Student Chapter',
        description: 'Computer Science Research Club',
        category: 'technical',
      );
      await provider.createClub(newClub);
      expect(provider.clubs.length, equals(2));

      await provider.togglePinCommunityPost('post-1', true);
      expect(provider.communityPosts.firstWhere((p) => p.id == 'post-1').isPinned, isTrue);
    });
  });
}

