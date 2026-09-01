import 'package:flutter/foundation.dart';
import '../../profile/data/repositories/supabase_college_repository.dart';
import '../../profile/domain/models/college.dart';
import '../../profile/domain/models/user_profile.dart';
import '../../profile/domain/repositories/college_repository.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../storage/data/repositories/supabase_storage_repository.dart';
import '../../storage/domain/repositories/storage_repository.dart';

enum OnboardingStepStatus {
  initial,
  loading,
  loaded,
  saving,
  success,
  error,
}

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    CollegeRepository? collegeRepository,
    StorageRepository? storageRepository,
  })  : _collegeRepository = collegeRepository ?? const SupabaseCollegeRepository(),
        _storageRepository = storageRepository ?? const SupabaseStorageRepository();

  final CollegeRepository _collegeRepository;
  final StorageRepository _storageRepository;

  OnboardingStepStatus _status = OnboardingStepStatus.initial;
  int _currentStep = 0;
  String? _errorMessage;

  // Form Fields
  String _fullName = '';
  College? _selectedCollege;
  String _customCollegeCode = '';
  String _branch = 'Computer Science & Engineering';
  int _semester = 1;
  String _division = 'A';
  String _academicYear = 'First Year (FY)';
  String _rollNumber = '';
  String _enrollmentNumber = '';
  String? _avatarUrl;
  Uint8List? _avatarBytesToUpload;
  String _reminderPreference = '15 minutes before';
  bool _notificationsEnabled = true;
  String _themePreference = 'System';

  List<College> _colleges = [];
  List<College> _filteredColleges = [];

  // Getters
  OnboardingStepStatus get status => _status;
  int get currentStep => _currentStep;
  String? get error => _errorMessage;
  bool get isLoading => _status == OnboardingStepStatus.loading || _status == OnboardingStepStatus.saving;

  String get fullName => _fullName;
  College? get selectedCollege => _selectedCollege;
  String get customCollegeCode => _customCollegeCode;
  String get branch => _branch;
  int get semester => _semester;
  String get division => _division;
  String get academicYear => _academicYear;
  String get rollNumber => _rollNumber;
  String get enrollmentNumber => _enrollmentNumber;
  String? get avatarUrl => _avatarUrl;
  Uint8List? get avatarBytesToUpload => _avatarBytesToUpload;
  String get reminderPreference => _reminderPreference;
  bool get notificationsEnabled => _notificationsEnabled;
  String get themePreference => _themePreference;
  List<College> get colleges => _filteredColleges.isNotEmpty ? _filteredColleges : _colleges;

  // ── Controlled Branch Options ─────────────────────────────────────────────
  static const List<String> availableBranches = [
    'Computer Science & Engineering',
    'Information Technology',
    'Artificial Intelligence & Data Science',
    'Electronics & Telecommunication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biomedical Engineering',
    'Other / Custom Branch',
  ];

  // ── Controlled Semester Options ───────────────────────────────────────────
  static const List<int> availableSemesters = [1, 2, 3, 4, 5, 6, 7, 8];

  // ── Controlled Division Options ───────────────────────────────────────────
  static const List<String> availableDivisions = ['A', 'B', 'C', 'D', 'E', 'Custom'];

  // ── Controlled Academic Year Options ──────────────────────────────────────
  static const List<String> availableAcademicYears = [
    'First Year (FY)',
    'Second Year (SY)',
    'Third Year (TY)',
    'Final Year (BE/BTech)',
  ];

  void init(UserProfile? initialProfile) {
    if (initialProfile != null) {
      _fullName = initialProfile.fullName;
      _avatarUrl = initialProfile.avatarUrl;
      _branch = initialProfile.branch ?? availableBranches.first;
      _semester = initialProfile.semester ?? 1;
      _division = initialProfile.division ?? 'A';
      _academicYear = initialProfile.academicYear ?? availableAcademicYears.first;
      _rollNumber = initialProfile.rollNumber ?? '';
      _enrollmentNumber = initialProfile.enrollmentNumber ?? '';
    }
    fetchColleges();
  }

  Future<void> fetchColleges() async {
    _status = OnboardingStepStatus.loading;
    notifyListeners();
    try {
      _colleges = await _collegeRepository.getColleges();
      _filteredColleges = _colleges;
      _status = OnboardingStepStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load college database. Form data is preserved for retry.';
      _status = OnboardingStepStatus.error;
    }
    notifyListeners();
  }

  void searchColleges(String query) {
    if (query.trim().isEmpty) {
      _filteredColleges = _colleges;
    } else {
      _filteredColleges = _colleges
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ── Form Setters ──────────────────────────────────────────────────────────
  void setFullName(String value) {
    _fullName = value.trim();
    notifyListeners();
  }

  void setSelectedCollege(College? college) {
    _selectedCollege = college;
    notifyListeners();
  }

  void setCustomCollegeCode(String code) {
    _customCollegeCode = code.trim();
    notifyListeners();
  }

  void setBranch(String value) {
    _branch = value;
    notifyListeners();
  }

  void setSemester(int value) {
    _semester = value;
    notifyListeners();
  }

  void setDivision(String value) {
    _division = value;
    notifyListeners();
  }

  void setAcademicYear(String value) {
    _academicYear = value;
    notifyListeners();
  }

  void setRollNumber(String value) {
    _rollNumber = value.trim();
    notifyListeners();
  }

  void setEnrollmentNumber(String value) {
    _enrollmentNumber = value.trim();
    notifyListeners();
  }

  void setAvatarBytes(Uint8List bytes) {
    _avatarBytesToUpload = bytes;
    notifyListeners();
  }

  void setReminderPreference(String pref) {
    _reminderPreference = pref;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void setThemePreference(String theme) {
    _themePreference = theme;
    notifyListeners();
  }

  // ── Step Navigation & Validation ─────────────────────────────────────────
  void setStep(int step) {
    _currentStep = step;
    _errorMessage = null;
    notifyListeners();
  }

  bool validateStep(int step) {
    _errorMessage = null;
    switch (step) {
      case 0: // Welcome Step
        return true;
      case 1: // College Step
        if (_selectedCollege == null) {
          _errorMessage = 'Please select your college to continue.';
          notifyListeners();
          return false;
        }
        return true;
      case 2: // Academic Information Step
        if (_branch.trim().isEmpty) {
          _errorMessage = 'Please select or specify your academic branch.';
          notifyListeners();
          return false;
        }
        if (_division.trim().isEmpty) {
          _errorMessage = 'Please select or specify your division.';
          notifyListeners();
          return false;
        }
        if (_academicYear.trim().isEmpty) {
          _errorMessage = 'Please select your academic year.';
          notifyListeners();
          return false;
        }
        return true;
      case 3: // Profile Step
        if (_fullName.trim().isEmpty) {
          _errorMessage = 'Full Name cannot be empty.';
          notifyListeners();
          return false;
        }
        return true;
      case 4: // Preferences Step
        return true;
      case 5: // Completion Step
        return validateAll();
      default:
        return true;
    }
  }

  bool validateAll() {
    if (_fullName.trim().isEmpty) {
      _errorMessage = 'Full Name is required.';
      notifyListeners();
      return false;
    }
    if (_selectedCollege == null) {
      _errorMessage = 'College selection is required.';
      notifyListeners();
      return false;
    }
    if (_branch.trim().isEmpty) {
      _errorMessage = 'Branch is required.';
      notifyListeners();
      return false;
    }
    if (_division.trim().isEmpty) {
      _errorMessage = 'Division is required.';
      notifyListeners();
      return false;
    }
    if (_academicYear.trim().isEmpty) {
      _errorMessage = 'Academic Year is required.';
      notifyListeners();
      return false;
    }
    return true;
  }

  bool nextStep() {
    if (!validateStep(_currentStep)) return false;
    if (_currentStep < 5) {
      _currentStep++;
      notifyListeners();
      return true;
    }
    return true;
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ── Avatar Upload to Supabase Storage ─────────────────────────────────────
  Future<bool> uploadAvatarToStorage(String firebaseUid) async {
    if (_avatarBytesToUpload == null) return true;

    _status = OnboardingStepStatus.saving;
    notifyListeners();

    try {
      final path = await _storageRepository.replaceAvatar(
        firebaseUid: firebaseUid,
        fileBytes: _avatarBytesToUpload!,
        fileName: 'profile.jpg',
        mimeType: 'image/jpeg',
      );

      final signedUrl = await _storageRepository.getSignedAvatarUrl(
        firebaseUid: firebaseUid,
        fileName: 'profile.jpg',
      );

      _avatarUrl = signedUrl.isNotEmpty ? signedUrl : path;
      return true;
    } catch (e) {
      _errorMessage = 'Avatar upload failed. Form data is preserved for retry.';
      _status = OnboardingStepStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Final Onboarding Completion & Profile Save ────────────────────────────
  Future<UserProfile?> completeOnboarding({
    required UserProfile currentProfile,
    required ProfileRepository profileRepository,
  }) async {
    if (!validateAll()) return null;

    _status = OnboardingStepStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload avatar if selected
      if (_avatarBytesToUpload != null) {
        final uploaded = await uploadAvatarToStorage(currentProfile.id);
        if (!uploaded) return null;
      }

      // 2. Build updated profile model with onboarding_completed = true
      final updatedProfile = currentProfile.copyWith(
        fullName: _fullName,
        collegeId: _selectedCollege?.id,
        branch: _branch,
        semester: _semester,
        division: _division,
        academicYear: _academicYear,
        rollNumber: _rollNumber.isNotEmpty ? _rollNumber : null,
        enrollmentNumber: _enrollmentNumber.isNotEmpty ? _enrollmentNumber : null,
        avatarUrl: _avatarUrl,
        onboardingCompleted: true,
      );

      // 3. Persist to Supabase public.profiles table
      final savedProfile = await profileRepository.updateProfile(updatedProfile);

      _status = OnboardingStepStatus.success;
      notifyListeners();
      return savedProfile;
    } catch (e) {
      _errorMessage = 'Failed to save academic identity. Please check connection and try again.';
      _status = OnboardingStepStatus.error;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
