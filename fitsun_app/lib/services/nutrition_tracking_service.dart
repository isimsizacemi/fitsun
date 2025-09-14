import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diet_plan.dart';

class NutritionTrackingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansları
  static CollectionReference get _dietPlansCollection =>
      _firestore.collection('diet_plans');

  static CollectionReference get _dietIntakesCollection =>
      _firestore.collection('diet_intakes');

  // Beslenme planı oluştur
  static Future<String> createDietPlan({
    required String userId,
    required String title,
    required String description,
    required int duration,
    required int targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    String? programId,
    List<Meal>? meals,
  }) async {
    try {
      print('🍽️ Beslenme planı oluşturuluyor...');
      print('👤 User ID: $userId');
      print('📋 Başlık: $title');

      final now = DateTime.now();
      final dietPlanId = 'diet_${userId}_${now.millisecondsSinceEpoch}';

      final dietPlan = DietPlan(
        id: dietPlanId,
        userId: userId,
        title: title,
        description: description,
        duration: duration,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        programId: programId,
        meals: meals ?? [],
        createdAt: now,
        updatedAt: now,
      );

      await _dietPlansCollection.doc(dietPlanId).set(dietPlan.toFirestore());

      print('✅ Beslenme planı oluşturuldu: $dietPlanId');
      return dietPlanId;
    } catch (e) {
      print('❌ Beslenme planı oluşturma hatası: $e');
      rethrow;
    }
  }

  // Beslenme planını güncelle
  static Future<void> updateDietPlan({
    required String dietPlanId,
    String? title,
    String? description,
    int? duration,
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    List<Meal>? meals,
  }) async {
    try {
      print('🍽️ Beslenme planı güncelleniyor...');
      print('📝 Diet Plan ID: $dietPlanId');

      final docRef = _dietPlansCollection.doc(dietPlanId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Beslenme planı bulunamadı');
      }

      Map<String, dynamic> updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (duration != null) updateData['duration'] = duration;
      if (targetCalories != null) updateData['targetCalories'] = targetCalories;
      if (targetProtein != null) updateData['targetProtein'] = targetProtein;
      if (targetCarbs != null) updateData['targetCarbs'] = targetCarbs;
      if (targetFat != null) updateData['targetFat'] = targetFat;
      if (meals != null)
        updateData['meals'] = meals.map((e) => e.toMap()).toList();

      await docRef.update(updateData);

      print('✅ Beslenme planı güncellendi');
    } catch (e) {
      print('❌ Beslenme planı güncelleme hatası: $e');
      rethrow;
    }
  }

  // Beslenme planını sil
  static Future<void> deleteDietPlan(String dietPlanId) async {
    try {
      print('🗑️ Beslenme planı siliniyor...');
      print('📝 Diet Plan ID: $dietPlanId');

      await _dietPlansCollection.doc(dietPlanId).delete();

      // İlgili beslenme kayıtlarını da sil
      final intakesQuery = await _dietIntakesCollection
          .where('dietPlanId', isEqualTo: dietPlanId)
          .get();

      final batch = _firestore.batch();
      for (final doc in intakesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ Beslenme planı ve kayıtları silindi');
    } catch (e) {
      print('❌ Beslenme planı silme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının beslenme planlarını getir
  static Future<List<DietPlan>> getUserDietPlans({
    required String userId,
    bool? isActive,
  }) async {
    try {
      print('🍽️ Kullanıcı beslenme planları getiriliyor...');
      print('👤 User ID: $userId');

      Query query = _dietPlansCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      final querySnapshot = await query.get();
      final dietPlans = querySnapshot.docs
          .map((doc) => DietPlan.fromFirestore(doc))
          .toList();

      print('✅ ${dietPlans.length} beslenme planı getirildi');
      return dietPlans;
    } catch (e) {
      print('❌ Beslenme planları getirme hatası: $e');
      rethrow;
    }
  }

  // Aktif beslenme planını getir
  static Future<DietPlan?> getActiveDietPlan(String userId) async {
    try {
      print('🍽️ Aktif beslenme planı getiriliyor...');
      print('👤 User ID: $userId');

      final querySnapshot = await _dietPlansCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Aktif beslenme planı bulunamadı');
        return null;
      }

      final dietPlan = DietPlan.fromFirestore(querySnapshot.docs.first);
      print('✅ Aktif beslenme planı getirildi: ${dietPlan.title}');
      return dietPlan;
    } catch (e) {
      print('❌ Aktif beslenme planı getirme hatası: $e');
      rethrow;
    }
  }

  // Beslenme kaydı ekle
  static Future<String> addDietIntake({
    required String userId,
    required String dietPlanId,
    required String mealId,
    required DateTime date,
    required DateTime time,
    String? actualAmount,
    String? notes,
  }) async {
    try {
      print('🍽️ Beslenme kaydı ekleniyor...');
      print('👤 User ID: $userId');
      print('📝 Diet Plan ID: $dietPlanId');
      print('🍽️ Meal ID: $mealId');

      final now = DateTime.now();
      final intakeId = 'intake_${userId}_${now.millisecondsSinceEpoch}';

      final dietIntake = DietIntake(
        id: intakeId,
        userId: userId,
        dietPlanId: dietPlanId,
        mealId: mealId,
        date: date,
        time: time,
        actualAmount: actualAmount,
        notes: notes,
        createdAt: now,
      );

      await _dietIntakesCollection.doc(intakeId).set(dietIntake.toFirestore());

      print('✅ Beslenme kaydı eklendi: $intakeId');
      return intakeId;
    } catch (e) {
      print('❌ Beslenme kaydı ekleme hatası: $e');
      rethrow;
    }
  }

  // Beslenme kaydını tamamla
  static Future<void> completeDietIntake({
    required String intakeId,
    String? actualAmount,
    String? notes,
  }) async {
    try {
      print('✅ Beslenme kaydı tamamlanıyor...');
      print('📝 Intake ID: $intakeId');

      await _dietIntakesCollection.doc(intakeId).update({
        'isCompleted': true,
        'actualAmount': actualAmount,
        'notes': notes,
      });

      print('✅ Beslenme kaydı tamamlandı');
    } catch (e) {
      print('❌ Beslenme kaydı tamamlama hatası: $e');
      rethrow;
    }
  }

  // Günlük beslenme kayıtlarını getir
  static Future<List<DietIntake>> getDailyDietIntakes({
    required String userId,
    required DateTime date,
  }) async {
    try {
      print('📅 Günlük beslenme kayıtları getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _dietIntakesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('time', descending: true)
          .get();

      final intakes = querySnapshot.docs
          .map((doc) => DietIntake.fromFirestore(doc))
          .toList();

      print('✅ ${intakes.length} günlük beslenme kaydı getirildi');
      return intakes;
    } catch (e) {
      print('❌ Günlük beslenme kayıtları getirme hatası: $e');
      rethrow;
    }
  }

  // Günlük beslenme özeti getir
  static Future<DailyNutritionSummary?> getDailyNutritionSummary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      print('📊 Günlük beslenme özeti getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      final activeDietPlan = await getActiveDietPlan(userId);
      if (activeDietPlan == null) {
        print('⚠️ Aktif beslenme planı bulunamadı');
        return null;
      }

      final intakes = await getDailyDietIntakes(userId: userId, date: date);

      // Planlanan öğünleri getir
      final dayName = _getDayName(date);
      final plannedMeals = activeDietPlan.getMealsForDay(dayName);

      // Tamamlanan öğünleri hesapla
      final completedIntakes = intakes
          .where((intake) => intake.isCompleted)
          .toList();
      final completedMealIds = completedIntakes
          .map((intake) => intake.mealId)
          .toSet();

      // Besin değerlerini hesapla
      int totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in plannedMeals) {
        if (completedMealIds.contains(meal.foodName)) {
          totalCalories += meal.calories;
          totalProtein += meal.protein;
          totalCarbs += meal.carbs;
          totalFat += meal.fat;
        }
      }

      final summary = DailyNutritionSummary(
        date: date,
        dietPlan: activeDietPlan,
        plannedMeals: plannedMeals,
        completedIntakes: completedIntakes,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        caloriesProgress: (totalCalories / activeDietPlan.targetCalories) * 100,
        proteinProgress: (totalProtein / activeDietPlan.targetProtein) * 100,
        carbsProgress: (totalCarbs / activeDietPlan.targetCarbs) * 100,
        fatProgress: (totalFat / activeDietPlan.targetFat) * 100,
      );

      print('✅ Günlük beslenme özeti oluşturuldu');
      print(
        '🍽️ Tamamlanan öğün: ${completedIntakes.length}/${plannedMeals.length}',
      );
      print('📊 Kalori: ${totalCalories}/${activeDietPlan.targetCalories}');

      return summary;
    } catch (e) {
      print('❌ Günlük beslenme özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Haftalık beslenme özeti getir
  static Future<List<DailyNutritionSummary>> getWeeklyNutritionSummary({
    required String userId,
    required DateTime startDate,
  }) async {
    try {
      print('📅 Haftalık beslenme özeti getiriliyor...');
      print('👤 User ID: $userId');
      print(
        '📅 Başlangıç tarihi: ${startDate.day}/${startDate.month}/${startDate.year}',
      );

      final summaries = <DailyNutritionSummary>[];

      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final summary = await getDailyNutritionSummary(
          userId: userId,
          date: date,
        );

        if (summary != null) {
          summaries.add(summary);
        }
      }

      print('✅ Haftalık beslenme özeti oluşturuldu');
      return summaries;
    } catch (e) {
      print('❌ Haftalık beslenme özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Beslenme istatistikleri getir
  static Future<Map<String, dynamic>> getNutritionStats(String userId) async {
    try {
      print('📊 Beslenme istatistikleri getiriliyor...');
      print('👤 User ID: $userId');

      final activeDietPlan = await getActiveDietPlan(userId);
      if (activeDietPlan == null) {
        return {
          'hasActivePlan': false,
          'totalDays': 0,
          'averageCalories': 0.0,
          'averageProtein': 0.0,
          'averageCarbs': 0.0,
          'averageFat': 0.0,
          'completionRate': 0.0,
        };
      }

      // Son 30 günün verilerini getir
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: 30));

      final intakes = await _dietIntakesCollection
          .where('userId', isEqualTo: userId)
          .where('dietPlanId', isEqualTo: activeDietPlan.id)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final completedIntakes = intakes.docs
          .map((doc) => DietIntake.fromFirestore(doc))
          .where((intake) => intake.isCompleted)
          .toList();

      // Günlere göre grupla
      Map<String, List<DietIntake>> dailyIntakes = {};
      for (final intake in completedIntakes) {
        final dateKey =
            '${intake.date.year}-${intake.date.month}-${intake.date.day}';
        dailyIntakes[dateKey] ??= [];
        dailyIntakes[dateKey]!.add(intake);
      }

      final totalDays = dailyIntakes.length;
      final totalMeals = completedIntakes.length;
      final totalPlannedMeals =
          30 * activeDietPlan.meals.length; // 30 gün * günlük öğün sayısı

      final stats = {
        'hasActivePlan': true,
        'totalDays': totalDays,
        'totalMeals': totalMeals,
        'totalPlannedMeals': totalPlannedMeals,
        'completionRate': totalPlannedMeals > 0
            ? (totalMeals / totalPlannedMeals) * 100
            : 0.0,
        'dietPlanTitle': activeDietPlan.title,
        'targetCalories': activeDietPlan.targetCalories,
        'targetProtein': activeDietPlan.targetProtein,
        'targetCarbs': activeDietPlan.targetCarbs,
        'targetFat': activeDietPlan.targetFat,
      };

      print('✅ Beslenme istatistikleri hesaplandı');
      print('📊 Toplam gün: $totalDays');
      print('🍽️ Tamamlanan öğün: $totalMeals');
      print(
        '📈 Tamamlanma oranı: ${(stats['completionRate'] as double).toStringAsFixed(1)}%',
      );

      return stats;
    } catch (e) {
      print('❌ Beslenme istatistikleri hesaplama hatası: $e');
      rethrow;
    }
  }

  // Beslenme hedeflerini kontrol et
  static Map<String, dynamic> checkNutritionGoals({
    required int currentCalories,
    required int targetCalories,
    required double currentProtein,
    required double targetProtein,
    required double currentCarbs,
    required double targetCarbs,
    required double currentFat,
    required double targetFat,
  }) {
    final caloriesProgress = (currentCalories / targetCalories) * 100;
    final proteinProgress = (currentProtein / targetProtein) * 100;
    final carbsProgress = (currentCarbs / targetCarbs) * 100;
    final fatProgress = (currentFat / targetFat) * 100;

    final overallProgress =
        (caloriesProgress + proteinProgress + carbsProgress + fatProgress) / 4;

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
      emoji = '🍽️';
      message = 'Devam et!';
    } else {
      status = 'very_low';
      emoji = '🥗';
      message = 'Daha fazla beslenmelisin!';
    }

    return {
      'status': status,
      'emoji': emoji,
      'message': message,
      'overallProgress': overallProgress,
      'caloriesProgress': caloriesProgress,
      'proteinProgress': proteinProgress,
      'carbsProgress': carbsProgress,
      'fatProgress': fatProgress,
      'remainingCalories': targetCalories - currentCalories,
      'remainingProtein': targetProtein - currentProtein,
      'remainingCarbs': targetCarbs - currentCarbs,
      'remainingFat': targetFat - currentFat,
    };
  }

  // Gün adını al
  static String _getDayName(DateTime date) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[date.weekday - 1];
  }
}
