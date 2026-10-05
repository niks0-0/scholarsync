import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:scholarsync/features/academic_catalog/presentation/academic_catalog_provider.dart';
import 'package:scholarsync/features/attendance/presentation/attendance_provider.dart';
import 'package:scholarsync/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:scholarsync/features/auth/auth_provider.dart';
import 'package:scholarsync/features/timetable/presentation/timetable_provider.dart';
import 'attendance_provider_test.dart';

void main() {
  testWidgets('AttendanceScreen renders without layout/paint errors', (tester) async {
    final mockRepo = MockAttendanceRepository();
    final attProvider = AttendanceProvider(repository: mockRepo);
    await attProvider.loadAttendance('test-user');

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ChangeNotifierProvider<AttendanceProvider>.value(value: attProvider),
          ChangeNotifierProvider<TimetableProvider>(create: (_) => TimetableProvider()),
          ChangeNotifierProvider<AcademicCatalogProvider>(create: (_) => AcademicCatalogProvider()),
        ],
        child: const MaterialApp(
          home: AttendanceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Attendance Tracker'), findsOneWidget);
    expect(find.text('Attendance Satisfied'), findsWidgets);
  });
}
