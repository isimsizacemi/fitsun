import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_session.dart';

class WorkoutTrackingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansı
  static CollectionReference get _workoutSessionsCollection =>
      _firestore.collection('workout_sessions');

  // Yeni antrenman oturumu başlat
  static Future<String> startWorkoutSession({
    required String userId,
    required String programId,
    required String dayName,
    required int dayNumber,
    required DateTime date,
  }) async {
    try {
      print('🏋️ Antrenman oturumu başlatılıyor...');
      print('👤 User ID: $userId');
      print('📝 Program ID: $programId');
      print('📅 Gün: $dayName ($dayNumber)');

      final now = DateTime.now();
      final sessionId = 'session_${userId}_${date.millisecondsSinceEpoch}';

      final workoutSession = WorkoutSession(
        id: sessionId,
        userId: userId,
        programId: programId,
        dayName: dayName,
        dayNumber: dayNumber,
        date: date,
        startTime: now,
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

  // Antrenman oturumu bitir
  static Future<void> endWorkoutSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      print('🏁 Antrenman oturumu bitiriliyor...');
      print('📝 Session ID: $sessionId');

      final now = DateTime.now();

      await _workoutSessionsCollection.doc(sessionId).update({
        'endTime': Timestamp.fromDate(now),
        'isCompleted': true,
        'notes': notes,
        'updatedAt': Timestamp.fromDate(now),
      });

      print('✅ Antrenman oturumu bitirildi');
    } catch (e) {
      print('❌ Antrenman oturumu bitirme hatası: $e');
      rethrow;
    }
  }

  // Egzersiz ekle/güncelle
  static Future<void> updateExercise({
    required String sessionId,
    required String exerciseName,
    required int plannedSets,
    required int plannedReps,
    required int restSeconds,
    List<int>? actualReps,
    List<double>? weights,
    bool? isCompleted,
    String? notes,
    List<SetDetail>? setDetails,
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

      // Mevcut egzersizi bul veya yeni oluştur
      int exerciseIndex = exercises.indexWhere(
        (e) => e.exerciseName == exerciseName,
      );

      final exerciseSession = ExerciseSession(
        exerciseName: exerciseName,
        plannedSets: plannedSets,
        plannedReps: plannedReps,
        actualReps: actualReps ?? [],
        weights: weights ?? [],
        restSeconds: restSeconds,
        isCompleted: isCompleted ?? false,
        notes: notes,
        setDetails: setDetails ?? [],
      );

      if (exerciseIndex >= 0) {
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

  // Set detayı ekle/güncelle
  static Future<void> updateSetDetail({
    required String sessionId,
    required String exerciseName,
    required int setNumber,
    required int reps,
    required double weight,
    bool? isCompleted,
    String? notes,
  }) async {
    try {
      print('🔢 Set detayı güncelleniyor...');
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
      int exerciseIndex = exercises.indexWhere(
        (e) => e.exerciseName == exerciseName,
      );

      if (exerciseIndex < 0) {
        throw Exception('Egzersiz bulunamadı');
      }

      // Set detayını bul veya yeni oluştur
      List<SetDetail> setDetails = List.from(
        exercises[exerciseIndex].setDetails,
      );
      int setIndex = setDetails.indexWhere((s) => s.setNumber == setNumber);

      final setDetail = SetDetail(
        setNumber: setNumber,
        reps: reps,
        weight: weight,
        isCompleted: isCompleted ?? true,
        notes: notes,
      );

      if (setIndex >= 0) {
        setDetails[setIndex] = setDetail;
      } else {
        setDetails.add(setDetail);
      }

      // Egzersizi güncelle
      exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(
        setDetails: setDetails,
      );

      await docRef.update({
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Set detayı güncellendi');
    } catch (e) {
      print('❌ Set detayı güncelleme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının antrenman oturumlarını getir
  static Future<List<WorkoutSession>> getUserWorkoutSessions({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📊 Kullanıcı antrenman oturumları getiriliyor...');
      print('👤 User ID: $userId');

      Query query = _workoutSessionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

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

  // Belirli bir antrenman oturumunu getir
  static Future<WorkoutSession?> getWorkoutSession(String sessionId) async {
    try {
      print('📝 Antrenman oturumu getiriliyor...');
      print('📝 Session ID: $sessionId');

      final doc = await _workoutSessionsCollection.doc(sessionId).get();

      if (!doc.exists) {
        print('⚠️ Antrenman oturumu bulunamadı');
        return null;
      }

      final session = WorkoutSession.fromFirestore(doc);
      print('✅ Antrenman oturumu getirildi');
      return session;
    } catch (e) {
      print('❌ Antrenman oturumu getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının günlük antrenman oturumunu getir
  static Future<WorkoutSession?> getTodayWorkoutSession({
    required String userId,
    required String programId,
  }) async {
    try {
      print('📅 Günlük antrenman oturumu getiriliyor...');
      print('👤 User ID: $userId');
      print('📝 Program ID: $programId');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final querySnapshot = await _workoutSessionsCollection
          .where('userId', isEqualTo: userId)
          .where('programId', isEqualTo: programId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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

  // Kullanıcının antrenman istatistiklerini getir
  static Future<Map<String, dynamic>> getUserWorkoutStats(String userId) async {
    try {
      print('📊 Kullanıcı antrenman istatistikleri getiriliyor...');
      print('👤 User ID: $userId');

      final sessions = await getUserWorkoutSessions(userId: userId);

      if (sessions.isEmpty) {
        return {
          'totalWorkouts': 0,
          'totalWorkoutTime': 0,
          'averageWorkoutDuration': 0.0,
          'completedWorkouts': 0,
          'favoriteExercise': null,
          'currentStreak': 0,
          'longestStreak': 0,
        };
      }

      // İstatistikleri hesapla
      final totalWorkouts = sessions.length;
      final completedWorkouts = sessions.where((s) => s.isCompleted).length;
      final totalWorkoutTime = sessions
          .where((s) => s.totalDuration != null)
          .fold(0, (sum, s) => sum + (s.totalDuration ?? 0));
      final averageWorkoutDuration = totalWorkouts > 0
          ? totalWorkoutTime / totalWorkouts
          : 0.0;

      // En sevilen egzersizi bul
      Map<String, int> exerciseCounts = {};
      for (final session in sessions) {
        for (final exercise in session.exercises) {
          exerciseCounts[exercise.exerciseName] =
              (exerciseCounts[exercise.exerciseName] ?? 0) + 1;
        }
      }
      final favoriteExercise = exerciseCounts.isNotEmpty
          ? exerciseCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
          : null;

      // Streak hesapla
      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;

      final sortedSessions = List<WorkoutSession>.from(sessions)
        ..sort((a, b) => b.date.compareTo(a.date));

      for (final session in sortedSessions) {
        if (session.isCompleted) {
          tempStreak++;
          if (currentStreak == 0) currentStreak = tempStreak;
        } else {
          if (tempStreak > longestStreak) longestStreak = tempStreak;
          tempStreak = 0;
        }
      }
      if (tempStreak > longestStreak) longestStreak = tempStreak;

      final stats = {
        'totalWorkouts': totalWorkouts,
        'totalWorkoutTime': totalWorkoutTime,
        'averageWorkoutDuration': averageWorkoutDuration,
        'completedWorkouts': completedWorkouts,
        'favoriteExercise': favoriteExercise,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };

      print('✅ Antrenman istatistikleri hesaplandı');
      print('📊 Toplam antrenman: $totalWorkouts');
      print('⏱️ Toplam süre: $totalWorkoutTime dakika');
      print('🏆 En sevilen egzersiz: $favoriteExercise');
      print('🔥 Mevcut seri: $currentStreak gün');

      return stats;
    } catch (e) {
      print('❌ Antrenman istatistikleri hesaplama hatası: $e');
      rethrow;
    }
  }

  // Antrenman oturumunu sil
  static Future<void> deleteWorkoutSession(String sessionId) async {
    try {
      print('🗑️ Antrenman oturumu siliniyor...');
      print('📝 Session ID: $sessionId');

      await _workoutSessionsCollection.doc(sessionId).delete();

      print('✅ Antrenman oturumu silindi');
    } catch (e) {
      print('❌ Antrenman oturumu silme hatası: $e');
      rethrow;
    }
  }
}
