import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/academic_master_data.dart';
import 'package:scholarsync/features/academic_catalog/domain/models/subject.dart';
import 'package:scholarsync/features/academic_catalog/domain/repositories/academic_catalog_repository.dart';
import 'package:scholarsync/features/onboarding/presentation/onboarding_provider.dart';
import 'package:scholarsync/features/profile/domain/models/college.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';
import 'package:scholarsync/features/profile/domain/repositories/college_repository.dart';
import 'package:scholarsync/features/profile/domain/repositories/profile_repository.dart';
import 'package:scholarsync/features/storage/domain/repositories/storage_repository.dart';

class MockCollegeRepository implements CollegeRepository {
  final List<College> sampleColleges = const [
    College(
      id: 'col-1',
      name: 'L.D. College of Engineering',
      code: 'LDCE',
      stateId: 'state-gj',
      universityId: 'uni-gtu',
    ),
    College(
      id: 'col-2',
      name: 'Vishwakarma Government Engineering College',
      code: 'VGEC',
      stateId: 'state-gj',
      universityId: 'uni-gtu',
    ),
    College(
      id: 'col-3',
      name: 'Stanford University',
      code: 'STANFORD',
      stateId: 'state-ca',
    ),
  ];

  @override
  Future<List<College>> getColleges() async => sampleColleges;

  @override
  Future<List<College>> searchColleges(String query) async {
    return sampleColleges
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class MockAcademicCatalogRepository implements AcademicCatalogRepository {
  final List<AcademicState> sampleStates = const [
    AcademicState(id: 'state-gj', name: 'Gujarat', code: 'GJ'),
    AcademicState(id: 'state-mh', name: 'Maharashtra', code: 'MH'),
  ];

  final List<University> sampleUniversities = const [
    University(id: 'uni-gtu', name: 'Gujarat Technological University', stateId: 'state-gj'),
    University(id: 'uni-gu', name: 'Gujarat University', stateId: 'state-gj'),
  ];

  final List<AcademicCourse> sampleCourses = const [
    AcademicCourse(id: 'course-btech', name: 'B.Tech', streamId: 'stream-eng'),
    AcademicCourse(id: 'course-mca', name: 'MCA', streamId: 'stream-ca'),
  ];

  final List<AcademicBranch> sampleBranches = const [
    AcademicBranch(id: 'branch-ce', name: 'Computer Engineering', streamId: 'stream-eng'),
    AcademicBranch(id: 'branch-it', name: 'Information Technology', streamId: 'stream-eng'),
  ];

  final List<AcademicSemester> sampleSemesters = const [
    AcademicSemester(id: 'sem-1', semesterNumber: 1, name: 'Semester 1'),
    AcademicSemester(id: 'sem-2', semesterNumber: 2, name: 'Semester 2'),
  ];

  bool saveProfileCalled = false;
  bool autoEnrollCalled = false;

  @override
  Future<List<AcademicState>> getStates() async => sampleStates;

  @override
  Future<List<University>> getUniversities({String? stateId}) async {
    if (stateId != null) {
      return sampleUniversities.where((u) => u.stateId == stateId).toList();
    }
    return sampleUniversities;
  }

  @override
  Future<List<College>> getColleges({String? stateId, String? universityId}) async {
    return const [];
  }

  @override
  Future<List<AcademicStream>> getStreams() async => const [];

  @override
  Future<List<AcademicCourse>> getCourses({String? streamId}) async => sampleCourses;

  @override
  Future<List<AcademicBranch>> getBranches({String? streamId}) async => sampleBranches;

  @override
  Future<List<AcademicSemester>> getSemesters() async => sampleSemesters;

  @override
  Future<void> saveStudentAcademicProfile({
    required String userId,
    String? stateId,
    String? universityId,
    String? collegeId,
    String? streamId,
    String? courseId,
    String? branchId,
    String? semesterId,
    String? rollNumber,
    String? enrollmentNumber,
    String? division,
  }) async {
    saveProfileCalled = true;
  }

  @override
  Future<List<Subject>> autoEnrollSemesterSubjects({
    required String userId,
    String? universityId,
    String? collegeId,
    String? courseId,
    String? branchId,
    required String branchName,
    required int semesterNumber,
  }) async {
    autoEnrollCalled = true;
    return const [];
  }

  @override
  Future<void> enrollUserInSubject({required String firebaseUid, required String subjectId}) async {}

  @override
  Future<List<Subject>> getEnrolledSubjectsForUser(String firebaseUid) async => const [];

  @override
  Future<Subject?> getSubjectById(String id) async => null;

  @override
  Future<List<Subject>> getSubjectsForBranchAndSemester({
    String? collegeId,
    required String branch,
    required int semester,
  }) async =>
      const [];

  @override
  Future<List<Subject>> searchSubjects(String query, {String? branch, int? semester}) async => const [];

  @override
  Future<void> unenrollUserFromSubject({required String firebaseUid, required String subjectId}) async {}
}

class MockProfileRepository implements ProfileRepository {
  UserProfile? storedProfile;
  bool shouldFail = false;

  @override
  Future<UserProfile?> getProfile(String firebaseUid) async => storedProfile;

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    if (shouldFail) throw Exception('Database write error');
    storedProfile = profile;
    return profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    if (shouldFail) throw Exception('Database update error');
    storedProfile = profile;
    return profile;
  }

  @override
  Future<UserProfile> ensureProfileExists({
    required String firebaseUid,
    required String email,
    required String fullName,
    String? avatarUrl,
    String authProvider = 'google.com',
  }) async {
    if (storedProfile != null) return storedProfile!;
    final p = UserProfile(
      id: firebaseUid,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      authProvider: authProvider,
    );
    storedProfile = p;
    return p;
  }
}

class MockStorageRepository implements StorageRepository {
  @override
  Future<String> uploadAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  }) async =>
      'avatars/$firebaseUid/$fileName';

  @override
  Future<String> replaceAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  }) async =>
      'avatars/$firebaseUid/$fileName';

  @override
  Future<void> deleteAvatar({required String firebaseUid, String fileName = 'profile.jpg'}) async {}

  @override
  Future<String> getSignedAvatarUrl({
    required String firebaseUid,
    String fileName = 'profile.jpg',
    int expiresInSeconds = 3600,
  }) async =>
      'https://storage.example.com/avatars/$firebaseUid/$fileName';

  @override
  Future<Uint8List> downloadAvatar({required String firebaseUid, String fileName = 'profile.jpg'}) async =>
      Uint8List.fromList([1, 2, 3]);
}

