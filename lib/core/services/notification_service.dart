import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../features/notifications/data/repositories/supabase_notification_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM Background Message Received: ${message.messageId}');
}

/// Core NotificationService managing Firebase Cloud Messaging (FCM)
/// and token persistence in Supabase `public.user_devices`.
class NotificationService {
  NotificationService._({NotificationRepository? repository})
      : _repository = repository ?? const SupabaseNotificationRepository();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationRepository _repository;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  String? _currentFcmToken;
  bool _isInitialized = false;
  NotificationSettings? _settings;

  String? get currentFcmToken => _currentFcmToken;
  bool get isInitialized => _isInitialized;
  NotificationSettings? get settings => _settings;

  /// Initializes FCM listeners and requests notification permissions.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Set background messaging handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permission
    await requestPermission();

    // 3. Obtain initial FCM token
    await fetchFcmToken();

    // 4. Listen for token refresh
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) async {
      _currentFcmToken = newToken;
      debugPrint('FCM Token Refreshed: $newToken');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await syncTokenToSupabase(user.uid);
      }
    });

    // 5. Handle foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM Foreground Message: ${message.notification?.title} - ${message.notification?.body}');
    });

    // 6. Handle notification tap (app in background)
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM Notification Tapped (Background App): ${message.data}');
    });

    // 7. Handle initial message (app launched from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM Initial Message (Terminated App): ${initialMessage.data}');
    }

    _isInitialized = true;
    debugPrint('NotificationService initialized cleanly.');
  }

  /// Requests notification permission from user.
  Future<NotificationSettings> requestPermission() async {
    try {
      _settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('FCM Permission Status: ${_settings?.authorizationStatus}');
      return _settings!;
    } catch (e) {
      debugPrint('FCM Permission Error: $e');
      rethrow;
    }
  }

  /// Fetches the current FCM token for this device.
  Future<String?> fetchFcmToken() async {
    try {
      if (kIsWeb) {
        // Web requires VAPID key if configured, or default token fetch
        _currentFcmToken = await _messaging.getToken();
      } else {
        _currentFcmToken = await _messaging.getToken();
      }
      debugPrint('FCM Registration Token: $_currentFcmToken');
      return _currentFcmToken;
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
      return null;
    }
  }

  /// Stores/updates the current device's FCM token in Supabase `public.user_devices`.
  Future<void> syncTokenToSupabase(String firebaseUid) async {
    if (_currentFcmToken == null || _currentFcmToken!.isEmpty) {
      await fetchFcmToken();
    }
    if (_currentFcmToken == null || _currentFcmToken!.isEmpty) return;

    try {
      final platform = kIsWeb
          ? 'web'
          : defaultTargetPlatform.name;

      await _repository.registerDeviceToken(
        firebaseUid: firebaseUid,
        fcmToken: _currentFcmToken!,
        platform: platform,
        deviceName: 'Device (${defaultTargetPlatform.name})',
      );
      debugPrint('FCM Token synced to Supabase user_devices for UID: $firebaseUid');
    } catch (e) {
      debugPrint('Error syncing FCM token to Supabase: $e');
    }
  }

  /// Removes ONLY the current device's token from Supabase on sign out.
  Future<void> unregisterCurrentDeviceToken(String firebaseUid) async {
    if (_currentFcmToken == null || _currentFcmToken!.isEmpty) return;
    try {
      await _repository.unregisterDeviceToken(
        firebaseUid: firebaseUid,
        fcmToken: _currentFcmToken!,
      );
      debugPrint('Current device FCM Token removed from Supabase on sign out.');
    } catch (e) {
      debugPrint('Error unregistering current device FCM token: $e');
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
  }
}
