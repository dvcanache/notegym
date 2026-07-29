class UserProfile {
  final String id;
  String name;
  String email;
  String? photoUrl;
  String? goal;
  String? tenantId;
  int totalWorkouts;
  int currentStreak;
  int bestStreak;
  final DateTime joinDate;
  DateTime? lastWorkoutDate;
  double? weightKg;
  double? heightCm;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.goal,
    this.tenantId,
    this.totalWorkouts = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    DateTime? joinDate,
    this.lastWorkoutDate,
    this.weightKg,
    this.heightCm,
  }) : joinDate = joinDate ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? goal,
    String? tenantId,
    int? totalWorkouts,
    int? currentStreak,
    int? bestStreak,
    DateTime? joinDate,
    DateTime? lastWorkoutDate,
    double? weightKg,
    double? heightCm,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      goal: goal ?? this.goal,
      tenantId: tenantId ?? this.tenantId,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      joinDate: joinDate ?? this.joinDate,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'goal': goal,
        'tenantId': tenantId,
        'totalWorkouts': totalWorkouts,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'joinDate': joinDate.toIso8601String(),
        'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
        'weightKg': weightKg,
        'heightCm': heightCm,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String?,
        goal: json['goal'] as String?,
        tenantId: json['tenantId'] as String?,
        totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
        joinDate: json['joinDate'] != null
            ? DateTime.parse(json['joinDate'] as String)
            : DateTime.now(),
        lastWorkoutDate: json['lastWorkoutDate'] != null
            ? DateTime.parse(json['lastWorkoutDate'] as String)
            : null,
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        heightCm: (json['heightCm'] as num?)?.toDouble(),
      );
}
