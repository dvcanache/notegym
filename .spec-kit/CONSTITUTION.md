# NoteGym — Reglas de Oro

## Principios inamovibles

- **Offline-first**: Toda funcionalidad crítica debe funcionar sin conexión. Firebase/Firestore es un canal de sincronización, no una dependencia obligatoria para la UX.
- **Persistencia triple**: SQLite (`sqflite`) para datos transaccionales offline, SharedPreferences para sesión/preferencias, Firestore para sincronización multi-dispositivo.
- **Arquitectura de capas limpia**: `lib/core/` para infraestructura transversal, `lib/features/{modulo}/` para cada dominio de negocio, `lib/models/` para modelos puros, `lib/widgets/` para componentes reutilizables de UI.
- **Riverpod** como única fuente de verdad para estado. Los providers se organizan por feature y se declaran con `Provider`, `StateNotifierProvider` o `StreamProvider` según corresponda.
- **GoRouter** para navegación declarativa con guards (gates) en el redirect.
- **SnakeCase** para nombres de archivo, **PascalCase** para clases, **camelCase** para variables y métodos.

## Autenticación

- El flujo real usa `google_sign_in 7.x` + `firebase_auth` + `cloud_firestore`.
- En **Windows (desarrollo local)** se usa un mock automático: si `GoogleSignIn.instance.authenticate()` lanza cualquier error no-recuperable (categoría `catch (e, _)`), se ejecuta `_simulateGoogleSignIn()` que crea un usuario de prueba (`uid: google_mock_001`). Este fallback **no debe romperse ni eliminarse** mientras no exista configuración nativa de Google Sign-In para Windows.
- El mock persiste en SharedPreferences mediante `authProvider.notifier.signInWithProfile()`, por lo que la sesión sobrevive a reinicios de la app.

## SignOut resiliente

- `AuthController.signOut()` debe ejecutar **siempre** el cleanup local, independientemente de si Firebase Auth falla o no.
- Cada paso (SyncService, SQLite, Google, Firebase, SharedPreferences) tiene su propio `try/catch`.
- `authProvider.notifier.signOut()` (limpia el estado local y SharedPreferences) debe ser la última operación y ejecutarse siempre.

## Base de datos SQLite

- `DatabaseHelper` es singleton. Usar `DatabaseHelper.instance` en toda la app.
- Foreign Keys habilitados en `onConfigure` via `PRAGMA foreign_keys = ON`.
- Las tablas locales reflejan la estructura Firestore para sync bidireccional.
- `is_synced` (INT DEFAULT 0) en cada tabla transaccional para tracking de pendientes.
- `clearLocalData()` elimina registros en orden FK-safe: set_logs → workouts → assessments → users.
- No usar Drift ni code generation — SQL plano con `sqflite`.

## SyncService

- Singleton. `startListening()` se llama en `main()` tras Firebase init.
- Escucha `Connectivity().onConnectivityChanged` para auto-sync al recuperar conexión.
- Usa `WriteBatch` de Firestore para subida atómica por documento.
- Estructura Firestore: `gyms/{tenantId}/{collection}/{docId}`.
- `set_logs` resuelve tenant desde su workout padre; `assessments` desde el user.
- `stopListening()` se llama en signOut.

## RecommendationEngine

- Motor **determinista** sin ML ni heurísticas externas.
- Entrada: `averageRir`, `lastWeight`, `lastReps`, `wellnessScore`.
- Reglas RIR: 0-1 → Deload, 2 → Maintain, 3-5 → Increment.
- WellnessScore corrige a la baja: < 40 → Deload forzado, 40-60 → baja Increment a Maintain.
- Salida: `RecommendationResult { suggestedWeight, suggestedReps, action, reason }`.

## RIR en Entreno Activo

- Cada set tiene selector RIR de 0 a 5 con indicador cromático:
  - RIR 0-1: Rojo (fallo/cerca del fallo)
  - RIR 2: Verde (esfuerzo óptimo)
  - RIR 3-5: Azul (carga moderada/liviana)
- Al marcar ✓ se persiste en SQLite `set_logs` con `is_synced = 0`.
- El `_workoutId` se genera con UUID al iniciar la pantalla.

## Sin regresión

- No se debe modificar la estructura de colecciones en Firestore, el orden ni la lógica de los guards de navegación (`_authGuard`, `_tenantGuard`, `_onboardingGuard`), el flag `isInitialized`, ni el flujo de `AuthController._refreshOnboardingAndTenant()` sin actualizar primero `.spec-kit/SPEC.md` y `.spec-kit/PLAN.md`.
- Cualquier cambio en los providers principales (`authProvider`, `authStateProvider`, `authControllerProvider`, `routerProvider`, `tenantProvider`, `onboardingProvider`) debe ser aprobado contra esta constitución.
- Regla anti-bucle: `_tenantGuard` nunca debe redirigir desde `/onboarding`; `_onboardingGuard` nunca debe redirigir desde `/join` ni desde `/onboarding`.
- Los tokens de color en `theme.dart` (`lightColors`) deben mantener contraste WCAG AA para texto (mínimo 4.5:1). `textMuted` no debe ser más claro que `#64748B` (Slate 500).