void main() {
  late OnboardingProvider onboardingProvider;
  late MockCollegeRepository mockCollegeRepo;
  late MockProfileRepository mockProfileRepo;
  late MockAcademicCatalogRepository mockAcademicRepo;
  late MockStorageRepository mockStorageRepo;

  setUp(() {
    mockCollegeRepo = MockCollegeRepository();
    mockProfileRepo = MockProfileRepository();
    mockAcademicRepo = MockAcademicCatalogRepository();
    mockStorageRepo = MockStorageRepository();
    onboardingProvider = OnboardingProvider(
      collegeRepository: mockCollegeRepo,
      academicCatalogRepository: mockAcademicRepo,
      storageRepository: mockStorageRepo,
    );
  });

  group('Onboarding State Transitions & Validation Tests', () {
    test('Initial step is 0 (Welcome)', () {
      expect(onboardingProvider.currentStep, equals(0));
      expect(onboardingProvider.status, equals(OnboardingStepStatus.initial));
    });

    test('Validation fails on Step 1 (College) if no college selected', () {
      onboardingProvider.setStep(1);
      final isValid = onboardingProvider.validateStep(1);
      expect(isValid, isFalse);
      expect(onboardingProvider.error, contains('select your college'));
    });

    test('Validation passes on Step 1 when a valid college is selected', () {
      onboardingProvider.setSelectedCollege(mockCollegeRepo.sampleColleges.first);
      final isValid = onboardingProvider.validateStep(1);
      expect(isValid, isTrue);
      expect(onboardingProvider.error, isNull);
    });

    test('Step navigation sequence works properly', () {
      onboardingProvider.setFullName('John Student');
      onboardingProvider.setSelectedCollege(mockCollegeRepo.sampleColleges.first);

      expect(onboardingProvider.nextStep(), isTrue); // step 0 -> 1
      expect(onboardingProvider.nextStep(), isTrue); // step 1 -> 2
      expect(onboardingProvider.currentStep, equals(2));

      onboardingProvider.previousStep();
      expect(onboardingProvider.currentStep, equals(1));
    });

    test('Successful profile onboarding completion sets onboarding_completed = true', () async {
      final initialProfile = const UserProfile(
        id: 'test_uid_123',
        email: 'john@example.com',
        fullName: 'John Student',
      );

      onboardingProvider.init(initialProfile);
      onboardingProvider.setSelectedCollege(mockCollegeRepo.sampleColleges.first);
      onboardingProvider.setBranch('Computer Science & Engineering');
      onboardingProvider.setSemester(4);
      onboardingProvider.setDivision('A');

      final result = await onboardingProvider.completeOnboarding(
        currentProfile: initialProfile,
        profileRepository: mockProfileRepo,
      );

      expect(result, isNotNull);
      expect(result!.onboardingCompleted, isTrue);
      expect(result.collegeId, equals('col-1'));
      expect(result.branch, equals('Computer Science & Engineering'));
      expect(result.semester, equals(4));
      expect(result.division, equals('A'));
      expect(onboardingProvider.status, equals(OnboardingStepStatus.success));
    });

    test('Failed profile update sets error status cleanly', () async {
      final initialProfile = const UserProfile(
        id: 'test_uid_123',
        email: 'john@example.com',
        fullName: 'John Student',
      );

      mockProfileRepo.shouldFail = true;

      onboardingProvider.init(initialProfile);
      onboardingProvider.setSelectedCollege(mockCollegeRepo.sampleColleges.first);

      final result = await onboardingProvider.completeOnboarding(
        currentProfile: initialProfile,
        profileRepository: mockProfileRepo,
      );

      expect(result, isNull);
      expect(onboardingProvider.status, equals(OnboardingStepStatus.error));
      expect(onboardingProvider.error, contains('Failed to save academic identity'));
    });

    test('Validation on Step 4 fails if legal undertaking is not accepted', () {
      onboardingProvider.setStep(4);
      onboardingProvider.setLegalUndertaking(false);
      onboardingProvider.setTermsAccepted(false);

      final isValid = onboardingProvider.validateStep(4);
      expect(isValid, isFalse);
      expect(onboardingProvider.error, contains('Self-Concern & Attendance Responsibility Guarantee'));
    });

    test('Validation on Step 4 passes when legal undertaking and terms are accepted with ID card', () {
      onboardingProvider.setStep(4);
      onboardingProvider.setLegalUndertaking(true);
      onboardingProvider.setTermsAccepted(true);
      onboardingProvider.setVerificationMethod('college_id');
      onboardingProvider.setIdCardBytes(Uint8List.fromList([1, 2, 3]));

      final isValid = onboardingProvider.validateStep(4);
      expect(isValid, isTrue);
      expect(onboardingProvider.error, isNull);
    });

    test('Email OTP verification updates verification status to verified', () {
      onboardingProvider.setInstitutionalEmail('student@mit.edu');
      onboardingProvider.sendEmailOtp();
      expect(onboardingProvider.generatedOtp, equals('742910'));

      final verified = onboardingProvider.verifyOtp('742910');
      expect(verified, isTrue);
      expect(onboardingProvider.isEmailVerified, isTrue);
      expect(onboardingProvider.verificationStatus, equals('verified'));
    });

    test('fetchMasterAcademicData populates master directory and auto-selects Gujarat', () async {
      await onboardingProvider.fetchMasterAcademicData();

      expect(onboardingProvider.states.length, equals(2));
      expect(onboardingProvider.selectedState?.name, equals('Gujarat'));
      expect(onboardingProvider.universities.length, equals(2));
      expect(onboardingProvider.courses.length, equals(2));
      expect(onboardingProvider.branches.length, equals(2));
    });

    test('Cascading filters: selecting GTU university filters colleges accurately', () async {
      await onboardingProvider.fetchMasterAcademicData();

      // Initially colleges in Gujarat (col-1 and col-2) are shown
      expect(onboardingProvider.colleges.length, equals(2));

      // Select GTU specifically
      final gtu = onboardingProvider.universities.first;
      onboardingProvider.setSelectedUniversity(gtu);

      expect(onboardingProvider.colleges.length, equals(2));
      expect(onboardingProvider.colleges.map((c) => c.code), containsAll(['LDCE', 'VGEC']));

      // Search filters within selected university
      onboardingProvider.searchColleges('LDCE');
      expect(onboardingProvider.colleges.length, equals(1));
      expect(onboardingProvider.colleges.first.name, equals('L.D. College of Engineering'));
    });

    test('completeOnboarding invokes saveStudentAcademicProfile and autoEnrollSemesterSubjects', () async {
      final initialProfile = const UserProfile(
        id: 'test_uid_456',
        email: 'student@ldce.ac.in',
        fullName: 'Patel Student',
      );

      onboardingProvider.init(initialProfile);
      await onboardingProvider.fetchMasterAcademicData();
      onboardingProvider.setSelectedCollege(mockCollegeRepo.sampleColleges.first);
      onboardingProvider.setSelectedCourse(mockAcademicRepo.sampleCourses.first); // B.Tech
      onboardingProvider.setSelectedBranch(mockAcademicRepo.sampleBranches.first); // CE
      onboardingProvider.setSelectedSemester(mockAcademicRepo.sampleSemesters.first); // Sem 1
      onboardingProvider.setRollNumber('210280107001');
      onboardingProvider.setLegalUndertaking(true);
      onboardingProvider.setTermsAccepted(true);
      onboardingProvider.setVerificationMethod('college_id');
      onboardingProvider.setIdCardBytes(Uint8List.fromList([1, 2, 3]));

      final result = await onboardingProvider.completeOnboarding(
        currentProfile: initialProfile,
        profileRepository: mockProfileRepo,
      );

      expect(result, isNotNull);
      expect(mockAcademicRepo.saveProfileCalled, isTrue);
      expect(mockAcademicRepo.autoEnrollCalled, isTrue);
    });
  });
}
