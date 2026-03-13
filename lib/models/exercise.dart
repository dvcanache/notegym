class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String description;
  final String? equipment;
  int defaultSets;
  int defaultReps;
  double defaultWeight;
  int restSeconds;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.description = '',
    this.equipment,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeight = 0,
    this.restSeconds = 60,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? description,
    String? equipment,
    int? defaultSets,
    int? defaultReps,
    double? defaultWeight,
    int? restSeconds,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      equipment: equipment ?? this.equipment,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'description': description,
        'equipment': equipment,
        'defaultSets': defaultSets,
        'defaultReps': defaultReps,
        'defaultWeight': defaultWeight,
        'restSeconds': restSeconds,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        muscleGroup: json['muscleGroup'] as String,
        description: json['description'] as String? ?? '',
        equipment: json['equipment'] as String?,
        defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
        defaultReps: (json['defaultReps'] as num?)?.toInt() ?? 10,
        defaultWeight: (json['defaultWeight'] as num?)?.toDouble() ?? 0,
        restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 60,
      );
}
