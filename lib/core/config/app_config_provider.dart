import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

/// Provider for global application dynamic settings and feature flags.
class AppConfigProvider extends ChangeNotifier {
  AppConfigProvider() {
    _loadSettings();
  }

  bool _requireEmailVerification = false;
  bool _isLoading = false;

  /// True if email verification is enforced before entering the app.
  /// When FALSE (Fast Testing Mode), registration bypasses verification & enters DB/app instantly.
  bool get requireEmailVerification => _requireEmailVerification;
  bool get isLoading => _isLoading;

  /// Fetch initial settings from Supabase `public.app_settings`.
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = SupabaseService.instance.client;
      final res = await client
          .from('app_settings')
          .select('value')
          .eq('key', 'require_email_verification')
          .maybeSingle();

      if (res != null && res['value'] != null) {
        final val = res['value'];
        if (val is bool) {
          _requireEmailVerification = val;
        } else if (val is String) {
          _requireEmailVerification = val.toLowerCase() == 'true';
        }
      }
    } catch (e) {
      debugPrint('AppConfigProvider: Error loading app settings (using default false): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle or update email verification requirement setting (Admin only).
  Future<bool> setRequireEmailVerification(bool value) async {
    _requireEmailVerification = value;
    notifyListeners();

    try {
      final client = SupabaseService.instance.client;
      await client.from('app_settings').upsert({
        'key': 'require_email_verification',
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('AppConfigProvider: Error updating require_email_verification: $e');
      return false;
    }
  }

  /// Manually refresh config.
  Future<void> refreshConfig() => _loadSettings();
}
