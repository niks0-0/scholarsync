import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarsync/features/dashboard/presentation/dashboard_personalization_provider.dart';
import 'package:scholarsync/features/dashboard/presentation/dashboard_widget_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardWidgetRegistry Tests', () {
    test('Registry contains all 10 summary widgets', () {
      final widgets = DashboardWidgetRegistry.allWidgets;
      expect(widgets.length, equals(10));
      expect(widgets.containsKey('greeting'), isTrue);
      expect(widgets.containsKey('today_classes'), isTrue);
      expect(widgets.containsKey('quick_actions'), isTrue);
      expect(widgets.containsKey('attendance_summary'), isTrue);
      expect(widgets.containsKey('assignments'), isTrue);
      expect(widgets.containsKey('calendar_preview'), isTrue);
      expect(widgets.containsKey('reminders'), isTrue);
      expect(widgets.containsKey('community_preview'), isTrue);
      expect(widgets.containsKey('announcements'), isTrue);
      expect(widgets.containsKey('compact_statistics'), isTrue);
    });

    test('getWidget returns correct config', () {
      final config = DashboardWidgetRegistry.getWidget('compact_statistics');
      expect(config, isNotNull);
      expect(config!.title, equals('Compact Statistics'));
    });
  });

  group('DashboardPersonalizationProvider Tests', () {
    late DashboardPersonalizationProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = DashboardPersonalizationProvider();
    });

    test('Initial active layout matches default order', () {
      expect(provider.activeWidgetIds, equals(DashboardWidgetRegistry.defaultOrder));
    });

    test('hideWidget removes widget from displayWidgetIds', () {
      provider.hideWidget('announcements');
      expect(provider.displayWidgetIds.contains('announcements'), isFalse);
      expect(provider.hiddenWidgetIds.contains('announcements'), isTrue);
    });

    test('showWidget restores widget to displayWidgetIds', () {
      provider.hideWidget('announcements');
      provider.showWidget('announcements');
      expect(provider.displayWidgetIds.contains('announcements'), isTrue);
    });

    test('togglePinWidget moves pinned widget to front of displayWidgetIds', () {
      provider.togglePinWidget('compact_statistics');
      expect(provider.displayWidgetIds.first, equals('compact_statistics'));
      expect(provider.pinnedWidgetIds.contains('compact_statistics'), isTrue);
    });

    test('resetToDefaultLayout clears pinned and hidden sets', () {
      provider.hideWidget('announcements');
      provider.togglePinWidget('compact_statistics');
      provider.resetToDefaultLayout();

      expect(provider.pinnedWidgetIds, isEmpty);
      expect(provider.hiddenWidgetIds, isEmpty);
      expect(provider.displayWidgetIds, equals(DashboardWidgetRegistry.defaultOrder));
    });
  });
}
