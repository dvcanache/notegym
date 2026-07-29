import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notegym/core/theme_extension.dart';
import 'package:notegym/widgets/glass_card.dart';
import 'package:notegym/widgets/gradient_button.dart';
import 'package:notegym/widgets/info_tooltip.dart';
import 'package:notegym/features/assessment/presentation/providers/assessment_provider.dart';
import 'package:notegym/features/auth/auth_provider.dart';
import 'package:notegym/models/assessment.dart';

class _Option {
  final int value;
  final String label;
  final String description;
  const _Option({required this.value, required this.label, required this.description});
}

class _Question {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_Option> options;
  final bool inverted;
  const _Question({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.options,
    this.inverted = false,
  });
}

const _questions = [
  _Question(
    key: 'sleepQuality',
    title: 'Calidad del sueño',
    subtitle: '¿Cómo calificas tu sueño esta semana?',
    icon: Icons.bed_rounded,
    options: [
      _Option(value: 1, label: 'Muy mala', description: 'Tuve problemas para dormir'),
      _Option(value: 2, label: 'Mala', description: 'Dormí poco y me desperté varias veces'),
      _Option(value: 3, label: 'Regular', description: 'Dormí lo justo, sin sentirme descansado'),
      _Option(value: 4, label: 'Buena', description: 'Dormí bien, me siento descansado'),
      _Option(value: 5, label: 'Excelente', description: 'Dormí profundo, me levanté con energía'),
    ],
  ),
  _Question(
    key: 'stress',
    title: 'Nivel de estrés',
    subtitle: '¿Cómo ha sido tu nivel de estrés?',
    icon: Icons.psychology_rounded,
    inverted: true,
    options: [
      _Option(value: 1, label: 'Muy alto', description: 'Estoy abrumado, no puedo relajarme'),
      _Option(value: 2, label: 'Alto', description: 'Bastante tenso, me cuesta desconectar'),
      _Option(value: 3, label: 'Moderado', description: 'Estrés normal de la semana'),
      _Option(value: 4, label: 'Bajo', description: 'He estado tranquilo casi siempre'),
      _Option(value: 5, label: 'Muy bajo', description: 'Muy relajado, sin preocupaciones'),
    ],
  ),
  _Question(
    key: 'muscleSoreness',
    title: 'Dolor muscular',
    subtitle: '¿Cómo sientes tu recuperación muscular?',
    icon: Icons.healing_rounded,
    inverted: true,
    options: [
      _Option(value: 1, label: 'Muy alto', description: 'Me duele mucho moverme'),
      _Option(value: 2, label: 'Alto', description: 'Molestias notables al entrenar'),
      _Option(value: 3, label: 'Moderado', description: 'Algo de dolor pero manejable'),
      _Option(value: 4, label: 'Bajo', description: 'Molestias leves'),
      _Option(value: 5, label: 'Ninguno', description: 'Sin dolor, completamente recuperado'),
    ],
  ),
  _Question(
    key: 'energyLevel',
    title: 'Nivel de energía',
    subtitle: '¿Cómo está tu energía?',
    icon: Icons.bolt_rounded,
    options: [
      _Option(value: 1, label: 'Muy bajo', description: 'Sin energía para nada'),
      _Option(value: 2, label: 'Bajo', description: 'Me cuesta arrancar el día'),
      _Option(value: 3, label: 'Regular', description: 'Energía normal'),
      _Option(value: 4, label: 'Bueno', description: 'Me siento con energía'),
      _Option(value: 5, label: 'Alto', description: 'Lleno de energía, listo para entrenar'),
    ],
  ),
  _Question(
    key: 'motivation',
    title: 'Motivación',
    subtitle: '¿Cómo está tu motivación para entrenar?',
    icon: Icons.emoji_events_rounded,
    options: [
      _Option(value: 1, label: 'Muy baja', description: 'No tengo ganas de entrenar'),
      _Option(value: 2, label: 'Baja', description: 'Prefiero hacer otra cosa'),
      _Option(value: 3, label: 'Regular', description: 'Puedo entrenar sin problemas'),
      _Option(value: 4, label: 'Alta', description: 'Quiero entrenar hoy'),
      _Option(value: 5, label: 'Máxima', description: 'Estoy ansioso por entrenar'),
    ],
  ),
];

