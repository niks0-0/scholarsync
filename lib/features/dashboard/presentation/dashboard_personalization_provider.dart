import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_widget_registry.dart';

class DashboardPersonalizationProvider extends ChangeNotifier {
  DashboardPersonalizationProvider() {
    _loadPreferences();
  }

  static const String _activeKey = 'scholarsync_dashboard_active_widgets';
  static const String _pinnedKey = 'scholarsync_dashboard_pinned_widgets';
  static const String _hiddenKey = 'scholarsync_dashboard_hidden_widgets';

  List<String> _activeWidgetIds = List.from(DashboardWidgetRegistry.defaultOrder);
  Set<String> _pinnedWidgetIds = {};
  Set<String> _hiddenWidgetIds = {};

  bool _isEditMode = false;
  bool _isInitialized = false;

  List<String> get activeWidgetIds => _activeWidgetIds;
  Set<String> get pinnedWidgetIds => _pinnedWidgetIds;
  Set<String> get hiddenWidgetIds => _hiddenWidgetIds;
  bool get isEditMode => _isEditMode;
  bool get isInitialized => _isInitialized;

  /// Ordered widget IDs to render on the Home Dashboard (pinned first, then active unpinned).
  List<String> get displayWidgetIds {
    final pinned = _activeWidgetIds.where((id) => _pinnedWidgetIds.contains(id) && !_hiddenWidgetIds.contains(id)).toList();
    final unpinned = _activeWidgetIds.where((id) => !_pinnedWidgetIds.contains(id) && !_hiddenWidgetIds.contains(id)).toList();
    return [...pinned, ...unpinned];
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeStr = prefs.getString(_activeKey);
      final pinnedStr = prefs.getString(_pinnedKey);
      final hiddenStr = prefs.getString(_hiddenKey);

      if (activeStr != null) {
        final List<dynamic> decoded = jsonDecode(activeStr);
        _activeWidgetIds = decoded.cast<String>();
      }
      if (pinnedStr != null) {
        final List<dynamic> decoded = jsonDecode(pinnedStr);
        _pinnedWidgetIds = decoded.cast<String>().toSet();
      }
      if (hiddenStr != null) {
        final List<dynamic> decoded = jsonDecode(hiddenStr);
        _hiddenWidgetIds = decoded.cast<String>().toSet();
      }
    } catch (e) {
      debugPrint('Error loading dashboard layout preferences: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeKey, jsonEncode(_activeWidgetIds));
      await prefs.setString(_pinnedKey, jsonEncode(_pinnedWidgetIds.toList()));
      await prefs.setString(_hiddenKey, jsonEncode(_hiddenWidgetIds.toList()));
    } catch (e) {
      debugPrint('Error saving dashboard layout preferences: $e');
    }
  }

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  void setEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
  }

  void reorderWidgets(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _activeWidgetIds.removeAt(oldIndex);
    _activeWidgetIds.insert(newIndex, item);
    _savePreferences();
    notifyListeners();
  }

  void togglePinWidget(String widgetId) {
    if (_pinnedWidgetIds.contains(widgetId)) {
      _pinnedWidgetIds.remove(widgetId);
    } else {
      _pinnedWidgetIds.add(widgetId);
    }
    _savePreferences();
    notifyListeners();
  }

  void hideWidget(String widgetId) {
    _hiddenWidgetIds.add(widgetId);
    _savePreferences();
    notifyListeners();
  }

  void showWidget(String widgetId) {
    _hiddenWidgetIds.remove(widgetId);
    _savePreferences();
    notifyListeners();
  }

  void resetToDefaultLayout() {
    _activeWidgetIds = List.from(DashboardWidgetRegistry.defaultOrder);
    _pinnedWidgetIds.clear();
    _hiddenWidgetIds.clear();
    _savePreferences();
    notifyListeners();
  }
}
