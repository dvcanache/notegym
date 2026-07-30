import 'package:notegym/models/recommendation_result.dart';

class RecommendationEngine {
  static const _weightIncrement = 2.5;
  static const _deloadFactor = 0.9;
  static const _minWellnessThreshold = 40.0;
  static const _moderateWellnessThreshold = 60.0;

  RecommendationResult calculateRecommendation({
    required double averageRir,
    required double lastWeight,
    required int lastReps,
    required double wellnessScore,
  }) {
    final base = _baseRecommendation(averageRir, lastWeight, lastReps);
    return _applyWellnessCorrection(base, wellnessScore);
  }

  _RawRecommendation _baseRecommendation(
    double averageRir,
    double lastWeight,
    int lastReps,
  ) {
    if (averageRir <= 1) {
      return _RawRecommendation(
        suggestedWeight: (lastWeight * _deloadFactor / 2.5).round() * 2.5,
        suggestedReps: lastReps,
        action: ProgressionAction.deload,
        reason:
            'RIR $averageRir — muy cerca del fallo. Recomendamos descarga (${_deloadFactor}x) para recuperación.',
      );
    }

    if (averageRir == 2) {
      return _RawRecommendation(
        suggestedWeight: lastWeight + _weightIncrement,
        suggestedReps: lastReps,
        action: ProgressionAction.maintain,
        reason:
            'RIR $averageRir — esfuerzo óptimo. Mantén peso o sube ligeramente (+${_weightIncrement}kg).',
      );
    }

    return _RawRecommendation(
      suggestedWeight: lastWeight + _weightIncrement * 2,
      suggestedReps: lastReps + 1,
      action: ProgressionAction.increment,
      reason:
          'RIR $averageRir — sobraron reps. Incrementa peso (+${_weightIncrement * 2}kg) o reps (+1).',
    );
  }

  RecommendationResult _applyWellnessCorrection(
    _RawRecommendation base,
    double wellnessScore,
  ) {
    if (wellnessScore >= _moderateWellnessThreshold) {
      return RecommendationResult(
        suggestedWeight: base.suggestedWeight,
        suggestedReps: base.suggestedReps,
        action: base.action,
        reason:
            '${base.reason} Bienestar óptimo ($wellnessScore/100). Sin ajustes.',
      );
    }

    if (wellnessScore >= _minWellnessThreshold) {
      if (base.action == ProgressionAction.increment) {
        return RecommendationResult(
          suggestedWeight: base.suggestedWeight - _weightIncrement,
          suggestedReps: base.suggestedReps - 1,
          action: ProgressionAction.maintain,
          reason:
              '${base.reason} Bienestar moderado ($wellnessScore/100) — mantenemos carga para evitar riesgo.',
        );
      }

      return RecommendationResult(
        suggestedWeight: base.suggestedWeight,
        suggestedReps: base.suggestedReps,
        action: base.action,
        reason:
            '${base.reason} Bienestar moderado ($wellnessScore/100) — se recomienda precaución.',
      );
    }

    return RecommendationResult(
      suggestedWeight: (base.suggestedWeight * _deloadFactor / 2.5).round() * 2.5,
      suggestedReps: (base.suggestedReps * _deloadFactor).round(),
      action: ProgressionAction.deload,
      reason:
          'Bienestar bajo ($wellnessScore/100). Prioriza recuperación — reducimos carga.',
    );
  }
}

class _RawRecommendation {
  final double suggestedWeight;
  final int suggestedReps;
  final ProgressionAction action;
  final String reason;

  const _RawRecommendation({
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.action,
    required this.reason,
  });
}
