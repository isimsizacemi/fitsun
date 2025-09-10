class Exercise {
  final String name;
  final int sets;
  final int reps;
  final String? weight; // "bodyweight", "5kg", etc.
  final int? restSeconds;
  final String? notes;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.restSeconds,
    this.notes,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    // reps alanı string veya int olabilir
    int repsValue = 0;
    if (map['reps'] != null) {
      if (map['reps'] is String) {
        // "8-12" gibi string'den ilk sayıyı al
        final repsStr = map['reps'].toString();
        final match = RegExp(r'(\d+)').firstMatch(repsStr);
        repsValue = match != null ? int.parse(match.group(1)!) : 0;
      } else {
        repsValue = map['reps'] as int? ?? 0;
      }
    }

    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: repsValue,
      weight: map['weight'],
      restSeconds: map['restSeconds'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }
}

class WorkoutDay {
  final String dayName; // "Monday", "Tuesday", etc.
  final String focus; // "Upper Body", "Lower Body", "Cardio", etc.
  final List<Exercise> exercises;
  final int? estimatedDuration; // minutes
  final String? notes;

  WorkoutDay({
    required this.dayName,
    required this.focus,
    required this.exercises,
    this.estimatedDuration,
    this.notes,
  });

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      dayName: map['dayName'] ?? map['title'] ?? '',
      focus: map['focus'] ?? map['muscleGroups']?.join(', ') ?? '',
      exercises:
          (map['exercises'] as List?)
              ?.map((e) => Exercise.fromMap(e))
              .toList() ??
          [],
      estimatedDuration:
          map['estimatedDuration'] ?? _parseDuration(map['duration']),
      notes: map['notes'],
    );
  }

  static int? _parseDuration(dynamic duration) {
    if (duration == null) return null;
    final durationStr = duration.toString();
    final match = RegExp(r'(\d+)').firstMatch(durationStr);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'focus': focus,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'estimatedDuration': estimatedDuration,
      'notes': notes,
    };
  }
}

class WorkoutProgram {
  final String id;
  final String userId;
  final String programName;
  final String description;
  final int durationWeeks;
  final List<WorkoutDay> weeklySchedule;
  final String difficulty;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  WorkoutProgram({
    required this.id,
    required this.userId,
    required this.programName,
    required this.description,
    required this.durationWeeks,
    required this.weeklySchedule,
    required this.difficulty,
    required this.createdAt,
    this.metadata,
  });

  factory WorkoutProgram.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutProgram(
      id: id,
      userId: map['userId'] ?? '',
      programName: map['programName'] ?? '',
      description: map['description'] ?? '',
      durationWeeks: map['durationWeeks'] ?? 0,
      weeklySchedule:
          (map['weeklySchedule'] as List?)
              ?.map((e) => WorkoutDay.fromMap(e))
              .toList() ??
          [],
      difficulty: map['difficulty'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'programName': programName,
      'description': description,
      'durationWeeks': durationWeeks,
      'weeklySchedule': weeklySchedule.map((e) => e.toMap()).toList(),
      'difficulty': difficulty,
      'createdAt': createdAt,
      'metadata': metadata,
    };
  }
}
