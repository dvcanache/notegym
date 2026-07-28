# NoteGym — Estructura Técnica y Hoja de Ruta

## Mapeo de carpetas

```
lib/
├── main.dart                          # Entry point, ProviderScope, MaterialApp.router
├── firebase_options.dart              # FlutterFire CLI
├── core/
│   ├── router.dart                    # GoRouter + AuthGate + refreshListenable
│   ├── theme.dart                     # AppTheme (light/dark)
│   ├── theme_extension.dart           # AppColorsExtension
│   └── theme_provider.dart            # ThemeModeNotifier (Riverpod)
├── data/
│   └── default_routines.dart          # 8 rutinas precargadas
├── models/
│   ├── exercise.dart                  # Ejercicio (id, nombre, grupo muscular, etc.)
│   ├── routine.dart                   # Rutina (id, nombre, ejercicios, etc.)
│   ├── user_profile.dart              # Perfil de usuario (nombre, email, streak, etc.)
│   └── workout_log.dart               # Historial de entrenamiento (sets, volumen, etc.)
├── widgets/
│   ├── app_shell.dart                 # ShellRoute + BottomNavigationBar
│   ├── glass_card.dart                # Glassmorphism card
│   └── gradient_button.dart           # GradientButton + OutlinedGlassButton
└── features/
    ├── auth/
    │   ├── login_screen.dart          # Login con formulario local + botón Google
    │   ├── auth_provider.dart         # AuthNotifier (SharedPreferences)
    │   └── presentation/providers/
    │       └── auth_provider.dart     # Firebase Auth + AuthController + mock
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
    │   ├── active_workout_screen.dart # Timer, sets, descanso
    │   ├── workout_complete_screen.dart
    │   └── workout_logs_provider.dart # WorkoutLogsNotifier (SharedPreferences)
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
| `authControllerProvider` | ídem | `firebaseAuthProvider`, `authProvider`, `cloud_firestore` |
| `routerProvider` | `core/router.dart` | `authProvider`, `authStateProvider` |
| `themeModeProvider` | `core/theme_provider.dart` | `SharedPreferences` |

## Hoja de ruta

### Próximos pasos técnicos

1. **TenantGate** — Implementar guard de navegación para selección/asignación de gimnasio (tenant). Requiere:
   - Modelo `Tenant` en `lib/models/`.
   - Provider `tenantProvider`.
   - Ruta `/select-tenant`.
   - Activar `_tenantGuard` en `router.dart`.

2. **OnboardingGate** — Implementar guard para completar datos iniciales del perfil (cédula, peso, altura, objetivo). Requiere:
   - Ruta `/onboarding`.
   - Provider `onboardingProvider`.
   - Activar `_onboardingGuard` en `router.dart`.

3. **Pantallas internas de `/home`** — Desarrollar el dashboard con:
   - Resumen del entrenamiento del día.
   - Racha semanal.
   - Rutinas recomendadas / recientes.
   - Quick-start de rutina favorita.
