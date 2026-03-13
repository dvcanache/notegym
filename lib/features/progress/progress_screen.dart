import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../workout/workout_logs_provider.dart';
import '../../models/workout_log.dart';
import 'package:notegym/core/theme_extension.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutLogsProvider);

    final weekData = _getWeeklyData(logs);
    final volumeData = _getWeeklyVolume(logs);
    final prs = _getPersonalRecords(logs);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: context.colors.backgroundGradient)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progreso', style: Theme.of(context).textTheme.displayMedium)
                      .animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // Weekly frequency
                  Text('Frecuencia Semanal', style: Theme.of(context).textTheme.headlineMedium)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),

                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                    child: weekData.every((v) => v == 0)
                        ? SizedBox(
                            height: 140,
                            child: Center(child: Text('Completa entrenamientos para ver estadísticas', style: TextStyle(color: context.colors.textMuted), textAlign: TextAlign.center)),
                          )
                        : SizedBox(
                            height: 150,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (weekData.reduce((a, b) => a > b ? a : b).toDouble() + 1),
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                                        return Text(days[v.toInt()], style: TextStyle(color: context.colors.textMuted, fontSize: 11));
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: weekData.asMap().entries.map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [BarChartRodData(
                                    toY: e.value.toDouble(),
                                    gradient: context.colors.primaryGradient,
                                    width: 20,
                                    borderRadius: BorderRadius.circular(6),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: (weekData.reduce((a, b) => a > b ? a : b).toDouble() + 1),
                                      color: context.colors.glassWhite,
                                    ),
                                  )],
                                )).toList(),
                              ),
                            ),
                          ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Volume last 4 weeks
                  Text('Volumen Semanal (kg)', style: Theme.of(context).textTheme.headlineMedium)
                      .animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),

                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                    child: volumeData.every((v) => v == 0)
                        ? SizedBox(
                            height: 140,
                            child: Center(child: Text('Sin datos de volumen todavía', style: TextStyle(color: context.colors.textMuted))),
                          )
                        : SizedBox(
                            height: 150,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(color: context.colors.glassBorder, strokeWidth: 0.5),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        const labels = ['S4', 'S3', 'S2', 'S1'];
                                        if (v.toInt() < labels.length) {
                                          return Text(labels[v.toInt()], style: TextStyle(color: context.colors.textMuted, fontSize: 11));
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: volumeData.asMap().entries
                                        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                                        .toList(),
                                    isCurved: true,
                                    gradient: context.colors.purpleOrangeGradient,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                        radius: 4,
                                        color: context.colors.accent,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [context.colors.primary.withOpacity(0.3), context.colors.accent.withOpacity(0)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Personal Records
                  Text('Récords Personales (PRs)', style: Theme.of(context).textTheme.headlineMedium)
                      .animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 12),

                  if (prs.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text('Completa entrenamientos para ver tus PRs', style: TextStyle(color: context.colors.textMuted), textAlign: TextAlign.center),
                      ),
                    )
                  else
                    ...prs.entries.take(10).toList().asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.colors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('PR', style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w700, fontSize: 11)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(e.value.key, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              e.value.value > 0 ? '${e.value.value.toStringAsFixed(1)} kg' : 'BW',
                              style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (700 + e.key * 60).ms),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Count workouts per day this week
  List<int> _getWeeklyData(List<WorkoutLog> logs) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final counts = List.filled(7, 0);
    for (final log in logs) {
      if (log.date.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        final diff = log.date.difference(weekStart).inDays;
        if (diff >= 0 && diff < 7) counts[diff]++;
      }
    }
    return counts;
  }

  // Volume for last 4 weeks
  List<double> _getWeeklyVolume(List<WorkoutLog> logs) {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final weekStart = now.subtract(Duration(days: (3 - i) * 7 + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      return logs
          .where((l) => l.date.isAfter(weekStart) && l.date.isBefore(weekEnd))
          .fold<double>(0, (sum, l) => sum + l.totalVolume);
    });
  }

  // Max weight per exercise across all logs
  Map<String, double> _getPersonalRecords(List<WorkoutLog> logs) {
    final prs = <String, double>{};
    for (final log in logs) {
      for (final set in log.sets) {
        if (set.completed) {
          final current = prs[set.exerciseName] ?? 0;
          if (set.weight > current) {
            prs[set.exerciseName] = set.weight;
          }
        }
      }
    }
    return prs;
  }
}
