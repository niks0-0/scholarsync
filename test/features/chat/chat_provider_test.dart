import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/admin/domain/models/chat_message.dart';
import 'package:scholarsync/features/admin/domain/models/chat_room.dart';
import 'package:scholarsync/features/chat/data/repositories/supabase_chat_repository.dart';
import 'package:scholarsync/features/chat/presentation/chat_provider.dart';

class MockChatRepository implements ChatRepository {
  final List<ChatRoom> rooms = [
    const ChatRoom(
      id: 'room-1',
      name: 'General Lounge',
      type: 'general',
      isLocked: false,
    ),
    const ChatRoom(
      id: 'room-2',
      name: 'Algorithms & Data Structures',
      type: 'subject',
      isLocked: false,
    ),
  ];

  final List<ChatMessage> messages = [
    ChatMessage(
      id: 'msg-1',
      roomId: 'room-1',
      senderId: 'user-1',
      senderName: 'Alice',
      content: 'Welcome to General Lounge!',
      createdAt: DateTime.now(),
    ),
  ];

  final StreamController<List<ChatMessage>> _streamController =
      StreamController<List<ChatMessage>>.broadcast();

  @override
  Future<List<ChatRoom>> fetchRooms({String? category, String? collegeId}) async {
    if (category == null || category == 'all') return rooms;
    return rooms.where((r) => r.type == category).toList();
  }

  @override
  Future<ChatRoom?> fetchRoomById(String roomId) async {
    try {
      return rooms.firstWhere((r) => r.id == roomId);
    } catch (_) {
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
  }) async {}

  @override
  Future<List<ChatMessage>> fetchRoomMessages(String roomId, {int limit = 50}) async =>
      messages.where((m) => m.roomId == roomId).toList();

  @override
  Stream<List<ChatMessage>> streamRoomMessages(String roomId) =>
      _streamController.stream;

  @override
  Future<ChatMessage> sendMessage({
    required String clientAssignedId,
    required String roomId,
    required String senderId,
    required String content,
    String? replyToId,
  }) async {
    final msg = ChatMessage(
      id: clientAssignedId,
      roomId: roomId,
      senderId: senderId,
      content: content,
      replyToId: replyToId,
      createdAt: DateTime.now(),
    );
    messages.add(msg);
    _streamController.add(messages.where((m) => m.roomId == roomId).toList());
    return msg;
  }

  @override
  Future<void> joinRoom({required String roomId, required String userId}) async {}

  void dispose() {
    _streamController.close();
  }
}

void main() {
  group('ChatProvider Unit Tests', () {
    late MockChatRepository mockRepo;
    late ChatProvider provider;

    setUp(() {
      mockRepo = MockChatRepository();
      provider = ChatProvider(repository: mockRepo);
    });

    tearDown(() {
      mockRepo.dispose();
      provider.dispose();
    });

    test('loadRooms loads active rooms and notifies listeners', () async {
      expect(provider.isLoadingRooms, isFalse);
      expect(provider.rooms, isEmpty);

      await provider.loadRooms();

      expect(provider.isLoadingRooms, isFalse);
      expect(provider.rooms.length, equals(2));
      expect(provider.rooms.first.name, equals('General Lounge'));
    });

    test('setCategory correctly filters loaded rooms on next load', () async {
      provider.setCategory('subject');
      await provider.loadRooms();
      expect(provider.rooms.length, equals(1));
      expect(provider.rooms.first.type, equals('subject'));

      provider.setCategory(null);
      await provider.loadRooms();
      expect(provider.rooms.length, equals(2));
    });

    test('enterRoom joins room and fetches initial messages', () async {
      const targetRoom = ChatRoom(
        id: 'room-1',
        name: 'General Lounge',
        type: 'general',
      );

      await provider.enterRoom(targetRoom, userId: 'user-alice');

      expect(provider.currentRoom?.id, equals('room-1'));
      expect(provider.messages.length, equals(1));
      expect(provider.messages.first.content, equals('Welcome to General Lounge!'));
    });

    test('sendMessage sends message into active room', () async {
      const targetRoom = ChatRoom(
        id: 'room-1',
        name: 'General Lounge',
        type: 'general',
      );
      await provider.enterRoom(targetRoom, userId: 'user-alice');

      final success = await provider.sendMessage(
        clientAssignedId: 'new-client-msg-1',
        senderId: 'user-alice',
        content: 'Testing chat broadcast',
      );

      expect(success, isTrue);
      expect(mockRepo.messages.length, equals(2));
      expect(mockRepo.messages.last.content, equals('Testing chat broadcast'));
    });

    test('sendMessage returns false when no active room is entered', () async {
      final success = await provider.sendMessage(
        clientAssignedId: 'fail-id',
        senderId: 'user-1',
        content: 'Should not send',
      );

      expect(success, isFalse);
    });
  });
}
