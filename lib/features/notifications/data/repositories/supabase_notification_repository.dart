import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/user_device.dart';
import '../../domain/repositories/notification_repository.dart';
import 'package:scholarsync/features/notifications/presentation/notification_provider.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  const SupabaseNotificationRepository();

  static const String _devicesTable = 'user_devices';
  static const String _notificationsTable = 'notifications';

  @override
  Future<UserDevice> registerDeviceToken({
    required String firebaseUid,
    required String fcmToken,
    required String platform,
    String? deviceName,
  }) async {
    try {
      final payload = {
        'user_id': firebaseUid,
        'fcm_token': fcmToken,
        'platform': platform,
        'device_name': deviceName,
        'last_seen_at': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseService.instance.client
          .from(_devicesTable)
          .upsert(
            payload,
            onConflict: 'user_id,fcm_token',
          )
          .select()
          .single();

      return UserDevice.fromJson(response);
    } catch (e) {
      debugPrint('SupabaseNotificationRepository.registerDeviceToken error: $e');
      rethrow;
    }
  }

  @override
  Future<void> unregisterDeviceToken({
    required String firebaseUid,
    required String fcmToken,
  }) async {
    try {
      await SupabaseService.instance.client
          .from(_devicesTable)
          .delete()
          .eq('user_id', firebaseUid)
          .eq('fcm_token', fcmToken);
    } catch (e) {
      debugPrint('SupabaseNotificationRepository.unregisterDeviceToken error: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserDevice>> getUserDevices(String firebaseUid) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_devicesTable)
          .select()
          .eq('user_id', firebaseUid);

      return (response as List)
          .map((json) => UserDevice.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SupabaseNotificationRepository.getUserDevices error: $e');
      return [];
    }
  }

  Future<List<NotificationItem>> fetchNotifications(String userId) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      if (response is List) {
        return response.map((data) {
          final m = data as Map<String, dynamic>;
          return NotificationItem(
            id: m['id']?.toString() ?? '',
            title: m['title']?.toString() ?? 'Notification',
            body: m['body']?.toString() ?? '',
            category: m['module']?.toString() ?? 'General',
            timestamp: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
            isRead: (m['is_read'] as bool?) ?? false,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching notifications from Supabase: $e');
      return [];
    }
  }

  Stream<List<NotificationItem>> streamNotifications(String userId) {
    return SupabaseService.instance.client
        .from(_notificationsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((records) => records.map((m) {
              return NotificationItem(
                id: m['id']?.toString() ?? '',
                title: m['title']?.toString() ?? 'Notification',
                body: m['body']?.toString() ?? '',
                category: m['module']?.toString() ?? 'General',
                timestamp: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
                isRead: (m['is_read'] as bool?) ?? false,
              );
            }).toList());
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await SupabaseService.instance.client
          .from(_notificationsTable)
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error marking notifications read: $e');
    }
  }
}