const _rirOptions = [
  _Option(value: 0, label: '0 RIR', description: 'Al fallo, no podía ni una más'),
  _Option(value: 1, label: '1 RIR', description: 'Podía hacer 1 más con buena forma'),
  _Option(value: 2, label: '2 RIR', description: 'Podía hacer 2-3 más con buena forma'),
  _Option(value: 3, label: '3 RIR', description: 'Podía hacer 3-4 más'),
  _Option(value: 4, label: '4+ RIR', description: 'Podía hacer 5+ más, muy fácil'),
];

const _totalSteps = 6;

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  int _currentStep = 0;
  final Map<String, int> _answers = {};
  int _rir = 2;
  Assessment? _lastAssessment;
  bool _showResult = false;

  String get _currentKey => _questions[_currentStep].key;

  bool get _canProceed {
    if (_currentStep < 5) return _answers.containsKey(_currentKey);
    return true;
  }

  void _proceed() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    final authState = ref.read(authProvider);
    final uid = authState.profile?.id;
    if (uid == null) return;

    final a = _answers;
    await ref.read(assessmentProvider.notifier).submitAssessment(
      userId: uid,
      sleepQuality: a['sleepQuality']!,
      stressLevel: a['stress']!,
      muscleSoreness: a['muscleSoreness']!,
      energyLevel: a['energyLevel']!,
      motivation: a['motivation']!,
      averageRir: _rir.toDouble(),
    );

    if (!mounted) return;
    final last = ref.read(assessmentProvider).assessments.last;
    setState(() {
      _lastAssessment = last;
      _showResult = true;
      _currentStep = _totalSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSubmitting = ref.watch(assessmentProvider).isSubmitting;

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
            child: _GlowOrb(color: colors.primary.withValues(alpha: 0.25), size: 300),
          ),
          Positioned(
            bottom: 80, right: -60,
            child: _GlowOrb(color: colors.accent.withValues(alpha: 0.2), size: 250),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(colors),
                if (!_showResult) _buildProgress(colors),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showResult
                        ? _ResultPanel(assessment: _lastAssessment!, colors: colors)
                        : _buildCurrentStep(colors),
                  ),
                ),
                if (!_showResult) _buildBottomBar(colors, isSubmitting),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          Text(
            'Check-In Semanal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700, color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          if (!_showResult)
            Text(
              '${_currentStep + 1}/$_totalSteps',
              style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w500, fontSize: 13),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgress(AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (_currentStep + 1) / _totalSteps,
          minHeight: 4,
          backgroundColor: colors.glassBorder,
          valueColor: AlwaysStoppedAnimation(colors.primaryLight),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AppColorsExtension colors) {
    if (_currentStep < 5) {
      return _buildQuestionStep(colors);
    }
    return _buildRirStep(colors);
  }

  Widget _buildQuestionStep(AppColorsExtension colors) {
    final q = _questions[_currentStep];
    return SingleChildScrollView(
      key: ValueKey('q_$_currentStep'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(q.icon, color: colors.primaryLight, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(q.title,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),
              ),

            ],
          ),
          const SizedBox(height: 6),
          Text(q.subtitle,
              style: TextStyle(color: colors.textMuted, fontSize: 14)),
          const SizedBox(height: 20),
          ...q.options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildOptionCard(opt, _answers[q.key] == opt.value, colors),
              )),
        ],
      ),
    );
  }

  Widget _buildOptionCard(_Option opt, bool selected, AppColorsExtension colors, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _answers[_currentKey] = opt.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.15)
              : colors.glassWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.primaryLight.withValues(alpha: 0.6) : colors.glassBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.label,
                      style: TextStyle(
                          color: selected ? colors.primaryLight : colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(opt.description,
                      style: TextStyle(color: colors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colors.primaryLight : Colors.transparent,
                border: Border.all(
                  color: selected ? colors.primaryLight : colors.textMuted.withValues(alpha: 0.4),
                  width: selected ? 0 : 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRirStep(AppColorsExtension colors) {
    return SingleChildScrollView(
      key: const ValueKey('rir_step'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat_rounded, color: colors.accent, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Repeticiones en Reserva (RIR)',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),
              ),
              const InfoTooltip(term: 'RIR (Repeticiones en Reserva)', iconSize: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text('¿Cuántas repeticiones más podías hacer en tu último entrenamiento?',
              style: TextStyle(color: colors.textMuted, fontSize: 14)),
          const SizedBox(height: 20),
          ..._rirOptions.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildOptionCard(opt, _rir == opt.value, colors,
                    onTap: () => setState(() => _rir = opt.value)),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppColorsExtension colors, bool isSubmitting) {
    final isLast = _currentStep == _totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedGlassButton(
                label: 'Atrás',
                icon: Icons.arrow_back_rounded,
                onPressed: () => setState(() => _currentStep--),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 2 : 1,
            child: GradientButton(
              label: isLast ? 'Completar Check-In' : 'Siguiente',
              icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
              isLoading: isSubmitting,
              onPressed: _canProceed ? _proceed : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final Assessment assessment;
  final AppColorsExtension colors;

  const _ResultPanel({required this.assessment, required this.colors});

  @override
  Widget build(BuildContext context) {
    final score = assessment.wellnessScore;
    final (Color scoreColor, String label, _Reco rec) = score >= 80
        ? (colors.success, 'Excelente recuperación', _Reco.excellent)
        : (score >= 50
            ? (Colors.amber, 'Recuperación moderada', _Reco.moderate)
            : (colors.error, 'Alta fatiga', _Reco.poor));

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Text('Check-In Completado',
              style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 22)),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            borderRadius: 24,
            child: Column(
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: colors.glassBorder,
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                      Text('${score.round()}',
                          style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 32)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(label,
                    style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text('Puntuación de bienestar',
                    style: TextStyle(color: colors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(rec.icon, color: scoreColor, size: 22),
                    const SizedBox(width: 10),
                    Text('Recomendación para tu próximo entreno',
                        style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(rec.title,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                const SizedBox(height: 8),
                Text(rec.description,
                    style: TextStyle(
                        color: colors.textPrimary.withValues(alpha: 0.85),
                        height: 1.5,
                        fontSize: 14)),
                const SizedBox(height: 16),
                ...rec.tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: scoreColor, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(tip,
                                style: TextStyle(
                                    color: colors.textPrimary
                                        .withValues(alpha: 0.85),
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: 'Cerrar',
              icon: Icons.check_rounded,
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Reco {
  final IconData icon;
  final String title;
  final String description;
  final List<String> tips;

  const _Reco({
    required this.icon,
    required this.title,
    required this.description,
    required this.tips,
  });

  static const excellent = _Reco(
    icon: Icons.arrow_upward_rounded,
    title: 'Progresar carga normalmente',
    description:
        'Tu recuperación está en óptimas condiciones. Es buen momento para '
        'aumentar el estímulo de entrenamiento.',
    tips: [
      'Aumenta el peso de tu ejercicio principal (2.5-5 kg)',
      'O agrega 1-2 repeticiones por serie',
      'Mantén la buena técnica y el control del movimiento',
      'Aprovecha para trabajar con RIR 2-3',
    ],
  );

  static const moderate = _Reco(
    icon: Icons.pause_circle_outline_rounded,
    title: 'Mantener carga, cuidar técnica',
    description:
        'Tu recuperación es aceptable pero no óptima. Mejor mantener '
        'el volumen y enfocarte en la calidad del movimiento.',
    tips: [
      'Mantén los pesos actuales, no aumentes',
      'Concéntrate en la técnica y el control',
      'Usa tempo más lento (3-1-2) para mayor calidad',
      'Prioriza RIR 2-3, evita llegar al fallo',
    ],
  );

  static const poor = _Reco(
    icon: Icons.arrow_downward_rounded,
    title: 'Reducir carga, priorizar recuperación',
    description:
        'Tu cuerpo muestra signos de fatiga acumulada. Es importante '
        'reducir el estímulo para evitar sobreentrenamiento.',
    tips: [
      'Reduce el peso entre 10-20% en tus ejercicios principales',
      'Mantén un RIR alto (3-4), evita el fallo muscular',
      'Considera una sesión ligera o de descarga activa',
      'Prioriza el sueño y la alimentación esta semana',
    ],
  );
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: const SizedBox()),
    );
  }
}
