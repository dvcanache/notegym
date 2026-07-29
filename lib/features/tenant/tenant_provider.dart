import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notegym/core/storage_service.dart';
import 'package:notegym/features/auth/auth_provider.dart';
import 'package:notegym/features/tenant/gym_service.dart';
import 'package:notegym/models/gym.dart';

class TenantState {
  final String? tenantId;
  final Gym? activeGym;
  final bool isLoading;
  final String? error;

  const TenantState({
    this.tenantId,
    this.activeGym,
    this.isLoading = false,
    this.error,
  });

  bool get hasTenant => tenantId != null;

  TenantState copyWith({
    String? tenantId,
    Gym? activeGym,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TenantState(
      tenantId: tenantId ?? this.tenantId,
      activeGym: activeGym ?? this.activeGym,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TenantNotifier extends StateNotifier<TenantState> {
  final Ref _ref;

  TenantNotifier(this._ref) : super(const TenantState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final authState = _ref.read(authProvider);
    final profile = authState.profile;

    String? tenantId;

    if (profile?.tenantId != null) {
      tenantId = profile!.tenantId;
    } else {
      tenantId = await StorageService.get<String>('tenantId');
    }

    if (tenantId != null) {
      final gym = await GymService.getGymById(tenantId);
      state = TenantState(tenantId: tenantId, activeGym: gym);
    } else {
      state = const TenantState();
    }
  }

  Future<void> joinGym(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final gym = await GymService.getGymById(gymId);
      if (gym == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Gimnasio no encontrado',
        );
        return;
      }

      final authState = _ref.read(authProvider);
      final uid = authState.profile?.id;

      if (uid != null && !uid.startsWith('local_') && !uid.startsWith('google_mock_')) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'tenantId': gymId}, SetOptions(merge: true));
      }

      await StorageService.set('tenantId', gymId);

      if (authState.profile != null) {
        final updated = authState.profile!.copyWith(tenantId: gymId);
        await _ref.read(authProvider.notifier).updateProfile(updated);
      }

      state = TenantState(tenantId: gymId, activeGym: gym);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> leaveGym() async {
    state = state.copyWith(isLoading: true);

    try {
      final authState = _ref.read(authProvider);
      final uid = authState.profile?.id;

      if (uid != null && !uid.startsWith('local_') && !uid.startsWith('google_mock_')) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'tenantId': FieldValue.delete()}, SetOptions(merge: true));
      }

      await StorageService.remove('tenantId');

      if (authState.profile != null) {
        final updated = authState.profile!.copyWith(tenantId: null);
        await _ref.read(authProvider.notifier).updateProfile(updated);
      }

      state = const TenantState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshTenant() async {
    final authState = _ref.read(authProvider);
    final uid = authState.profile?.id;

    if (uid == null || uid.startsWith('local_') || uid.startsWith('google_mock_')) {
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) return;

      final tenantId = userDoc.data()?['tenantId'] as String?;

      if (tenantId != null) {
        await joinGym(tenantId);
      }
    } catch (_) {}
  }
}

final tenantProvider = StateNotifierProvider<TenantNotifier, TenantState>(
  (ref) => TenantNotifier(ref),
);
