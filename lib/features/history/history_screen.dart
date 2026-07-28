import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_card.dart';
import '../workout/workout_logs_provider.dart';
import '../../models/workout_log.dart';
import 'package:notegym/core/theme_extension.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);

    // Group by week
    final grouped = <String, List<WorkoutLog>>{};
    for (final log in logs) {
      final weekKey = _weekKey(log.date);
      grouped.putIfAbsent(weekKey, () => []).add(log);
    }
    final weeks = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
              decoration:
                  BoxDecoration(gradient: context.colors.backgroundGradient)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Text('Historial',
                          style: Theme.of(context).textTheme.displayMedium)
                      .animate()
                      .fadeIn(delay: 100.ms),
                ),
                if (logs.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_outlined,
                              color: context.colors.textMuted, size: 56),
                          const SizedBox(height: 16),
                          Text('No hay entrenamientos todavía',
                              style: TextStyle(
                                  color: context.colors.textMuted,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('¡Completa tu primera rutina!',
                              style: TextStyle(
                                  color: context.colors.textMuted,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: weeks.length,
                      itemBuilder: (ctx, wi) {
                        final week = weeks[wi];
                        final weekLogs = grouped[week]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                week,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: context.colors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            ...weekLogs.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _LogCard(log: e.value)
                                      .animate()
                                      .fadeIn(delay: (wi * 100 + e.key * 60).ms)
                                      .slideY(begin: 0.1),
                                )),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weekKey(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff < 7) return 'Esta semana';
    if (diff < 14) return 'La semana pasada';
    final fmt = DateFormat("'Semana del' d 'de' MMMM", 'es');
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return fmt.format(weekStart);
  }
}

class _LogCard extends StatelessWidget {
  final WorkoutLog log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("EEEE, d MMM • HH:mm", 'es').format(log.date);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: context.colors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.routineName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(dateStr,
                        style: TextStyle(
                            color: context.colors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(
                  label: 'Duración',
                  value: log.durationFormatted,
                  icon: Icons.timer_outlined),
              const SizedBox(width: 12),
              _MiniStat(
                  label: 'Series',
                  value: '${log.totalSets}',
                  icon: Icons.repeat_rounded),
              const SizedBox(width: 12),
              _MiniStat(
                  label: 'Volumen',
                  value: '${log.totalVolume.toStringAsFixed(0)}kg',
                  icon: Icons.monitor_weight_outlined),
              const SizedBox(width: 12),
              _MiniStat(
                  label: 'Reps',
                  value: '${log.totalReps}',
                  icon: Icons.numbers_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: context.colors.glassWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 13, color: context.colors.textMuted),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Text(label,
                style: TextStyle(color: context.colors.textMuted, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
