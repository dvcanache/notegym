class SetLog {
  final int reps;
  final double weight;
  final bool completed;
  final String exerciseId;
  final String exerciseName;

  SetLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.reps,
    this.weight = 0,
    this.completed = true,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'reps': reps,
        'weight': weight,
        'completed': completed,
      };

  factory SetLog.fromJson(Map<String, dynamic> json) => SetLog(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        reps: (json['reps'] as num).toInt(),
        weight: (json['weight'] as num?)?.toDouble() ?? 0,
        completed: json['completed'] as bool? ?? true,
      );
}

class WorkoutLog {
  final String id;
  final String routineId;
  final String routineName;
  final DateTime date;
  final int durationSeconds;
  final List<SetLog> sets;
  final String? notes;

  WorkoutLog({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.date,
    required this.durationSeconds,
    required this.sets,
    this.notes,
  });

  double get totalVolume =>
      sets.where((s) => s.completed).fold(0, (sum, s) => sum + s.weight * s.reps);

  int get totalSets => sets.where((s) => s.completed).length;

  int get totalReps => sets.where((s) => s.completed).fold(0, (sum, s) => sum + s.reps);

  String get durationFormatted {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'routineId': routineId,
        'routineName': routineName,
        'date': date.toIso8601String(),
        'durationSeconds': durationSeconds,
        'sets': sets.map((s) => s.toJson()).toList(),
        'notes': notes,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String,
        routineId: json['routineId'] as String,
        routineName: json['routineName'] as String,
        date: DateTime.parse(json['date'] as String),
        durationSeconds: (json['durationSeconds'] as num).toInt(),
        sets: (json['sets'] as List<dynamic>)
            .map((s) => SetLog.fromJson(s as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
      );
}
