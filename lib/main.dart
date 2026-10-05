import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/firebase/firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'features/academic_catalog/data/repositories/supabase_academic_catalog_repository.dart';
import 'features/academic_catalog/domain/repositories/academic_catalog_repository.dart';
import 'features/academic_catalog/presentation/academic_catalog_provider.dart';
import 'features/admin/data/repositories/resilient_admin_repository.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/admin_provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/dashboard/data/repositories/production_dashboard_repository.dart';
import 'features/dashboard/presentation/dashboard_personalization_provider.dart';
import 'features/dashboard/presentation/dashboard_provider.dart';
import 'features/notifications/presentation/notification_provider.dart';
import 'features/onboarding/presentation/onboarding_provider.dart';
import 'features/profile/data/repositories/supabase_profile_repository.dart';
import 'features/profile/domain/models/user_profile.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/profile_provider.dart';
import 'features/storage/presentation/storage_provider.dart';
import 'features/timetable/data/repositories/supabase_timetable_repository.dart';
import 'features/timetable/domain/repositories/timetable_repository.dart';
import 'features/timetable/presentation/timetable_provider.dart';
import 'features/calendar/data/repositories/supabase_calendar_repository.dart';
import 'features/calendar/domain/repositories/calendar_repository.dart';
import 'features/calendar/presentation/calendar_provider.dart';
import 'features/attendance/data/repositories/supabase_attendance_repository.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/presentation/attendance_provider.dart';
import 'features/chat/data/repositories/supabase_chat_repository.dart';
import 'features/chat/presentation/chat_provider.dart';
import 'features/resources/data/repositories/supabase_resources_repository.dart';
import 'features/resources/presentation/resources_provider.dart';
import 'features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'features/leaderboard/presentation/leaderboard_provider.dart';
import 'core/config/app_config_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase Core & Authentication
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  // 2. Initialize Supabase Client with Firebase ID Token Bridge
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Supabase initialization warning: $e');
  }

  // 3. Initialize Firebase Cloud Messaging (FCM) Notification Service
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('FCM NotificationService initialization warning: $e');
  }

  // 4. Pre-load profile quickly if user session is already cached synchronously
  UserProfile? initialProfile;
  try {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser != null) {
      initialProfile = await const SupabaseProfileRepository()
          .getProfile(currentFirebaseUser.uid)
          .timeout(const Duration(milliseconds: 600), onTimeout: () => null);
    }
  } catch (e) {
    debugPrint('Profile pre-load note: $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}\n${details.stack}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: SelectableText(
          '⚠️ UI Rendering Error:\n${details.exceptionAsString()}\n\nStack:\n${details.stack}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontFamily: 'monospace'),
        ),
      ),
    );
  };

  runApp(ScholarSyncApp(initialProfile: initialProfile));
}

class ScholarSyncApp extends StatelessWidget {
  const ScholarSyncApp({super.key, this.initialProfile});

  final UserProfile? initialProfile;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProfileRepository>(
          create: (_) => const SupabaseProfileRepository(),
        ),
        Provider<AcademicCatalogRepository>(
          create: (_) => const SupabaseAcademicCatalogRepository(),
        ),
        Provider<TimetableRepository>(
          create: (_) => const SupabaseTimetableRepository(),
        ),
        Provider<AdminRepository>(
          create: (_) => ResilientAdminRepository(),
        ),
        Provider<CalendarRepository>(
          create: (_) => const SupabaseCalendarRepository(),
        ),
        Provider<AttendanceRepository>(
          create: (_) => const SupabaseAttendanceRepository(),
        ),
        Provider<ChatRepository>(
          create: (_) => const SupabaseChatRepository(),
        ),
        Provider<ResourcesRepository>(
          create: (_) => const SupabaseResourcesRepository(),
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<AppConfigProvider>(
          create: (_) => AppConfigProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(initialProfile: initialProfile),
        ),
        ChangeNotifierProvider<StorageProvider>(
          create: (_) => StorageProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<OnboardingProvider>(
          create: (ctx) => OnboardingProvider(
            academicCatalogRepository: ctx.read<AcademicCatalogRepository>(),
          ),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (ctx) => DashboardProvider(
            repository: ProductionDashboardRepository(
              timetableRepository: ctx.read<TimetableRepository>(),
              attendanceRepository: ctx.read<AttendanceRepository>(),
              calendarRepository: ctx.read<CalendarRepository>(),
            ),
          ),
        ),
        ChangeNotifierProvider<DashboardPersonalizationProvider>(
          create: (_) => DashboardPersonalizationProvider(),
        ),
        ChangeNotifierProvider<AcademicCatalogProvider>(
          create: (_) => AcademicCatalogProvider(),
        ),
        ChangeNotifierProvider<TimetableProvider>(
          create: (_) => TimetableProvider(),
        ),
        ChangeNotifierProvider<CalendarProvider>(
          create: (_) => CalendarProvider(),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (ctx) => AttendanceProvider(
            repository: ctx.read<AttendanceRepository>(),
          ),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (ctx) => ChatProvider(
            repository: ctx.read<ChatRepository>(),
          ),
        ),
        ChangeNotifierProvider<ResourcesProvider>(
          create: (ctx) => ResourcesProvider(
            repository: ctx.read<ResourcesRepository>(),
          ),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (ctx) => AdminProvider(
            repository: ctx.read<AdminRepository>(),
          ),
        ),
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (_) => LeaderboardProvider(
            repository: SupabaseLeaderboardRepository(),
          ),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return MaterialApp.router(
      // ── App metadata ───────────────────────────────────────────────────────
      title: 'ScholarSync',
      debugShowCheckedModeBanner: false,

      // ── Drag & Click-to-Scroll on Web / Desktop ────────────────────────────
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),

      // ── Themes ────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeService.mode,

      // ── Routing ───────────────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}