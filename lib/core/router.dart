import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/routines/routines_screen.dart';
import '../features/routines/routine_detail_screen.dart';
import '../features/routines/create_routine_screen.dart';
import '../features/workout/active_workout_screen.dart';
import '../features/workout/workout_complete_screen.dart';
import '../features/history/history_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/tenant/tenant_provider.dart';
import '../features/tenant/join_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/onboarding_provider.dart';
import '../features/assessment/presentation/assessment_screen.dart';
import '../widgets/app_shell.dart';

String? _authGuard(GoRouterState state, bool isLoggedIn) {
  final isOnLogin = state.matchedLocation.startsWith('/login');
  if (!isLoggedIn && !isOnLogin) return '/login';
  if (isLoggedIn && isOnLogin) return '/home';
  return null;
}

String? _tenantGuard(GoRouterState state, TenantState tenantState) {
  if (tenantState.isLoading) return null;
  final isOnJoin = state.matchedLocation == '/join';
  if (!tenantState.hasTenant && !isOnJoin) return '/join';
  if (tenantState.hasTenant && isOnJoin) return '/home';
  return null;
}

String? _onboardingGuard(GoRouterState state, OnboardingState onboardingState) {
  if (onboardingState.isLoading) return null;
  final isOnOnboarding = state.matchedLocation == '/onboarding';
  if (!onboardingState.isCompleted && !isOnOnboarding) return '/onboarding';
  if (onboardingState.isCompleted && isOnOnboarding) return '/home';
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final goRouter = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final localAuth = ref.read(authProvider);
      final firebaseUser = ref.read(authStateProvider);
      final tenantState = ref.read(tenantProvider);
      final onboardingState = ref.read(onboardingProvider);

      final isLoggedIn =
          localAuth.isLoggedIn || firebaseUser.valueOrNull != null;

      if (state.matchedLocation == '/') {
        return isLoggedIn ? '/home' : '/login';
      }

      final authRedirect = _authGuard(state, isLoggedIn);
      if (authRedirect != null) return authRedirect;
      if (isLoggedIn) {
        final tenantRedirect = _tenantGuard(state, tenantState);
        if (tenantRedirect != null) return tenantRedirect;
        final onboardingRedirect = _onboardingGuard(state, onboardingState);
        if (onboardingRedirect != null) return onboardingRedirect;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'register/:gymSlug',
            builder: (context, state) {
              final slug = state.pathParameters['gymSlug'];
              return RegisterScreen(gymSlug: slug);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/assessment',
        builder: (context, state) => const AssessmentScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/routines',
            builder: (context, state) => const RoutinesScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final extra = state.extra as Map<String, dynamic>?;
                  return RoutineDetailScreen(
                    routineId: id,
                    extra: extra,
                  );
                },
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return CreateRoutineScreen(editingRoutineId: extra?['id']);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/workout/active',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ActiveWorkoutScreen(routineId: extra['routineId']);
        },
      ),
      GoRoute(
        path: '/workout/complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WorkoutCompleteScreen(logId: extra['logId']);
        },
      ),
    ],
    errorBuilder: (context, state) {
      debugPrint('[GoRouter 404] Ruta no encontrada: ${state.uri}');
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Página no encontrada',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Ruta: ${state.uri}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    },
  );

  ref.listen(authProvider, (_, __) => goRouter.refresh());
  ref.listen(authStateProvider, (_, __) => goRouter.refresh());
  ref.listen(tenantProvider, (_, __) => goRouter.refresh());
  ref.listen(onboardingProvider, (_, __) => goRouter.refresh());

  return goRouter;
});
