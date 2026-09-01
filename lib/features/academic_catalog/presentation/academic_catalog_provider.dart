import 'package:flutter/foundation.dart';
import '../../profile/domain/models/user_profile.dart';
import '../data/repositories/supabase_academic_catalog_repository.dart';
import '../domain/models/subject.dart';
import '../domain/repositories/academic_catalog_repository.dart';

enum CatalogStatus { initial, loading, loaded, error }

class AcademicCatalogProvider extends ChangeNotifier {
  AcademicCatalogProvider({AcademicCatalogRepository? repository})
      : _repository = repository ?? const SupabaseAcademicCatalogRepository();

  final AcademicCatalogRepository _repository;

  CatalogStatus _status = CatalogStatus.initial;
  String? _error;

  List<Subject> _curriculumSubjects = [];
  List<Subject> _enrolledSubjects = [];
  List<Subject> _filteredSubjects = [];
  Set<String> _enrolledSubjectIds = {};

  String _searchQuery = '';
  int? _semesterFilter;

  CatalogStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == CatalogStatus.loading;

  List<Subject> get curriculumSubjects => _curriculumSubjects;
  List<Subject> get enrolledSubjects => _enrolledSubjects;
  List<Subject> get subjects => _filteredSubjects.isNotEmpty || _searchQuery.isNotEmpty || _semesterFilter != null
      ? _filteredSubjects
      : _curriculumSubjects;
  Set<String> get enrolledSubjectIds => _enrolledSubjectIds;
  String get searchQuery => _searchQuery;
  int? get semesterFilter => _semesterFilter;

  /// Loads academic curriculum subjects for student's academic identity (branch & semester).
  Future<void> loadCatalogForUser(UserProfile? profile) async {
    if (profile == null) return;
    _status = CatalogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final branch = profile.branch ?? 'Computer Science & Engineering';
      final semester = profile.semester ?? 1;

      // 1. Fetch official curriculum subjects for branch & semester
      final curriculum = await _repository.getSubjectsForBranchAndSemester(
        collegeId: profile.collegeId,
        branch: branch,
        semester: semester,
      );

      // 2. Fetch student's enrolled subjects
      final enrolled = await _repository.getEnrolledSubjectsForUser(profile.id);

      _curriculumSubjects = curriculum;
      _enrolledSubjects = enrolled;
      _enrolledSubjectIds = enrolled.map((s) => s.id).toSet();
      _filteredSubjects = curriculum;
      _status = CatalogStatus.loaded;
    } catch (e) {
      _error = 'Failed to load curriculum catalog. Check connection and retry.';
      _status = CatalogStatus.error;
    }
    notifyListeners();
  }

  /// Searches and filters subjects by query and optional semester.
  void filterSubjects(String query, {int? semester}) {
    _searchQuery = query.trim().toLowerCase();
    _semesterFilter = semester;

    if (_searchQuery.isEmpty && _semesterFilter == null) {
      _filteredSubjects = _curriculumSubjects;
    } else {
      _filteredSubjects = _curriculumSubjects.where((s) {
        final matchesQuery = _searchQuery.isEmpty ||
            s.subjectName.toLowerCase().contains(_searchQuery) ||
            s.subjectCode.toLowerCase().contains(_searchQuery) ||
            s.shortName.toLowerCase().contains(_searchQuery);

        final matchesSem = _semesterFilter == null || s.semester == _semesterFilter;
        return matchesQuery && matchesSem;
      }).toList();
    }
    notifyListeners();
  }

  /// Toggles student subject enrollment in lightweight user_subjects mapping.
  Future<void> toggleSubjectEnrollment(String firebaseUid, Subject subject) async {
    final isEnrolled = _enrolledSubjectIds.contains(subject.id);
    try {
      if (isEnrolled) {
        await _repository.unenrollUserFromSubject(
          firebaseUid: firebaseUid,
          subjectId: subject.id,
        );
        _enrolledSubjectIds.remove(subject.id);
        _enrolledSubjects.removeWhere((s) => s.id == subject.id);
      } else {
        await _repository.enrollUserInSubject(
          firebaseUid: firebaseUid,
          subjectId: subject.id,
        );
        _enrolledSubjectIds.add(subject.id);
        _enrolledSubjects.add(subject);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling subject enrollment: $e');
    }
  }

  bool isEnrolled(String subjectId) => _enrolledSubjectIds.contains(subjectId);
}
