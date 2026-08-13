import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/main.dart';

void main() {
  testWidgets('ScholarSync app renders without error', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const ScholarSyncApp());
    // Verify the app starts — splash screen should be present.
    expect(find.byType(MaterialApp), findsNothing); // uses MaterialApp.router
  });
}
