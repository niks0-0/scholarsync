import 'package:flutter/material.dart';

/// Notifier that manages the app's [ThemeMode].
/// Use [Provider] or [ChangeNotifierProvider] to expose this.
class ThemeService extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;
  bool get isLight => _mode == ThemeMode.light;
  bool get isSystem => _mode == ThemeMode.system;

  void setLight() {
    if (_mode != ThemeMode.light) {
      _mode = ThemeMode.light;
      notifyListeners();
    }
  }

  void setDark() {
    if (_mode != ThemeMode.dark) {
      _mode = ThemeMode.dark;
      notifyListeners();
    }
  }

  void setSystem() {
    if (_mode != ThemeMode.system) {
      _mode = ThemeMode.system;
      notifyListeners();
    }
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

