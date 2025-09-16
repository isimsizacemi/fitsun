import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSession {
  final String id;
  final String userId;
  final String programId;
  final String programName;
  final String? dayName; // Antrenman günü adı
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalDuration; // dakika
  final int totalExercises;
  final int totalSets;
  final List<ExerciseSession> exercises;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.programId,
    required this.programName,
    this.dayName,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.totalDuration,
    required this.totalExercises,
    required this.totalSets,
    required this.exercises,
    this.notes,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WorkoutSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      programId: data['programId'] ?? '',
      programName: data['programName'] ?? '',
      dayName: data['dayName'],
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      totalDuration: data['totalDuration'] ?? 0,
      totalExercises: data['totalExercises'] ?? 0,
      totalSets: data['totalSets'] ?? 0,
      exercises:
          (data['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseSession.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'],
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'programId': programId,
      'programName': programName,
      'dayName': dayName,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'totalDuration': totalDuration,
      'totalExercises': totalExercises,
      'totalSets': totalSets,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? programId,
    String? programName,
    String? dayName,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? totalDuration,
    int? totalExercises,
    int? totalSets,
    List<ExerciseSession>? exercises,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      programId: programId ?? this.programId,
      programName: programName ?? this.programName,
      dayName: dayName ?? this.dayName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDuration: totalDuration ?? this.totalDuration,
      totalExercises: totalExercises ?? this.totalExercises,
      totalSets: totalSets ?? this.totalSets,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Süre formatı
  String get durationFormatted {
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;

    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }

  // Tarih formatı
  String get dateFormatted {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Saat formatı
  String get startTimeFormatted {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  // Tamamlanan egzersiz sayısı
  int get completedExercises {
    return exercises.where((exercise) => exercise.isCompleted).length;
  }

  // Hesaplanan süre (dakika)
  int? get calculatedDuration {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  // Tamamlanma yüzdesi
  double get completionPercentage {
    if (totalExercises == 0) return 0.0;
    return (completedExercises / totalExercises) * 100;
  }
}

class ExerciseSession {
  final String exerciseName;
  final int plannedSets;
  final int completedSets;
  final int plannedReps;
  final int completedReps;
  final double? plannedWeight;
  final double? completedWeight;
  final int restTime; // saniye
  final List<SetDetail> setDetails;
  final String? notes;
  final bool isCompleted;

  ExerciseSession({
    required this.exerciseName,
    required this.plannedSets,
    required this.completedSets,
    required this.plannedReps,
    required this.completedReps,
    this.plannedWeight,
    this.completedWeight,
    required this.restTime,
    required this.setDetails,
    this.notes,
    required this.isCompleted,
  });

  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    return ExerciseSession(
      exerciseName: map['exerciseName'] ?? '',
      plannedSets: map['plannedSets'] ?? 0,
      completedSets: map['completedSets'] ?? 0,
      plannedReps: map['plannedReps'] ?? 0,
      completedReps: map['completedReps'] ?? 0,
      plannedWeight: map['plannedWeight']?.toDouble(),
      completedWeight: map['completedWeight']?.toDouble(),
      restTime: map['restTime'] ?? 0,
      setDetails:
          (map['setDetails'] as List<dynamic>?)
              ?.map((e) => SetDetail.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'plannedSets': plannedSets,
      'completedSets': completedSets,
      'plannedReps': plannedReps,
      'completedReps': completedReps,
      'plannedWeight': plannedWeight,
      'completedWeight': completedWeight,
      'restTime': restTime,
      'setDetails': setDetails.map((e) => e.toMap()).toList(),
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  ExerciseSession copyWith({
    String? exerciseName,
    int? plannedSets,
    int? completedSets,
    int? plannedReps,
    int? completedReps,
    double? plannedWeight,
    double? completedWeight,
    int? restTime,
    List<SetDetail>? setDetails,
    String? notes,
    bool? isCompleted,
  }) {
    return ExerciseSession(
      exerciseName: exerciseName ?? this.exerciseName,
      plannedSets: plannedSets ?? this.plannedSets,
      completedSets: completedSets ?? this.completedSets,
      plannedReps: plannedReps ?? this.plannedReps,
      completedReps: completedReps ?? this.completedReps,
      plannedWeight: plannedWeight ?? this.plannedWeight,
      completedWeight: completedWeight ?? this.completedWeight,
      restTime: restTime ?? this.restTime,
      setDetails: setDetails ?? this.setDetails,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Tamamlanma oranı
  double get completionPercentage {
    if (plannedSets == 0) return 0.0;
    return (completedSets / plannedSets) * 100;
  }

  // Toplam hacim (ağırlık x tekrar)
  double get totalVolume {
    return setDetails.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  // Toplam gerçek tekrar sayısı
  int get totalActualReps {
    return setDetails.fold(0, (sum, set) => sum + set.reps);
  }

  // Kullanılan ağırlıklar listesi
  List<double> get weights {
    return setDetails.map((set) => set.weight).toList();
  }

  // Maksimum ağırlık
  double get maxWeight {
    if (setDetails.isEmpty) return 0.0;
    return setDetails.map((set) => set.weight).reduce((a, b) => a > b ? a : b);
  }
}

class SetDetail {
  final int setNumber;
  final int reps;
  final double weight;
  final int restTime; // saniye
  final String? notes;
  final bool isCompleted;

  SetDetail({
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.restTime,
    this.notes,
    required this.isCompleted,
  });

  factory SetDetail.fromMap(Map<String, dynamic> map) {
    return SetDetail(
      setNumber: map['setNumber'] ?? 0,
      reps: map['reps'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      restTime: map['restTime'] ?? 0,
      notes: map['notes'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  SetDetail copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    int? restTime,
    String? notes,
    bool? isCompleted,
  }) {
    return SetDetail(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Set hacmi
  double get volume => weight * reps;

  // Ağırlık formatı
  String get weightFormatted {
    if (weight == weight.toInt().toDouble()) {
      return '${weight.toInt()}kg';
    } else {
      return '${weight.toStringAsFixed(1)}kg';
    }
  }
}

// Günlük antrenman özeti
class DailyWorkoutSummary {
  final DateTime date;
  final int totalSessions;
  final int totalDuration; // dakika
  final int totalExercises;
  final int totalSets;
  final List<WorkoutSession> sessions;
  final double completionPercentage;

  DailyWorkoutSummary({
    required this.date,
    required this.totalSessions,
    required this.totalDuration,
    required this.totalExercises,
    required this.totalSets,
    required this.sessions,
    required this.completionPercentage,
  });

  // Süre formatı
  String get durationFormatted {
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;

    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }

  // Tarih formatı
  String get dateFormatted {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Ortalama set süresi
  double get averageSetDuration {
    if (totalSets == 0) return 0.0;
    return totalDuration / totalSets;
  }

  // Tamamlanan oturum sayısı
  int get completedSessions {
    return sessions.where((session) => session.isCompleted).length;
  }
}
