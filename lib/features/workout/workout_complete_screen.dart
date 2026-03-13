import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../workout/workout_logs_provider.dart';
import 'package:notegym/core/theme_extension.dart';

class WorkoutCompleteScreen extends ConsumerWidget {
  final String logId;
  const WorkoutCompleteScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.read(workoutLogsProvider.notifier).getById(logId);
    if (log == null) {
      return Scaffold(body: Center(child: Text('Log no encontrado')));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: context.colors.backgroundGradient)),
          Positioned(
            top: -40, left: -40,
            child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.success.withOpacity(0.15))),
          ),
          Positioned(
            bottom: 80, right: -40,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.accent.withOpacity(0.1))),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy icon
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [context.colors.success, context.colors.success.withOpacity(0.6)]),
                      boxShadow: [BoxShadow(color: context.colors.success.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 52),
                  ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  Text('¡Entrenamiento Completado!',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),

                  Text(log.routineName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.textSecondary),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 36),

                  // Stats
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(label: 'Duración', value: log.durationFormatted, icon: Icons.timer_outlined, color: context.colors.primary),
                        _divider(context),
                        _Stat(label: 'Series', value: '${log.totalSets}', icon: Icons.repeat_rounded, color: context.colors.accent),
                        _divider(context),
                        _Stat(label: 'Volumen', value: '${log.totalVolume.toStringAsFixed(0)}kg', icon: Icons.monitor_weight_outlined, color: context.colors.success),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 40),

                  GradientButton(
                    label: 'Volver al inicio',
                    icon: Icons.home_rounded,
                    onPressed: () => context.go('/home'),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 12),

                  OutlinedGlassButton(
                    label: 'Ver historial',
                    icon: Icons.history_rounded,
                    onPressed: () => context.go('/history'),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(width: 1, height: 48, color: context.colors.glassBorder);
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Stat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: context.colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
      ],
    );
  }
}
