import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notegym/core/storage_service.dart';
import 'package:notegym/features/auth/auth_provider.dart';

class OnboardingState {
  final bool isLoading;
  final bool isCompleted;
  final String? error;

  const OnboardingState({
    this.isLoading = false,
    this.isCompleted = false,
    this.error,
  });

  OnboardingState copyWith({
    bool? isLoading,
    bool? isCompleted,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final authState = _ref.read(authProvider);
    final profile = authState.profile;

    if (profile?.onboardingCompleted == true) {
      state = const OnboardingState(isCompleted: true);
      return;
    }

    final cached = await StorageService.get<bool>('onboarding_completed');
    if (cached == true) {
      state = const OnboardingState(isCompleted: true);
      return;
    }

    state = const OnboardingState();
  }

  Future<void> completeOnboarding({
    required String fitnessLevel,
    required String somatotype,
    required int weeklyDays,
    required String primaryGoal,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authState = _ref.read(authProvider);
      final profile = authState.profile;
      final uid = profile?.id;

      if (uid == null) {
        state = state.copyWith(isLoading: false, error: 'Usuario no autenticado');
        return;
      }

      final updated = profile!.copyWith(
        fitnessLevel: fitnessLevel,
        somatotype: somatotype,
        weeklyDays: weeklyDays,
        primaryGoal: primaryGoal,
        onboardingCompleted: true,
      );

      final isRealUser = !uid.startsWith('local_') && !uid.startsWith('google_mock_');

      if (isRealUser) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'fitnessLevel': fitnessLevel,
            'somatotype': somatotype,
            'weeklyDays': weeklyDays,
            'primaryGoal': primaryGoal,
            'onboardingCompleted': true,
          },
          SetOptions(merge: true),
        );
      }

      await StorageService.set('onboarding_completed', true);

      await _ref.read(authProvider.notifier).updateProfile(updated);

      state = const OnboardingState(isCompleted: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(ref),
);
