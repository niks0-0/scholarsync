import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../admin/domain/models/chat_room.dart';
import '../../admin/domain/models/chat_message.dart';
import '../data/repositories/supabase_chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? const SupabaseChatRepository();

  final ChatRepository _repository;

  List<ChatRoom> _rooms = [];
  String? _selectedCategory;
  bool _isLoadingRooms = false;
  String? _roomError;

  // Active room state
  ChatRoom? _currentRoom;
  List<ChatMessage> _messages = [];
  bool _isLoadingMessages = false;
  StreamSubscription<List<ChatMessage>>? _messageSubscription;

  List<ChatRoom> get rooms => _rooms;
  String? get selectedCategory => _selectedCategory;
  bool get isLoadingRooms => _isLoadingRooms;
  String? get roomError => _roomError;
  ChatRoom? get currentRoom => _currentRoom;
  List<ChatMessage> get messages => _messages;
  bool get isLoadingMessages => _isLoadingMessages;

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadRooms({String? collegeId}) async {
    _isLoadingRooms = true;
    _roomError = null;
    notifyListeners();

    try {
      _rooms = await _repository.fetchRooms(
        category: _selectedCategory,
        collegeId: collegeId,
      );
    } catch (e) {
      _roomError = e.toString();
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }

  Future<void> enterRoom(ChatRoom room, {required String userId}) async {
    _currentRoom = room;
    _messages = [];
    _isLoadingMessages = true;
    notifyListeners();

    await _messageSubscription?.cancel();

    try {
      // Auto-join member
      await _repository.joinRoom(roomId: room.id, userId: userId);

      // Initial messages fetch
      _messages = await _repository.fetchRoomMessages(room.id);
      _isLoadingMessages = false;
      notifyListeners();

      // Listen to Realtime stream
      _messageSubscription = _repository.streamRoomMessages(room.id).listen((liveMessages) {
        _messages = liveMessages;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error entering room: $e');
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String clientAssignedId,
    required String senderId,
    required String content,
    String? replyToId,
  }) async {
    if (_currentRoom == null) return false;

    try {
      final msg = await _repository.sendMessage(
        clientAssignedId: clientAssignedId,
        roomId: _currentRoom!.id,
        senderId: senderId,
        content: content,
        replyToId: replyToId,
      );
      // Realtime stream will receive the confirmed event
      return true;
    } catch (e) {
      debugPrint('Failed to send message: $e');
      return false;
    }
  }

  Future<bool> submitRoomCreation({
    required String requesterId,
    required String name,
    required String category,
    String? description,
    String? collegeId,
    String? branch,
    int? semester,
    String? subjectId,
  }) async {
    try {
      await _repository.submitRoomCreationRequest(
        requesterId: requesterId,
        name: name,
        category: category,
        description: description,
        collegeId: collegeId,
        branch: branch,
        semester: semester,
        subjectId: subjectId,
      );
      return true;
    } catch (e) {
      debugPrint('Error submitting room creation request: $e');
      return false;
    }
  }

  void leaveCurrentRoom() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _currentRoom = null;
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
