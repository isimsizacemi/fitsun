import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSession {
  final String id;
  final String userId;
  final String programId;
  final String dayName;
  final int dayNumber;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? totalDuration; // dakika
  final bool isCompleted;
  final String? notes;
  final List<ExerciseSession> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.programId,
    required this.dayName,
    required this.dayNumber,
    required this.date,
    this.startTime,
    this.endTime,
    this.totalDuration,
    this.isCompleted = false,
    this.notes,
    this.exercises = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore'dan veri okuma
  factory WorkoutSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WorkoutSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      programId: data['programId'] ?? '',
      dayName: data['dayName'] ?? '',
      dayNumber: data['dayNumber'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      totalDuration: data['totalDuration'],
      isCompleted: data['isCompleted'] ?? false,
      notes: data['notes'],
      exercises:
          (data['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseSession.fromMap(e))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'programId': programId,
      'dayName': dayName,
      'dayNumber': dayNumber,
      'date': Timestamp.fromDate(date),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'totalDuration': totalDuration,
      'isCompleted': isCompleted,
      'notes': notes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Kopyalama (update için)
  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? programId,
    String? dayName,
    int? dayNumber,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? totalDuration,
    bool? isCompleted,
    String? notes,
    List<ExerciseSession>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      programId: programId ?? this.programId,
      dayName: dayName ?? this.dayName,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration: totalDuration ?? this.totalDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Antrenman süresini hesapla
  int? get calculatedDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!).inMinutes;
    }
    return totalDuration;
  }

  // Toplam egzersiz sayısı
  int get totalExercises => exercises.length;

  // Tamamlanan egzersiz sayısı
  int get completedExercises => exercises.where((e) => e.isCompleted).length;

  // Antrenman tamamlanma yüzdesi
  double get completionPercentage {
    if (exercises.isEmpty) return 0.0;
    return (completedExercises / totalExercises) * 100;
  }
}

class ExerciseSession {
  final String exerciseName;
  final int plannedSets;
  final int plannedReps;
  final List<int> actualReps; // her set için ayrı
  final List<double> weights; // her set için ayrı kg
  final int restSeconds;
  final bool isCompleted;
  final String? notes;
  final List<SetDetail> setDetails;

  ExerciseSession({
    required this.exerciseName,
    required this.plannedSets,
    required this.plannedReps,
    this.actualReps = const [],
    this.weights = const [],
    required this.restSeconds,
    this.isCompleted = false,
    this.notes,
    this.setDetails = const [],
  });

  // Map'ten oluşturma
  factory ExerciseSession.fromMap(Map<String, dynamic> data) {
    return ExerciseSession(
      exerciseName: data['exerciseName'] ?? '',
      plannedSets: data['plannedSets'] ?? 0,
      plannedReps: data['plannedReps'] ?? 0,
      actualReps: List<int>.from(data['actualReps'] ?? []),
      weights: List<double>.from(data['weights'] ?? []),
      restSeconds: data['restSeconds'] ?? 60,
      isCompleted: data['isCompleted'] ?? false,
      notes: data['notes'],
      setDetails:
          (data['setDetails'] as List<dynamic>?)
              ?.map((e) => SetDetail.fromMap(e))
              .toList() ??
          [],
    );
  }

  // Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'plannedSets': plannedSets,
      'plannedReps': plannedReps,
      'actualReps': actualReps,
      'weights': weights,
      'restSeconds': restSeconds,
      'isCompleted': isCompleted,
      'notes': notes,
      'setDetails': setDetails.map((e) => e.toMap()).toList(),
    };
  }

  // Kopyalama
  ExerciseSession copyWith({
    String? exerciseName,
    int? plannedSets,
    int? plannedReps,
    List<int>? actualReps,
    List<double>? weights,
    int? restSeconds,
    bool? isCompleted,
    String? notes,
    List<SetDetail>? setDetails,
  }) {
    return ExerciseSession(
      exerciseName: exerciseName ?? this.exerciseName,
      plannedSets: plannedSets ?? this.plannedSets,
      plannedReps: plannedReps ?? this.plannedReps,
      actualReps: actualReps ?? this.actualReps,
      weights: weights ?? this.weights,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      setDetails: setDetails ?? this.setDetails,
    );
  }

  // En yüksek ağırlık
  double get maxWeight {
    if (weights.isEmpty) return 0.0;
    return weights.reduce((a, b) => a > b ? a : b);
  }

  // Toplam tekrar sayısı
  int get totalActualReps {
    return actualReps.fold(0, (sum, reps) => sum + reps);
  }
}

class SetDetail {
  final int setNumber;
  final int reps;
  final double weight;
  final bool isCompleted;
  final String? notes;

  SetDetail({
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.isCompleted = false,
    this.notes,
  });

  factory SetDetail.fromMap(Map<String, dynamic> data) {
    return SetDetail(
      setNumber: data['setNumber'] ?? 0,
      reps: data['reps'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      isCompleted: data['isCompleted'] ?? false,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  SetDetail copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? isCompleted,
    String? notes,
  }) {
    return SetDetail(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
