import 'package:flutter/foundation.dart';
import '../../../core/services/notification_service.dart';
import '../data/repositories/supabase_notification_repository.dart';
import '../domain/models/user_device.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      category: category,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? const SupabaseNotificationRepository() {
    // Initial sample announcements & alerts
    _notifications = [
      NotificationItem(
        id: 'notif-1',
        title: 'Midterm Examination Schedule Released',
        body: 'The Spring term exam timetable is now published. Please check your academic portal.',
        category: 'Announcements',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: 'notif-2',
        title: 'Assignment Due Tomorrow: Data Structures',
        body: 'Submit your Binary Search Tree lab assignment before 11:59 PM.',
        category: 'Assignments',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationItem(
        id: 'notif-3',
        title: 'Attendance Warning Alert',
        body: 'Your attendance in Basic Electrical Engineering is currently at 68%. Maintain at least 75%.',
        category: 'Attendance',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  final NotificationRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<UserDevice> _userDevices = [];
  List<NotificationItem> _notifications = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserDevice> get userDevices => _userDevices;
  List<NotificationItem> get notifications => _notifications;
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

  void addNotificationItem(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void clear() {
    _userDevices.clear();
    _notifications.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
