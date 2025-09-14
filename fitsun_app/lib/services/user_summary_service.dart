import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_summary.dart';
import 'workout_tracking_service.dart';
import 'water_tracking_service.dart';

class UserSummaryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansı
  static CollectionReference get _userSummaryCollection =>
      _firestore.collection('user_summary');

  // Kullanıcı özetini getir veya oluştur
  static Future<UserSummary> getUserSummary(String userId) async {
    try {
      print('📊 Kullanıcı özeti getiriliyor...');
      print('👤 User ID: $userId');

      final doc = await _userSummaryCollection.doc(userId).get();

      if (!doc.exists) {
        print('⚠️ Kullanıcı özeti bulunamadı, yeni oluşturuluyor...');
        return await _createUserSummary(userId);
      }

      final summary = UserSummary.fromFirestore(doc);
      print('✅ Kullanıcı özeti getirildi');
      return summary;
    } catch (e) {
      print('❌ Kullanıcı özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı özetini oluştur
  static Future<UserSummary> _createUserSummary(String userId) async {
    try {
      print('📊 Yeni kullanıcı özeti oluşturuluyor...');
      print('👤 User ID: $userId');

      final summary = UserSummary.empty(userId);

      await _userSummaryCollection.doc(userId).set(summary.toFirestore());

      print('✅ Yeni kullanıcı özeti oluşturuldu');
      return summary;
    } catch (e) {
      print('❌ Kullanıcı özeti oluşturma hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı özetini güncelle
  static Future<void> updateUserSummary(String userId) async {
    try {
      print('📊 Kullanıcı özeti güncelleniyor...');
      print('👤 User ID: $userId');

      // Antrenman istatistiklerini getir
      final workoutStats = await WorkoutTrackingService.getUserWorkoutStats(
        userId,
      );

      // Su tüketim istatistiklerini getir
      final waterStats = await WaterTrackingService.getUserWaterStats(userId);

      // Özet metni oluştur
      final summaryText = await _generateSummaryText(
        userId: userId,
        workoutStats: workoutStats,
        waterStats: waterStats,
      );

      // Güncelleme verilerini hazırla
      final updateData = {
        'totalWorkouts': workoutStats['totalWorkouts'],
        'totalWorkoutTime': workoutStats['totalWorkoutTime'],
        'averageWorkoutDuration': workoutStats['averageWorkoutDuration'],
        'favoriteExercise': workoutStats['favoriteExercise'],
        'totalWaterIntake': waterStats['totalWaterIntake'],
        'averageDailyWater': waterStats['averageDailyWater'],
        'lastWorkoutDate': workoutStats['lastWorkoutDate'] != null
            ? Timestamp.fromDate(workoutStats['lastWorkoutDate'])
            : null,
        'lastWaterIntakeDate': waterStats['lastWaterIntakeDate'] != null
            ? Timestamp.fromDate(waterStats['lastWaterIntakeDate'])
            : null,
        'currentStreak': workoutStats['currentStreak'],
        'longestStreak': workoutStats['longestStreak'],
        'summaryText': summaryText,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      };

      await _userSummaryCollection.doc(userId).update(updateData);

      print('✅ Kullanıcı özeti güncellendi');
      print('📊 Toplam antrenman: ${workoutStats['totalWorkouts']}');
      print('💧 Toplam su: ${waterStats['totalWaterIntake']}ml');
      print('🔥 Mevcut seri: ${workoutStats['currentStreak']} gün');
    } catch (e) {
      print('❌ Kullanıcı özeti güncelleme hatası: $e');
      rethrow;
    }
  }

  // Özet metni oluştur
  static Future<String> _generateSummaryText({
    required String userId,
    required Map<String, dynamic> workoutStats,
    required Map<String, dynamic> waterStats,
  }) async {
    try {
      print('📝 Özet metni oluşturuluyor...');

      final totalWorkouts = workoutStats['totalWorkouts'] as int;
      final totalWorkoutTime = workoutStats['totalWorkoutTime'] as int;
      final favoriteExercise = workoutStats['favoriteExercise'] as String?;
      final currentStreak = workoutStats['currentStreak'] as int;
      final totalWaterIntake = waterStats['totalWaterIntake'] as int;
      final averageDailyWater = waterStats['averageDailyWater'] as double;

      String summary = '';

      // Antrenman özeti
      if (totalWorkouts > 0) {
        summary += 'Son 30 günde $totalWorkouts antrenman yaptın. ';
        summary +=
            'Toplam ${(totalWorkoutTime / 60.0).toStringAsFixed(1)} saat spor yapmışsın. ';

        if (favoriteExercise != null) {
          summary += 'En çok $favoriteExercise egzersizini yapıyorsun. ';
        }

        if (currentStreak > 0) {
          summary += 'Spor serin $currentStreak gün devam ediyor! ';
        }
      } else {
        summary += 'Henüz antrenman yapmamışsın. Hadi başlayalım! ';
      }

      // Su tüketimi özeti
      if (totalWaterIntake > 0) {
        summary +=
            'Günlük ortalama ${(averageDailyWater / 1000.0).toStringAsFixed(1)}L su içiyorsun. ';

        if (averageDailyWater >= 2500) {
          summary += 'Su tüketimin mükemmel! ';
        } else if (averageDailyWater >= 2000) {
          summary += 'Su tüketimin iyi. ';
        } else {
          summary += 'Daha fazla su içmelisin. ';
        }
      } else {
        summary += 'Su tüketimini takip etmeye başla! ';
      }

      // Motivasyon mesajı
      if (totalWorkouts >= 10 && currentStreak >= 7) {
        summary += 'Harika gidiyorsun! 💪';
      } else if (totalWorkouts >= 5) {
        summary += 'İyi başladın, devam et! 🔥';
      } else {
        summary += 'Hedeflerine ulaşmak için çalışmaya devam et! 🎯';
      }

      print('✅ Özet metni oluşturuldu');
      return summary;
    } catch (e) {
      print('❌ Özet metni oluşturma hatası: $e');
      return 'Özet oluşturulamadı.';
    }
  }

  // AI için kullanıcı özeti metni oluştur
  static Future<String> generateSummaryForAI(String userId) async {
    try {
      print('🤖 AI için kullanıcı özeti oluşturuluyor...');
      print('👤 User ID: $userId');

      final summary = await getUserSummary(userId);
      final aiSummary = summary.generateSummaryForAI();

      print('✅ AI için özet metni oluşturuldu');
      return aiSummary;
    } catch (e) {
      print('❌ AI için özet metni oluşturma hatası: $e');
      return 'Kullanıcı özeti oluşturulamadı.';
    }
  }

  // Kullanıcının başarılarını getir
  static Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    try {
      print('🏆 Kullanıcı başarıları getiriliyor...');
      print('👤 User ID: $userId');

      final summary = await getUserSummary(userId);

      final achievements = <String, dynamic>{
        'totalWorkouts': summary.totalWorkouts,
        'totalWorkoutTime': summary.totalWorkoutTime,
        'currentStreak': summary.currentStreak,
        'longestStreak': summary.longestStreak,
        'favoriteExercise': summary.favoriteExercise,
        'totalWaterIntake': summary.totalWaterIntake,
        'averageDailyWater': summary.averageDailyWater,
        'fitnessLevel': summary.fitnessLevel,
        'streakStatus': summary.streakStatus,
        'streakEmoji': summary.streakEmoji,
        'waterStatus': summary.waterStatus,
      };

      print('✅ Kullanıcı başarıları getirildi');
      return achievements;
    } catch (e) {
      print('❌ Kullanıcı başarıları getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının ilerleme durumunu getir
  static Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      print('📈 Kullanıcı ilerleme durumu getiriliyor...');
      print('👤 User ID: $userId');

      final summary = await getUserSummary(userId);

      // Haftalık ilerleme
      final weeklyWorkouts =
          await WorkoutTrackingService.getUserWorkoutSessions(
            userId: userId,
            limit: 7,
          );

      final weeklyWater = await WaterTrackingService.getWeeklyWaterSummary(
        userId: userId,
        startDate: DateTime.now().subtract(Duration(days: 7)),
      );

      final progress = {
        'weeklyWorkouts': weeklyWorkouts.length,
        'weeklyWaterAverage': weeklyWater.isNotEmpty
            ? weeklyWater.map((w) => w.totalAmount).reduce((a, b) => a + b) /
                  weeklyWater.length
            : 0,
        'currentStreak': summary.currentStreak,
        'longestStreak': summary.longestStreak,
        'totalWorkouts': summary.totalWorkouts,
        'totalWaterIntake': summary.totalWaterIntake,
        'fitnessLevel': summary.fitnessLevel,
        'lastWorkoutDate': summary.lastWorkoutDate,
        'lastWaterIntakeDate': summary.lastWaterIntakeDate,
      };

      print('✅ Kullanıcı ilerleme durumu getirildi');
      return progress;
    } catch (e) {
      print('❌ Kullanıcı ilerleme durumu getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı özetini sil
  static Future<void> deleteUserSummary(String userId) async {
    try {
      print('🗑️ Kullanıcı özeti siliniyor...');
      print('👤 User ID: $userId');

      await _userSummaryCollection.doc(userId).delete();

      print('✅ Kullanıcı özeti silindi');
    } catch (e) {
      print('❌ Kullanıcı özeti silme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı özetini sıfırla
  static Future<void> resetUserSummary(String userId) async {
    try {
      print('🔄 Kullanıcı özeti sıfırlanıyor...');
      print('👤 User ID: $userId');

      final summary = UserSummary.empty(userId);

      await _userSummaryCollection.doc(userId).set(summary.toFirestore());

      print('✅ Kullanıcı özeti sıfırlandı');
    } catch (e) {
      print('❌ Kullanıcı özeti sıfırlama hatası: $e');
      rethrow;
    }
  }

  // Tüm kullanıcı özetlerini getir (admin için)
  static Future<List<UserSummary>> getAllUserSummaries() async {
    try {
      print('📊 Tüm kullanıcı özetleri getiriliyor...');

      final querySnapshot = await _userSummaryCollection
          .orderBy('lastUpdated', descending: true)
          .get();

      final summaries = querySnapshot.docs
          .map((doc) => UserSummary.fromFirestore(doc))
          .toList();

      print('✅ ${summaries.length} kullanıcı özeti getirildi');
      return summaries;
    } catch (e) {
      print('❌ Tüm kullanıcı özetleri getirme hatası: $e');
      rethrow;
    }
  }
}
