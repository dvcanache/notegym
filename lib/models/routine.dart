import 'exercise.dart';

class Routine {
  final String id;
  String name;
  String description;
  String type;
  List<Exercise> exercises;
  bool isDefault;
  String emoji;
  int estimatedMinutes;
  String difficulty;
  final DateTime createdAt;

  Routine({
    required this.id,
    required this.name,
    this.description = '',
    this.type = 'strength',
    this.exercises = const [],
    this.isDefault = false,
    this.emoji = '💪',
    this.estimatedMinutes = 45,
    this.difficulty = 'Intermedio',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Routine copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    List<Exercise>? exercises,
    bool? isDefault,
    String? emoji,
    int? estimatedMinutes,
    String? difficulty,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      exercises: exercises ?? this.exercises,
      isDefault: isDefault ?? this.isDefault,
      emoji: emoji ?? this.emoji,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isDefault': isDefault,
        'emoji': emoji,
        'estimatedMinutes': estimatedMinutes,
        'difficulty': difficulty,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        type: json['type'] as String? ?? 'strength',
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isDefault: json['isDefault'] as bool? ?? false,
        emoji: json['emoji'] as String? ?? '💪',
        estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 45,
        difficulty: json['difficulty'] as String? ?? 'Intermedio',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
