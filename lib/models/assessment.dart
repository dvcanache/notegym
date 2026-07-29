import 'package:cloud_firestore/cloud_firestore.dart';

class Assessment {
  final String id;
  final String userId;
  final DateTime date;
  final int sleepQuality;
  final int stressLevel;
  final int muscleSoreness;
  final int energyLevel;
  final int motivation;
  final double averageRir;
  final double wellnessScore;

  Assessment({
    required this.id,
    required this.userId,
    required this.date,
    required this.sleepQuality,
    required this.stressLevel,
    required this.muscleSoreness,
    required this.energyLevel,
    required this.motivation,
    required this.averageRir,
    double? wellnessScore,
  }) : wellnessScore = wellnessScore ?? _compute(
          sleepQuality, stressLevel, muscleSoreness, energyLevel, motivation, averageRir,
        );

  static double _compute(int sq, int sl, int ms, int en, int mo, double rir) {
    final normalized = [
      sq.toDouble(),
      6 - sl.toDouble(),
      6 - ms.toDouble(),
      en.toDouble(),
      mo.toDouble(),
    ];
    final rawAvg = normalized.reduce((a, b) => a + b) / 25 * 100;
    double adj = 0;
    if (rir <= 1.0) adj = 5;
    if (rir >= 3.0) adj = -5;
    return (rawAvg + adj).clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'sleepQuality': sleepQuality,
        'stressLevel': stressLevel,
        'muscleSoreness': muscleSoreness,
        'energyLevel': energyLevel,
        'motivation': motivation,
        'averageRir': averageRir,
        'wellnessScore': wellnessScore,
      };

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        id: json['id'] as String,
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        sleepQuality: (json['sleepQuality'] as num).toInt(),
        stressLevel: (json['stressLevel'] as num).toInt(),
        muscleSoreness: (json['muscleSoreness'] as num).toInt(),
        energyLevel: (json['energyLevel'] as num).toInt(),
        motivation: (json['motivation'] as num).toInt(),
        averageRir: (json['averageRir'] as num).toDouble(),
        wellnessScore: (json['wellnessScore'] as num).toDouble(),
      );

  factory Assessment.fromFirestore(String docId, Map<String, dynamic> data) => Assessment(
        id: docId,
        userId: data['userId'] as String,
        date: (data['date'] as Timestamp).toDate(),
        sleepQuality: (data['sleepQuality'] as num).toInt(),
        stressLevel: (data['stressLevel'] as num).toInt(),
        muscleSoreness: (data['muscleSoreness'] as num).toInt(),
        energyLevel: (data['energyLevel'] as num).toInt(),
        motivation: (data['motivation'] as num).toInt(),
        averageRir: (data['averageRir'] as num).toDouble(),
        wellnessScore: (data['wellnessScore'] as num).toDouble(),
      );
}
