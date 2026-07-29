import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../auth/auth_provider.dart';
import '../routines/routines_provider.dart';
import '../workout/workout_logs_provider.dart';
import 'package:notegym/core/theme_extension.dart';
import 'package:notegym/features/assessment/presentation/providers/assessment_provider.dart';
import 'package:notegym/models/assessment.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final profile = auth.profile;
    final logs = ref.watch(workoutLogsProvider);
    final routines = ref.watch(routinesProvider);
    final weekLogs = ref.watch(workoutLogsProvider.notifier).getWeekLogs();

    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final dateStr = DateFormat("EEEE, d 'de' MMMM", 'es').format(now);

    final assessments = ref.watch(assessmentProvider).assessments;
    final lastAssessment = assessments.isEmpty
        ? null
        : assessments.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final hasCheckinThisWeek = lastAssessment != null &&
        lastAssessment.date.isAfter(now.subtract(const Duration(days: 7)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration:
                BoxDecoration(gradient: context.colors.backgroundGradient),
          ),
          // Purple glow top
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(greeting,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text(
                                profile?.name ?? 'Atleta',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                dateStr,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: context.colors.textMuted,
                                        fontSize: 12),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.go('/profile'),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: context.colors.purpleOrangeGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  profile?.name.isNotEmpty == true
                                      ? profile!.name[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 28),

                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Entrenos esta semana',
                              value: '${weekLogs.length}',
                              icon: Icons.calendar_today_rounded,
                              color: context.colors.primary,
                            )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideX(begin: -0.2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Racha actual',
                              value: '${profile?.currentStreak ?? 0} días',
                              icon: Icons.local_fire_department_rounded,
                              color: context.colors.accent,
                            )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideX(begin: 0.2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Total entrenos',
                              value: '${profile?.totalWorkouts ?? 0}',
                              icon: Icons.fitness_center_rounded,
                              color: context.colors.success,
                            )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideX(begin: 0.2),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Check-In Semanal
                      _WellnessCheckinCard(
                        hasThisWeek: hasCheckinThisWeek,
                        lastAssessment: lastAssessment,
                        onTap: () => context.push('/assessment'),
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 28),

                      // Week day tracker
                      _WeekDayTracker(weekLogs: weekLogs)
                          .animate()
                          .fadeIn(delay: 500.ms),

                      const SizedBox(height: 28),

                      // Quick start section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Inicio Rápido',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton(
                            onPressed: () => context.go('/routines'),
                            child: Text(
                              'Ver todas',
                              style: TextStyle(
                                  color: context.colors.primaryLight,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 12),

                      // Routine cards (first 3 defaults)
                      ...routines
                          .where((r) => r.isDefault)
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _QuickRoutineCard(
                                routine: e.value,
                                onTap: () => context.go(
                                  '/routines/detail/${e.value.id}',
                                  extra: {'fromHome': true},
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: (700 + e.key * 100).ms)
                                  .slideY(begin: 0.15),
                            ),
                          ),

                      const SizedBox(height: 80), // bottom nav space
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return '¡Buenos días! 🌅';
    if (hour < 18) return '¡Buenas tardes! ☀️';
    return '¡Buenas noches! 🌙';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WellnessCheckinCard extends StatelessWidget {
  final bool hasThisWeek;
  final Assessment? lastAssessment;
  final VoidCallback onTap;

  const _WellnessCheckinCard({
    required this.hasThisWeek,
    required this.lastAssessment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (!hasThisWeek || lastAssessment == null) return _buildPrompt(colors);

    final score = lastAssessment!.wellnessScore;
    final scoreColor = score >= 80
        ? colors.success
        : (score >= 50 ? Colors.amber : colors.error);
    final label = score >= 80
        ? 'Excelente recuperación'
        : (score >= 60
            ? 'Buena recuperación'
            : (score >= 40 ? 'Recuperación regular' : 'Necesita atención'));

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 5,
                  backgroundColor: colors.glassBorder,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${score.round()}',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-In Semanal',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              color: colors.textMuted, size: 16),
        ],
      ),
    );
  }

  Widget _buildPrompt(AppColorsExtension colors) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      backgroundColor: colors.primary.withValues(alpha: 0.08),
      borderColor: colors.primary.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: colors.purpleOrangeGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.health_and_safety_outlined,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-In Semanal',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Evalúa tu recuperación para ajustar tu entrenamiento',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GradientButton(
            label: 'Comenzar',
            width: 110,
            height: 38,
            fontSize: 13,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _WeekDayTracker extends StatelessWidget {
  final List logs;
  const _WeekDayTracker({required this.weekLogs}) : logs = weekLogs;
  final List weekLogs;

  @override
  Widget build(BuildContext context) {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Días activos esta semana',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final day = weekStart.add(Duration(days: i));
              final isToday = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              final hasLog = weekLogs.any((l) {
                final ld = l.date;
                return ld.day == day.day &&
                    ld.month == day.month &&
                    ld.year == day.year;
              });
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient:
                          hasLog ? context.colors.purpleOrangeGradient : null,
                      color: hasLog
                          ? null
                          : (isToday
                              ? context.colors.primary.withValues(alpha: 0.2)
                              : context.colors.glassWhite),
                      shape: BoxShape.circle,
                      border: isToday && !hasLog
                          ? Border.all(
                              color: context.colors.primary, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: hasLog
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : Text(
                              days[i],
                              style: TextStyle(
                                color: isToday
                                    ? context.colors.primaryLight
                                    : context.colors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday
                          ? context.colors.primaryLight
                          : context.colors.textMuted,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuickRoutineCard extends StatelessWidget {
  final dynamic routine;
  final VoidCallback onTap;

  const _QuickRoutineCard({required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: context.colors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                routine.emoji ?? '💪',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(context, Icons.timer_outlined,
                        '${routine.estimatedMinutes}min'),
                    const SizedBox(width: 8),
                    _chip(context, Icons.fitness_center_outlined,
                        '${routine.exercises.length} ejercicios'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.play_arrow_rounded,
                color: context.colors.primaryLight, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: context.colors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
      ],
    );
  }
}
