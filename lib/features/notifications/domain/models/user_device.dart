/// Represents a user's device registration record in Supabase `public.user_devices`.
class UserDevice {
  const UserDevice({
    required this.id,
    required this.userId,
    required this.fcmToken,
    this.platform = 'unknown',
    this.deviceName,
    this.createdAt,
    this.updatedAt,
    this.lastSeenAt,
  });

  final String id;
  final String userId; // Firebase Auth UID
  final String fcmToken;
  final String platform;
  final String? deviceName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSeenAt;

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fcmToken: json['fcm_token'] as String,
      platform: (json['platform'] as String?) ?? 'unknown',
      deviceName: json['device_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fcm_token': fcmToken,
      'platform': platform,
      'device_name': deviceName,
      'last_seen_at': DateTime.now().toIso8601String(),
    };
  }
}
