import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scholarsync/core/services/supabase_service.dart';
import 'package:scholarsync/features/admin/domain/models/study_note.dart';

abstract class ResourcesRepository {
  Future<List<StudyNote>> fetchSubjectNotes({String? subjectId, String? category});
  Future<List<Map<String, dynamic>>> fetchSavedResources(String userId);
  Future<void> saveResourceBookmark({
    required String userId,
    required String attachmentId,
    String? subjectId,
  });
  Future<void> removeResourceBookmark({
    required String userId,
    required String bookmarkId,
  });
  Future<String?> uploadStudyDocument({
    required File file,
    required String fileName,
    required String subjectId,
  });
  Future<void> recordDownload({
    required String userId,
    required String attachmentId,
  });
}

class SupabaseResourcesRepository implements ResourcesRepository {
  const SupabaseResourcesRepository();

  SupabaseClient get _client => SupabaseService.instance.client;

  @override
  Future<List<StudyNote>> fetchSubjectNotes({String? subjectId, String? category}) async {
    final List<StudyNote> results = [];
    try {
      // 1. Fetch official and admin study notes from 'notes'
      try {
        var notesQuery = _client
            .from('notes')
            .select('*, profiles(full_name), subjects(subject_name)')
            .eq('is_deleted', false)
            .eq('status', 'approved');
        if (subjectId != null && subjectId.isNotEmpty) {
          notesQuery = notesQuery.eq('subject_id', subjectId);
        }
        final notesRes = await notesQuery.order('created_at', ascending: false).limit(50);
        if (notesRes is List) {
          results.addAll(
            notesRes.map<StudyNote>((item) => StudyNote.fromJson(item as Map<String, dynamic>)),
          );
        }
      } catch (e) {
        debugPrint('Note catalog query note: $e');
      }

      // 2. Fetch shared files from chatroom attachments
      try {
        var attQuery = _client.from('chatroom_attachments').select().eq('is_available', true);
        if (subjectId != null && subjectId.isNotEmpty) {
          attQuery = attQuery.eq('subject_id', subjectId);
        }
        final attRes = await attQuery.order('created_at', ascending: false).limit(50);
        if (attRes is List) {
          results.addAll(
            attRes.map<StudyNote>((data) {
              final m = data as Map<String, dynamic>;
              return StudyNote(
                id: m['id']?.toString() ?? '',
                title: m['file_name']?.toString() ?? 'Study Document',
                subjectId: m['subject_id']?.toString() ?? '',
                subjectName: 'Shared Resource',
                uploaderId: m['uploader_id']?.toString() ?? '',
                uploaderName: 'Contributor',
                fileUrl: m['storage_path']?.toString() ?? '',
                fileSizeBytes: (m['file_size_bytes'] as num?)?.toInt() ?? 1024,
                status: 'approved',
                createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) : null,
              );
            }),
          );
        }
      } catch (e) {
        debugPrint('Attachment query note: $e');
      }

      return results;
    } catch (e) {
      debugPrint('Error fetching study notes: $e');
      return results;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSavedResources(String userId) async {
    try {
      final response = await _client
          .from('saved_resources')
          .select('id, saved_at, chatroom_attachments(*)')
          .eq('user_id', userId)
          .order('saved_at', ascending: false);

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching saved resources: $e');
      return [];
    }
  }

  @override
  Future<void> saveResourceBookmark({
    required String userId,
    required String attachmentId,
    String? subjectId,
  }) async {
    await _client.from('saved_resources').upsert({
      'user_id': userId,
      'attachment_id': attachmentId,
      if (subjectId != null) 'subject_id': subjectId,
    }, onConflict: 'user_id,attachment_id');
  }

  @override
  Future<void> removeResourceBookmark({
    required String userId,
    required String bookmarkId,
  }) async {
    await _client.from('saved_resources').delete().eq('id', bookmarkId).eq('user_id', userId);
  }

  @override
  Future<String?> uploadStudyDocument({
    required File file,
    required String fileName,
    required String subjectId,
  }) async {
    try {
      final path = 'uploads/$subjectId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await _client.storage.from('study-notes').upload(path, file);
      final signedUrl = await _client.storage.from('study-notes').createSignedUrl(path, 60 * 60 * 24); // 24hr link
      
      try {
        final fileSize = await file.length();
        await _client.from('chatroom_attachments').insert({
          'file_name': fileName,
          'file_size_bytes': fileSize,
          'storage_path': signedUrl,
          'is_available': true,
        });
      } catch (e) {
        debugPrint('Warning: unable to register in chatroom_attachments: $e');
      }

      return signedUrl;
    } catch (e) {
      debugPrint('Error uploading study note to storage: $e');
      return null;
    }
  }

  @override
  Future<void> recordDownload({
    required String userId,
    required String attachmentId,
  }) async {
    try {
      await _client.from('resource_downloads').insert({
        'user_id': userId,
        'attachment_id': attachmentId,
        'status': 'completed',
      });
    } catch (e) {
      debugPrint('Error recording download in Supabase: $e');
    }
  }
}
