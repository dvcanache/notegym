import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../routines/routines_provider.dart';
import '../../models/routine.dart';
import 'excel/excel_export_service.dart';
import 'package:notegym/core/theme_extension.dart';

class RoutineDetailScreen extends ConsumerWidget {
  final String routineId;
  final Map<String, dynamic>? extra;

  const RoutineDetailScreen({super.key, required this.routineId, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final routine = routines.firstWhere(
      (r) => r.id == routineId,
      orElse: () => Routine(id: '', name: 'No encontrada'),
    );

    if (routine.id.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Rutina no encontrada',
              style: TextStyle(color: context.colors.textPrimary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: context.colors.backgroundGradient),
          ),
          // Color accent top
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withOpacity(0.15),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                backgroundColor: Colors.transparent,
                pinned: true,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: GlassCard(
                      borderRadius: 12,
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => ExcelExportService.exportRoutine(context, routine),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Icon(Icons.download_outlined, color: context.colors.accent, size: 16),
                            const SizedBox(width: 6),
                            Text('Exportar', style: TextStyle(color: context.colors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colors.primary.withOpacity(0.4), context.colors.background],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(routine.emoji, style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(routine.name, style: Theme.of(context).textTheme.displayMedium),
                            Text(routine.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Info chips
                    Row(
                      children: [
                        _InfoChip(icon: Icons.timer_outlined, text: '${routine.estimatedMinutes} min'),
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.signal_cellular_alt_rounded, text: routine.difficulty),
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.fitness_center_outlined,
                            text: '${routine.exercises.length} ejercicios'),
                      ],
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 24),

                    Text('Ejercicios', style: Theme.of(context).textTheme.headlineMedium)
                        .animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),

                    // Exercises list
                    ...routine.exercises.asMap().entries.map((e) {
                      final ex = e.value;
                      final i = e.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: (context.colors.muscleColors[ex.muscleGroup] ??
                                          context.colors.primary)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: context.colors.muscleColors[ex.muscleGroup] ??
                                          context.colors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ex.name, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (context.colors.muscleColors[ex.muscleGroup] ??
                                                context.colors.primary)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ex.muscleGroup,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.muscleColors[ex.muscleGroup] ?? context.colors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${ex.defaultSets} × ${ex.defaultReps}',
                                    style: TextStyle(
                                      color: context.colors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (ex.defaultWeight > 0)
                                    Text(
                                      '${ex.defaultWeight.toStringAsFixed(0)} kg',
                                      style: TextStyle(color: context.colors.textMuted, fontSize: 11),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (300 + i * 50).ms).slideY(begin: 0.1),
                      );
                    }),

                    const SizedBox(height: 24),

                    GradientButton(
                      label: '¡Iniciar Entrenamiento!',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.push(
                        '/workout/active',
                        extra: {'routineId': routine.id},
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: 10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.colors.textSecondary),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
