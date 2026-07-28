import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/login_screen.dart';
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
import '../widgets/app_shell.dart';

// ──────────────────────────────────────────────
// AuthGate
//   - No autenticado → /login
//   - Autenticado en /login → /home
// ──────────────────────────────────────────────
String? _authGuard(GoRouterState state, bool isLoggedIn) {
  final isOnLogin = state.matchedLocation == '/login';
  if (!isLoggedIn && !isOnLogin) return '/login';
  if (isLoggedIn && isOnLogin) return '/home';
  return null;
}

// ──────────────────────────────────────────────
// TenantGate  (placeholder)
//   - Verificar suscripción / tenant activo
//   - Redirigir a /select-tenant si aplica
// ──────────────────────────────────────────────
// String? _tenantGuard(GoRouterState state) { ... }

// ──────────────────────────────────────────────
// OnboardingGate  (placeholder)
//   - Verificar si el perfil está completo
//   - Redirigir a /onboarding si aplica
// ──────────────────────────────────────────────
// String? _onboardingGuard(GoRouterState state) { ... }

/// Notificador externo para forzar a GoRouter a re-evaluar el redirect
/// cuando cambia el estado de autenticación.
final _routerRefreshNotifier = ValueNotifier(0);

final routerProvider = Provider<GoRouter>((ref) {
  final localAuth = ref.watch(authProvider);
  final firebaseUser = ref.watch(authStateProvider);

  final isLoggedIn =
      localAuth.isLoggedIn || firebaseUser.valueOrNull != null;

  final goRouter = GoRouter(
    refreshListenable: _routerRefreshNotifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final authRedirect = _authGuard(state, isLoggedIn);
      if (authRedirect != null) return authRedirect;
      // final tenantRedirect = _tenantGuard(state);
      // if (tenantRedirect != null) return tenantRedirect;
      // final onboardingRedirect = _onboardingGuard(state);
      // if (onboardingRedirect != null) return onboardingRedirect;
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
    errorBuilder: (context, state) => const Scaffold(
      backgroundColor: Color(0xFF0D0D1A),
      body: Center(
        child: Text(
          'Página no encontrada',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback(
    (_) => _routerRefreshNotifier.value++,
  );

  return goRouter;
});
