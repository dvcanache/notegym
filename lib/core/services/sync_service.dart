import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:notegym/core/database/database_helper.dart';

class SyncService {
  static SyncService? _instance;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncing = false;

  SyncService._();

  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }

  void startListening() {
    _connectivitySub ??= Connectivity().onConnectivityChanged.listen(
      (results) {
        final hasConnection = results.any(
          (r) => r != ConnectivityResult.none,
        );
        if (hasConnection) {
          syncPendingData();
        }
      },
    );
  }

  void stopListening() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await _syncWorkouts();
      await _syncSetLogs();
      await _syncAssessments();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncWorkouts() async {
    final unsynced = await DatabaseHelper.instance.getUnsynced('workouts');
    if (unsynced.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    for (final workout in unsynced) {
      final tenantId = workout['tenant_id'] as String?;
      if (tenantId == null) continue;

      final batch = firestore.batch();
      final docRef = firestore
          .collection('gyms')
          .doc(tenantId)
          .collection('workouts')
          .doc(workout['id'] as String);

      batch.set(docRef, {
        'id': workout['id'],
        'user_id': workout['user_id'],
        'tenant_id': tenantId,
        'date': workout['date'],
        'is_synced': 1,
        'updated_at': workout['updated_at'],
        'synced_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      await DatabaseHelper.instance.markSynced('workouts', workout['id'] as String);
    }
  }

  Future<void> _syncSetLogs() async {
    final unsynced = await DatabaseHelper.instance.getUnsynced('set_logs');
    if (unsynced.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    for (final log in unsynced) {
      final workoutId = log['workout_id'] as String;
      final workout = await DatabaseHelper.instance.queryById(
        'workouts',
        workoutId,
      );
      final tenantId = workout?['tenant_id'] as String?;
      if (tenantId == null) continue;

      final batch = firestore.batch();
      final docRef = firestore
          .collection('gyms')
          .doc(tenantId)
          .collection('set_logs')
          .doc(log['id'] as String);

      batch.set(docRef, {
        'id': log['id'],
        'workout_id': workoutId,
        'exercise_id': log['exercise_id'],
        'weight': log['weight'],
        'reps': log['reps'],
        'rir': log['rir'],
        'is_synced': 1,
        'synced_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      await DatabaseHelper.instance.markSynced(
        'set_logs',
        log['id'] as String,
      );
    }
  }

  Future<void> _syncAssessments() async {
    final unsynced = await DatabaseHelper.instance.getUnsynced('assessments');
    if (unsynced.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    for (final assessment in unsynced) {
      final userId = assessment['user_id'] as String;
      final user = await DatabaseHelper.instance.queryById('users', userId);
      final tenantId = user?['tenant_id'] as String?;
      if (tenantId == null) continue;

      final batch = firestore.batch();
      final docRef = firestore
          .collection('gyms')
          .doc(tenantId)
          .collection('assessments')
          .doc(assessment['id'] as String);

      batch.set(docRef, {
        'id': assessment['id'],
        'user_id': userId,
        'wellness_score': assessment['wellness_score'],
        'is_synced': 1,
        'synced_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      await DatabaseHelper.instance.markSynced(
        'assessments',
        assessment['id'] as String,
      );
    }
  }

  void dispose() {
    stopListening();
    _instance = null;
  }
}
