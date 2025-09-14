import 'package:cloud_firestore/cloud_firestore.dart';
import 'water_tracking_service.dart';
import 'nutrition_tracking_service.dart';
import 'workout_tracking_service.dart';
import '../models/water_intake.dart';
import '../models/diet_plan.dart';
import '../models/workout_model.dart';

class WeeklySummaryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Haftalık özet oluştur
  static Future<String> createWeeklySummary({
    required String userId,
    required DateTime weekStart,
  }) async {
    try {
      print('📅 Haftalık özet oluşturuluyor...');
      print('👤 User ID: $userId');
      print(
        '📅 Hafta başlangıcı: ${weekStart.day}/${weekStart.month}/${weekStart.year}',
      );

      final now = DateTime.now();
      final summaryId = 'weekly_${userId}_${weekStart.millisecondsSinceEpoch}';

      // Haftalık verileri topla
      final weeklyData = await _collectWeeklyData(userId, weekStart);

      final summary = WeeklySummary(
        id: summaryId,
        userId: userId,
        weekStart: weekStart,
        weekEnd: weekStart.add(Duration(days: 6)),
        waterData: weeklyData['water'],
        nutritionData: weeklyData['nutrition'],
        workoutData: weeklyData['workout'],
        overallScore: weeklyData['overallScore'],
        achievements: weeklyData['achievements'],
        goals: weeklyData['goals'],
        insights: weeklyData['insights'],
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('weekly_summaries')
          .doc(summaryId)
          .set(summary.toFirestore());

      print('✅ Haftalık özet oluşturuldu: $summaryId');
      return summaryId;
    } catch (e) {
      print('❌ Haftalık özet oluşturma hatası: $e');
      rethrow;
    }
  }

  // Haftalık özeti getir
  static Future<WeeklySummary?> getWeeklySummary({
    required String userId,
    required DateTime weekStart,
  }) async {
    try {
      print('📅 Haftalık özet getiriliyor...');
      print('👤 User ID: $userId');
      print(
        '📅 Hafta başlangıcı: ${weekStart.day}/${weekStart.month}/${weekStart.year}',
      );

      final querySnapshot = await _firestore
          .collection('weekly_summaries')
          .where('userId', isEqualTo: userId)
          .where('weekStart', isEqualTo: Timestamp.fromDate(weekStart))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Haftalık özet bulunamadı');
        return null;
      }

      final summary = WeeklySummary.fromFirestore(querySnapshot.docs.first);
      print('✅ Haftalık özet getirildi');
      return summary;
    } catch (e) {
      print('❌ Haftalık özet getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının haftalık özetlerini getir
  static Future<List<WeeklySummary>> getUserWeeklySummaries({
    required String userId,
    int? limit,
  }) async {
    try {
      print('📅 Kullanıcı haftalık özetleri getiriliyor...');
      print('👤 User ID: $userId');

      Query query = _firestore
          .collection('weekly_summaries')
          .where('userId', isEqualTo: userId)
          .orderBy('weekStart', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final summaries = querySnapshot.docs
          .map((doc) => WeeklySummary.fromFirestore(doc))
          .toList();

      print('✅ ${summaries.length} haftalık özet getirildi');
      return summaries;
    } catch (e) {
      print('❌ Haftalık özetler getirme hatası: $e');
      rethrow;
    }
  }

  // Otomatik haftalık özet oluştur (geçmiş haftalar için)
  static Future<void> generatePastWeeklySummaries({
    required String userId,
    int weeksBack = 4,
  }) async {
    try {
      print('📅 Geçmiş haftalık özetler oluşturuluyor...');
      print('👤 User ID: $userId');
      print('📅 Hafta sayısı: $weeksBack');

      final now = DateTime.now();
      final currentWeekStart = _getWeekStart(now);

      for (int i = 1; i <= weeksBack; i++) {
        final weekStart = currentWeekStart.subtract(Duration(days: i * 7));

        // Bu hafta için özet var mı kontrol et
        final existingSummary = await getWeeklySummary(
          userId: userId,
          weekStart: weekStart,
        );

        if (existingSummary == null) {
          // Özet oluştur
          await createWeeklySummary(userId: userId, weekStart: weekStart);
        }
      }

      print('✅ Geçmiş haftalık özetler oluşturuldu');
    } catch (e) {
      print('❌ Geçmiş haftalık özetler oluşturma hatası: $e');
      rethrow;
    }
  }

  // Haftalık verileri topla
  static Future<Map<String, dynamic>> _collectWeeklyData(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      // Su verileri
      final waterSummary = await WaterTrackingService.getWeeklyWaterSummary(
        userId: userId,
        startDate: weekStart,
      );

      // Beslenme verileri
      final nutritionSummary =
          await NutritionTrackingService.getWeeklyNutritionSummary(
            userId: userId,
            startDate: weekStart,
          );

      // Antrenman verileri
      final workoutSummary =
          await WorkoutTrackingService.getWeeklyWorkoutSummary(
            userId: userId,
            startDate: weekStart,
          );

      // Su istatistikleri
      final waterTotal = waterSummary.fold(
        0,
        (sum, day) => sum + day.totalAmount,
      );
      final waterAverage = waterTotal / 7;
      final waterDays = waterSummary.where((day) => day.totalAmount > 0).length;
      final waterTargetDays = waterSummary
          .where((day) => day.percentage >= 100)
          .length;

      // Beslenme istatistikleri
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
      final nutritionDays = nutritionSummary
          .where((day) => day.completedMealsCount > 0)
          .length;

      // Antrenman istatistikleri
      final workoutSessions = workoutSummary.length;
      final workoutDuration = workoutSummary.fold<int>(
        0,
        (sum, day) => sum + day.totalDuration,
      );
      final workoutExercises = workoutSummary.fold<int>(
        0,
        (sum, day) => sum + day.totalExercises,
      );
      final workoutDays = workoutSummary
          .where((day) => day.totalExercises > 0)
          .length;

      // Genel skor hesapla
      final waterScore = (waterAverage / 2500.0) * 100; // 2.5L hedef
      final nutritionScore = nutritionRate;
      final workoutScore = (workoutDays / 7.0) * 100; // Haftada 7 gün hedef
      final overallScore = (waterScore + nutritionScore + workoutScore) / 3;

      // Başarılar
      final achievements = <Map<String, dynamic>>[];
      if (waterTargetDays >= 5) {
        achievements.add({
          'title': 'Su Ustası',
          'description': '5 gün su hedefini tuttun',
          'icon': '💧',
          'category': 'water',
        });
      }
      if (nutritionRate >= 80) {
        achievements.add({
          'title': 'Beslenme Ustası',
          'description': 'Beslenme planını %80 tamamladın',
          'icon': '🍽️',
          'category': 'nutrition',
        });
      }
      if (workoutDays >= 5) {
        achievements.add({
          'title': 'Antrenman Ustası',
          'description': '5 gün antrenman yaptın',
          'icon': '🏋️',
          'category': 'workout',
        });
      }

      // Hedefler
      final goals = {
        'water': {
          'target': 2500 * 7, // Haftalık hedef
          'achieved': waterTotal,
          'percentage': (waterTotal / (2500 * 7)) * 100,
        },
        'nutrition': {
          'target': nutritionTotal,
          'achieved': nutritionCompleted,
          'percentage': nutritionRate,
        },
        'workout': {
          'target': 7, // Haftada 7 gün
          'achieved': workoutDays,
          'percentage': (workoutDays / 7) * 100,
        },
      };

      // İçgörüler
      final insights = _generateInsights(
        waterData: waterSummary,
        nutritionData: nutritionSummary,
        workoutData: workoutSummary,
      );

      return {
        'water': {
          'total': waterTotal,
          'average': waterAverage,
          'days': waterDays,
          'targetDays': waterTargetDays,
          'score': waterScore,
        },
        'nutrition': {
          'completedMeals': nutritionCompleted,
          'totalMeals': nutritionTotal,
          'completionRate': nutritionRate,
          'days': nutritionDays,
          'score': nutritionScore,
        },
        'workout': {
          'sessions': workoutSessions,
          'duration': workoutDuration,
          'exercises': workoutExercises,
          'days': workoutDays,
          'score': workoutScore,
        },
        'overallScore': overallScore,
        'achievements': achievements,
        'goals': goals,
        'insights': insights,
      };
    } catch (e) {
      print('❌ Haftalık veri toplama hatası: $e');
      rethrow;
    }
  }

  // İçgörüler oluştur
  static List<Map<String, dynamic>> _generateInsights({
    required List<DailyWaterSummary> waterData,
    required List<DailyNutritionSummary> nutritionData,
    required List<DailyWorkoutSummary> workoutData,
  }) {
    final insights = <Map<String, dynamic>>[];

    // Su içgörüleri
    final waterDays = waterData.where((day) => day.totalAmount > 0).length;
    if (waterDays >= 5) {
      insights.add({
        'type': 'positive',
        'category': 'water',
        'title': 'Su Tüketimi Mükemmel!',
        'description':
            'Haftanın $waterDays gününde su tüketimi yaptın. Harika!',
        'icon': '💧',
      });
    } else if (waterDays < 3) {
      insights.add({
        'type': 'improvement',
        'category': 'water',
        'title': 'Su Tüketimi Artırılabilir',
        'description':
            'Sadece $waterDays gün su tüketimi yaptın. Daha fazla su içmeyi deneyebilirsin.',
        'icon': '💧',
      });
    }

    // Beslenme içgörüleri
    final nutritionRate =
        nutritionData.fold(0.0, (sum, day) => sum + day.completionRate) / 7;
    if (nutritionRate >= 80) {
      insights.add({
        'type': 'positive',
        'category': 'nutrition',
        'title': 'Beslenme Planı Başarılı!',
        'description':
            'Beslenme planını %${nutritionRate.toStringAsFixed(1)} tamamladın. Mükemmel!',
        'icon': '🍽️',
      });
    } else if (nutritionRate < 50) {
      insights.add({
        'type': 'improvement',
        'category': 'nutrition',
        'title': 'Beslenme Planına Odaklan',
        'description':
            'Beslenme planını %${nutritionRate.toStringAsFixed(1)} tamamladın. Daha düzenli beslenmeyi deneyebilirsin.',
        'icon': '🍽️',
      });
    }

    // Antrenman içgörüleri
    final workoutDays = workoutData.length;
    if (workoutDays >= 5) {
      insights.add({
        'type': 'positive',
        'category': 'workout',
        'title': 'Antrenman Tutarlılığı Harika!',
        'description': 'Haftanın $workoutDays gününde antrenman yaptın. Süper!',
        'icon': '🏋️',
      });
    } else if (workoutDays < 3) {
      insights.add({
        'type': 'improvement',
        'category': 'workout',
        'title': 'Antrenman Sıklığını Artır',
        'description':
            'Sadece $workoutDays gün antrenman yaptın. Daha sık antrenman yapmayı deneyebilirsin.',
        'icon': '🏋️',
      });
    }

    // Genel içgörü
    final overallScore = (waterDays + nutritionRate + workoutDays) / 3;
    if (overallScore >= 80) {
      insights.add({
        'type': 'positive',
        'category': 'overall',
        'title': 'Harika Bir Hafta!',
        'description':
            'Genel olarak çok başarılı bir hafta geçirdin. Tebrikler!',
        'icon': '🎉',
      });
    } else if (overallScore < 50) {
      insights.add({
        'type': 'improvement',
        'category': 'overall',
        'title': 'Gelecek Hafta Daha İyi Olacak',
        'description':
            'Bu hafta biraz zorlu geçti ama gelecek hafta daha iyi olacak. Sen yapabilirsin!',
        'icon': '💪',
      });
    }

    return insights;
  }

  // Hafta başlangıcını hesapla (Pazartesi)
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1; // Pazartesi = 1
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  // Haftalık özeti güncelle
  static Future<void> updateWeeklySummary({
    required String summaryId,
    Map<String, dynamic>? insights,
    List<Map<String, dynamic>>? achievements,
  }) async {
    try {
      print('📅 Haftalık özet güncelleniyor...');
      print('📝 Summary ID: $summaryId');

      final docRef = _firestore.collection('weekly_summaries').doc(summaryId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Haftalık özet bulunamadı');
      }

      Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (insights != null) {
        updateData['insights'] = insights;
      }

      if (achievements != null) {
        updateData['achievements'] = achievements;
      }

      await docRef.update(updateData);

      print('✅ Haftalık özet güncellendi');
    } catch (e) {
      print('❌ Haftalık özet güncelleme hatası: $e');
      rethrow;
    }
  }

  // Haftalık özeti sil
  static Future<void> deleteWeeklySummary(String summaryId) async {
    try {
      print('🗑️ Haftalık özet siliniyor...');
      print('📝 Summary ID: $summaryId');

      await _firestore.collection('weekly_summaries').doc(summaryId).delete();

      print('✅ Haftalık özet silindi');
    } catch (e) {
      print('❌ Haftalık özet silme hatası: $e');
      rethrow;
    }
  }
}

// Haftalık özet sınıfı
class WeeklySummary {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, dynamic> waterData;
  final Map<String, dynamic> nutritionData;
  final Map<String, dynamic> workoutData;
  final double overallScore;
  final List<Map<String, dynamic>> achievements;
  final Map<String, dynamic> goals;
  final List<Map<String, dynamic>> insights;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklySummary({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.waterData,
    required this.nutritionData,
    required this.workoutData,
    required this.overallScore,
    required this.achievements,
    required this.goals,
    required this.insights,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklySummary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WeeklySummary(
      id: doc.id,
      userId: data['userId'] ?? '',
      weekStart: (data['weekStart'] as Timestamp).toDate(),
      weekEnd: (data['weekEnd'] as Timestamp).toDate(),
      waterData: Map<String, dynamic>.from(data['waterData'] ?? {}),
      nutritionData: Map<String, dynamic>.from(data['nutritionData'] ?? {}),
      workoutData: Map<String, dynamic>.from(data['workoutData'] ?? {}),
      overallScore: (data['overallScore'] ?? 0.0).toDouble(),
      achievements: List<Map<String, dynamic>>.from(data['achievements'] ?? []),
      goals: Map<String, dynamic>.from(data['goals'] ?? {}),
      insights: List<Map<String, dynamic>>.from(data['insights'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'weekStart': Timestamp.fromDate(weekStart),
      'weekEnd': Timestamp.fromDate(weekEnd),
      'waterData': waterData,
      'nutritionData': nutritionData,
      'workoutData': workoutData,
      'overallScore': overallScore,
      'achievements': achievements,
      'goals': goals,
      'insights': insights,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Hafta formatı
  String get weekFormatted {
    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}';
  }

  // Genel durum
  String get overallStatus {
    if (overallScore >= 80) return 'Mükemmel';
    if (overallScore >= 60) return 'İyi';
    if (overallScore >= 40) return 'Orta';
    return 'Geliştirilebilir';
  }

  // Başarı sayısı
  int get achievementCount => achievements.length;

  // İçgörü sayısı
  int get insightCount => insights.length;
}
