import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/onboarding/presentation/onboarding_provider.dart';
import 'package:scholarsync/features/profile/domain/models/college.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';
import 'package:scholarsync/features/profile/domain/repositories/college_repository.dart';
import 'package:scholarsync/features/profile/domain/repositories/profile_repository.dart';

class MockCollegeRepository implements CollegeRepository {
  final List<College> sampleColleges = const [
    College(id: 'col-1', name: 'Stanford University', code: 'STANFORD'),
    College(id: 'col-2', name: 'Harvard University', code: 'HARVARD'),
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

void main() {
  late OnboardingProvider onboardingProvider;
  late MockCollegeRepository mockCollegeRepo;
  late MockProfileRepository mockProfileRepo;

  setUp(() {
    mockCollegeRepo = MockCollegeRepository();
    mockProfileRepo = MockProfileRepository();
    onboardingProvider = OnboardingProvider(collegeRepository: mockCollegeRepo);
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
  });
}
