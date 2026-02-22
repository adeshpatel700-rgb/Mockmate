/// App Router — All navigation defined centrally using GoRouter.
///
/// WHY GOROUTER INSTEAD OF NAVIGATOR 2.0?
/// - Declarative URL-based routing (great for deep links)
/// - Built-in redirect support (perfect for auth guards)
/// - Works with BlocBuilder for reactive navigation
/// - Better for production apps than pushNamed/pop
///
/// HOW THE AUTH GUARD WORKS:
/// The [redirect] function runs before every navigation.
/// If the user isn't logged in and tries to access a protected route,
/// they get redirected to the login screen automatically.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockmate/core/constants/app_constants.dart';

// Splash screen
import 'package:mockmate/features/splash/presentation/splash_screen.dart';

// Auth screens
import 'package:mockmate/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:mockmate/features/auth/presentation/screens/login_screen.dart';
import 'package:mockmate/features/auth/presentation/screens/register_screen.dart';

// Interview screens
import 'package:mockmate/features/interview/presentation/screens/role_selection_screen.dart';
import 'package:mockmate/features/interview/presentation/screens/interview_screen.dart';
import 'package:mockmate/features/interview/presentation/screens/feedback_screen.dart';

// Dashboard screens
import 'package:mockmate/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mockmate/features/dashboard/presentation/screens/history_screen.dart';

// Named route constants — use these instead of string literals.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String roleSelection = '/interview/select';
  static const String interview = '/interview/session';
  static const String feedback = '/interview/feedback';
  static const String history = '/dashboard/history';
}

/// Builds and returns the configured [GoRouter] instance.
GoRouter buildRouter(FlutterSecureStorage secureStorage) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Auth Guard ─────────────────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) async {
      final token = await secureStorage.read(key: AppConstants.accessTokenKey);
      final isLoggedIn = token != null;

      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
      ];

      final isGoingToPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Not logged in → trying to access protected route → send to login
      if (!isLoggedIn && !isGoingToPublicRoute) {
        return AppRoutes.login;
      }

      // Logged in → trying to access auth screens → send to dashboard
      if (isLoggedIn && isGoingToPublicRoute) {
        return AppRoutes.dashboard;
      }

      // No redirect needed
      return null;
    },

    // ── Routes ────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.interview,
        name: 'interview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return InterviewScreen(
            role: extra?['role'] ?? 'Flutter Developer',
            difficulty: extra?['difficulty'] ?? 'Intermediate',
            questionCount: extra?['questionCount'] ?? 5,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.feedback,
        name: 'feedback',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return FeedbackScreen(
            sessionId: extra?['sessionId'] ?? '',
            score: extra?['score'] ?? 0,
            feedback: extra?['feedback'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],

    // ── Error Screen ──────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            TextButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
