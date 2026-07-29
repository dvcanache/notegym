import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:notegym/core/theme_extension.dart';
import 'package:notegym/widgets/glass_card.dart';
import 'package:notegym/widgets/gradient_button.dart';
import 'package:notegym/features/onboarding/onboarding_provider.dart';

const _fitnessLevels = ['Principiante', 'Intermedio', 'Avanzado'];
const _fitnessSubtitles = [
  'Menos de 6 meses entrenando constantemente.',
  'Entre 6 meses y 2 años de experiencia continua.',
  'Más de 2 años aplicando sobrecarga progresiva.',
];
const _somatotypes = ['Ectomorfo', 'Mesomorfo', 'Endomorfo', 'No estoy seguro'];
const _somaSubtitles = [
  'Delgado por naturaleza, metabolismo rápido.',
  'Estructura atlética, facilita ganancia muscular.',
  'Estructura grande, tiende a acumular grasa fácilmente.',
  'Aún no conozco bien mi tipo de cuerpo.',
];
const _goals = ['Fuerza', 'Hipertrofia', 'Resistencia', 'Pérdida de peso'];
const _goalSubtitles = [
  'Priorizar levantar más peso en básicos.',
  'Maximizar el crecimiento muscular.',
  'Mejorar capacidad aeróbica y cardiovascular.',
  'Reducir porcentaje de grasa corporal.',
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0;

  String? _fitnessLevel;
  String? _somatotype;
  int _weeklyDays = 3;
  String? _primaryGoal;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  bool get _canGoNext {
    switch (_currentStep) {
      case 0: return _fitnessLevel != null;
      case 1: return _somatotype != null;
      case 2: return _primaryGoal != null;
      default: return false;
    }
  }

  bool get _isLastStep => _currentStep == 2;

  void _next() {
    if (_isLastStep) return;
    _pageCtrl.nextPage(duration: 300.ms, curve: Curves.easeInOut);
  }

  void _back() {
    if (_currentStep == 0) return;
    _pageCtrl.previousPage(duration: 300.ms, curve: Curves.easeInOut);
  }

  Future<void> _finish() async {
    if (_fitnessLevel == null || _somatotype == null || _primaryGoal == null) return;
    await ref.read(onboardingProvider.notifier).completeOnboarding(
      fitnessLevel: _fitnessLevel!,
      somatotype: _somatotype!,
      weeklyDays: _weeklyDays,
      primaryGoal: _primaryGoal!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(onboardingProvider).isLoading;

    ref.listen<OnboardingState>(onboardingProvider, (_, next) {
      if (next.isCompleted && mounted) {
        GoRouter.of(context).go('/home');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E), Color(0xFF0D0D1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -80, left: -80,
            child: _GlowOrb(color: context.colors.primary.withValues(alpha: 0.25), size: 300),
          ),
          Positioned(
            bottom: 80, right: -60,
            child: _GlowOrb(color: context.colors.accent.withValues(alpha: 0.2), size: 250),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _ProgressDots(count: 3, current: _currentStep, colors: context.colors),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StepFitnessLevel(
                        selected: _fitnessLevel,
                        onSelect: (v) => setState(() => _fitnessLevel = v),
                      ),
                      _StepSomatotype(
                        selected: _somatotype,
                        onSelect: (v) => setState(() => _somatotype = v),
                      ),
                      _StepGoals(
                        selectedGoal: _primaryGoal,
                        weeklyDays: _weeklyDays,
                        onGoalSelect: (v) => setState(() => _primaryGoal = v),
                        onDaysChanged: (v) => setState(() => _weeklyDays = v),
                      ),
                    ],
                  ),
                ),
                _BottomNav(
                  currentStep: _currentStep,
                  canGoNext: _canGoNext,
                  isLoading: isLoading,
                  onBack: _back,
                  onNext: _next,
                  onFinish: _finish,
                  colors: context.colors,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Dots ─────────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  final int count;
  final int current;
  final AppColorsExtension colors;
  const _ProgressDots({required this.count, required this.current, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i <= current;
        return AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isActive ? colors.primary : colors.glassBorder,
            boxShadow: isActive
                ? [BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 8)]
                : null,
          ),
        );
      }),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentStep;
  final bool canGoNext;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final AppColorsExtension colors;

  const _BottomNav({
    required this.currentStep,
    required this.canGoNext,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentStep == 0;
    final isLast = currentStep == 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          if (!isFirst)
            SizedBox(
              height: 48,
              child: OutlinedGlassButton(
                label: 'Atrás',
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
            )
          else
            const SizedBox(width: 1),
          const Spacer(),
          if (isLast)
            SizedBox(
              width: 160,
              child: GradientButton(
                label: 'Finalizar',
                icon: Icons.check_rounded,
                isLoading: isLoading,
                onPressed: canGoNext ? onFinish : null,
              ),
            )
          else
            SizedBox(
              width: 160,
              child: GradientButton(
                label: 'Siguiente',
                icon: Icons.arrow_forward_rounded,
                onPressed: canGoNext ? onNext : null,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Selection Card ────────────────────────────────────────────
class _OptionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _OptionCard({
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      backgroundColor: selected ? colors.primary.withValues(alpha: 0.2) : colors.glassWhiteStrong,
      borderColor: selected ? colors.primary : colors.glassBorder,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: selected ? colors.primary : colors.textMuted, size: 22),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? colors.textPrimary : colors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AnimatedContainer(
              duration: 200.ms,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.primary : colors.textMuted,
                  width: 2,
                ),
                color: selected ? colors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Fitness Level ──────────────────────────────────────
class _StepFitnessLevel extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _StepFitnessLevel({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _Header(
            icon: Icons.fitness_center_rounded,
            title: 'Tu experiencia',
            subtitle: '¿Cuál es tu nivel actual de entrenamiento?',
            color: colors.primary,
            colors: colors,
          ),
          const SizedBox(height: 28),
          ...List.generate(_fitnessLevels.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionCard(
                label: _fitnessLevels[i],
                subtitle: _fitnessSubtitles[i],
                selected: selected == _fitnessLevels[i],
                onTap: () => onSelect(_fitnessLevels[i]),
                icon: [Icons.child_care_rounded, Icons.trending_up_rounded, Icons.local_fire_department_rounded][i],
              ).animate().fadeIn(delay: (200 + i * 100).ms).slideX(begin: 0.1),
            );
          }),
        ],
      ),
    );
  }
}

// ── Step 2: Somatotype ─────────────────────────────────────────
class _StepSomatotype extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _StepSomatotype({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _Header(
            icon: Icons.accessibility_new_rounded,
            title: 'Tu cuerpo',
            subtitle: '¿Cómo describirías tu composición corporal?',
            color: colors.accent,
            colors: colors,
          ),
          const SizedBox(height: 28),
          ...List.generate(_somatotypes.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionCard(
                label: _somatotypes[i],
                subtitle: _somaSubtitles[i],
                selected: selected == _somatotypes[i],
                onTap: () => onSelect(_somatotypes[i]),
                icon: const [
                  Icons.line_weight_rounded,
                  Icons.accessibility_new_rounded,
                  Icons.circle_rounded,
                  Icons.help_outline_rounded,
                ][i],
              ).animate().fadeIn(delay: (200 + i * 80).ms).slideX(begin: 0.1),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'No te preocupes si no estás seguro. Puedes cambiarlo después.',
              style: TextStyle(color: colors.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Goals + Weekly Days ────────────────────────────────
class _StepGoals extends StatelessWidget {
  final String? selectedGoal;
  final int weeklyDays;
  final ValueChanged<String> onGoalSelect;
  final ValueChanged<int> onDaysChanged;

  const _StepGoals({
    required this.selectedGoal,
    required this.weeklyDays,
    required this.onGoalSelect,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _Header(
            icon: Icons.flag_rounded,
            title: 'Tus metas',
            subtitle: '¿Qué quieres lograr?',
            color: colors.success,
            colors: colors,
          ),
          const SizedBox(height: 28),
          ...List.generate(_goals.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionCard(
                label: _goals[i],
                subtitle: _goalSubtitles[i],
                selected: selectedGoal == _goals[i],
                onTap: () => onGoalSelect(_goals[i]),
                icon: const [
                  Icons.fitness_center_rounded,
                  Icons.airline_seat_flat_rounded,
                  Icons.directions_run_rounded,
                  Icons.monitor_weight_rounded,
                ][i],
              ).animate().fadeIn(delay: (200 + i * 80).ms).slideX(begin: 0.1),
            );
          }),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Días por semana',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¿Cuántos días planeas entrenar?',
                  style: TextStyle(color: colors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final isSelected = weeklyDays == day;
                    return GestureDetector(
                      onTap: () => onDaysChanged(day),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? colors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? Colors.white : colors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

// ── Shared Header ──────────────────────────────────────────────
class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final AppColorsExtension colors;

  const _Header({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: colors.purpleOrangeGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.7, 0.7)),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.3),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Glow Orb (reused from JoinScreen) ──────────────────────────
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox(),
      ),
    );
  }
}
