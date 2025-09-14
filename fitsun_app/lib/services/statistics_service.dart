import 'package:cloud_firestore/cloud_firestore.dart';
import 'water_tracking_service.dart';
import 'nutrition_tracking_service.dart';
import 'workout_tracking_service.dart';

class StatisticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Genel istatistikleri getir
  static Future<Map<String, dynamic>> getOverallStats({
    required String userId,
    int? daysBack,
  }) async {
    try {
      print('📊 Genel istatistikler getiriliyor...');
      print('👤 User ID: $userId');

      final endDate = DateTime.now();
      final startDate = daysBack != null
          ? endDate.subtract(Duration(days: daysBack))
          : endDate.subtract(Duration(days: 30));

      // Paralel olarak tüm servislerden veri çek
      final futures = await Future.wait([
        WaterTrackingService.getUserWaterStats(userId),
        NutritionTrackingService.getNutritionStats(userId),
        WorkoutTrackingService.getWorkoutStats(
          userId: userId,
          daysBack: daysBack,
        ),
      ]);

      final waterStats = futures[0] as Map<String, dynamic>;
      final nutritionStats = futures[1] as Map<String, dynamic>;
      final workoutStats = futures[2] as Map<String, dynamic>;

      // Genel skor hesapla (0-100)
      double overallScore = 0.0;
      int scoreFactors = 0;

      // Su skoru (25 puan)
      if (waterStats['averageDailyWater'] > 0) {
        final waterScore =
            (waterStats['averageDailyWater'] / 2500.0) * 25; // 2.5L hedef
        overallScore += waterScore.clamp(0.0, 25.0);
        scoreFactors++;
      }

      // Beslenme skoru (25 puan)
      if (nutritionStats['hasActivePlan']) {
        final nutritionScore = (nutritionStats['completionRate'] / 100.0) * 25;
        overallScore += nutritionScore.clamp(0.0, 25.0);
        scoreFactors++;
      }

      // Antrenman skoru (50 puan)
      if (workoutStats['totalSessions'] > 0) {
        final workoutScore = (workoutStats['completionRate'] / 100.0) * 50;
        overallScore += workoutScore.clamp(0.0, 50.0);
        scoreFactors++;
      }

      // Skor normalizasyonu
      if (scoreFactors > 0) {
        overallScore = (overallScore / scoreFactors) * 100;
      }

      final stats = {
        'overallScore': overallScore,
        'waterStats': waterStats,
        'nutritionStats': nutritionStats,
        'workoutStats': workoutStats,
        'period': {
          'startDate': startDate,
          'endDate': endDate,
          'days': daysBack ?? 30,
        },
        'summary': {
          'totalWaterIntake': waterStats['totalWaterIntake'] ?? 0,
          'averageDailyWater': waterStats['averageDailyWater'] ?? 0.0,
          'hasActiveDietPlan': nutritionStats['hasActivePlan'] ?? false,
          'nutritionCompletionRate': nutritionStats['completionRate'] ?? 0.0,
          'totalWorkoutSessions': workoutStats['totalSessions'] ?? 0,
          'totalWorkoutDuration': workoutStats['totalDuration'] ?? 0,
          'workoutStreak': workoutStats['workoutStreak'] ?? 0,
        },
      };

      print('✅ Genel istatistikler hesaplandı');
      print('📊 Genel skor: ${overallScore.toStringAsFixed(1)}/100');
      print(
        '💧 Su: ${waterStats['averageDailyWater']?.toStringAsFixed(0) ?? 0}ml/gün',
      );
      print(
        '🍽️ Beslenme: ${nutritionStats['completionRate']?.toStringAsFixed(1) ?? 0}%',
      );
      print('🏋️ Antrenman: ${workoutStats['totalSessions'] ?? 0} oturum');

      return stats;
    } catch (e) {
      print('❌ Genel istatistikler hesaplama hatası: $e');
      rethrow;
    }
  }

  // Haftalık trend analizi
  static Future<Map<String, dynamic>> getWeeklyTrends({
    required String userId,
    int? weeksBack,
  }) async {
    try {
      print('📈 Haftalık trend analizi getiriliyor...');
      print('👤 User ID: $userId');

      final weeks = weeksBack ?? 4;
      final trends = <Map<String, dynamic>>[];

      for (int i = 0; i < weeks; i++) {
        final weekStart = DateTime.now().subtract(Duration(days: (i + 1) * 7));
        final weekEnd = DateTime.now().subtract(Duration(days: i * 7));

        // Haftalık verileri getir
        final waterSummary = await WaterTrackingService.getWeeklyWaterSummary(
          userId: userId,
          startDate: weekStart,
        );

        final nutritionSummary =
            await NutritionTrackingService.getWeeklyNutritionSummary(
              userId: userId,
              startDate: weekStart,
            );

        final workoutSummary =
            await WorkoutTrackingService.getWeeklyWorkoutSummary(
              userId: userId,
              startDate: weekStart,
            );

        // Haftalık istatistikleri hesapla
        final waterTotal = waterSummary.fold(
          0,
          (sum, day) => sum + day.totalAmount,
        );
        final waterAverage = waterTotal / 7;

        final nutritionCompleted = nutritionSummary.fold(
          0,
          (sum, day) => sum + day.completedMealsCount,
        );
        final nutritionTotal = nutritionSummary.fold(
          0,
          (sum, day) => sum + day.totalPlannedMeals,
        );
        final nutritionRate = nutritionTotal > 0
            ? (nutritionCompleted / nutritionTotal) * 100
            : 0;

        final workoutSessions = workoutSummary.length;
        final workoutDuration = workoutSummary.fold(
          0,
          (sum, day) => sum + day.totalDuration,
        );
        final workoutExercises = workoutSummary.fold(
          0,
          (sum, day) => sum + day.totalExercises,
        );

        trends.add({
          'week': i + 1,
          'startDate': weekStart,
          'endDate': weekEnd,
          'water': {
            'total': waterTotal,
            'average': waterAverage,
            'days': waterSummary.length,
          },
          'nutrition': {
            'completedMeals': nutritionCompleted,
            'totalMeals': nutritionTotal,
            'completionRate': nutritionRate,
            'days': nutritionSummary.length,
          },
          'workout': {
            'sessions': workoutSessions,
            'duration': workoutDuration,
            'exercises': workoutExercises,
            'days': workoutSummary.length,
          },
        });
      }

      // Trend analizi
      final waterTrend = _calculateTrend(
        trends.map((t) => t['water']['average'] as double).toList(),
      );
      final nutritionTrend = _calculateTrend(
        trends.map((t) => t['nutrition']['completionRate'] as double).toList(),
      );
      final workoutTrend = _calculateTrend(
        trends.map((t) => t['workout']['sessions'] as double).toList(),
      );

      final result = {
        'trends': trends.reversed.toList(), // En yeni hafta ilk sırada
        'analysis': {
          'waterTrend': waterTrend,
          'nutritionTrend': nutritionTrend,
          'workoutTrend': workoutTrend,
        },
        'summary': {
          'overallTrend': _getOverallTrend([
            waterTrend,
            nutritionTrend,
            workoutTrend,
          ]),
          'bestWeek': _findBestWeek(trends),
          'improvementAreas': _findImprovementAreas(trends),
        },
      };

      print('✅ Haftalık trend analizi tamamlandı');
      print('📈 Su trendi: ${_getTrendEmoji(waterTrend)}');
      print('📈 Beslenme trendi: ${_getTrendEmoji(nutritionTrend)}');
      print('📈 Antrenman trendi: ${_getTrendEmoji(workoutTrend)}');

      return result;
    } catch (e) {
      print('❌ Haftalık trend analizi hatası: $e');
      rethrow;
    }
  }

  // Günlük aktivite skorları
  static Future<Map<String, dynamic>> getDailyActivityScores({
    required String userId,
    required DateTime date,
  }) async {
    try {
      print('📊 Günlük aktivite skorları getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      // Günlük verileri getir
      final waterSummary = await WaterTrackingService.getDailyWaterSummary(
        userId: userId,
        date: date,
      );

      final nutritionSummary =
          await NutritionTrackingService.getDailyNutritionSummary(
            userId: userId,
            date: date,
          );

      final workoutSummary =
          await WorkoutTrackingService.getDailyWorkoutSummary(
            userId: userId,
            date: date,
          );

      // Skorları hesapla (0-100)
      double waterScore = 0.0;
      double nutritionScore = 0.0;
      double workoutScore = 0.0;

      // Su skoru
      if (waterSummary != null) {
        waterScore = (waterSummary.percentage / 100.0) * 100;
      }

      // Beslenme skoru
      if (nutritionSummary != null) {
        nutritionScore = nutritionSummary.overallProgress;
      }

      // Antrenman skoru
      if (workoutSummary != null) {
        workoutScore = workoutSummary.completionPercentage;
      }

      // Genel skor
      final overallScore = (waterScore + nutritionScore + workoutScore) / 3;

      // Hedef durumu
      final goals = {
        'water': WaterTrackingService.checkWaterGoals(
          currentAmount: waterSummary?.totalAmount ?? 0,
          targetAmount: 2500,
        ),
        'nutrition': nutritionSummary != null
            ? NutritionTrackingService.checkNutritionGoals(
                currentCalories: nutritionSummary.totalCalories,
                targetCalories: nutritionSummary.dietPlan.targetCalories,
                currentProtein: nutritionSummary.totalProtein,
                targetProtein: nutritionSummary.dietPlan.targetProtein,
                currentCarbs: nutritionSummary.totalCarbs,
                targetCarbs: nutritionSummary.dietPlan.targetCarbs,
                currentFat: nutritionSummary.totalFat,
                targetFat: nutritionSummary.dietPlan.targetFat,
              )
            : null,
        'workout': workoutSummary != null
            ? WorkoutTrackingService.checkWorkoutGoals(
                currentSessions: 1,
                targetSessions: 1,
                currentDuration: workoutSummary.totalDuration,
                targetDuration: 60, // 1 saat hedef
                currentExercises: workoutSummary.totalExercises,
                targetExercises: workoutSummary.totalExercises,
              )
            : null,
      };

      final result = {
        'date': date,
        'scores': {
          'water': waterScore,
          'nutrition': nutritionScore,
          'workout': workoutScore,
          'overall': overallScore,
        },
        'goals': goals,
        'summary': {
          'waterAmount': waterSummary?.totalAmount ?? 0,
          'waterTarget': 2500,
          'nutritionCompleted': nutritionSummary?.completedMealsCount ?? 0,
          'nutritionTotal': nutritionSummary?.totalPlannedMeals ?? 0,
          'workoutDuration': workoutSummary?.totalDuration ?? 0,
          'workoutExercises': workoutSummary?.totalExercises ?? 0,
        },
        'achievements': _getDailyAchievements(
          waterScore,
          nutritionScore,
          workoutScore,
        ),
      };

      print('✅ Günlük aktivite skorları hesaplandı');
      print('📊 Genel skor: ${overallScore.toStringAsFixed(1)}/100');
      print('💧 Su skoru: ${waterScore.toStringAsFixed(1)}/100');
      print('🍽️ Beslenme skoru: ${nutritionScore.toStringAsFixed(1)}/100');
      print('🏋️ Antrenman skoru: ${workoutScore.toStringAsFixed(1)}/100');

      return result;
    } catch (e) {
      print('❌ Günlük aktivite skorları hesaplama hatası: $e');
      rethrow;
    }
  }

  // Başarı rozetleri
  static Future<List<Map<String, dynamic>>> getUserAchievements({
    required String userId,
  }) async {
    try {
      print('🏆 Kullanıcı başarı rozetleri getiriliyor...');
      print('👤 User ID: $userId');

      final achievements = <Map<String, dynamic>>[];

      // Su başarıları
      final waterStats = await WaterTrackingService.getUserWaterStats(userId);
      if (waterStats['totalDays'] >= 7) {
        achievements.add({
          'id': 'water_week',
          'title': 'Su İçme Ustası',
          'description': '7 gün boyunca su takibi yaptın',
          'icon': '💧',
          'unlockedAt': DateTime.now(),
          'category': 'water',
        });
      }

      if (waterStats['averageDailyWater'] >= 2500) {
        achievements.add({
          'id': 'water_target',
          'title': 'Su Hedefi',
          'description': 'Günlük su hedefini tuttun',
          'icon': '🎯',
          'unlockedAt': DateTime.now(),
          'category': 'water',
        });
      }

      // Beslenme başarıları
      final nutritionStats = await NutritionTrackingService.getNutritionStats(
        userId,
      );
      if (nutritionStats['hasActivePlan'] &&
          nutritionStats['completionRate'] >= 80) {
        achievements.add({
          'id': 'nutrition_consistent',
          'title': 'Beslenme Ustası',
          'description': 'Beslenme planını %80 tamamladın',
          'icon': '🍽️',
          'unlockedAt': DateTime.now(),
          'category': 'nutrition',
        });
      }

      // Antrenman başarıları
      final workoutStats = await WorkoutTrackingService.getWorkoutStats(
        userId: userId,
      );
      if (workoutStats['workoutStreak'] >= 7) {
        achievements.add({
          'id': 'workout_streak',
          'title': 'Antrenman Serisi',
          'description': '7 gün üst üste antrenman yaptın',
          'icon': '🔥',
          'unlockedAt': DateTime.now(),
          'category': 'workout',
        });
      }

      if (workoutStats['totalSessions'] >= 30) {
        achievements.add({
          'id': 'workout_milestone',
          'title': 'Antrenman Milestone',
          'description': '30 antrenman oturumu tamamladın',
          'icon': '🏋️',
          'unlockedAt': DateTime.now(),
          'category': 'workout',
        });
      }

      print('✅ ${achievements.length} başarı rozeti bulundu');
      return achievements;
    } catch (e) {
      print('❌ Başarı rozetleri getirme hatası: $e');
      rethrow;
    }
  }

  // Trend hesaplama yardımcı fonksiyonu
  static String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'stable';

    final first = values.first;
    final last = values.last;
    final change = ((last - first) / first) * 100;

    if (change > 10) return 'increasing';
    if (change < -10) return 'decreasing';
    return 'stable';
  }

  // Genel trend hesaplama
  static String _getOverallTrend(List<String> trends) {
    final increasing = trends.where((t) => t == 'increasing').length;
    final decreasing = trends.where((t) => t == 'decreasing').length;

    if (increasing > decreasing) return 'improving';
    if (decreasing > increasing) return 'declining';
    return 'stable';
  }

  // En iyi hafta bulma
  static Map<String, dynamic> _findBestWeek(List<Map<String, dynamic>> trends) {
    if (trends.isEmpty) return {};

    return trends.reduce((best, current) {
      final bestScore =
          (best['water']['average'] as double) +
          (best['nutrition']['completionRate'] as double) +
          (best['workout']['sessions'] as double);
      final currentScore =
          (current['water']['average'] as double) +
          (current['nutrition']['completionRate'] as double) +
          (current['workout']['sessions'] as double);

      return currentScore > bestScore ? current : best;
    });
  }

  // İyileştirme alanları bulma
  static List<String> _findImprovementAreas(List<Map<String, dynamic>> trends) {
    final areas = <String>[];

    if (trends.isEmpty) return areas;

    final latest = trends.first;

    if ((latest['water']['average'] as double) < 2000) {
      areas.add('Su tüketimi artırılabilir');
    }

    if ((latest['nutrition']['completionRate'] as double) < 70) {
      areas.add('Beslenme planına daha sıkı uyulabilir');
    }

    if ((latest['workout']['sessions'] as double) < 3) {
      areas.add('Antrenman sıklığı artırılabilir');
    }

    return areas;
  }

  // Trend emoji
  static String _getTrendEmoji(String trend) {
    switch (trend) {
      case 'increasing':
        return '📈';
      case 'decreasing':
        return '📉';
      default:
        return '➡️';
    }
  }

  // Günlük başarılar
  static List<Map<String, dynamic>> _getDailyAchievements(
    double waterScore,
    double nutritionScore,
    double workoutScore,
  ) {
    final achievements = <Map<String, dynamic>>[];

    if (waterScore >= 100) {
      achievements.add({
        'title': 'Su Hedefi Tamamlandı!',
        'icon': '💧',
        'description': 'Günlük su hedefini tuttun',
      });
    }

    if (nutritionScore >= 80) {
      achievements.add({
        'title': 'Beslenme Başarısı!',
        'icon': '🍽️',
        'description': 'Beslenme planını başarıyla uyguladın',
      });
    }

    if (workoutScore >= 100) {
      achievements.add({
        'title': 'Antrenman Tamamlandı!',
        'icon': '🏋️',
        'description': 'Günlük antrenmanını tamamladın',
      });
    }

    return achievements;
  }
}
