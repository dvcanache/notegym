# NoteGym — Estructura Técnica y Hoja de Ruta

## Mapeo de carpetas

```
lib/
├── main.dart                          # Entry point, ProviderScope, MaterialApp.router + SyncService init
├── firebase_options.dart              # FlutterFire CLI
├── core/
│   ├── router.dart                    # GoRouter + AuthGate + TenantGate + refreshListenable
│   ├── storage_service.dart           # Wrapper SharedPreferences con prefijo notegym:
│   ├── theme.dart                     # AppTheme (light/dark) — tokens de diseño
│   ├── theme_extension.dart           # AppColorsExtension
│   ├── theme_provider.dart            # ThemeModeNotifier (Riverpod)
│   ├── database/
│   │   └── database_helper.dart       # SQLite singleton — users, workouts, set_logs, assessments
│   └── services/
│       ├── sync_service.dart          # Connectivity listener + Firestore batch sync
│       └── recommendation_engine.dart # Motor determinista de progresión (RIR + wellness)
├── data/
│   └── default_routines.dart          # 8 rutinas precargadas
├── models/
│   ├── exercise.dart                  # Ejercicio (id, nombre, grupo muscular, etc.)
│   ├── gym.dart                       # Gimnasio (id, name, slug, address, createdBy, createdAt)
│   ├── routine.dart                   # Rutina (id, nombre, ejercicios, etc.)
│   ├── user_profile.dart              # Perfil de usuario (incluye tenantId)
│   ├── workout_log.dart               # Historial de entrenamiento (sets, volumen, etc.)
│   ├── assessment.dart                # Assessment con wellnessScore
│   └── recommendation_result.dart     # RecommendationResult + ProgressionAction enum
├── widgets/
│   ├── app_shell.dart                 # ShellRoute + BottomNavigationBar
│   ├── glass_card.dart                # Glassmorphism card
│   └── gradient_button.dart           # GradientButton + OutlinedGlassButton
└── features/
    ├── auth/
    │   ├── login_screen.dart          # Login con formulario local + botón Google
    │   ├── register_screen.dart       # Registro con soporte gymSlug param
    │   ├── auth_provider.dart         # AuthNotifier (SharedPreferences)
    │   └── presentation/providers/
    │       └── auth_provider.dart     # Firebase Auth + AuthController + mock + gymSlug
    ├── home/
    │   └── home_screen.dart           # Dashboard (stats, week tracker, quick-start)
    ├── routines/
    │   ├── routines_screen.dart       # Lista de rutinas (default / custom)
    │   ├── routine_detail_screen.dart # Detalle + "Iniciar Entrenamiento"
    │   ├── create_routine_screen.dart # Crear/editar rutina
    │   ├── routines_provider.dart     # RoutinesNotifier (SharedPreferences)
    │   └── excel/
    │       ├── excel_import_service.dart
    │       └── excel_export_service.dart
    ├── workout/
    │   ├── active_workout_screen.dart # Timer, sets, descanso, RIR selector, SQLite persistence
    │   ├── workout_complete_screen.dart
    │   └── workout_logs_provider.dart # WorkoutLogsNotifier (SharedPreferences)
    ├── tenant/
    │   ├── gym_service.dart           # Firestore CRUD para colección gyms
    │   ├── tenant_provider.dart       # TenantNotifier (SharedPreferences + Firestore sync)
    │   └── join_screen.dart           # Selección de gimnasio con buscador + slug manual
    ├── assessment/
    │   └── presentation/
    │       └── assessment_screen.dart # Check-in diario de bienestar
    ├── onboarding/
    │   ├── onboarding_screen.dart
    │   └── onboarding_provider.dart
    ├── history/
    │   └── history_screen.dart        # Historial agrupado por semana
    ├── progress/
    │   └── progress_screen.dart       # Gráficos (frecuencia, volumen, PRs)
    └── profile/
        └── profile_screen.dart        # Perfil, tema, cerrar sesión
```

## Providers principales

| Provider | Archivo | Dependencias |
|----------|---------|-------------|
| `authProvider` | `features/auth/auth_provider.dart` | `SharedPreferences` |
| `firebaseAuthProvider` | `features/auth/presentation/providers/auth_provider.dart` | `FirebaseAuth.instance` |
| `authStateProvider` | ídem | `firebaseAuthProvider` |
| `authControllerProvider` | ídem | `firebaseAuthProvider`, `authProvider`, `cloud_firestore`, `tenantProvider` |
| `routerProvider` | `core/router.dart` | `authProvider`, `authStateProvider`, `tenantProvider`, `onboardingProvider` |
| `tenantProvider` | `features/tenant/tenant_provider.dart` | `SharedPreferences`, `cloud_firestore`, `authProvider` |
| `onboardingProvider` | `features/onboarding/onboarding_provider.dart` | `authProvider`, `StorageService`, `cloud_firestore` |
| `themeModeProvider` | `core/theme_provider.dart` | `SharedPreferences` |

## Hoja de ruta

### Pasos completados

1. ✅ **TenantGate** — Guard de navegación para selección/asignación de gimnasio.
2. ✅ **OnboardingGate** — Guard para completar datos iniciales del perfil.
3. ✅ **Race condition guards** — `isInitialized` flag en TenantState y OnboardingState.
4. ✅ **Anti-bucle entre `/onboarding` y `/join`** — Guards que se anulan mutuamente.
5. ✅ **Refresco de providers al login** — `AuthController._refreshOnboardingAndTenant()`.
6. ✅ **Firma Release Android** — Keystore, key.properties, signingConfigs en build.gradle.kts.
7. ✅ **SQLite local (`DatabaseHelper`)** — 4 tablas, Foreign Keys, clearLocalData(), getUnsynced/markSynced.
8. ✅ **SyncService offline→online** — connectivity_plus listener, Firestore WriteBatch, multi-tenant.
9. ✅ **RIR Capture en Entreno Activo** — Selector 0-5 con color coding, persistencia SQLite por set.
10. ✅ **RecommendationEngine** — Motor determinista de progresión (RIR + wellness → Increment/Maintain/Deload).
11. ✅ **Light Theme refinado** — Colores corregidos: sin blanco puro chillón, textos legibles (WCAG), cards con relleno sólido.
12. ✅ **Logout resiliente** — signOut() con try/catch por paso, garantiza limpieza local siempre.

### Pendientes / Próximos pasos

13. **Pantallas internas de `/home`** — Dashboard con:
    - Resumen del entrenamiento del día
    - Racha semanal
    - Rutinas recomendadas / recientes
    - Quick-start de rutina favorita
14. **Sincronización bidireccional** — Pull desde Firestore al reconectar (no solo push).
15. **UX Offline** — Indicador visual de estado de conexión, cola de pendientes.
