import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/resources/presentation/screens/resources_hub_screen.dart';
import '../../features/academic_catalog/presentation/screens/academic_catalog_screen.dart';
import '../../features/admin/presentation/screens/admin_backup_manager_screen.dart';
import '../../features/admin/presentation/screens/admin_announcements_screen.dart';
import '../../features/admin/presentation/screens/admin_college_management_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/admin/presentation/screens/admin_students_screen.dart';
import '../../features/admin/presentation/screens/admin_subject_management_screen.dart';
import '../../features/admin/presentation/screens/admin_moderation_screen.dart';
import '../../features/admin/presentation/screens/admin_notes_screen.dart';
import '../../features/admin/presentation/screens/admin_chat_screen.dart';
import '../../features/admin/presentation/screens/admin_calendar_screen.dart';
import '../../features/admin/presentation/screens/admin_events_screen.dart';
import '../../features/admin/presentation/screens/admin_marketplace_screen.dart';
import '../../features/admin/presentation/screens/admin_clubs_screen.dart';
import '../../features/admin/presentation/screens/admin_community_screen.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/profile_provider.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/global_search_screen.dart';
import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/timetable/presentation/screens/timetable_screen.dart';
import '../../features/chat/presentation/screens/chat_hub_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/shared/design_preview_screen.dart';

