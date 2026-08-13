import 'package:flutter/foundation.dart';
import '../../../core/services/notification_service.dart';
import '../data/repositories/supabase_notification_repository.dart';
import '../domain/models/user_device.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? const SupabaseNotificationRepository();

  final NotificationRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<UserDevice> _userDevices = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserDevice> get userDevices => _userDevices;
  String? get currentFcmToken => NotificationService.instance.currentFcmToken;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Syncs FCM registration token for [firebaseUid] to Supabase `user_devices`.
  Future<void> syncDeviceToken(String firebaseUid) async {
    _setLoading(true);
    _setError(null);
    try {
      await NotificationService.instance.syncTokenToSupabase(firebaseUid);
      await fetchUserDevices(firebaseUid);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sync FCM token: $e');
      _setLoading(false);
    }
  }

  /// Fetches all registered device records for [firebaseUid] from Supabase.
  Future<List<UserDevice>> fetchUserDevices(String firebaseUid) async {
    try {
      final devices = await _repository.getUserDevices(firebaseUid);
      _userDevices = devices;
      notifyListeners();
      return devices;
    } catch (e) {
      debugPrint('NotificationProvider.fetchUserDevices error: $e');
      return [];
    }
  }

  /// Removes current device token from Supabase on sign out.
  Future<void> unregisterCurrentDevice(String firebaseUid) async {
    try {
      await NotificationService.instance.unregisterCurrentDeviceToken(firebaseUid);
      _userDevices.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationProvider.unregisterCurrentDevice error: $e');
    }
  }

  void clear() {
    _userDevices.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
