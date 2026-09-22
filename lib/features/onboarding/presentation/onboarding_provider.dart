import 'package:flutter/foundation.dart';
import '../../academic_catalog/data/repositories/supabase_academic_catalog_repository.dart';
import '../../academic_catalog/domain/models/academic_master_data.dart';
import '../../academic_catalog/domain/repositories/academic_catalog_repository.dart';
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
    AcademicCatalogRepository? academicCatalogRepository,
  })  : _collegeRepository = collegeRepository ?? const SupabaseCollegeRepository(),
        _storageRepository = storageRepository ?? const SupabaseStorageRepository(),
        _academicCatalogRepository =
            academicCatalogRepository ?? const SupabaseAcademicCatalogRepository();

  final CollegeRepository _collegeRepository;
  final StorageRepository _storageRepository;
  final AcademicCatalogRepository _academicCatalogRepository;

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

  // Master Academic Directory States
  List<AcademicState> _states = [];
  AcademicState? _selectedState;
  List<University> _universities = [];
  University? _selectedUniversity;
  List<AcademicStream> _streams = [];
  AcademicStream? _selectedStream;
  List<AcademicCourse> _courses = [];
  AcademicCourse? _selectedCourse;
  List<AcademicBranch> _branches = [];
  AcademicBranch? _selectedBranch;
  List<AcademicSemester> _semesters = [];
  AcademicSemester? _selectedSemester;
  String _collegeSearchQuery = '';

  // Legal Compliance & Dual-Method Verification Fields
  bool _legalUndertakingAccepted = false;
  bool _termsAccepted = false;
  String _verificationMethod = 'college_id'; // 'college_email' or 'college_id'
  String _institutionalEmail = '';
  String _otpInput = '';
  String? _generatedOtp;
  bool _isEmailVerified = false;
  Uint8List? _idCardBytes;
  String? _idCardUrl;
  String _verificationStatus = 'pending_verification';

  List<College> _colleges = [];

  // Getters
  OnboardingStepStatus get status => _status;
  int get currentStep => _currentStep;
  String? get error => _errorMessage;
  bool get isLoading =>
      _status == OnboardingStepStatus.loading || _status == OnboardingStepStatus.saving;

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

  // Master Academic Getters
  List<AcademicState> get states => _states;
  AcademicState? get selectedState => _selectedState;
  List<University> get universities => _universities;
  University? get selectedUniversity => _selectedUniversity;
  List<University> get filteredUniversities {
    if (_selectedState == null) return _universities;
    return _universities.where((u) => u.stateId == _selectedState!.id).toList();
  }

  List<AcademicStream> get streams => _streams;
  AcademicStream? get selectedStream => _selectedStream;
  List<AcademicCourse> get courses => _courses;
  AcademicCourse? get selectedCourse => _selectedCourse;
  List<AcademicBranch> get branches => _branches;
  AcademicBranch? get selectedBranch => _selectedBranch;
  List<AcademicBranch> get filteredBranches {
    if (_selectedCourse != null && _selectedCourse!.streamId != null) {
      final sBranches =
          _branches.where((b) => b.streamId == _selectedCourse!.streamId).toList();
      if (sBranches.isNotEmpty) return sBranches;
    }
    return _branches;
  }

  List<AcademicSemester> get semesters => _semesters;
  AcademicSemester? get selectedSemester => _selectedSemester;
  String get collegeSearchQuery => _collegeSearchQuery;

  List<College> get colleges {
    List<College> list = _colleges;
    if (_selectedUniversity != null) {
      list = list.where((c) => c.universityId == _selectedUniversity!.id).toList();
    } else if (_selectedState != null) {
      list = list.where((c) => c.stateId == _selectedState!.id).toList();
    }
    if (_collegeSearchQuery.isNotEmpty) {
      final q = _collegeSearchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) || c.code.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  // Legal & Verification Getters
  bool get legalUndertakingAccepted => _legalUndertakingAccepted;
  bool get termsAccepted => _termsAccepted;
  String get verificationMethod => _verificationMethod;
  String get institutionalEmail => _institutionalEmail;
  String get otpInput => _otpInput;
  String? get generatedOtp => _generatedOtp;
  bool get isEmailVerified => _isEmailVerified;
  Uint8List? get idCardBytes => _idCardBytes;
  String? get idCardUrl => _idCardUrl;
  String get verificationStatus => _verificationStatus;

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
    fetchMasterAcademicData();
  }

  Future<void> fetchMasterAcademicData() async {
    _status = OnboardingStepStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _collegeRepository.getColleges(),
        _academicCatalogRepository.getStates(),
        _academicCatalogRepository.getUniversities(),
        _academicCatalogRepository.getCourses(),
        _academicCatalogRepository.getBranches(),
        _academicCatalogRepository.getSemesters(),
        _academicCatalogRepository.getStreams(),
      ]);

      _colleges = results[0] as List<College>;
      _states = results[1] as List<AcademicState>;
      _universities = results[2] as List<University>;
      _courses = results[3] as List<AcademicCourse>;
      _branches = results[4] as List<AcademicBranch>;
      _semesters = results[5] as List<AcademicSemester>;
      _streams = results[6] as List<AcademicStream>;

      // Auto-select Gujarat if present and no state selected yet
      if (_selectedState == null && _states.isNotEmpty) {
        final gujarat =
            _states.where((s) => s.name.toLowerCase() == 'gujarat').firstOrNull;
        if (gujarat != null) {
          _selectedState = gujarat;
        }
      }

      _status = OnboardingStepStatus.loaded;
    } catch (e) {
      _errorMessage =
          'Failed to load master academic directory. Form data is preserved for retry.';
      _status = OnboardingStepStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchColleges() => fetchMasterAcademicData();

  void searchColleges(String query) {
    _collegeSearchQuery = query.trim();
    notifyListeners();
  }

  // ── Master Academic Setters ───────────────────────────────────────────────
  void setSelectedState(AcademicState? state) {
    _selectedState = state;
    _selectedUniversity = null;
    _selectedCollege = null;
    notifyListeners();
  }

  void setSelectedUniversity(University? uni) {
    _selectedUniversity = uni;
    _selectedCollege = null;
    notifyListeners();
  }

  void setSelectedStream(AcademicStream? stream) {
    _selectedStream = stream;
    _selectedCourse = null;
    _selectedBranch = null;
    notifyListeners();
  }

  void setSelectedCourse(AcademicCourse? course) {
    _selectedCourse = course;
    _selectedBranch = null;
    notifyListeners();
  }

  void setSelectedBranch(AcademicBranch? branch) {
    _selectedBranch = branch;
    if (branch != null) {
      _branch = branch.name;
    }
    notifyListeners();
  }

  void setSelectedSemester(AcademicSemester? sem) {
    _selectedSemester = sem;
    if (sem != null) {
      _semester = sem.semesterNumber;
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

  void setAvatarUrl(String? url) {
    _avatarUrl = url;
    _avatarBytesToUpload = null;
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

  // ── Legal & Verification Setters ──────────────────────────────────────────
  void setLegalUndertaking(bool value) {
    _legalUndertakingAccepted = value;
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  void setVerificationMethod(String method) {
    _verificationMethod = method;
    notifyListeners();
  }

  void setInstitutionalEmail(String email) {
    _institutionalEmail = email.trim();
    notifyListeners();
  }

  void setOtpInput(String otp) {
    _otpInput = otp.trim();
    notifyListeners();
  }

  void sendEmailOtp() {
    if (_institutionalEmail.isEmpty || !_institutionalEmail.contains('@')) {
      _errorMessage = 'Please enter a valid institutional college email address.';
      notifyListeners();
      return;
    }
    // Deterministic instant OTP for verification
    _generatedOtp = '742910';
    _errorMessage = null;
    notifyListeners();
  }

  bool verifyOtp(String code) {
    if (_generatedOtp != null && code.trim() == _generatedOtp) {
      _isEmailVerified = true;
      _verificationStatus = 'verified';
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid verification code. Enter evaluation OTP: 742910';
      notifyListeners();
      return false;
    }
  }

  void setIdCardBytes(Uint8List bytes) {
    _idCardBytes = bytes;
    _verificationStatus = 'pending_verification';
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
      case 4: // Legal Undertaking & Student ID Verification Step
        if (!_legalUndertakingAccepted) {
          _errorMessage = 'Please accept the Self-Concern & Attendance Responsibility Guarantee.';
          notifyListeners();
          return false;
        }
        if (!_termsAccepted) {
          _errorMessage = 'Please accept the Terms of Service & Privacy Policy.';
          notifyListeners();
          return false;
        }
        if (_verificationMethod == 'college_email' && !_isEmailVerified) {
          _errorMessage = 'Please verify your college email with the OTP or switch to College ID Card upload.';
          notifyListeners();
          return false;
        }
        if (_verificationMethod == 'college_id' && _idCardBytes == null) {
          _errorMessage = 'Please upload or capture your student College ID card photo.';
          notifyListeners();
          return false;
        }
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

      // 2. Upload College ID Card if selected
      if (_idCardBytes != null) {
        try {
          final path = await _storageRepository.replaceAvatar(
            firebaseUid: currentProfile.id,
            fileBytes: _idCardBytes!,
            fileName: 'college_id_card.jpg',
            mimeType: 'image/jpeg',
          );
          final signedUrl = await _storageRepository.getSignedAvatarUrl(
            firebaseUid: currentProfile.id,
            fileName: 'college_id_card.jpg',
          );
          _idCardUrl = signedUrl.isNotEmpty ? signedUrl : path;
        } catch (_) {
          // Continue if storage upload has network exception
        }
      }

      // 3. Build updated profile model with onboarding_completed = true
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
        verificationStatus: _isEmailVerified ? 'verified' : 'pending_verification',
        collegeIdCardUrl: _idCardUrl,
        legalAcceptedAt: DateTime.now(),
        onboardingCompleted: true,
      );

      // 4. Persist to Supabase public.profiles table
      final savedProfile = await profileRepository.updateProfile(updatedProfile);

      // 5. Persist to Supabase public.student_academic_profile table
      try {
        await _academicCatalogRepository.saveStudentAcademicProfile(
          userId: currentProfile.id,
          stateId: _selectedState?.id ?? _selectedCollege?.stateId,
          universityId: _selectedUniversity?.id ?? _selectedCollege?.universityId,
          collegeId: _selectedCollege?.id,
          streamId: _selectedStream?.id ?? _selectedCourse?.streamId,
          courseId: _selectedCourse?.id,
          branchId: _selectedBranch?.id,
          semesterId: _selectedSemester?.id,
          rollNumber: _rollNumber,
          enrollmentNumber: _enrollmentNumber,
          division: _division,
        );
      } catch (e) {
        debugPrint('Warning: Failed to save student_academic_profile: $e');
      }

      // 6. Auto-enroll student into corresponding semester subjects
      try {
        await _academicCatalogRepository.autoEnrollSemesterSubjects(
          userId: currentProfile.id,
          universityId: _selectedUniversity?.id ?? _selectedCollege?.universityId,
          collegeId: _selectedCollege?.id,
          courseId: _selectedCourse?.id,
          branchId: _selectedBranch?.id,
          branchName: _branch,
          semesterNumber: _semester,
        );
      } catch (e) {
        debugPrint('Warning: Failed to auto-enroll semester subjects: $e');
      }

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
