import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/core/config/app_config_provider.dart';

void main() {
  group('AppConfigProvider Tests', () {
    test('Default requireEmailVerification is false for Fast Testing Mode', () {
      final provider = AppConfigProvider();
      expect(provider.requireEmailVerification, isFalse);
    });

    test('setRequireEmailVerification updates state locally', () async {
      final provider = AppConfigProvider();

      expect(provider.requireEmailVerification, isFalse);

      // setRequireEmailVerification calls Supabase, which fails silently in test environment, but updates local state
      await provider.setRequireEmailVerification(true);

      expect(provider.requireEmailVerification, isTrue);
    });
  });
}
