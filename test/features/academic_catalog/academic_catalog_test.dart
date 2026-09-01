import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/academic_catalog/domain/repositories/academic_catalog_repository.dart';
import 'package:scholarsync/features/academic_catalog/presentation/academic_catalog_provider.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';

class MockAcademicCatalogRepository implements AcademicCatalogRepository {
  final List<Subject> sampleSubjects = [
    const Subject(
      id: 'sub-1',
      branch: 'Computer Science & Engineering',
      semester: 4,
      subjectCode: 'CS401',
      subjectName: 'Data Structures & Algorithms',
      shortName: 'DSA',
      credits: 4,
      facultyName: 'Dr. Robert Smith',
      practical: true,
      theory: true,
    ),
    const Subject(
      id: 'sub-2',
      branch: 'Computer Science & Engineering',
      semester: 4,
      subjectCode: 'CS402',
      subjectName: 'Database Management Systems',
      shortName: 'DBMS',
      credits: 4,
      facultyName: 'Prof. Anita Sharma',
      practical: true,
      theory: true,
    ),
  ];

  final Set<String> enrolledIds = {'sub-1'};

  @override
  Future<List<Subject>> getSubjectsForBranchAndSemester({
    String? collegeId,
    required String branch,
    required int semester,
  }) async {
    return sampleSubjects
        .where((s) => s.branch == branch && s.semester == semester)
        .toList();
  }

  @override
  Future<List<Subject>> getEnrolledSubjectsForUser(String firebaseUid) async {
    return sampleSubjects.where((s) => enrolledIds.contains(s.id)).toList();
  }

  @override
  Future<List<Subject>> searchSubjects(
    String query, {
    String? branch,
    int? semester,
  }) async {
    return sampleSubjects.where((s) {
      final matchesQuery = s.subjectName.toLowerCase().contains(query.toLowerCase()) ||
          s.subjectCode.toLowerCase().contains(query.toLowerCase());
      return matchesQuery;
    }).toList();
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    return sampleSubjects.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> enrollUserInSubject({
    required String firebaseUid,
    required String subjectId,
  }) async {
    enrolledIds.add(subjectId);
  }

  @override
  Future<void> unenrollUserFromSubject({
    required String firebaseUid,
    required String subjectId,
  }) async {
    enrolledIds.remove(subjectId);
  }
}

void main() {
  late MockAcademicCatalogRepository mockRepo;
  late AcademicCatalogProvider catalogProvider;

  setUp(() {
    mockRepo = MockAcademicCatalogRepository();
    catalogProvider = AcademicCatalogProvider(repository: mockRepo);
  });

  group('Academic Subject Entity Serialization Tests', () {
    test('Subject json parsing and map serialization works', () {
      final json = {
        'id': 'sub-101',
        'branch': 'Computer Science & Engineering',
        'semester': 4,
        'subject_code': 'CS401',
        'subject_name': 'Data Structures & Algorithms',
        'short_name': 'DSA',
        'credits': 4,
        'faculty_name': 'Dr. Robert Smith',
        'practical': true,
        'theory': true,
        'display_order': 1,
        'is_active': true,
      };

      final subject = Subject.fromJson(json);

      expect(subject.id, equals('sub-101'));
      expect(subject.subjectCode, equals('CS401'));
      expect(subject.credits, equals(4));
      expect(subject.practical, isTrue);
      expect(subject.theory, isTrue);
    });

    test('Subject copyWith maintains unmodified values', () {
      const subject = Subject(
        id: 'sub-1',
        branch: 'Computer Science & Engineering',
        semester: 4,
        subjectCode: 'CS401',
        subjectName: 'Data Structures',
        shortName: 'DSA',
      );

      final updated = subject.copyWith(facultyName: 'Dr. Jane Doe');
      expect(updated.id, equals('sub-1'));
      expect(updated.subjectCode, equals('CS401'));
      expect(updated.facultyName, equals('Dr. Jane Doe'));
    });
  });

  group('AcademicCatalogProvider State & Filtering Tests', () {
    test('loadCatalogForUser fetches subjects matching student academic identity', () async {
      const studentProfile = UserProfile(
        id: 'uid_test_123',
        email: 'student@college.edu',
        fullName: 'John Student',
        branch: 'Computer Science & Engineering',
        semester: 4,
      );

      await catalogProvider.loadCatalogForUser(studentProfile);

      expect(catalogProvider.status, equals(CatalogStatus.loaded));
      expect(catalogProvider.curriculumSubjects.length, equals(2));
      expect(catalogProvider.isEnrolled('sub-1'), isTrue);
      expect(catalogProvider.isEnrolled('sub-2'), isFalse);
    });

    test('filterSubjects filters subjects by query string', () async {
      const studentProfile = UserProfile(
        id: 'uid_test_123',
        email: 'student@college.edu',
        fullName: 'John Student',
        branch: 'Computer Science & Engineering',
        semester: 4,
      );

      await catalogProvider.loadCatalogForUser(studentProfile);
      catalogProvider.filterSubjects('Database');

      expect(catalogProvider.subjects.length, equals(1));
      expect(catalogProvider.subjects.first.subjectCode, equals('CS402'));
    });

    test('toggleSubjectEnrollment updates student enrolled subject IDs', () async {
      const studentProfile = UserProfile(
        id: 'uid_test_123',
        email: 'student@college.edu',
        fullName: 'John Student',
        branch: 'Computer Science & Engineering',
        semester: 4,
      );

      await catalogProvider.loadCatalogForUser(studentProfile);
      final secondSubject = catalogProvider.curriculumSubjects[1];

      await catalogProvider.toggleSubjectEnrollment('uid_test_123', secondSubject);

      expect(catalogProvider.isEnrolled('sub-2'), isTrue);
    });
  });
}
