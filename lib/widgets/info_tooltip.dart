import 'package:flutter/material.dart';
import '../core/theme_extension.dart';

const glossaryEntries = <_GlossaryEntry>[
  _GlossaryEntry(
    term: 'RIR (Repeticiones en Reserva)',
    definition:
        'Son las repeticiones que podrías haber hecho antes de llegar al fallo muscular. '
        'Por ejemplo, si haces 10 repeticiones pero sentías que podías hacer 2 más, '
        'ese es tu RIR. Entre más bajo el RIR, más intenso fue el ejercicio.\n\n'
        '• RIR 0 = Al fallo, no podías ni una más\n'
        '• RIR 2 = Podías hacer 2-3 repeticiones más\n'
        '• RIR 4-5 = Muy fácil, podías seguir\n\n'
        'Úsalo para medir qué tan intenso fue tu entrenamiento y ajustar la carga.',
  ),
  _GlossaryEntry(
    term: 'Wellness Score (Puntuación de Bienestar)',
    definition:
        'Es un número del 0 al 100 que resume cómo llegas a tu entrenamiento. '
        'Combina 5 factores: sueño, estrés, dolor muscular, energía y motivación.\n\n'
        '• 80+ → Excelente recuperación, puedes progresar\n'
        '• 50-79 → Recuperación moderada, mejor mantener\n'
        '• Menos de 50 → Alta fatiga, reduce carga\n\n'
        'También ajusta según el RIR de tu último entrenamiento.',
  ),
  _GlossaryEntry(
    term: 'Somatotipo',
    definition:
        'Es una forma de clasificar tu tipo de cuerpo. No es una etiqueta fija, '
        'sino una guía para entender cómo respondes al entrenamiento.\n\n'
        '• Ectomorfo: Cuerpo delgado, metabolismo rápido, '
        'cuesta ganar peso. Prioriza fuerza y pocas repeticiones.\n'
        '• Mesomorfo: Cuerpo atlético, gana músculo y fuerza '
        'con facilidad. Responde bien a cualquier estímulo.\n'
        '• Endomorfo: Tiende a acumular grasa, gana músculo '
        'pero también peso. Prioriza volumen y densidad.\n\n'
        'La mayoría de personas son una combinación de los tres.',
  ),
];

class _GlossaryEntry {
  final String term;
  final String definition;
  const _GlossaryEntry({required this.term, required this.definition});
}

class InfoTooltip extends StatelessWidget {
  final String term;
  final double iconSize;

  const InfoTooltip({super.key, required this.term, this.iconSize = 18});

  @override
  Widget build(BuildContext context) {
    final entry = glossaryEntries.where((e) => e.term == term).firstOrNull;
    if (entry == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showGlossary(context, entry),
      child: Container(
        width: iconSize + 4,
        height: iconSize + 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.glassWhite,
          border: Border.all(color: context.colors.textMuted.withValues(alpha: 0.4)),
        ),
        child: Icon(Icons.help_outline_rounded,
            size: iconSize - 4, color: context.colors.textMuted),
      ),
    );
  }

  void _showGlossary(BuildContext context, _GlossaryEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GlossarySheet(entry: entry),
    );
  }
}

class _GlossarySheet extends StatelessWidget {
  final _GlossaryEntry entry;
  const _GlossarySheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.glassBorder),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entry.term,
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.glassWhite,
                  ),
                  child: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(entry.definition,
              style: TextStyle(
                  color: colors.textPrimary.withValues(alpha: 0.85),
                  height: 1.6,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
