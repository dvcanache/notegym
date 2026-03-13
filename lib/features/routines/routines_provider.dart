import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/routine.dart';
import '../../models/exercise.dart';
import '../../data/default_routines.dart';

class RoutinesNotifier extends StateNotifier<List<Routine>> {
  RoutinesNotifier() : super([]) {
    _load();
  }

  static const _key = 'custom_routines';
  final _uuid = const Uuid();

  Future<void> _load() async {
    final defaults = DefaultRoutines.all;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    List<Routine> custom = [];
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      custom = list
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    state = [...defaults, ...custom];
  }

  Future<void> _saveCustom() async {
    final custom = state.where((r) => !r.isDefault).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(custom.map((r) => r.toJson()).toList()),
    );
  }

  Future<Routine> createRoutine({
    required String name,
    required String description,
    required String type,
    required String emoji,
    required int estimatedMinutes,
    required String difficulty,
    required List<Exercise> exercises,
  }) async {
    final routine = Routine(
      id: _uuid.v4(),
      name: name,
      description: description,
      type: type,
      emoji: emoji,
      estimatedMinutes: estimatedMinutes,
      difficulty: difficulty,
      exercises: exercises,
      isDefault: false,
    );
    state = [...state, routine];
    await _saveCustom();
    return routine;
  }

  Future<void> updateRoutine(Routine updated) async {
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
    await _saveCustom();
  }

  Future<void> deleteRoutine(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _saveCustom();
  }

  Future<void> importRoutine(Routine routine) async {
    final existing = state.indexWhere((r) => r.id == routine.id);
    if (existing >= 0) {
      state = state.map((r) => r.id == routine.id ? routine : r).toList();
    } else {
      state = [...state, routine];
    }
    await _saveCustom();
  }

  Routine? getById(String id) {
    try {
      return state.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

final routinesProvider =
    StateNotifierProvider<RoutinesNotifier, List<Routine>>(
  (ref) => RoutinesNotifier(),
);

final defaultRoutinesProvider = Provider<List<Routine>>((ref) {
  return ref.watch(routinesProvider).where((r) => r.isDefault).toList();
});

final customRoutinesProvider = Provider<List<Routine>>((ref) {
  return ref.watch(routinesProvider).where((r) => !r.isDefault).toList();
});
