# NoteGym — Especificación del Producto

## Qué es NoteGym / Progressa

SaaS de fitness **offline-first** para gestión de entrenamientos personales y de gimnasio. Los usuarios pueden registrar rutinas, seguir entrenamientos en vivo, ver historial, gráficos de progreso y compartir plantillas. La plataforma está diseñada para funcionar sin conexión y sincronizar cuando haya red.

---

## Arquitectura de Datos

### Persistencia triple

| Capa | Medio | Propósito |
|------|-------|-----------|
| Local SQLite | `sqflite` (`notegym.db`) | Datos transaccionales offline (workouts, set_logs, assessments) |
| Local SharedPreferences | `shared_preferences` | Sesión, perfil, preferencias de tema, tenantId |
| Nube | Firestore `gyms/{tenantId}/{collection}` | Sincronización multi-dispositivo, backup |

### Base de datos SQLite — `DatabaseHelper` (`lib/core/database/database_helper.dart`)

- Singleton (`DatabaseHelper.instance`)
- Foreign Keys habilitados via `PRAGMA foreign_keys = ON`
- 4 tablas:

```sql
users (id TEXT PK, name TEXT, email TEXT, tenant_id TEXT)

workouts (id TEXT PK, user_id TEXT FK→users, tenant_id TEXT,
          date TEXT, is_synced INT DEFAULT 0, updated_at TEXT)

set_logs (id TEXT PK, workout_id TEXT FK→workouts, exercise_id TEXT,
          weight REAL, reps INT, rir INT, is_synced INT DEFAULT 0)

assessments (id TEXT PK, user_id TEXT FK→users,
             wellness_score REAL, is_synced INT DEFAULT 0)
```

- `clearLocalData()` — borra set_logs → workouts → assessments → users (orden FK-safe)
- `getUnsynced(table)` / `markSynced(table, id)` — soporte para sync offline→online

---

## Motor de Sincronización — `SyncService` (`lib/core/services/sync_service.dart`)

- Singleton con `startListening()` / `stopListening()` a `Connectivity().onConnectivityChanged`
- `syncPendingData()` — sube registros con `is_synced = 0` a Firestore usando `WriteBatch`
- Estructura Firestore: `gyms/{tenantId}/{collection}/{docId}`
- Flujo: `workouts` primero (tienen tenant_id directo) → `set_logs` (resuelve tenant desde workout padre) → `assessments` (resuelve tenant desde user)
- `SyncService.instance.startListening()` se llama en `main()` tras Firebase init
- `SyncService.instance.stopListening()` se llama en `signOut()` antes de limpiar datos

---

## RecommendationEngine — `lib/core/services/recommendation_engine.dart`

Motor determinista de progresión basado en RIR + wellness.

### Reglas de progresión

| RIR | Acción base | Peso sugerido | Reps sugeridas |
|-----|-------------|---------------|----------------|
| 0 — 1 (fallo/cerca) | **Deload** | peso × 0.9 (múltiplo 2.5) | = lastReps |
| 2 (óptimo) | **Maintain** | lastWeight + 2.5kg | = lastReps |
| 3 — 5 (sobró) | **Increment** | lastWeight + 5kg | lastReps + 1 |

### Factor de corrección wellnessScore (0-100)

| Wellness | Ajuste |
|----------|--------|
| ≥ 60 | Aplica regla base sin cambios |
| 40 — 60 | Increment → Maintain; Maintain/Deload se mantienen |
| < 40 | Todo pasa a Deload (peso × 0.9, reps × 0.9) |

Retorna `RecommendationResult { suggestedWeight, suggestedReps, action, reason }`.

---

## Captura de RIR en Entreno Activo — `active_workout_screen.dart`

