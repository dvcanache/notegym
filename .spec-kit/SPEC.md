# NoteGym — Especificación del Producto

## Qué es NoteGym / Progressa

SaaS de fitness **offline-first** para gestión de entrenamientos personales y de gimnasio. Los usuarios pueden registrar rutinas, seguir entrenamientos en vivo, ver historial, gráficos de progreso y compartir plantillas. La plataforma está diseñada para funcionar sin conexión y sincronizar cuando haya red.

## Estado actual del módulo de autenticación

### Flujo de sign-in con Google (Firebase Auth)

1. Usuario presiona "Continuar con Google" en `LoginScreen`.
2. `_signInWithGoogle()` → `AuthController.signInWithGoogle()`.
3. Intenta `GoogleSignIn.instance.initialize()` + `authenticate()`.
4. Si éxito: obtiene `idToken`, crea `credential` con `GoogleAuthProvider.credential(idToken:)`, firma en Firebase Auth con `signInWithCredential()`.
5. Guarda/actualiza documento en `firestore.collection('users').doc(uid)` con `SetOptions(merge: true)`.
6. Crea `UserProfile` local y llama `authProvider.notifier.signInWithProfile()`.
7. Si falla (Windows sin configuración nativa): `catch (e, _)` → `_simulateGoogleSignIn()` → usuario mock.

### Persistencia dual

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

## Registro con vinculación a gimnasio

Ruta: `/login/register/:gymSlug`

- Si se accede con un `gymSlug` válido, `AuthController._saveFirebaseUser()` busca el gym por slug y asigna `tenantId` automáticamente en el documento de usuario y en el perfil local.
- El usuario salta la pantalla `/join` y va directamente a `/home`.

## Flujo de navegación — 3 guards

Todos los guards están en `lib/core/router.dart` y se ejecutan en cadena:

```dart
redirect: (context, state) {
  final authRedirect = _authGuard(state, isLoggedIn);
  if (authRedirect != null) return authRedirect;
  final tenantRedirect = _tenantGuard(state, tenantState);
  if (tenantRedirect != null) return tenantRedirect;
  // final onboardingRedirect = _onboardingGuard(state);
  // if (onboardingRedirect != null) return onboardingRedirect;
  return null;
},
```

| Guard | Estado | Lógica |
|-------|--------|--------|
| **AuthGate** (`_authGuard`) | ✅ Activo | No autenticado → `/login`; autenticado en `/login` → `/home` |
| **TenantGate** (`_tenantGuard`) | ✅ Activo | `isLoading` → espera. Sin tenant → `/join`. Con tenant en `/join` → `/home` |
| **OnboardingGate** (`_onboardingGuard`) | ⏳ Placeholder | Verificar perfil completo; redirigir a `/onboarding` |
