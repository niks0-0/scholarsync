import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../admin/domain/models/study_note.dart';
import '../data/repositories/supabase_resources_repository.dart';

class ResourcesProvider extends ChangeNotifier {
  ResourcesProvider({ResourcesRepository? repository})
      : _repository = repository ?? const SupabaseResourcesRepository();

  final ResourcesRepository _repository;

  List<StudyNote> _notes = [];
  List<Map<String, dynamic>> _savedResources = [];
  bool _isLoading = false;
  String? _error;

  List<StudyNote> get notes => _notes;
  List<Map<String, dynamic>> get savedResources => _savedResources;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadResources(String userId, {String? subjectId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _repository.fetchSubjectNotes(subjectId: subjectId);
      _savedResources = await _repository.fetchSavedResources(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookmarkResource({
    required String userId,
    required String attachmentId,
    String? subjectId,
  }) async {
    try {
      await _repository.saveResourceBookmark(
        userId: userId,
        attachmentId: attachmentId,
        subjectId: subjectId,
      );
      _savedResources = await _repository.fetchSavedResources(userId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to bookmark resource: $e');
      return false;
    }
  }

  Future<bool> removeBookmark({
    required String userId,
    required String bookmarkId,
  }) async {
    try {
      await _repository.removeResourceBookmark(
        userId: userId,
        bookmarkId: bookmarkId,
      );
      _savedResources.removeWhere((item) => item['id'] == bookmarkId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to remove bookmark: $e');
      return false;
    }
  }

  Future<String?> uploadDocument({
    required File file,
    required String fileName,
    required String subjectId,
  }) async {
    return await _repository.uploadStudyDocument(
      file: file,
      fileName: fileName,
      subjectId: subjectId,
    );
  }

  Future<void> recordDownload({
    required String userId,
    required String attachmentId,
  }) async {
    await _repository.recordDownload(userId: userId, attachmentId: attachmentId);
  }
}