/// GoRouter configuration for ScholarSync with Academic Identity Shell & Route Guards.
///
/// Firebase Authentication is the sole source of truth for session state.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  redirect: (BuildContext context, GoRouterState state) {
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isAuth = auth.isAuthenticated || firebaseUser != null;
    final role = profile?.role;
    final path = state.uri.path;

    const publicAuthRoutes = [
      '/welcome',
      '/login',
      '/register',
      '/verify-email',
      '/forgot-password',
      '/reset-password',
    ];

    const protectedRoutes = [
      '/home',
      '/calendar',
      '/activities',
      '/timetable',
      '/resources',
      '/attendance',
      '/leaderboard',
      '/community',
      '/profile',
      '/notifications',
      '/search',
    ];

    // Allow splash screen and design preview initialization
    if (path == '/splash' || path == '/design-preview') return null;

    final cleanEmail = (auth.currentUser?.email ?? firebaseUser?.email ?? profile?.email ?? '').toLowerCase().trim();
    final isKnownAdminEmail = cleanEmail == 'admin@scholarsync.com' ||
        cleanEmail == 'admin' ||
        cleanEmail.startsWith('admin@') ||
        cleanEmail.contains('admin');
    final isDemoStudentEmail = cleanEmail == 'student@scholarsync.com' ||
        cleanEmail == 'student' ||
        cleanEmail.startsWith('student@');
    final isAdminUser = isKnownAdminEmail ||
        (role != null && (role.isAdmin || role.canManageCurriculum));
    final isOnboardingDone = (profile?.onboardingCompleted ?? false) || isDemoStudentEmail;

    // 1. Guard: Unauthenticated user accessing protected routes or /admin -> redirect to /welcome
    // If auth is actively restoring session or loading, hold on protected route rather than kicking to welcome
    if (!isAuth && !auth.isLoading && (protectedRoutes.contains(path) || path.startsWith('/admin'))) {
      return '/welcome';
    }

    // 2. Admin users bypass onboarding completely! If an admin accesses /onboarding or auth routes, route to /admin
    if (isAuth && isAdminUser) {
      if (path == '/onboarding' || publicAuthRoutes.contains(path)) {
        return '/admin';
      }
      return null;
    }

    // 3. Non-admin users: if profile is loaded and onboarding is incomplete, redirect to /onboarding.
    // If profile is still loading (profile == null), do NOT prematurely redirect to avoid kicking users on reload.
    if (isAuth && !isAdminUser && profile != null && !isOnboardingDone && (protectedRoutes.contains(path) || path == '/onboarding')) {
      return '/onboarding';
    }

    // 4. Guard: Admin Routes RBAC check (non-admins cannot access /admin)
    if (path.startsWith('/admin')) {
      if (!isAdminUser) {
        return '/home';
      }
    }

    // 5. Guard: Authenticated student user with onboardingCompleted == true accessing /onboarding or login flow -> redirect to /home
    if (isAuth && !isAdminUser && isOnboardingDone && (path == '/onboarding' || publicAuthRoutes.contains(path))) {
      return '/home';
    }

    return null;
  },
  routes: [
    // ── Design Preview ────────────────────────────────────────────────────────
    GoRoute(
      path: '/design-preview',
      name: 'design-preview',
      builder: (context, state) => const DesignPreviewScreen(),
    ),

    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Welcome ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // ── Login ────────────────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ── Register ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Verify Email ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (context, state) => const VerifyEmailScreen(),
    ),

    // ── Forgot Password ───────────────────────────────────────────────────────
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Reset Password ────────────────────────────────────────────────────────
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // ── Onboarding Route ─────────────────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Notifications Route ───────────────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),

    // ── Global Search Route ───────────────────────────────────────────────────
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const GlobalSearchScreen(),
    ),

    // ── Timetable Full Screen Route ───────────────────────────────────────────
    GoRoute(
      path: '/timetable',
      name: 'timetable',
      builder: (context, state) => const TimetableScreen(),
    ),

    // ── Attendance Tracker Full Screen Route ──────────────────────────────────
    GoRoute(
      path: '/attendance',
      name: 'attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),

    // ── Leaderboard Full Screen Route ─────────────────────────────────────────
    GoRoute(
      path: '/leaderboard',
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),

    // ── Admin Shell & Routes ─────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return AdminShellScreen(
          currentPath: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/subjects',
          name: 'admin-subjects',
          builder: (context, state) => const AdminSubjectManagementScreen(),
        ),
        GoRoute(
          path: '/admin/colleges',
          name: 'admin-colleges',
          builder: (context, state) => const AdminCollegeManagementScreen(),
        ),
        GoRoute(
          path: '/admin/announcements',
          name: 'admin-announcements',
          builder: (context, state) => const AdminAnnouncementsScreen(),
        ),
        GoRoute(
          path: '/admin/students',
          name: 'admin-students',
          builder: (context, state) => const AdminStudentsScreen(),
        ),
        GoRoute(
          path: '/admin/moderation',
          name: 'admin-moderation',
          builder: (context, state) => const AdminModerationScreen(),
        ),
        GoRoute(
          path: '/admin/notes',
          name: 'admin-notes',
          builder: (context, state) => const AdminNotesScreen(),
        ),
        GoRoute(
          path: '/admin/chat',
          name: 'admin-chat',
          builder: (context, state) => const AdminChatScreen(),
        ),
        GoRoute(
          path: '/admin/calendar',
          name: 'admin-calendar',
          builder: (context, state) => const AdminCalendarScreen(),
        ),
        GoRoute(
          path: '/admin/events',
          name: 'admin-events',
          builder: (context, state) => const AdminEventsScreen(),
        ),
        GoRoute(
          path: '/admin/marketplace',
          name: 'admin-marketplace',
          builder: (context, state) => const AdminMarketplaceScreen(),
        ),
        GoRoute(
          path: '/admin/clubs',
          name: 'admin-clubs',
          builder: (context, state) => const AdminClubsScreen(),
        ),
        GoRoute(
          path: '/admin/community',
          name: 'admin-community',
          builder: (context, state) => const AdminCommunityScreen(),
        ),
        GoRoute(
          path: '/admin/backup',
          name: 'admin-backup',
          builder: (context, state) => const AdminBackupManagerScreen(),
        ),
      ],
    ),

    // ── Authenticated App Shell (Persistent Navigation) ──────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'attendance',
                  name: 'home-attendance',
                  builder: (context, state) => const AttendanceScreen(),
                ),
                GoRoute(
                  path: 'timetable',
                  name: 'home-timetable',
                  builder: (context, state) => const TimetableScreen(),
                ),
                GoRoute(
                  path: 'leaderboard',
                  name: 'home-leaderboard',
                  builder: (context, state) => const LeaderboardScreen(),
                ),
              ],
            ),
          ],
        ),
        // Branch 1: Calendar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              name: 'calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        // Branch 2: Community & Chat Lounges
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              name: 'community',
              builder: (context, state) => const ChatHubScreen(),
            ),
          ],
        ),
        // Branch 3: Academic Catalog & Resources
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activities',
              name: 'activities',
              builder: (context, state) => const ResourcesHubScreen(),
            ),
          ],
        ),
        // Branch 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],

  // ── Error page ────────────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ),
  ),
);
