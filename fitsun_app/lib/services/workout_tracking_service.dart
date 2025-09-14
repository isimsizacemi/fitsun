import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutTrackingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansı
  static CollectionReference get _workoutSessionsCollection =>
      _firestore.collection('workout_sessions');

  // Antrenman oturumu başlat
  static Future<String> startWorkoutSession({
    required String userId,
    required String programId,
    required String programName,
    required String dayName,
    required int dayNumber,
    required DateTime date,
    List<ExerciseSession>? exercises,
  }) async {
    try {
      print('🏋️ Antrenman oturumu başlatılıyor...');
      print('👤 User ID: $userId');
      print('📋 Program ID: $programId');
      print('📅 Gün: $dayName ($dayNumber)');

      final now = DateTime.now();
      final sessionId = 'workout_${userId}_${now.millisecondsSinceEpoch}';

      final workoutSession = WorkoutSession(
        id: sessionId,
        userId: userId,
        programId: programId,
        programName: programName,
        dayName: dayName,
        date: date,
        startTime: now,
        totalDuration: 0,
        totalExercises: exercises?.length ?? 0,
        totalSets:
            exercises?.fold<int>(0, (total, ex) => total + ex.plannedSets) ?? 0,
        exercises: exercises ?? [],
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      await _workoutSessionsCollection
          .doc(sessionId)
          .set(workoutSession.toFirestore());

      print('✅ Antrenman oturumu başlatıldı: $sessionId');
      return sessionId;
    } catch (e) {
      print('❌ Antrenman oturumu başlatma hatası: $e');
      rethrow;
    }
  }

  // Antrenman oturumunu güncelle
  static Future<void> updateWorkoutSession({
    required String sessionId,
    List<ExerciseSession>? exercises,
    String? notes,
  }) async {
    try {
      print('🏋️ Antrenman oturumu güncelleniyor...');
      print('📝 Session ID: $sessionId');

      final docRef = _workoutSessionsCollection.doc(sessionId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Antrenman oturumu bulunamadı');
      }

      Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (exercises != null) {
        updateData['exercises'] = exercises.map((e) => e.toMap()).toList();
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await docRef.update(updateData);

      print('✅ Antrenman oturumu güncellendi');
    } catch (e) {
      print('❌ Antrenman oturumu güncelleme hatası: $e');
      rethrow;
    }
  }

  // Antrenman oturumunu tamamla
  static Future<void> completeWorkoutSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      print('🏁 Antrenman oturumu tamamlanıyor...');
      print('📝 Session ID: $sessionId');

      final docRef = _workoutSessionsCollection.doc(sessionId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Antrenman oturumu bulunamadı');
      }

      final data = doc.data() as Map<String, dynamic>;
      final startTime = (data['startTime'] as Timestamp).toDate();
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime).inMinutes;

      await docRef.update({
        'endTime': Timestamp.fromDate(endTime),
        'totalDuration': totalDuration,
        'isCompleted': true,
        'notes': notes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Antrenman oturumu tamamlandı');
      print('⏱️ Toplam süre: ${totalDuration} dakika');
    } catch (e) {
      print('❌ Antrenman oturumu tamamlama hatası: $e');
      rethrow;
    }
  }

  // Egzersiz ekle/güncelle
  static Future<void> updateExerciseInSession({
    required String sessionId,
    required String exerciseName,
    required ExerciseSession exerciseSession,
  }) async {
    try {
      print('💪 Egzersiz güncelleniyor...');
      print('📝 Session ID: $sessionId');
      print('🏋️ Egzersiz: $exerciseName');

      final docRef = _workoutSessionsCollection.doc(sessionId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Antrenman oturumu bulunamadı');
      }

      final data = doc.data() as Map<String, dynamic>;
      final exercises =
          (data['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseSession.fromMap(e))
              .toList() ??
          [];

      // Mevcut egzersizi bul ve güncelle
      final exerciseIndex = exercises.indexWhere(
        (e) => e.exerciseName == exerciseName,
      );

      if (exerciseIndex != -1) {
        exercises[exerciseIndex] = exerciseSession;
      } else {
        exercises.add(exerciseSession);
      }

      await docRef.update({
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Egzersiz güncellendi');
    } catch (e) {
      print('❌ Egzersiz güncelleme hatası: $e');
      rethrow;
    }
  }

  // Set ekle/güncelle
  static Future<void> updateSetInExercise({
    required String sessionId,
    required String exerciseName,
    required int setNumber,
    required int reps,
    required double weight,
    String? notes,
  }) async {
    try {
      print('🏋️ Set güncelleniyor...');
      print('📝 Session ID: $sessionId');
      print('🏋️ Egzersiz: $exerciseName');
      print('🔢 Set: $setNumber');

      final docRef = _workoutSessionsCollection.doc(sessionId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Antrenman oturumu bulunamadı');
      }

      final data = doc.data() as Map<String, dynamic>;
      final exercises =
          (data['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseSession.fromMap(e))
              .toList() ??
          [];

      // Egzersizi bul
      final exerciseIndex = exercises.indexWhere(
        (e) => e.exerciseName == exerciseName,
      );

      if (exerciseIndex == -1) {
        throw Exception('Egzersiz bulunamadı');
      }

      final exercise = exercises[exerciseIndex];
      final setDetails = List<SetDetail>.from(exercise.setDetails);

      // Set'i bul ve güncelle
      final setIndex = setDetails.indexWhere((s) => s.setNumber == setNumber);

      if (setIndex != -1) {
        setDetails[setIndex] = SetDetail(
          setNumber: setNumber,
          reps: reps,
          weight: weight,
          restTime: 60,
          isCompleted: true,
          notes: notes,
        );
      } else {
        setDetails.add(
          SetDetail(
            setNumber: setNumber,
            reps: reps,
            weight: weight,
            restTime: 60,
            isCompleted: true,
            notes: notes,
          ),
        );
      }

      // Egzersizi güncelle
      exercises[exerciseIndex] = exercise.copyWith(
        setDetails: setDetails,
        isCompleted: setDetails.length >= exercise.plannedSets,
      );

      await docRef.update({
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Set güncellendi');
    } catch (e) {
      print('❌ Set güncelleme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının antrenman oturumlarını getir
  static Future<List<WorkoutSession>> getUserWorkoutSessions({
    required String userId,
    String? programId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🏋️ Kullanıcı antrenman oturumları getiriliyor...');
      print('👤 User ID: $userId');

      Query query = _workoutSessionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (programId != null) {
        query = query.where('programId', isEqualTo: programId);
      }

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final sessions = querySnapshot.docs
          .map((doc) => WorkoutSession.fromFirestore(doc))
          .toList();

      print('✅ ${sessions.length} antrenman oturumu getirildi');
      return sessions;
    } catch (e) {
      print('❌ Antrenman oturumları getirme hatası: $e');
      rethrow;
    }
  }

  // Belirli bir günün antrenman oturumunu getir
  static Future<WorkoutSession?> getDailyWorkoutSession({
    required String userId,
    required DateTime date,
    String? programId,
  }) async {
    try {
      print('📅 Günlük antrenman oturumu getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      Query query = _workoutSessionsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));

      if (programId != null) {
        query = query.where('programId', isEqualTo: programId);
      }

      final querySnapshot = await query
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Günlük antrenman oturumu bulunamadı');
        return null;
      }

      final session = WorkoutSession.fromFirestore(querySnapshot.docs.first);
      print('✅ Günlük antrenman oturumu getirildi');
      return session;
    } catch (e) {
      print('❌ Günlük antrenman oturumu getirme hatası: $e');
      rethrow;
    }
  }

  // Günlük antrenman özeti getir
  static Future<DailyWorkoutSummary?> getDailyWorkoutSummary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      print('📊 Günlük antrenman özeti getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      final session = await getDailyWorkoutSession(userId: userId, date: date);

      if (session == null) {
        print('⚠️ Günlük antrenman oturumu bulunamadı');
        return null;
      }

      final totalExercises = session.totalExercises;
      final completedExercises = session.completedExercises;
      final totalDuration = session.calculatedDuration ?? 0;
      final completionPercentage = session.completionPercentage;

      // Toplam ağırlık ve tekrar hesapla
      int totalReps = 0;
      double maxWeight = 0.0;

      for (final exercise in session.exercises) {
        totalReps += exercise.totalActualReps;
        if (exercise.maxWeight > maxWeight) {
          maxWeight = exercise.maxWeight;
        }
      }

      final summary = DailyWorkoutSummary(
        date: date,
        totalSessions: 1,
        totalDuration: totalDuration,
        totalExercises: totalExercises,
        totalSets: session.totalSets,
        sessions: [session],
        completionPercentage: completionPercentage,
      );

      print('✅ Günlük antrenman özeti oluşturuldu');
      print('🏋️ Tamamlanan egzersiz: $completedExercises/$totalExercises');
      print('⏱️ Toplam süre: ${totalDuration} dakika');
      print('💪 Toplam tekrar: $totalReps');

      return summary;
    } catch (e) {
      print('❌ Günlük antrenman özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Haftalık antrenman özeti getir
  static Future<List<DailyWorkoutSummary>> getWeeklyWorkoutSummary({
    required String userId,
    required DateTime startDate,
  }) async {
    try {
      print('📅 Haftalık antrenman özeti getiriliyor...');
      print('👤 User ID: $userId');
      print(
        '📅 Başlangıç tarihi: ${startDate.day}/${startDate.month}/${startDate.year}',
      );

      final summaries = <DailyWorkoutSummary>[];

      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final summary = await getDailyWorkoutSummary(
          userId: userId,
          date: date,
        );

        if (summary != null) {
          summaries.add(summary);
        }
      }

      print('✅ Haftalık antrenman özeti oluşturuldu');
      return summaries;
    } catch (e) {
      print('❌ Haftalık antrenman özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Antrenman istatistikleri getir
  static Future<Map<String, dynamic>> getWorkoutStats({
    required String userId,
    String? programId,
    int? daysBack,
  }) async {
    try {
      print('📊 Antrenman istatistikleri getiriliyor...');
      print('👤 User ID: $userId');

      final endDate = DateTime.now();
      final startDate = daysBack != null
          ? endDate.subtract(Duration(days: daysBack))
          : endDate.subtract(Duration(days: 30));

      final sessions = await getUserWorkoutSessions(
        userId: userId,
        programId: programId,
        startDate: startDate,
        endDate: endDate,
      );

      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'totalDuration': 0,
          'totalExercises': 0,
          'totalReps': 0,
          'totalWeight': 0.0,
          'averageDuration': 0.0,
          'completionRate': 0.0,
          'maxWeight': 0.0,
          'mostUsedExercise': null,
          'workoutStreak': 0,
        };
      }

      // İstatistikleri hesapla
      final totalSessions = sessions.length;
      final completedSessions = sessions.where((s) => s.isCompleted).length;
      final totalDuration = sessions.fold(
        0,
        (sum, s) => sum + (s.calculatedDuration ?? 0),
      );
      final totalExercises = sessions.fold(
        0,
        (sum, s) => sum + s.totalExercises,
      );
      final completedExercises = sessions.fold(
        0,
        (sum, s) => sum + s.completedExercises,
      );

      int totalReps = 0;
      double totalWeight = 0.0;
      double maxWeight = 0.0;
      Map<String, int> exerciseCounts = {};

      for (final session in sessions) {
        for (final exercise in session.exercises) {
          totalReps += exercise.totalActualReps;
          totalWeight += exercise.totalVolume;
          if (exercise.maxWeight > maxWeight) {
            maxWeight = exercise.maxWeight;
          }
          exerciseCounts[exercise.exerciseName] =
              (exerciseCounts[exercise.exerciseName] ?? 0) + 1;
        }
      }

      final mostUsedExercise = exerciseCounts.isNotEmpty
          ? exerciseCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
          : null;

      // Workout streak hesapla
      int workoutStreak = 0;
      final sortedSessions = sessions.where((s) => s.isCompleted).toList();
      sortedSessions.sort((a, b) => b.date.compareTo(a.date));

      DateTime currentDate = DateTime.now();
      for (final session in sortedSessions) {
        final sessionDate = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        final checkDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (sessionDate.isAtSameMomentAs(checkDate) ||
            sessionDate.isAtSameMomentAs(
              checkDate.subtract(Duration(days: workoutStreak)),
            )) {
          workoutStreak++;
          currentDate = currentDate.subtract(Duration(days: 1));
        } else {
          break;
        }
      }

      final stats = {
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'totalDuration': totalDuration,
        'totalExercises': totalExercises,
        'completedExercises': completedExercises,
        'totalReps': totalReps,
        'totalWeight': totalWeight,
        'averageDuration': totalSessions > 0
            ? totalDuration / totalSessions
            : 0.0,
        'completionRate': totalExercises > 0
            ? (completedExercises / totalExercises) * 100
            : 0.0,
        'maxWeight': maxWeight,
        'mostUsedExercise': mostUsedExercise,
        'workoutStreak': workoutStreak,
      };

      print('✅ Antrenman istatistikleri hesaplandı');
      print('🏋️ Toplam oturum: $totalSessions');
      print('⏱️ Toplam süre: ${totalDuration} dakika');
      print('💪 Toplam egzersiz: $totalExercises');
      print('🔥 Streak: $workoutStreak gün');

      return stats;
    } catch (e) {
      print('❌ Antrenman istatistikleri hesaplama hatası: $e');
      rethrow;
    }
  }

  // Antrenman hedeflerini kontrol et
  static Map<String, dynamic> checkWorkoutGoals({
    required int currentSessions,
    required int targetSessions,
    required int currentDuration,
    required int targetDuration,
    required int currentExercises,
    required int targetExercises,
  }) {
    final sessionsProgress = targetSessions > 0
        ? (currentSessions / targetSessions) * 100
        : 0;
    final durationProgress = targetDuration > 0
        ? (currentDuration / targetDuration) * 100
        : 0;
    final exercisesProgress = targetExercises > 0
        ? (currentExercises / targetExercises) * 100
        : 0;

    final overallProgress =
        (sessionsProgress + durationProgress + exercisesProgress) / 3;

    String status;
    String emoji;
    String message;

    if (overallProgress >= 100) {
      status = 'completed';
      emoji = '🎉';
      message = 'Tüm hedefler tamamlandı!';
    } else if (overallProgress >= 80) {
      status = 'almost';
      emoji = '💪';
      message = 'Neredeyse tamamlandı!';
    } else if (overallProgress >= 60) {
      status = 'good';
      emoji = '👍';
      message = 'İyi gidiyor!';
    } else if (overallProgress >= 40) {
      status = 'low';
      emoji = '🏋️';
      message = 'Devam et!';
    } else {
      status = 'very_low';
      emoji = '💪';
      message = 'Daha fazla antrenman yapmalısın!';
    }

    return {
      'status': status,
      'emoji': emoji,
      'message': message,
      'overallProgress': overallProgress,
      'sessionsProgress': sessionsProgress,
      'durationProgress': durationProgress,
      'exercisesProgress': exercisesProgress,
      'remainingSessions': targetSessions - currentSessions,
      'remainingDuration': targetDuration - currentDuration,
      'remainingExercises': targetExercises - currentExercises,
    };
  }
}
