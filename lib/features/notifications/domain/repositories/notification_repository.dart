import '../models/user_device.dart';

/// Contract for FCM token persistence in Supabase `public.user_devices`.
abstract class NotificationRepository {
  /// Upserts the FCM token for the given [firebaseUid] into Supabase.
  /// Enforces unique (user_id, fcm_token) constraint.
  Future<UserDevice> registerDeviceToken({
    required String firebaseUid,
    required String fcmToken,
    required String platform,
    String? deviceName,
  });

  /// Deactivates/removes ONLY the specified [fcmToken] for [firebaseUid] on sign out.
  Future<void> unregisterDeviceToken({
    required String firebaseUid,
    required String fcmToken,
  });

  /// Retrieves all active registered device tokens for [firebaseUid].
  Future<List<UserDevice>> getUserDevices(String firebaseUid);
}
