# NoteGym — Reglas de Oro

## Principios inamovibles

- **Offline-first**: Toda funcionalidad crítica debe funcionar sin conexión. Firebase/Firestore es un canal de sincronización, no una dependencia obligatoria para la UX.
- **Arquitectura de capas limpia**: `lib/core/` para infraestructura transversal, `lib/features/{modulo}/` para cada dominio de negocio, `lib/models/` para modelos puros, `lib/widgets/` para componentes reutilizables de UI.
- **Riverpod** como única fuente de verdad para estado. Los providers se organizan por feature y se declaran con `Provider`, `StateNotifierProvider` o `StreamProvider` según corresponda.
- **GoRouter** para navegación declarativa con guards (gates) en el redirect.
- **SnakeCase** para nombres de archivo, **PascalCase** para clases, **camelCase** para variables y métodos.

## Autenticación

- El flujo real usa `google_sign_in 7.x` + `firebase_auth` + `cloud_firestore`.
- En **Windows (desarrollo local)** se usa un mock automático: si `GoogleSignIn.instance.authenticate()` lanza cualquier error no-recuperable (categoría `catch (e, _)`), se ejecuta `_simulateGoogleSignIn()` que crea un usuario de prueba (`uid: google_mock_001`). Este fallback **no debe romperse ni eliminarse** mientras no exista configuración nativa de Google Sign-In para Windows.
- El mock persiste en SharedPreferences mediante `authProvider.notifier.signInWithProfile()`, por lo que la sesión sobrevive a reinicios de la app.

## Sin regresión

- No se debe modificar la estructura de colecciones en Firestore, los guards de navegación (`_authGuard`, `_tenantGuard`, `_onboardingGuard`) ni el flujo de `AuthController` sin actualizar primero `.spec-kit/SPEC.md` y `.spec-kit/PLAN.md`.
- Cualquier cambio en los providers principales (`authProvider`, `authStateProvider`, `authControllerProvider`, `routerProvider`) debe ser aprobado contra esta constitución.
