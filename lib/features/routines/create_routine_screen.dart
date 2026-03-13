import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../routines/routines_provider.dart';
import '../../models/exercise.dart';
import '../../models/routine.dart';
import '../../data/default_routines.dart';
import 'package:notegym/core/theme_extension.dart';

class CreateRoutineScreen extends ConsumerStatefulWidget {
  final String? editingRoutineId;
  const CreateRoutineScreen({super.key, this.editingRoutineId});

  @override
  ConsumerState<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'strength';
  String _emoji = '💪';
  String _difficulty = 'Intermedio';
  int _minutes = 45;
  List<Exercise> _exercises = [];
  bool _isLoading = false;

  final _emojis = ['💪', '🔥', '⚡', '🏋️', '🧘', '🤸', '🏃', '🍑', '🦾', '📋'];
  final _types = {'strength': 'Fuerza', 'cardio': 'Cardio', 'hiit': 'HIIT', 'yoga': 'Yoga', 'flexibility': 'Flexibilidad'};
  final _difficulties = ['Principiante', 'Intermedio', 'Avanzado'];

  @override
  void initState() {
    super.initState();
    if (widget.editingRoutineId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final routine = ref.read(routinesProvider.notifier).getById(widget.editingRoutineId!);
        if (routine != null) _loadRoutine(routine);
      });
    }
  }

  void _loadRoutine(Routine r) {
    _nameCtrl.text = r.name;
    _descCtrl.text = r.description;
    setState(() {
      _type = r.type;
      _emoji = r.emoji;
      _difficulty = r.difficulty;
      _minutes = r.estimatedMinutes;
      _exercises = List.from(r.exercises);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Añade al menos un ejercicio'), backgroundColor: context.colors.error),
      );
      return;
    }
    setState(() => _isLoading = true);

    if (widget.editingRoutineId != null) {
      final existing = ref.read(routinesProvider.notifier).getById(widget.editingRoutineId!);
      if (existing != null) {
        await ref.read(routinesProvider.notifier).updateRoutine(
              existing.copyWith(
                name: _nameCtrl.text.trim(),
                description: _descCtrl.text.trim(),
                type: _type,
                emoji: _emoji,
                difficulty: _difficulty,
                estimatedMinutes: _minutes,
                exercises: _exercises,
              ),
            );
      }
    } else {
      await ref.read(routinesProvider.notifier).createRoutine(
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            type: _type,
            emoji: _emoji,
            difficulty: _difficulty,
            estimatedMinutes: _minutes,
            exercises: _exercises,
          );
    }

    setState(() => _isLoading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingRoutineId != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: context.colors.backgroundGradient)),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: GlassCard(
                          padding: EdgeInsets.all(10),
                          borderRadius: 12,
                          child: Icon(Icons.close_rounded, color: context.colors.textPrimary, size: 20),
                        ),
                      ),
                      Text(isEditing ? 'Editar Rutina' : 'Nueva Rutina',
                          style: Theme.of(context).textTheme.headlineMedium),
                      GestureDetector(
                        onTap: _save,
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          borderRadius: 12,
                          backgroundColor: context.colors.primary.withOpacity(0.3),
                          child: Text('Guardar', style: TextStyle(color: context.colors.primaryLight, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Emoji picker
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Emoji', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: _emojis.map((e) => GestureDetector(
                                    onTap: () => setState(() => _emoji = e),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _emoji == e
                                            ? context.colors.primary.withOpacity(0.3)
                                            : context.colors.glassWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: _emoji == e
                                            ? Border.all(color: context.colors.primary)
                                            : null,
                                      ),
                                      child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Name & Description
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameCtrl,
                                  style: TextStyle(color: context.colors.textPrimary),
                                  decoration: const InputDecoration(labelText: 'Nombre de la rutina'),
                                  validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _descCtrl,
                                  style: TextStyle(color: context.colors.textPrimary),
                                  maxLines: 2,
                                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Type, Difficulty, Duration
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tipo de entrenamiento', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _types.entries.map((e) => GestureDetector(
                                    onTap: () => setState(() => _type = e.key),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _type == e.key ? context.colors.primary.withOpacity(0.3) : context.colors.glassWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: _type == e.key ? Border.all(color: context.colors.primary) : null,
                                      ),
                                      child: Text(e.value, style: TextStyle(
                                        color: _type == e.key ? context.colors.primaryLight : context.colors.textSecondary,
                                        fontWeight: FontWeight.w500, fontSize: 13,
                                      )),
                                    ),
                                  )).toList(),
                                ),

                                const SizedBox(height: 16),
                                Text('Dificultad', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 10),
                                Row(
                                  children: _difficulties.map((d) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                        onTap: () => setState(() => _difficulty = d),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _difficulty == d ? context.colors.accent.withOpacity(0.2) : context.colors.glassWhite,
                                            borderRadius: BorderRadius.circular(10),
                                            border: _difficulty == d ? Border.all(color: context.colors.accent) : null,
                                          ),
                                          child: Center(child: Text(d, style: TextStyle(
                                            color: _difficulty == d ? context.colors.accent : context.colors.textMuted,
                                            fontSize: 12, fontWeight: FontWeight.w500,
                                          ))),
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                ),

                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Duración estimada: ${_minutes}min', style: Theme.of(context).textTheme.titleMedium),
                                  ],
                                ),
                                Slider(
                                  value: _minutes.toDouble(),
                                  min: 10,
                                  max: 120,
                                  divisions: 22,
                                  activeColor: context.colors.primary,
                                  inactiveColor: context.colors.glassWhite,
                                  onChanged: (v) => setState(() => _minutes = v.round()),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Exercises
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ejercicios (${_exercises.length})', style: Theme.of(context).textTheme.headlineMedium),
                              GestureDetector(
                                onTap: _showExercisePicker,
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  borderRadius: 10,
                                  backgroundColor: context.colors.primary.withOpacity(0.2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_rounded, color: context.colors.primaryLight, size: 16),
                                      SizedBox(width: 4),
                                      Text('Añadir', style: TextStyle(color: context.colors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (_exercises.isEmpty)
                            GlassCard(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded, color: context.colors.textMuted, size: 40),
                                    const SizedBox(height: 8),
                                    Text('Toca "Añadir" para agregar ejercicios', style: TextStyle(color: context.colors.textMuted)),
                                  ],
                                ),
                              ),
                            ),

                          ..._exercises.asMap().entries.map((e) => _ExerciseEditCard(
                            exercise: e.value,
                            index: e.key,
                            onRemove: () => setState(() => _exercises.removeAt(e.key)),
                            onEdit: (updated) => setState(() => _exercises[e.key] = updated),
                          )),

                          const SizedBox(height: 24),

                          if (_exercises.isNotEmpty)
                            GradientButton(
                              label: isEditing ? 'Guardar Cambios' : 'Crear Rutina',
                              icon: Icons.check_rounded,
                              onPressed: _save,
                              isLoading: _isLoading,
                            ),

                          const SizedBox(height: 60),
                        ],
                      ),
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

  void _showExercisePicker() async {
    final library = DefaultRoutines.exerciseLibrary;
    String search = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, ctrl) => Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40, height: 4,
                decoration: BoxDecoration(color: context.colors.glassBorder, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seleccionar ejercicio', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    TextField(
                      style: TextStyle(color: context.colors.textPrimary),
                      onChanged: (v) => setBS(() => search = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: Icon(Icons.search_rounded, color: context.colors.textMuted),
                        filled: true,
                        fillColor: context.colors.glassWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.colors.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.colors.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.colors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: library
                      .where((e) => e.name.toLowerCase().contains(search.toLowerCase()) ||
                          e.muscleGroup.toLowerCase().contains(search.toLowerCase()))
                      .length,
                  itemBuilder: (_, i) {
                    final filtered = library
                        .where((e) => e.name.toLowerCase().contains(search.toLowerCase()) ||
                            e.muscleGroup.toLowerCase().contains(search.toLowerCase()))
                        .toList();
                    final ex = filtered[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: (context.colors.muscleColors[ex.muscleGroup] ?? context.colors.primary).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.fitness_center_rounded,
                          color: context.colors.muscleColors[ex.muscleGroup] ?? context.colors.primary, size: 18),
                      ),
                      title: Text(ex.name, style: TextStyle(color: context.colors.textPrimary, fontSize: 14)),
                      subtitle: Text(ex.muscleGroup, style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                      trailing: Icon(Icons.add_circle_outline_rounded, color: context.colors.primaryLight),
                      onTap: () {
                        setState(() => _exercises.add(ex.copyWith(id: const Uuid().v4())));
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseEditCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<Exercise> onEdit;

  const _ExerciseEditCard({
    required this.exercise,
    required this.index,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (context.colors.muscleColors[exercise.muscleGroup] ?? context.colors.primary).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text('${index + 1}', style: TextStyle(
                    color: context.colors.muscleColors[exercise.muscleGroup] ?? context.colors.primary,
                    fontWeight: FontWeight.w700, fontSize: 13,
                  ))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(exercise.name, style: Theme.of(context).textTheme.titleMedium)),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.delete_outline_rounded, color: context.colors.error, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _NumInput(
                  label: 'Series',
                  value: exercise.defaultSets,
                  onChanged: (v) => onEdit(exercise.copyWith(defaultSets: v)),
                ),
                const SizedBox(width: 8),
                _NumInput(
                  label: 'Reps',
                  value: exercise.defaultReps,
                  onChanged: (v) => onEdit(exercise.copyWith(defaultReps: v)),
                ),
                const SizedBox(width: 8),
                _NumInput(
                  label: 'Peso (kg)',
                  value: exercise.defaultWeight.toInt(),
                  onChanged: (v) => onEdit(exercise.copyWith(defaultWeight: v.toDouble())),
                ),
                const SizedBox(width: 8),
                _NumInput(
                  label: 'Descanso (s)',
                  value: exercise.restSeconds,
                  onChanged: (v) => onEdit(exercise.copyWith(restSeconds: v)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumInput extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumInput({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.glassWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.glassBorder),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: context.colors.textSecondary),
            ),
            Text('$value', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            GestureDetector(
              onTap: () { if (value > 0) onChanged(value - 1); },
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.colors.textSecondary),
            ),
            Text(label, style: TextStyle(fontSize: 9, color: context.colors.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
