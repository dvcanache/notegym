import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../routines/routines_provider.dart';
import '../workout/workout_logs_provider.dart';
import '../../models/workout_log.dart';
import 'package:notegym/core/theme_extension.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String routineId;
  const ActiveWorkoutScreen({super.key, required this.routineId});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _workoutTimer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  bool _isResting = false;
  int _currentExercise = 0;

  // [exerciseIndex] -> [setIndex] -> {reps, weight, completed}
  List<List<Map<String, dynamic>>> _setData = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSets());
  }

  void _initSets() {
    final routine =
        ref.read(routinesProvider.notifier).getById(widget.routineId);
    if (routine != null) {
      setState(() {
        _setData = routine.exercises.map((ex) {
          return List.generate(
              ex.defaultSets,
              (_) => {
                    'reps': ex.defaultReps,
                    'weight': ex.defaultWeight,
                    'completed': false,
                  });
        }).toList();
      });
    }
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restSeconds = seconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restSeconds <= 0) {
        _restTimer?.cancel();
        HapticFeedback.mediumImpact();
        setState(() => _isResting = false);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _isResting = false);
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  String get _elapsedFormatted {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0)
      return '${h.toString().padLeft(2, "0")}:${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")}';
    return '${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")}';
  }

  int get _completedSets => _setData.fold(
      0, (sum, ex) => sum + ex.where((s) => s['completed'] == true).length);
  int get _totalSets => _setData.fold(0, (sum, ex) => sum + ex.length);

  Future<void> _finishWorkout() async {
    setState(() => _isSaving = true);
    _workoutTimer?.cancel();
    _restTimer?.cancel();

    final routine =
        ref.read(routinesProvider.notifier).getById(widget.routineId);
    if (routine == null) return;

    final sets = <SetLog>[];
    for (int i = 0; i < routine.exercises.length; i++) {
      final ex = routine.exercises[i];
      for (final s in _setData[i]) {
        if (s['completed'] == true) {
          sets.add(SetLog(
            exerciseId: ex.id,
            exerciseName: ex.name,
            reps: s['reps'] as int,
            weight: (s['weight'] as num).toDouble(),
          ));
        }
      }
    }

    final log = WorkoutLog(
      id: const Uuid().v4(),
      routineId: routine.id,
      routineName: routine.name,
      date: DateTime.now(),
      durationSeconds: _elapsedSeconds,
      sets: sets,
    );

    await ref.read(workoutLogsProvider.notifier).addLog(log);

    if (mounted) {
      context.pushReplacement('/workout/complete', extra: {'logId': log.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    final routine =
        ref.watch(routinesProvider.notifier).getById(widget.routineId);
    if (routine == null || _setData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final exercises = routine.exercises;
    final currentEx = exercises[_currentExercise];
    final currentSets = _setData[_currentExercise];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
              decoration:
                  BoxDecoration(gradient: context.colors.backgroundGradient)),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _confirmAbandon(context),
                        child: GlassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 12,
                          child: Icon(Icons.close_rounded,
                              color: context.colors.textPrimary, size: 20),
                        ),
                      ),

                      // Timer
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                color: context.colors.accent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _elapsedFormatted,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        borderRadius: 12,
                        child: Text(
                          '$_completedSets/$_totalSets',
                          style: TextStyle(
                              color: context.colors.primaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _totalSets > 0 ? _completedSets / _totalSets : 0,
                      backgroundColor: context.colors.glassWhite,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(context.colors.primary),
                      minHeight: 4,
                    ),
                  ),
                ),

                // Rest timer overlay
                if (_isResting)
                  Expanded(
                    child: Center(
                      child: GlassCard(
                        padding: const EdgeInsets.all(32),
                        borderRadius: 24,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('⏱️ Descanso',
                                style: TextStyle(
                                    color: context.colors.textSecondary,
                                    fontSize: 16)),
                            const SizedBox(height: 16),
                            Text(
                              '${_restSeconds}s',
                              style: TextStyle(
                                  color: context.colors.accent,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 20),
                            GradientButton(
                              label: 'Saltar descanso',
                              gradient: context.colors.accentGradient,
                              onPressed: _skipRest,
                              height: 44,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // Exercise navigator
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Exercise tabs
                          SizedBox(
                            height: 44,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: exercises.length,
                              itemBuilder: (_, i) {
                                final ex = exercises[i];
                                final exSets = _setData[i];
                                final done = exSets
                                    .where((s) => s['completed'] == true)
                                    .length;
                                final total = exSets.length;
                                final isCurrent = i == _currentExercise;
                                final isComplete = done == total;

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _currentExercise = i),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: isCurrent
                                          ? context.colors.primaryGradient
                                          : null,
                                      color: isCurrent
                                          ? null
                                          : context.colors.glassWhite,
                                      borderRadius: BorderRadius.circular(10),
                                      border: isComplete && !isCurrent
                                          ? Border.all(
                                              color: context.colors.success
                                                  .withValues(alpha: 0.5))
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        if (isComplete)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Icon(
                                                Icons.check_circle_rounded,
                                                color: context.colors.success,
                                                size: 14),
                                          ),
                                        Text(
                                          '${i + 1}. ${ex.name.length > 12 ? ex.name.substring(0, 12) : ex.name}',
                                          style: TextStyle(
                                            color: isCurrent
                                                ? Colors.white
                                                : context.colors.textMuted,
                                            fontSize: 12,
                                            fontWeight: isCurrent
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Current exercise title
                          Text(
                            currentEx.name,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (context.colors.muscleColors[
                                              currentEx.muscleGroup] ??
                                          context.colors.primary)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentEx.muscleGroup,
                                  style: TextStyle(
                                    color: context.colors.muscleColors[
                                            currentEx.muscleGroup] ??
                                        context.colors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (currentEx.equipment != null) ...[
                                const SizedBox(width: 6),
                                Text('• ${currentEx.equipment}',
                                    style: TextStyle(
                                        color: context.colors.textMuted,
                                        fontSize: 12)),
                              ],
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Sets table header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 44,
                                    child: Text('Set',
                                        style: TextStyle(
                                            color: context.colors.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600))),
                                Expanded(
                                    child: Center(
                                        child: Text('Reps',
                                            style: TextStyle(
                                                color: context.colors.textMuted,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)))),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Center(
                                        child: Text('Peso (kg)',
                                            style: TextStyle(
                                                color: context.colors.textMuted,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)))),
                                const SizedBox(width: 12),
                                SizedBox(
                                    width: 44,
                                    child: Center(
                                        child: Text('✓',
                                            style: TextStyle(
                                                color: context.colors.textMuted,
                                                fontSize: 14)))),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sets
                          ...currentSets.asMap().entries.map((e) {
                            final i = e.key;
                            final set = e.value;
                            final completed = set['completed'] == true;

                            return GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              backgroundColor: completed
                                  ? context.colors.success
                                      .withValues(alpha: 0.15)
                                  : context.colors.glassWhite,
                              borderColor: completed
                                  ? context.colors.success
                                      .withValues(alpha: 0.3)
                                  : context.colors.glassBorder,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 44,
                                    child: Text(
                                      'Set ${i + 1}',
                                      style: TextStyle(
                                        color: completed
                                            ? context.colors.success
                                            : context.colors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // Reps
                                  Expanded(
                                    child: _SetInput(
                                      value: set['reps'] as int,
                                      enabled: !completed,
                                      onChanged: (v) => setState(() =>
                                          _setData[_currentExercise][i]
                                              ['reps'] = v),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Weight
                                  Expanded(
                                    child: _WeightInput(
                                      value: (set['weight'] as num).toDouble(),
                                      enabled: !completed,
                                      onChanged: (v) => setState(() =>
                                          _setData[_currentExercise][i]
                                              ['weight'] = v),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Complete toggle
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _setData[_currentExercise][i]
                                            ['completed'] = !completed;
                                      });
                                      if (!completed) {
                                        _startRest(currentEx.restSeconds);
                                      }
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: completed
                                            ? context.colors.success
                                            : context.colors.glassWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: completed
                                              ? context.colors.success
                                              : context.colors.glassBorder,
                                        ),
                                      ),
                                      child: Icon(
                                        completed
                                            ? Icons.check_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        color: completed
                                            ? Colors.white
                                            : context.colors.textMuted,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 24),

                          // Navigation between exercises
                          Row(
                            children: [
                              if (_currentExercise > 0)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _currentExercise--),
                                    child: GlassCard(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.arrow_back_ios_new_rounded,
                                              size: 14,
                                              color:
                                                  context.colors.textSecondary),
                                          const SizedBox(width: 6),
                                          Text('Anterior',
                                              style: TextStyle(
                                                  color: context
                                                      .colors.textSecondary,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentExercise > 0)
                                const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _currentExercise < exercises.length - 1
                                    ? GradientButton(
                                        label: 'Siguiente',
                                        icon: Icons.arrow_forward_rounded,
                                        onPressed: () =>
                                            setState(() => _currentExercise++),
                                      )
                                    : GradientButton(
                                        label: '¡Finalizar!',
                                        icon: Icons.flag_rounded,
                                        gradient: LinearGradient(colors: [
                                          context.colors.success,
                                          context.colors.success
                                              .withValues(alpha: 0.7)
                                        ]),
                                        onPressed: _finishWorkout,
                                        isLoading: _isSaving,
                                      ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAbandon(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('¿Abandonar entrenamiento?',
            style: TextStyle(color: context.colors.textPrimary)),
        content: Text('El progreso no se guardará',
            style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Continuar',
                style: TextStyle(color: context.colors.primaryLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Abandonar',
                style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) context.pop();
  }
}

class _SetInput extends StatelessWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _SetInput(
      {required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.colors.glassWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.glassBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: enabled && value > 0 ? () => onChanged(value - 1) : null,
            child: Container(
              width: 28,
              alignment: Alignment.center,
              child: Icon(Icons.remove_rounded,
                  size: 14,
                  color: enabled
                      ? context.colors.textSecondary
                      : context.colors.textMuted),
            ),
          ),
          Expanded(
            child: Center(
                child: Text(
              '$value',
              style: TextStyle(
                  color: enabled
                      ? context.colors.textPrimary
                      : context.colors.textMuted,
                  fontWeight: FontWeight.w600),
            )),
          ),
          GestureDetector(
            onTap: enabled ? () => onChanged(value + 1) : null,
            child: Container(
              width: 28,
              alignment: Alignment.center,
              child: Icon(Icons.add_rounded,
                  size: 14,
                  color: enabled
                      ? context.colors.textSecondary
                      : context.colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightInput extends StatelessWidget {
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _WeightInput(
      {required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.colors.glassWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.glassBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap:
                enabled && value >= 2.5 ? () => onChanged(value - 2.5) : null,
            child: Container(
              width: 28,
              alignment: Alignment.center,
              child: Icon(Icons.remove_rounded,
                  size: 14,
                  color: enabled
                      ? context.colors.textSecondary
                      : context.colors.textMuted),
            ),
          ),
          Expanded(
            child: Center(
                child: Text(
              value == 0 ? 'BW' : value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
              style: TextStyle(
                  color: enabled
                      ? context.colors.textPrimary
                      : context.colors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            )),
          ),
          GestureDetector(
            onTap: enabled ? () => onChanged(value + 2.5) : null,
            child: Container(
              width: 28,
              alignment: Alignment.center,
              child: Icon(Icons.add_rounded,
                  size: 14,
                  color: enabled
                      ? context.colors.textSecondary
                      : context.colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
