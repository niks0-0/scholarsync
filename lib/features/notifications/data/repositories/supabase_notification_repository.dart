import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/user_device.dart';
import '../../domain/repositories/notification_repository.dart';

/// Implementation of [NotificationRepository] using Supabase PostgREST.
///
/// Stores user device FCM registration tokens in `public.user_devices`.
/// Protected by RLS (`user_id = firebase_uid()`).
class SupabaseNotificationRepository implements NotificationRepository {
  const SupabaseNotificationRepository();

  static const String _tableName = 'user_devices';

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
          .from(_tableName)
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
          .from(_tableName)
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
          .from(_tableName)
          .select()
          .eq('user_id', firebaseUid);

      return (response as List)
          .map((json) => UserDevice.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SupabaseNotificationRepository.getUserDevices error: $e');
      rethrow;
    }
  }
}