- Cada set tiene selector RIR (0-5) con indicador visual:
  - **Rojo** (#FF5252): RIR 0-1 (Fallo / Cerca del fallo)
  - **Verde** (#69F0AE): RIR 2 (Esfuerzo óptimo)
  - **Azul** (#82B1FF): RIR 3-5 (Carga moderada / Liviana)
- Modal bottom sheet con descripciones textuales para selección
- Al marcar ✓ se persiste en SQLite `set_logs` con `is_synced = 0`
- `_workoutId` generado con UUID al iniciar pantalla
- Al finalizar workout se guarda registro en `workouts` + `workout_logs` (SharedPreferences legacy)

---

## Firma de Compilación Android

- Keystore: `android/app/upload-keystore.jks` (JKS, RSA 2048, validez 10000 días)
- Credenciales: `android/key.properties` (excluido via `.gitignore`)
- `build.gradle.kts`:
  - Función `loadKeystoreProperties()` que lee `key.properties`
  - `signingConfigs { release { ... } }` con los valores del archivo
  - `buildTypes.release` apunta a `signingConfigs.release`

---

## Estado actual del módulo de autenticación

### Flujo de sign-in con Google (Firebase Auth)

1. Usuario presiona "Continuar con Google" en `LoginScreen`.
2. `_signInWithGoogle()` → `AuthController.signInWithGoogle()`.
3. Intenta `GoogleSignIn.instance.initialize()` + `authenticate()`.
4. Si éxito: obtiene `idToken`, crea `credential` con `GoogleAuthProvider.credential(idToken:)`, firma en Firebase Auth con `signInWithCredential()`.
5. Guarda/actualiza documento en `firestore.collection('users').doc(uid)` con `SetOptions(merge: true)`.
6. Crea `UserProfile` local y llama `authProvider.notifier.signInWithProfile()`.
7. Si falla (Windows sin configuración nativa): `catch (e, _)` → `_simulateGoogleSignIn()` → usuario mock.

### Flujo de SignOut

```
signOut()
  ├── SyncService.instance.stopListening()
  ├── DatabaseHelper.instance.clearLocalData()      ← SQLite wipe (protegido try/catch)
  ├── GoogleSignIn.signOut()                        ← protegido try/catch
  ├── FirebaseAuth.signOut()                        ← protegido try/catch
  ├── authProvider.notifier.signOut()               ← siempre se ejecuta
  └── router.refresh() → redirect a /login
```

Cada paso tiene su propio `try/catch` para garantizar que el estado local siempre se limpie, incluso si Firebase falla (ej: mock sin Firebase inicializado).

### Persistencia de sesión

| Capa | Medio | Propósito |
|------|-------|-----------|
| Local | SharedPreferences (`user_profile` key) | Sesión offline, arranque inmediato |
| Nube | Firestore `users/{uid}` | Sincronización entre dispositivos |

### Providers

| Provider | Tipo | Función |
|----------|------|---------|
| `authProvider` | `StateNotifierProvider<AuthNotifier, AuthState>` | Auth local (SharedPreferences) |
| `firebaseAuthProvider` | `Provider<FirebaseAuth>` | Instancia de Firebase Auth |
| `authStateProvider` | `StreamProvider<User?>` | Stream de `authStateChanges()` |
| `authControllerProvider` | `StateNotifierProvider<AuthController, AsyncValue<void>>` | Controlador de sign-in/out |

---

## Modelo Gym

La colección `gyms` en Firestore contiene documentos con la siguiente estructura:

```
/gyms/{gymId}
  - name: string
  - slug: string (URL-friendly, unique)
  - address: string (opcional)
  - createdBy: string (userId del admin que lo creó)
  - createdAt: Timestamp
```

Modelo Dart en `lib/models/gym.dart` con constructores `fromFirestore`, `fromJson`, `toJson`.

---

## TenantProvider / Gimnasio activo

| Provider | Archivo | Tipo | Función |
|----------|---------|------|---------|
| `tenantProvider` | `lib/features/tenant/tenant_provider.dart` | `StateNotifierProvider<TenantNotifier, TenantState>` | Estado del gimnasio activo |

**Flujo de selección de gimnasio:**
1. Usuario autenticado sin `tenantId` → redirigido a `/join`
2. En `/join` lista todos los gimnasios desde Firestore (`gym_service.getAllGyms()`)
3. Usuario selecciona un gimnasio o ingresa slug manualmente
4. `TenantNotifier.joinGym(gymId)` escribe `tenantId` en `users/{uid}` (Firestore) y en `StorageService` (local)
5. Router detecta `hasTenant: true` y permite acceso a `/home`

**Cache local:** `StorageService` (wrapper de SharedPreferences con prefijo `notegym:`) guarda `tenantId`.

---

## Registro con vinculación a gimnasio

Ruta: `/login/register/:gymSlug`

- Si se accede con un `gymSlug` válido, `AuthController._saveFirebaseUser()` busca el gym por slug y asigna `tenantId` automáticamente en el documento de usuario y en el perfil local.
- El usuario salta la pantalla `/join` y va directamente a `/home`.

---

## Flujo de navegación — 3 guards activos

Todos los guards están en `lib/core/router.dart` y se ejecutan en cadena:

```dart
redirect: (context, state) {
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
```

| Guard | Estado | Lógica |
|-------|--------|--------|
| **AuthGate** (`_authGuard`) | ✅ Activo | No autenticado → `/login`; autenticado en `/login` → `/home` |
| **TenantGate** (`_tenantGuard`) | ✅ Activo | `!isInitialized` → espera consulta inicial Firestore. Sin tenant y no en `/join` → `/join`. Con tenant en `/join` → `/home`. No redirige desde `/onboarding` |
| **OnboardingGate** (`_onboardingGuard`) | ✅ Activo | `!isInitialized` → espera. No completado y no en `/onboarding` ni `/join` → `/onboarding`. No redirige desde `/onboarding` ni `/join` |

### Anti-bucle entre guards

- `_tenantGuard` retorna `null` si `state.matchedLocation == '/onboarding'` (no redirige a `/join` desde onboarding)
- `_onboardingGuard` retorna `null` si `state.matchedLocation == '/onboarding'` o `state.matchedLocation == '/join'` (no redirige desde estas pantallas)
- **Razón:** evitar el bucle `/onboarding <-> /join` que GoRouter aborta con 404

### Flag `isInitialized` (race condition)

Cada provider (`TenantState`, `OnboardingState`) tiene un campo `isInitialized` que arranca en `false` y se pone `true` **solo al final** del método `_init()`. Mientras `isInitialized` es `false`, los guards retornan `null` sin hacer ninguna redirección. Esto evita que los guards evalúen estado incompleto durante la consulta async a Firestore.

### Refresco de providers al login

Tras un sign-up o sign-in exitoso, `AuthController._refreshOnboardingAndTenant()` invalida `onboardingProvider` y `tenantProvider`. Al invalidarse, se recrean y ejecutan `_init()` de nuevo con el UID recién logueado, leyendo Firestore para obtener `tenantId` y `onboardingCompleted`.

| Provider | Archivo | Tipo | Dependencias |
|----------|---------|------|-------------|
| `tenantProvider` | `lib/features/tenant/tenant_provider.dart` | `StateNotifierProvider<TenantNotifier, TenantState>` | `authProvider`, `StorageService`, `cloud_firestore` |
| `onboardingProvider` | `lib/features/onboarding/onboarding_provider.dart` | `StateNotifierProvider<OnboardingNotifier, OnboardingState>` | `authProvider`, `StorageService`, `cloud_firestore` |
