import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/profile/domain/models/user_profile.dart';
import 'package:scholarsync/features/profile/domain/repositories/profile_repository.dart';
import 'package:scholarsync/features/profile/presentation/profile_provider.dart';
import 'package:scholarsync/features/storage/domain/repositories/storage_repository.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfile? stored;
  bool shouldThrow = false;

  @override
  Future<UserProfile?> getProfile(String firebaseUid) async => stored;

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    if (shouldThrow) throw Exception('Postgres write failure');
    stored = profile;
    return profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    if (shouldThrow) throw Exception('Postgres update failure');
    stored = profile;
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
    if (stored != null) return stored!;
    final p = UserProfile(
      id: firebaseUid,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      authProvider: authProvider,
    );
    stored = p;
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
  }) async => 'avatars/$firebaseUid/$fileName';

  @override
  Future<String> replaceAvatar({
    required String firebaseUid,
    required Uint8List fileBytes,
    String fileName = 'profile.jpg',
    String mimeType = 'image/jpeg',
  }) async => 'avatars/$firebaseUid/$fileName';

  @override
  Future<void> deleteAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  }) async {}

  @override
  Future<String> getSignedAvatarUrl({
    required String firebaseUid,
    String fileName = 'profile.jpg',
    int expiresInSeconds = 3600,
  }) async => 'https://fnsyxmrnpjzshcrhhpfn.supabase.co/storage/v1/object/sign/avatars/$firebaseUid/$fileName?token=signed';

  @override
  Future<Uint8List> downloadAvatar({
    required String firebaseUid,
    String fileName = 'profile.jpg',
  }) async => Uint8List.fromList([1, 2, 3, 4]);
}

void main() {
  late MockProfileRepository mockProfileRepo;
  late MockStorageRepository mockStorageRepo;
  late ProfileProvider profileProvider;

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    mockStorageRepo = MockStorageRepository();
    profileProvider = ProfileProvider(
      repository: mockProfileRepo,
      storageRepository: mockStorageRepo,
    );
  });

  group('Academic Identity UserProfile Serialization Tests', () {
    test('UserProfile handles academicYear, rollNumber, and enrollmentNumber json parsing', () {
      final json = {
        'id': 'uid_123',
        'email': 'student@stanford.edu',
        'full_name': 'Jane Student',
        'auth_provider': 'google.com',
        'onboarding_completed': true,
        'college_id': 'col-101',
        'branch': 'Computer Science & Engineering',
        'semester': 4,
        'division': 'B',
        'academic_year': 'Second Year (SY)',
        'roll_number': '1042',
        'enrollment_number': '2026-CS-09',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, equals('uid_123'));
      expect(profile.email, equals('student@stanford.edu'));
      expect(profile.branch, equals('Computer Science & Engineering'));
      expect(profile.semester, equals(4));
      expect(profile.division, equals('B'));
      expect(profile.academicYear, equals('Second Year (SY)'));
      expect(profile.rollNumber, equals('1042'));
      expect(profile.enrollmentNumber, equals('2026-CS-09'));
    });

    test('UserProfile copyWith maintains read-only identity fields', () {
      const original = UserProfile(
        id: 'uid_123',
        email: 'original@college.edu',
        fullName: 'Original Name',
        authProvider: 'google.com',
      );

      final updated = original.copyWith(
        fullName: 'Updated Name',
        branch: 'Information Technology',
        semester: 3,
        academicYear: 'Second Year (SY)',
      );

      expect(updated.id, equals('uid_123'));
      expect(updated.email, equals('original@college.edu'));
      expect(updated.authProvider, equals('google.com'));
      expect(updated.fullName, equals('Updated Name'));
      expect(updated.branch, equals('Information Technology'));
    });
  });

  group('ProfileProvider State & Academic Identity Management Tests', () {
    test('syncProfile loads and initializes UserProfile state', () async {
      final res = await profileProvider.syncProfile(
        firebaseUid: 'uid_999',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      expect(res, isNotNull);
      expect(profileProvider.hasProfile, isTrue);
      expect(profileProvider.profile!.id, equals('uid_999'));
    });

    test('updateProfile updates academic identity correctly in repository', () async {
      await profileProvider.syncProfile(
        firebaseUid: 'uid_999',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      final current = profileProvider.profile!;
      final updated = current.copyWith(
        branch: 'Mechanical Engineering',
        semester: 6,
        division: 'A',
        academicYear: 'Third Year (TY)',
        rollNumber: 'ME-404',
      );

      final result = await profileProvider.updateProfile(updated);

      expect(result, isNotNull);
      expect(profileProvider.profile!.branch, equals('Mechanical Engineering'));
      expect(profileProvider.profile!.academicYear, equals('Third Year (TY)'));
      expect(profileProvider.profile!.rollNumber, equals('ME-404'));
    });

    test('uploadAvatar returns signed public URL from Supabase Storage', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final url = await profileProvider.uploadAvatar(
        firebaseUid: 'uid_999',
        bytes: fakeBytes,
      );

      expect(url, isNotNull);
      expect(url, contains('fnsyxmrnpjzshcrhhpfn.supabase.co'));
      expect(url, contains('uid_999/profile.jpg'));
    });

    test('clear resets profile state on sign out', () async {
      await profileProvider.syncProfile(
        firebaseUid: 'uid_999',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      profileProvider.clear();
      expect(profileProvider.hasProfile, isFalse);
      expect(profileProvider.profile, isNull);
    });
  });
}
