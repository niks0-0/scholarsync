import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/admin/domain/models/study_note.dart';
import 'package:scholarsync/features/resources/data/repositories/supabase_resources_repository.dart';
import 'package:scholarsync/features/resources/presentation/resources_provider.dart';

class MockResourcesRepository implements ResourcesRepository {
  final List<StudyNote> notes = [
    StudyNote(
      id: 'note-1',
      title: 'Data Structures Handout.pdf',
      subjectId: 'CS201',
      subjectName: 'Data Structures',
      uploaderId: 'prof-1',
      uploaderName: 'Prof. Turing',
      fileUrl: 'https://example.com/note1.pdf',
      fileSizeBytes: 2048576,
      status: 'approved',
      createdAt: DateTime.now(),
    ),
  ];

  final List<Map<String, dynamic>> saved = [];

  @override
  Future<List<StudyNote>> fetchSubjectNotes({String? subjectId, String? category}) async {
    return notes;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSavedResources(String userId) async {
    return saved;
  }

  @override
  Future<void> saveResourceBookmark({
    required String userId,
    required String attachmentId,
    String? subjectId,
  }) async {
    saved.add({
      'id': 'bookmark-${saved.length + 1}',
      'user_id': userId,
      'attachment_id': attachmentId,
      'subject_id': subjectId,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeResourceBookmark({
    required String userId,
    required String bookmarkId,
  }) async {
    saved.removeWhere((item) => item['id'] == bookmarkId);
  }

  @override
  Future<String?> uploadStudyDocument({
    required File file,
    required String fileName,
    required String subjectId,
  }) async {
    return 'https://supabase.co/storage/v1/object/signed/study-notes/uploads/$fileName';
  }

  @override
  Future<void> recordDownload({
    required String userId,
    required String attachmentId,
  }) async {}
}

void main() {
  group('ResourcesProvider Unit Tests', () {
    late MockResourcesRepository mockRepo;
    late ResourcesProvider provider;

    setUp(() {
      mockRepo = MockResourcesRepository();
      provider = ResourcesProvider(repository: mockRepo);
    });

    test('loadResources fetches notes and bookmarks', () async {
      expect(provider.isLoading, isFalse);
      expect(provider.notes, isEmpty);

      await provider.loadResources('student-1');

      expect(provider.isLoading, isFalse);
      expect(provider.notes.length, equals(1));
      expect(provider.notes.first.title, equals('Data Structures Handout.pdf'));
    });

    test('bookmarkResource adds bookmark and refreshes saved resources', () async {
      final success = await provider.bookmarkResource(
        userId: 'student-1',
        attachmentId: 'att-123',
        subjectId: 'CS201',
      );

      expect(success, isTrue);
      expect(provider.savedResources.length, equals(1));
      expect(provider.savedResources.first['attachment_id'], equals('att-123'));
    });

    test('removeBookmark removes bookmark and updates state', () async {
      await provider.bookmarkResource(
        userId: 'student-1',
        attachmentId: 'att-123',
      );
      expect(provider.savedResources.length, equals(1));
      final bookmarkId = provider.savedResources.first['id'] as String;

      final success = await provider.removeBookmark(
        userId: 'student-1',
        bookmarkId: bookmarkId,
      );

      expect(success, isTrue);
      expect(provider.savedResources, isEmpty);
    });
  });
}
