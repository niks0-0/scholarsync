import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/shared/placeholder_screen.dart';

/// GoRouter configuration for ScholarSync with Strict Session Route Guards.
///
/// Firebase Authentication is the sole source of truth for session state.
///
/// Public & Auth routes:
///   /splash, /welcome, /login, /register, /verify-email, /forgot-password, /reset-password
///
/// Protected routes:
///   /home, /calendar, /activities, /attendance, /community, /profile
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  redirect: (BuildContext context, GoRouterState state) {
    final auth = context.read<AuthProvider>();
    final isAuth = auth.isAuthenticated;
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
      '/attendance',
      '/community',
      '/profile',
    ];

    // Allow splash screen initialization
    if (path == '/splash') return null;

    // 1. Guard: Unauthenticated user accessing protected routes -> redirect to /welcome
    if (!isAuth && protectedRoutes.contains(path)) {
      return '/welcome';
    }

    // 2. Guard: Authenticated user accessing login/welcome flow -> redirect to /home
    if (isAuth && publicAuthRoutes.contains(path)) {
      return '/home';
    }

    return null;
  },
  routes: [
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

    // ── Protected Routes ──────────────────────────────────────────────────────
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const PlaceholderScreen(title: 'Home'),
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      builder: (context, state) => const PlaceholderScreen(title: 'Calendar'),
    ),
    GoRoute(
      path: '/activities',
      name: 'activities',
      builder: (context, state) => const PlaceholderScreen(title: 'Activities'),
    ),
    GoRoute(
      path: '/attendance',
      name: 'attendance',
      builder: (context, state) => const PlaceholderScreen(title: 'Attendance'),
    ),
    GoRoute(
      path: '/community',
      name: 'community',
      builder: (context, state) => const PlaceholderScreen(title: 'Community'),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
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
