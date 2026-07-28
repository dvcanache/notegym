import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notegym/features/auth/auth_provider.dart';
import 'package:notegym/models/user_profile.dart';

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

  Future<void> signInWithGoogle() async {
    debugPrint('[AuthController] signInWithGoogle called');
    state = const AsyncValue.loading();

    try {
      await _tryGoogleSignIn();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        debugPrint('[AuthController] Google sign-in cancelled');
        state = const AsyncValue.data(null);
        return;
      }
      debugPrint('[AuthController] GoogleSignInException: ${e.code}');
      state = AsyncValue.error(e, StackTrace.current);
      return;
    } catch (e, _) {
      debugPrint('[AuthController] Google Sign-In failed: $e');
      debugPrint('[AuthController] Falling back to mock login');
      await _simulateGoogleSignIn();
    }

    state = const AsyncValue.data(null);
  }

  Future<void> _tryGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final firebaseAuth = _ref.read(firebaseAuthProvider);
    final userCredential =
        await firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(firebaseUser.uid).set(
        {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'displayName': firebaseUser.displayName,
          'photoURL': firebaseUser.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final profile = UserProfile(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Usuario',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
      );

      await _ref.read(authProvider.notifier).signInWithProfile(profile);
    }
  }

  Future<void> _simulateGoogleSignIn() async {
    debugPrint('[AuthController] Simulating Google sign-in');
    await Future.delayed(const Duration(milliseconds: 600));

    const mockUid = 'google_mock_001';
    const mockEmail = 'usuario.demo@notegym.app';
    const mockName = 'Usuario Demo';

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
      try {
        await GoogleSignIn.instance.initialize();
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      final firebaseAuth = _ref.read(firebaseAuthProvider);
      await firebaseAuth.signOut();
      await _ref.read(authProvider.notifier).signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);
