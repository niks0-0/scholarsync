import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/core/utils/uuid_helper.dart';
import 'package:scholarsync/features/admin/data/repositories/mock_admin_repository.dart';
import 'package:scholarsync/features/admin/domain/models/chat_room.dart';
import 'package:scholarsync/features/admin/domain/models/chat_message.dart';
import 'package:scholarsync/features/admin/domain/models/chat_member.dart';
import 'package:scholarsync/features/admin/domain/models/moderation_context.dart';
import 'package:scholarsync/features/admin/presentation/admin_provider.dart';

void main() {
  group('Chat Safety & Reliability Models Unit Tests', () {
    test('UuidHelper generates valid RFC 4122 v4 UUIDs', () {
      final id1 = UuidHelper.generateV4();
      final id2 = UuidHelper.generateV4();

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));

      final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
      expect(uuidRegex.hasMatch(id1), isTrue);
      expect(uuidRegex.hasMatch(id2), isTrue);
    });

    test('ChatRoom Safe-Lock serialization & copyWith', () {
      final now = DateTime.now();
      const room = ChatRoom(
        id: 'room-101',
        name: 'Algorithms Channel',
        type: 'subject',
        isLocked: false,
      );

      final lockedRoom = room.copyWith(
        isLocked: true,
        lockReason: 'Spam containment',
        lockedBy: 'admin-1',
        lockedAt: now,
      );

      expect(lockedRoom.isLocked, isTrue);
      expect(lockedRoom.lockReason, equals('Spam containment'));
      expect(lockedRoom.lockedBy, equals('admin-1'));
      expect(lockedRoom.lockedAt, equals(now));

      final json = lockedRoom.toJson();
      expect(json['is_locked'], isTrue);
      expect(json['lock_reason'], equals('Spam containment'));

      final parsed = ChatRoom.fromJson(json);
      expect(parsed.id, equals('room-101'));
      expect(parsed.isLocked, isTrue);
      expect(parsed.lockReason, equals('Spam containment'));
    });

    test('ChatMessage idempotency & soft-deletion model properties', () {
      final now = DateTime.now();
      final message = ChatMessage(
        id: 'msg-101',
        roomId: 'room-101',
        senderId: 'user-1',
        senderName: 'Student One',
        content: 'Hello channel',
        clientMessageId: 'uuid-1234',
        createdAt: now,
      );

      final json = message.toJson();
      expect(json['client_message_id'], equals('uuid-1234'));
      expect(json['is_deleted'], isFalse);

      final softDeleted = message.copyWith(
        isDeleted: true,
        deletedBy: 'admin-1',
        deletionReason: 'Off-topic violation',
      );

      expect(softDeleted.isDeleted, isTrue);
      expect(softDeleted.deletedBy, equals('admin-1'));
      expect(softDeleted.deletionReason, equals('Off-topic violation'));
    });

    test('ChatMember moderation status helpers', () {
      final unmuted = ChatMember(
        id: 'm-1',
        roomId: 'room-1',
        userId: 'u-1',
        isMuted: false,
      );
      expect(unmuted.isCurrentlyMuted, isFalse);
      expect(unmuted.isCurrentlyBanned, isFalse);

      final muted = ChatMember(
        id: 'm-2',
        roomId: 'room-1',
        userId: 'u-2',
        isMuted: true,
        mutedUntil: DateTime.now().add(const Duration(hours: 24)),
      );
      expect(muted.isCurrentlyMuted, isTrue);

      final expiredMute = ChatMember(
        id: 'm-3',
        roomId: 'room-1',
        userId: 'u-3',
        isMuted: true,
        mutedUntil: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(expiredMute.isCurrentlyMuted, isFalse);
    });

    test('ModerationContext deserializes thread context cleanly', () {
      final json = {
        'report_id': 'rep-1',
        'reason': 'Abusive language',
        'status': 'pending',
        'reporter_id': 'student-1',
        'reported_user_id': 'student-2',
        'room_id': 'room-1',
        'room_name': 'Operating Systems',
        'target_message': {
          'id': 'msg-target',
          'room_id': 'room-1',
          'sender_id': 'student-2',
          'sender_name': 'Bad Actor',
          'content': 'Disruptive message',
          'created_at': DateTime.now().toIso8601String(),
        },
        'previous_messages': [
          {
            'id': 'msg-prev',
            'room_id': 'room-1',
            'sender_id': 'student-1',
            'sender_name': 'Good Student',
            'content': 'Legitimate question',
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
        'next_messages': [],
      };

      final context = ModerationContext.fromJson(json);
      expect(context.reportId, equals('rep-1'));
      expect(context.targetMessage.content, equals('Disruptive message'));
      expect(context.previousMessages.length, equals(1));
      expect(context.previousMessages.first.content, equals('Legitimate question'));
    });
  });

  group('AdminProvider Safe-Lock & Graduated Moderation Integration Tests', () {
    late MockAdminRepository mockRepo;
    late AdminProvider provider;

    setUp(() {
      mockRepo = MockAdminRepository();
      provider = AdminProvider(repository: mockRepo);
    });

    test('toggleRoomLock locks and unlocks chat room safely', () async {
      await provider.loadChatRooms();
      expect(provider.chatRooms.isNotEmpty, isTrue);
      final roomId = provider.chatRooms.first.id;

      // Lock room
      final lockResult = await provider.toggleRoomLock(roomId, true, reason: 'Emergency maintenance');
      expect(lockResult, isTrue);
      expect(provider.chatRooms.firstWhere((r) => r.id == roomId).isLocked, isTrue);
      expect(provider.chatRooms.firstWhere((r) => r.id == roomId).lockReason, equals('Emergency maintenance'));

      // Unlock room
      final unlockResult = await provider.toggleRoomLock(roomId, false);
      expect(unlockResult, isTrue);
      expect(provider.chatRooms.firstWhere((r) => r.id == roomId).isLocked, isFalse);
    });

    test('moderateChatMessage soft-deletes message with reason', () async {
      await provider.loadRoomMessages('room-1');
      expect(provider.activeRoomMessages.isNotEmpty, isTrue);
      final msgId = provider.activeRoomMessages.first.id;

      final result = await provider.moderateChatMessage(
        messageId: msgId,
        action: 'soft_delete',
        reason: 'Violation of safety policy',
      );

      expect(result, isTrue);
      final moderatedMsg = provider.activeRoomMessages.firstWhere((m) => m.id == msgId);
      expect(moderatedMsg.isDeleted, isTrue);
      expect(moderatedMsg.deletionReason, equals('Violation of safety policy'));
    });

    test('moderateUser graduates sanctions and logs audit trail', () async {
      final muteSuccess = await provider.moderateUser(
        userId: 'student-2',
        action: 'mute',
        durationMinutes: 1440,
        reason: 'Spamming channel',
        roomId: 'room-1',
      );
      expect(muteSuccess, isTrue);

      final banSuccess = await provider.moderateUser(
        userId: 'student-2',
        action: 'ban',
        reason: 'Repeated harassment',
      );
      expect(banSuccess, isTrue);

      // Verify audit trail logged
      final auditLogs = await mockRepo.fetchAuditLogs();
      expect(auditLogs.any((a) => a.action == 'user_ban' && a.targetId == 'student-2'), isTrue);
    });

    test('fetchReportContext provides contextual preceding messages', () async {
      await provider.loadModerationReports();
      expect(provider.reports.isNotEmpty, isTrue);

      final modContext = await provider.fetchReportContext(provider.reports.first.id);
      expect(modContext, isNotNull);
      expect(modContext!.targetMessage, isNotNull);
    });
  });
}
