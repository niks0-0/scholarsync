import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ScholarSync widget Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('ScholarSync'),
          ),
        ),
      ),
    );
    expect(find.text('ScholarSync'), findsOneWidget);
  });
}
