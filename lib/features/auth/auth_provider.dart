import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final UserProfile? profile;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.profile,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    UserProfile? profile,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _loadSession();
  }

  static const _profileKey = 'user_profile';

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      if (profileJson != null) {
        final profile = UserProfile.fromJson(
          jsonDecode(profileJson) as Map<String, dynamic>,
        );
        state = AuthState(isLoggedIn: true, profile: profile);
      } else {
        state = const AuthState(isLoggedIn: false);
      }
    } catch (_) {
      state = const AuthState(isLoggedIn: false);
    }
  }

  Future<bool> signIn({required String name, required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // simulate
      final profile = UserProfile(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
      state = AuthState(isLoggedIn: true, profile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateProfile(UserProfile updated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(updated.toJson()));
    state = state.copyWith(profile: updated);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    state = const AuthState(isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
