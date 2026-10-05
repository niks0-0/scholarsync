import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../admin/domain/models/chat_room.dart';
import '../../../admin/domain/models/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> fetchRooms({String? category, String? collegeId});
  Future<ChatRoom?> fetchRoomById(String roomId);
  Future<void> submitRoomCreationRequest({
    required String requesterId,
    required String name,
    required String category,
    String? description,
    String? collegeId,
    String? branch,
    int? semester,
    String? subjectId,
    String joiningPolicy = 'public_academic',
  });
  Future<List<ChatMessage>> fetchRoomMessages(String roomId, {int limit = 50});
  Stream<List<ChatMessage>> streamRoomMessages(String roomId);
  Future<ChatMessage> sendMessage({
    required String clientAssignedId,
    required String roomId,
    required String senderId,
    required String content,
    String? replyToId,
  });
  Future<void> joinRoom({required String roomId, required String userId});
}

class SupabaseChatRepository implements ChatRepository {
  const SupabaseChatRepository();

  SupabaseClient get _client => SupabaseService.instance.client;

  @override
  Future<List<ChatRoom>> fetchRooms({String? category, String? collegeId}) async {
    try {
      var query = _client.from('chat_rooms').select().eq('is_deleted', false);
      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.or('type.eq.$category,category.eq.$category');
      }
      if (collegeId != null && collegeId.isNotEmpty) {
        query = query.or('college_id.eq.$collegeId,college_id.is.null');
      }
      final response = await query.order('created_at', ascending: false);
      if (response is List) {
        return response.map((data) => ChatRoom.fromJson(data as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching chat rooms from Supabase: $e');
      return [];
    }
  }

  @override
  Future<ChatRoom?> fetchRoomById(String roomId) async {
    try {
      final response = await _client.from('chat_rooms').select().eq('id', roomId).maybeSingle();
      if (response != null) {
        return ChatRoom.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching chat room $roomId: $e');
      return null;
    }
  }

  @override
  Future<void> submitRoomCreationRequest({
    required String requesterId,
    required String name,
    required String category,
    String? description,
    String? collegeId,
    String? branch,
    int? semester,
    String? subjectId,
    String joiningPolicy = 'public_academic',
  }) async {
    await _client.from('chatroom_creation_requests').insert({
      'requester_id': requesterId,
      'name': name,
      'description': description,
      'category': category,
      if (collegeId != null && collegeId.isNotEmpty) 'college_id': collegeId,
      if (branch != null && branch.isNotEmpty) 'branch': branch,
      if (semester != null) 'semester': semester,
      if (subjectId != null && subjectId.isNotEmpty) 'subject_id': subjectId,
      'joining_policy': joiningPolicy,
      'status': 'pending',
    });
  }

  @override
  Future<List<ChatMessage>> fetchRoomMessages(String roomId, {int limit = 50}) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select()
          .eq('room_id', roomId)
          .neq('status', 'purged')
          .order('created_at', ascending: true)
          .limit(limit);

      if (response is List) {
        return response.map((data) => ChatMessage.fromJson(data as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching room messages: $e');
      return [];
    }
  }

  @override
  Stream<List<ChatMessage>> streamRoomMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((records) => records.map((json) => ChatMessage.fromJson(json)).toList());
  }

  @override
  Future<ChatMessage> sendMessage({
    required String clientAssignedId,
    required String roomId,
    required String senderId,
    required String content,
    String? replyToId,
  }) async {
    final payload = {
      'id': clientAssignedId,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'status': 'sent',
      if (replyToId != null) 'reply_to_id': replyToId,
    };

    final response = await _client.from('chat_messages').insert(payload).select().single();
    return ChatMessage.fromJson(response);
  }

  @override
  Future<void> joinRoom({required String roomId, required String userId}) async {
    await _client.from('chatroom_members').upsert({
      'room_id': roomId,
      'user_id': userId,
      'role': 'member',
      'membership_status': 'active',
      'is_muted': false,
    }, onConflict: 'room_id,user_id');
  }
}
