import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diet_plan.dart';

class DietService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Koleksiyon referansları
  static CollectionReference get _dietPlansCollection =>
      _firestore.collection('diet_plans');
  static CollectionReference get _dietIntakesCollection =>
      _firestore.collection('diet_intakes');

  // Yeni diyet planı oluştur
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
      print('🍎 Diyet planı oluşturuluyor...');
      print('👤 User ID: $userId');
      print('📝 Başlık: $title');
      print('🎯 Hedef kalori: $targetCalories');
      
      final now = DateTime.now();
      final dietId = 'diet_${userId}_${now.millisecondsSinceEpoch}';
      
      final dietPlan = DietPlan(
        id: dietId,
        userId: userId,
        title: title,
        description: description,
        duration: duration,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        isActive: true,
        programId: programId,
        meals: meals ?? [],
        createdAt: now,
        updatedAt: now,
      );

      await _dietPlansCollection.doc(dietId).set(dietPlan.toFirestore());
      
      print('✅ Diyet planı oluşturuldu: $dietId');
      return dietId;
    } catch (e) {
      print('❌ Diyet planı oluşturma hatası: $e');
      rethrow;
    }
  }

  // Diyet planını güncelle
  static Future<void> updateDietPlan({
    required String dietId,
    String? title,
    String? description,
    int? duration,
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    bool? isActive,
    String? programId,
    List<Meal>? meals,
  }) async {
    try {
      print('🍎 Diyet planı güncelleniyor...');
      print('📝 Diet ID: $dietId');
      
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
      if (isActive != null) updateData['isActive'] = isActive;
      if (programId != null) updateData['programId'] = programId;
      if (meals != null) updateData['meals'] = meals.map((m) => m.toMap()).toList();
      
      await _dietPlansCollection.doc(dietId).update(updateData);
      
      print('✅ Diyet planı güncellendi');
    } catch (e) {
      print('❌ Diyet planı güncelleme hatası: $e');
      rethrow;
    }
  }

  // Diyet planına öğün ekle
  static Future<void> addMealToDietPlan({
    required String dietId,
    required Meal meal,
  }) async {
    try {
      print('🍽️ Öğün ekleniyor...');
      print('📝 Diet ID: $dietId');
      print('🍽️ Öğün: ${meal.mealType} - ${meal.foodName}');
      
      final docRef = _dietPlansCollection.doc(dietId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Diyet planı bulunamadı');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final meals = (data['meals'] as List<dynamic>?)
          ?.map((e) => Meal.fromMap(e))
          .toList() ?? [];
      
      meals.add(meal);
      
      await docRef.update({
        'meals': meals.map((m) => m.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      print('✅ Öğün eklendi');
    } catch (e) {
      print('❌ Öğün ekleme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının diyet planlarını getir
  static Future<List<DietPlan>> getUserDietPlans({
    required String userId,
    bool? isActive,
  }) async {
    try {
      print('🍎 Kullanıcı diyet planları getiriliyor...');
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
      
      print('✅ ${dietPlans.length} diyet planı getirildi');
      return dietPlans;
    } catch (e) {
      print('❌ Diyet planları getirme hatası: $e');
      rethrow;
    }
  }

  // Belirli bir diyet planını getir
  static Future<DietPlan?> getDietPlan(String dietId) async {
    try {
      print('🍎 Diyet planı getiriliyor...');
      print('📝 Diet ID: $dietId');
      
      final doc = await _dietPlansCollection.doc(dietId).get();
      
      if (!doc.exists) {
        print('⚠️ Diyet planı bulunamadı');
        return null;
      }
      
      final dietPlan = DietPlan.fromFirestore(doc);
      print('✅ Diyet planı getirildi');
      return dietPlan;
    } catch (e) {
      print('❌ Diyet planı getirme hatası: $e');
      rethrow;
    }
  }

  // Diyet tüketimi ekle
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
      print('🍽️ Diyet tüketimi ekleniyor...');
      print('👤 User ID: $userId');
      print('📝 Diet Plan ID: $dietPlanId');
      print('🍽️ Meal ID: $mealId');
      
      final now = DateTime.now();
      final intakeId = 'diet_intake_${userId}_${now.millisecondsSinceEpoch}';
      
      final dietIntake = DietIntake(
        id: intakeId,
        userId: userId,
        dietPlanId: dietPlanId,
        mealId: mealId,
        date: date,
        time: time,
        isCompleted: true,
        actualAmount: actualAmount,
        notes: notes,
        createdAt: now,
      );

      await _dietIntakesCollection.doc(intakeId).set(dietIntake.toFirestore());
      
      print('✅ Diyet tüketimi eklendi: $intakeId');
      return intakeId;
    } catch (e) {
      print('❌ Diyet tüketimi ekleme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının diyet tüketimlerini getir
  static Future<List<DietIntake>> getUserDietIntakes({
    required String userId,
    String? dietPlanId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🍽️ Kullanıcı diyet tüketimleri getiriliyor...');
      print('👤 User ID: $userId');
      
      Query query = _dietIntakesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);
      
      if (dietPlanId != null) {
        query = query.where('dietPlanId', isEqualTo: dietPlanId);
      }
      
      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final querySnapshot = await query.get();
      final intakes = querySnapshot.docs
          .map((doc) => DietIntake.fromFirestore(doc))
          .toList();
      
      print('✅ ${intakes.length} diyet tüketimi getirildi');
      return intakes;
    } catch (e) {
      print('❌ Diyet tüketimleri getirme hatası: $e');
      rethrow;
    }
  }

  // Belirli bir günün diyet tüketimlerini getir
  static Future<List<DietIntake>> getDailyDietIntakes({
    required String userId,
    required DateTime date,
    String? dietPlanId,
  }) async {
    try {
      print('📅 Günlük diyet tüketimleri getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');
      
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      Query query = _dietIntakesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('time', descending: true);
      
      if (dietPlanId != null) {
        query = query.where('dietPlanId', isEqualTo: dietPlanId);
      }
      
      final querySnapshot = await query.get();
      final intakes = querySnapshot.docs
          .map((doc) => DietIntake.fromFirestore(doc))
          .toList();
      
      print('✅ ${intakes.length} günlük diyet tüketimi getirildi');
      return intakes;
    } catch (e) {
      print('❌ Günlük diyet tüketimleri getirme hatası: $e');
      rethrow;
    }
  }

  // Günlük besin değerleri özeti getir
  static Future<Map<String, dynamic>> getDailyNutritionSummary({
    required String userId,
    required DateTime date,
    String? dietPlanId,
  }) async {
    try {
      print('📊 Günlük besin değerleri özeti getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');
      
      final intakes = await getDailyDietIntakes(
        userId: userId,
        date: date,
        dietPlanId: dietPlanId,
      );
      
      if (intakes.isEmpty) {
        return {
          'totalCalories': 0,
          'totalProtein': 0.0,
          'totalCarbs': 0.0,
          'totalFat': 0.0,
          'mealCount': 0,
          'goalAchievement': {
            'calories': 0.0,
            'protein': 0.0,
            'carbs': 0.0,
            'fat': 0.0,
          },
        };
      }
      
      // Besin değerlerini hesapla
      int totalCalories = 0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      int mealCount = intakes.length;
      
      // Her tüketim için besin değerlerini topla
      for (final intake in intakes) {
        // Meal bilgisini diet planından al
        if (dietPlanId != null) {
          final dietPlan = await getDietPlan(dietPlanId);
          if (dietPlan != null) {
            final meal = dietPlan.meals.firstWhere(
              (m) => m.foodName == intake.mealId, // Bu kısım düzeltilmeli
              orElse: () => Meal(
                dayName: '',
                mealType: '',
                foodName: '',
                calories: 0,
                protein: 0.0,
                carbs: 0.0,
                fat: 0.0,
                amount: '',
                time: '',
              ),
            );
            
            totalCalories += meal.calories;
            totalProtein += meal.protein;
            totalCarbs += meal.carbs;
            totalFat += meal.fat;
          }
        }
      }
      
      // Hedef başarı yüzdesi (varsayılan hedefler)
      final goalAchievement = {
        'calories': (totalCalories / 2000.0) * 100, // 2000 kcal hedef
        'protein': (totalProtein / 150.0) * 100, // 150g protein hedef
        'carbs': (totalCarbs / 250.0) * 100, // 250g karbonhidrat hedef
        'fat': (totalFat / 65.0) * 100, // 65g yağ hedef
      };
      
      final summary = {
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'mealCount': mealCount,
        'goalAchievement': goalAchievement,
      };
      
      print('✅ Günlük besin değerleri özeti oluşturuldu');
      print('🔥 Toplam kalori: $totalCalories');
      print('🥩 Toplam protein: ${totalProtein.toStringAsFixed(1)}g');
      print('🍞 Toplam karbonhidrat: ${totalCarbs.toStringAsFixed(1)}g');
      print('🥑 Toplam yağ: ${totalFat.toStringAsFixed(1)}g');
      
      return summary;
    } catch (e) {
      print('❌ Günlük besin değerleri özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Diyet planını sil
  static Future<void> deleteDietPlan(String dietId) async {
    try {
      print('🗑️ Diyet planı siliniyor...');
      print('📝 Diet ID: $dietId');
      
      await _dietPlansCollection.doc(dietId).delete();
      
      print('✅ Diyet planı silindi');
    } catch (e) {
      print('❌ Diyet planı silme hatası: $e');
      rethrow;
    }
  }

  // Diyet tüketimini sil
  static Future<void> deleteDietIntake(String intakeId) async {
    try {
      print('🗑️ Diyet tüketimi siliniyor...');
      print('📝 Intake ID: $intakeId');
      
      await _dietIntakesCollection.doc(intakeId).delete();
      
      print('✅ Diyet tüketimi silindi');
    } catch (e) {
      print('❌ Diyet tüketimi silme hatası: $e');
      rethrow;
    }
  }

  // Diyet hedeflerini kontrol et
  static Map<String, dynamic> checkDietGoals({
    required int currentCalories,
    required int targetCalories,
    required double currentProtein,
    required double targetProtein,
    required double currentCarbs,
    required double targetCarbs,
    required double currentFat,
    required double targetFat,
  }) {
    final caloriePercentage = (currentCalories / targetCalories) * 100;
    final proteinPercentage = (currentProtein / targetProtein) * 100;
    final carbsPercentage = (currentCarbs / targetCarbs) * 100;
    final fatPercentage = (currentFat / targetFat) * 100;
    
    String overallStatus;
    String emoji;
    String message;
    
    final averagePercentage = (caloriePercentage + proteinPercentage + carbsPercentage + fatPercentage) / 4;
    
    if (averagePercentage >= 100) {
      overallStatus = 'excellent';
      emoji = '🏆';
      message = 'Mükemmel! Hedeflerin tamamlandı!';
    } else if (averagePercentage >= 90) {
      overallStatus = 'very_good';
      emoji = '🎉';
      message = 'Çok iyi! Neredeyse tamamlandı!';
    } else if (averagePercentage >= 80) {
      overallStatus = 'good';
      emoji = '👍';
      message = 'İyi gidiyor!';
    } else if (averagePercentage >= 60) {
      overallStatus = 'fair';
      emoji = '💪';
      message = 'Devam et!';
    } else {
      overallStatus = 'needs_improvement';
      emoji = '🍎';
      message = 'Daha fazla beslenmelisin!';
    }
    
    return {
      'overallStatus': overallStatus,
      'emoji': emoji,
      'message': message,
      'averagePercentage': averagePercentage,
      'caloriePercentage': caloriePercentage,
      'proteinPercentage': proteinPercentage,
      'carbsPercentage': carbsPercentage,
      'fatPercentage': fatPercentage,
      'remaining': {
        'calories': targetCalories - currentCalories,
        'protein': targetProtein - currentProtein,
        'carbs': targetCarbs - currentCarbs,
        'fat': targetFat - currentFat,
      },
    };
  }

  // Diyet planını aktifleştir (diğerlerini pasifleştir)
  static Future<bool> activateDietPlan(String userId, String dietId) async {
    try {
      print('🔄 Diyet planı aktifleştiriliyor...');
      print('👤 User ID: $userId');
      print('📋 Diet ID: $dietId');

      // Önce tüm diyet planlarını pasifleştir
      final allDiets = await _dietPlansCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in allDiets.docs) {
        await doc.reference.update({'isActive': false});
      }

      // Seçilen diyet planını aktifleştir
      await _dietPlansCollection.doc(dietId).update({'isActive': true});

      print('✅ Diyet planı aktifleştirildi');
      return true;
    } catch (e) {
      print('❌ Diyet planı aktifleştirme hatası: $e');
      return false;
    }
  }

  // Aktif diyet planını getir
  static Future<DietPlan?> getActiveDietPlan(String userId) async {
    try {
      print('🔍 Aktif diyet planı getiriliyor...');
      print('👤 User ID: $userId');

      final snapshot = await _dietPlansCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final dietPlan = DietPlan.fromFirestore(snapshot.docs.first);
        print('✅ Aktif diyet planı bulundu: ${dietPlan.title}');
        return dietPlan;
      } else {
        print('⚠️ Aktif diyet planı bulunamadı');
        return null;
      }
    } catch (e) {
      print('❌ Aktif diyet planı getirme hatası: $e');
      return null;
    }
  }
}
