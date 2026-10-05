import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/notifications/data/repositories/supabase_notification_repository.dart';
import 'package:scholarsync/features/notifications/domain/models/user_device.dart';
import 'package:scholarsync/features/notifications/presentation/notification_provider.dart';

class MockNotificationRepository extends SupabaseNotificationRepository {
  final List<NotificationItem> notifs = [
    NotificationItem(
      id: 'notif-1',
      title: 'Room Approved',
      body: 'Your AI Club chatroom request has been approved!',
      category: 'chatroom_approved',
      timestamp: DateTime.now(),
      isRead: false,
    ),
  ];

  final StreamController<List<NotificationItem>> _controller =
      StreamController<List<NotificationItem>>.broadcast();

  @override
  Future<List<NotificationItem>> fetchNotifications(String userId) async {
    return notifs;
  }

  @override
  Stream<List<NotificationItem>> streamNotifications(String userId) {
    return _controller.stream;
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < notifs.length; i++) {
      notifs[i] = notifs[i].copyWith(isRead: true);
    }
  }

  @override
  Future<List<UserDevice>> getUserDevices(String firebaseUid) async {
    return [
      UserDevice(
        id: 'dev-1',
        userId: firebaseUid,
        fcmToken: 'mock-fcm-token',
        platform: 'android',
        deviceName: 'Pixel 8',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('NotificationProvider Unit Tests', () {
    late MockNotificationRepository mockRepo;
    late NotificationProvider provider;

    setUp(() {
      mockRepo = MockNotificationRepository();
      provider = NotificationProvider(repository: mockRepo);
    });

    tearDown(() {
      mockRepo.dispose();
      provider.dispose();
    });

    test('loadNotifications fetches unread alerts for student', () async {
      await provider.loadNotifications('student-1');

      expect(provider.isLoading, isFalse);
      expect(provider.notifications.length, equals(1));
      expect(provider.notifications.first.title, equals('Room Approved'));
      expect(provider.notifications.first.isRead, isFalse);
    });

    test('markAllRead marks all user notifications as read in state', () async {
      await provider.loadNotifications('student-1');
      await provider.markAllRead('student-1');

      expect(provider.notifications.every((n) => n.isRead), isTrue);
    });

    test('fetchUserDevices retrieves active push targets', () async {
      final devices = await provider.fetchUserDevices('student-1');

      expect(devices.length, equals(1));
      expect(devices.first.deviceName, equals('Pixel 8'));
    });
  });
}
