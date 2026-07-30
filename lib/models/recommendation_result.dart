enum ProgressionAction { increment, maintain, deload }

class RecommendationResult {
  final double suggestedWeight;
  final int suggestedReps;
  final ProgressionAction action;
  final String reason;

  const RecommendationResult({
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.action,
    required this.reason,
  });
}
