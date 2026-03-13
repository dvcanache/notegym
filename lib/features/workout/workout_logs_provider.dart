import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/workout_log.dart';
import '../../models/user_profile.dart';
import '../auth/auth_provider.dart';

class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  WorkoutLogsNotifier(this._ref) : super([]) {
    _load();
  }

  final Ref _ref;
  static const _key = 'workout_logs';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      state = list
          .map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((l) => l.toJson()).toList()),
    );
  }

  Future<void> addLog(WorkoutLog log) async {
    state = [log, ...state];
    await _save();

    // Update user stats
    final authNotifier = _ref.read(authProvider.notifier);
    final profile = _ref.read(authProvider).profile;
    if (profile != null) {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final lastDate = profile.lastWorkoutDate;
      int newStreak = profile.currentStreak;

      if (lastDate == null ||
          lastDate.isBefore(yesterday.subtract(const Duration(days: 1)))) {
        newStreak = 1;
      } else if (lastDate.isBefore(now.subtract(const Duration(hours: 20)))) {
        newStreak += 1;
      }

      final updated = UserProfile(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        photoUrl: profile.photoUrl,
        goal: profile.goal,
        totalWorkouts: profile.totalWorkouts + 1,
        currentStreak: newStreak,
        bestStreak:
            newStreak > profile.bestStreak ? newStreak : profile.bestStreak,
        joinDate: profile.joinDate,
        lastWorkoutDate: now,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
      );
      await authNotifier.updateProfile(updated);
    }
  }

  List<WorkoutLog> getWeekLogs() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return state
        .where((l) => l.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .toList();
  }

  WorkoutLog? getById(String id) {
    try {
      return state.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}

final workoutLogsProvider =
    StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>(
  (ref) => WorkoutLogsNotifier(ref),
);
