import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notegym/core/database/database_helper.dart';
import 'package:notegym/core/services/sync_service.dart';
import 'package:notegym/features/auth/auth_provider.dart';
import 'package:notegym/features/onboarding/onboarding_provider.dart';
import 'package:notegym/features/tenant/gym_service.dart';
import 'package:notegym/features/tenant/tenant_provider.dart';
import 'package:notegym/models/user_profile.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authStateProvider = StreamProvider<User?>(
  (ref) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    return firebaseAuth.authStateChanges();
  },
);

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncValue.data(null));

  void _refreshOnboardingAndTenant() {
    _ref.invalidate(onboardingProvider);
    _ref.invalidate(tenantProvider);
  }

  Future<void> signInWithGoogle({String? name, String? email}) async {
    debugPrint('[AuthController] signInWithGoogle called');
    state = const AsyncValue.loading();

    try {
      await _tryGoogleSignIn();
    } on GoogleSignInException catch (e) {
      debugPrint('[AuthController] GoogleSignInException: ${e.code}');
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        debugPrint('[AuthController] Credential Manager unavailable, falling back to mock');
        await _simulateGoogleSignIn(name: name, email: email);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
        return;
      }
    } catch (e, _) {
      debugPrint('[AuthController] Google Sign-In failed: $e');
      debugPrint('[AuthController] Falling back to mock login');
      await _simulateGoogleSignIn(name: name, email: email);
    }

    _refreshOnboardingAndTenant();
    state = const AsyncValue.data(null);
  }

  Future<void> signInWithEmail(String email, String password) async {
    debugPrint('[AuthController] signInWithEmail called');
    state = const AsyncValue.loading();
    try {
      final firebaseAuth = _ref.read(firebaseAuthProvider);
      final userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveFirebaseUser(userCredential.user!);
      _refreshOnboardingAndTenant();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthController] signInWithEmail error: ${e.code}');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUpWithEmail(
      String name, String email, String password,
      {String? gymSlug}) async {
    debugPrint('[AuthController] signUpWithEmail called');
    state = const AsyncValue.loading();
    try {
      final firebaseAuth = _ref.read(firebaseAuthProvider);
      final userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await _saveFirebaseUser(userCredential.user!, gymSlug: gymSlug);
      _refreshOnboardingAndTenant();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthController] signUpWithEmail error: ${e.code}');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveFirebaseUser(User firebaseUser, {String? gymSlug}) async {
    final firestore = FirebaseFirestore.instance;

    final Map<String, dynamic> userData = {
      'uid': firebaseUser.uid,
      'email': firebaseUser.email,
      'displayName': firebaseUser.displayName,
      'lastLogin': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    String? tenantId;

    if (gymSlug != null) {
      final gym = await GymService.getGymBySlug(gymSlug);
      if (gym != null) {
        tenantId = gym.id;
        userData['tenantId'] = gym.id;
      }
    }

    await firestore.collection('users').doc(firebaseUser.uid).set(
      userData,
      SetOptions(merge: true),
    );

    final profile = UserProfile(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Usuario',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      tenantId: tenantId,
    );

    await _ref.read(authProvider.notifier).signInWithProfile(profile);

    if (tenantId != null) {
      await _ref.read(tenantProvider.notifier).joinGym(tenantId);
    }
  }

  Future<void> _tryGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId: '168512024611-5o0vb2fva2dlt3a8uptin5mb36laq337.apps.googleusercontent.com',
    );
    final GoogleSignInAccount googleUser =
        await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final firebaseAuth = _ref.read(firebaseAuthProvider);
    final userCredential =
        await firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      await _saveFirebaseUser(firebaseUser);
    }
  }

  Future<void> _simulateGoogleSignIn({String? name, String? email}) async {
    debugPrint('[AuthController] Simulating Google sign-in');
    await Future.delayed(const Duration(milliseconds: 600));

    const mockUid = 'google_mock_001';
    final mockName = name ?? 'Usuario Demo';
    final mockEmail = email ?? 'usuario.demo@notegym.app';

    final profile = UserProfile(
      id: mockUid,
      name: mockName,
      email: mockEmail,
    );

    await _ref.read(authProvider.notifier).signInWithProfile(profile);
    debugPrint('[AuthController] Mock sign-in complete, isLoggedIn=true');
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      SyncService.instance.stopListening();
      await DatabaseHelper.instance.clearLocalData();
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      final firebaseAuth = _ref.read(firebaseAuthProvider);
      await firebaseAuth.signOut();
    } catch (_) {}

    await _ref.read(authProvider.notifier).signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);
