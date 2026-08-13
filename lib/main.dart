import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/firebase/firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/notifications/presentation/notification_provider.dart';
import 'features/profile/presentation/profile_provider.dart';
import 'features/storage/presentation/storage_provider.dart';

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

  runApp(const ScholarSyncApp());
}

class ScholarSyncApp extends StatelessWidget {
  const ScholarSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<StorageProvider>(
          create: (_) => StorageProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
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

      // ── Themes ────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeService.mode,

      // ── Routing ───────────────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}
