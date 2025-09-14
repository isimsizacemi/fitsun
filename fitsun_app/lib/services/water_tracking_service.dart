import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_intake.dart';

class WaterTrackingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansı
  static CollectionReference get _waterIntakesCollection =>
      _firestore.collection('water_intakes');

  // Su tüketimi ekle
  static Future<String> addWaterIntake({
    required String userId,
    required int amount, // ml cinsinden
    String? notes,
  }) async {
    try {
      print('💧 Su tüketimi ekleniyor...');
      print('👤 User ID: $userId');
      print('💧 Miktar: ${amount}ml');

      final now = DateTime.now();
      final waterId = 'water_${userId}_${now.millisecondsSinceEpoch}';

      // Günlük toplamı hesapla
      final dailyTotal = await _calculateDailyTotal(userId, now);

      final waterIntake = WaterIntake(
        id: waterId,
        userId: userId,
        date: now,
        time: now,
        amount: amount,
        notes: notes,
        dailyTotal: dailyTotal + amount,
        createdAt: now,
      );

      await _waterIntakesCollection.doc(waterId).set(waterIntake.toFirestore());

      // Günlük toplamı güncelle
      await _updateDailyTotals(userId, now);

      print('✅ Su tüketimi eklendi: $waterId');
      print('📊 Günlük toplam: ${dailyTotal + amount}ml');
      return waterId;
    } catch (e) {
      print('❌ Su tüketimi ekleme hatası: $e');
      rethrow;
    }
  }

  // Su tüketimini güncelle
  static Future<void> updateWaterIntake({
    required String waterId,
    int? amount,
    String? notes,
  }) async {
    try {
      print('💧 Su tüketimi güncelleniyor...');
      print('📝 Water ID: $waterId');

      final docRef = _waterIntakesCollection.doc(waterId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Su tüketimi kaydı bulunamadı');
      }

      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'];
      final date = (data['date'] as Timestamp).toDate();

      Map<String, dynamic> updateData = {};

      if (amount != null) {
        updateData['amount'] = amount;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await docRef.update(updateData);

      // Günlük toplamı güncelle
      await _updateDailyTotals(userId, date);

      print('✅ Su tüketimi güncellendi');
    } catch (e) {
      print('❌ Su tüketimi güncelleme hatası: $e');
      rethrow;
    }
  }

  // Su tüketimini sil
  static Future<void> deleteWaterIntake(String waterId) async {
    try {
      print('🗑️ Su tüketimi siliniyor...');
      print('📝 Water ID: $waterId');

      final docRef = _waterIntakesCollection.doc(waterId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Su tüketimi kaydı bulunamadı');
      }

      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'];
      final date = (data['date'] as Timestamp).toDate();

      await docRef.delete();

      // Günlük toplamı güncelle
      await _updateDailyTotals(userId, date);

      print('✅ Su tüketimi silindi');
    } catch (e) {
      print('❌ Su tüketimi silme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının su tüketimlerini getir
  static Future<List<WaterIntake>> getUserWaterIntakes({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('💧 Kullanıcı su tüketimleri getiriliyor...');
      print('👤 User ID: $userId');

      Query query = _waterIntakesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('time', descending: true);

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
      final intakes = querySnapshot.docs
          .map((doc) => WaterIntake.fromFirestore(doc))
          .toList();

      print('✅ ${intakes.length} su tüketimi getirildi');
      return intakes;
    } catch (e) {
      print('❌ Su tüketimleri getirme hatası: $e');
      rethrow;
    }
  }

  // Belirli bir günün su tüketimlerini getir
  static Future<List<WaterIntake>> getDailyWaterIntakes({
    required String userId,
    required DateTime date,
  }) async {
    try {
      print('📅 Günlük su tüketimleri getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _waterIntakesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('time', descending: true)
          .get();

      final intakes = querySnapshot.docs
          .map((doc) => WaterIntake.fromFirestore(doc))
          .toList();

      print('✅ ${intakes.length} günlük su tüketimi getirildi');
      return intakes;
    } catch (e) {
      print('❌ Günlük su tüketimleri getirme hatası: $e');
      rethrow;
    }
  }

  // Günlük su özeti getir
  static Future<DailyWaterSummary?> getDailyWaterSummary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      print('📊 Günlük su özeti getiriliyor...');
      print('👤 User ID: $userId');
      print('📅 Tarih: ${date.day}/${date.month}/${date.year}');

      final intakes = await getDailyWaterIntakes(userId: userId, date: date);

      if (intakes.isEmpty) {
        print('⚠️ Günlük su tüketimi bulunamadı');
        return null;
      }

      final totalAmount = intakes.fold(0, (sum, intake) => sum + intake.amount);
      final intakeCount = intakes.length;
      final percentage = (totalAmount / 2500.0) * 100; // 2.5L hedef

      final summary = DailyWaterSummary(
        date: date,
        totalAmount: totalAmount,
        intakeCount: intakeCount,
        percentage: percentage,
        intakes: intakes,
      );

      print('✅ Günlük su özeti oluşturuldu');
      print('💧 Toplam: ${totalAmount}ml (${summary.totalInLiters}L)');
      print('📊 Yüzde: ${percentage.toStringAsFixed(1)}%');

      return summary;
    } catch (e) {
      print('❌ Günlük su özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının su tüketim istatistiklerini getir
  static Future<Map<String, dynamic>> getUserWaterStats(String userId) async {
    try {
      print('📊 Kullanıcı su tüketim istatistikleri getiriliyor...');
      print('👤 User ID: $userId');

      final intakes = await getUserWaterIntakes(userId: userId);

      if (intakes.isEmpty) {
        return {
          'totalWaterIntake': 0,
          'averageDailyWater': 0.0,
          'totalDays': 0,
          'lastWaterIntakeDate': null,
          'averageIntakesPerDay': 0.0,
        };
      }

      // İstatistikleri hesapla
      final totalWaterIntake = intakes.fold(
        0,
        (sum, intake) => sum + intake.amount,
      );

      // Günlere göre grupla
      Map<String, List<WaterIntake>> dailyIntakes = {};
      for (final intake in intakes) {
        final dateKey =
            '${intake.date.year}-${intake.date.month}-${intake.date.day}';
        dailyIntakes[dateKey] ??= [];
        dailyIntakes[dateKey]!.add(intake);
      }

      final totalDays = dailyIntakes.length;
      final averageDailyWater = totalDays > 0
          ? totalWaterIntake / totalDays
          : 0.0;
      final averageIntakesPerDay = totalDays > 0
          ? intakes.length / totalDays
          : 0.0;

      // Son su tüketimi tarihi
      final lastWaterIntakeDate = intakes.isNotEmpty
          ? intakes.first.date
          : null;

      final stats = {
        'totalWaterIntake': totalWaterIntake,
        'averageDailyWater': averageDailyWater,
        'totalDays': totalDays,
        'lastWaterIntakeDate': lastWaterIntakeDate,
        'averageIntakesPerDay': averageIntakesPerDay,
      };

      print('✅ Su tüketim istatistikleri hesaplandı');
      print(
        '💧 Toplam su: ${totalWaterIntake}ml (${totalWaterIntake / 1000.0}L)',
      );
      print('📊 Ortalama günlük: ${averageDailyWater.toStringAsFixed(1)}ml');
      print('📅 Toplam gün: $totalDays');

      return stats;
    } catch (e) {
      print('❌ Su tüketim istatistikleri hesaplama hatası: $e');
      rethrow;
    }
  }

  // Haftalık su tüketim özeti getir
  static Future<List<DailyWaterSummary>> getWeeklyWaterSummary({
    required String userId,
    required DateTime startDate,
  }) async {
    try {
      print('📅 Haftalık su tüketim özeti getiriliyor...');
      print('👤 User ID: $userId');
      print(
        '📅 Başlangıç tarihi: ${startDate.day}/${startDate.month}/${startDate.year}',
      );

      final summaries = <DailyWaterSummary>[];

      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final summary = await getDailyWaterSummary(userId: userId, date: date);

        if (summary != null) {
          summaries.add(summary);
        } else {
          // Boş gün için özet oluştur
          summaries.add(
            DailyWaterSummary(
              date: date,
              totalAmount: 0,
              intakeCount: 0,
              percentage: 0.0,
              intakes: [],
            ),
          );
        }
      }

      print('✅ Haftalık su tüketim özeti oluşturuldu');
      return summaries;
    } catch (e) {
      print('❌ Haftalık su tüketim özeti getirme hatası: $e');
      rethrow;
    }
  }

  // Günlük toplamı hesapla
  static Future<int> _calculateDailyTotal(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _waterIntakesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      int total = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = data['amount'] as int;
        total += amount;
      }

      return total;
    } catch (e) {
      print('❌ Günlük toplam hesaplama hatası: $e');
      return 0;
    }
  }

  // Günlük toplamları güncelle
  static Future<void> _updateDailyTotals(String userId, DateTime date) async {
    try {
      final dailyTotal = await _calculateDailyTotal(userId, date);

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _waterIntakesCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'dailyTotal': dailyTotal});
      }

      await batch.commit();

      print('✅ Günlük toplamlar güncellendi: ${dailyTotal}ml');
    } catch (e) {
      print('❌ Günlük toplam güncelleme hatası: $e');
    }
  }

  // Su tüketim hedeflerini kontrol et
  static Map<String, dynamic> checkWaterGoals({
    required int currentAmount,
    required int targetAmount,
  }) {
    final percentage = (currentAmount / targetAmount) * 100;

    String status;
    String emoji;
    String message;

    if (percentage >= 100) {
      status = 'completed';
      emoji = '🎉';
      message = 'Hedef tamamlandı!';
    } else if (percentage >= 80) {
      status = 'almost';
      emoji = '💪';
      message = 'Neredeyse tamamlandı!';
    } else if (percentage >= 60) {
      status = 'good';
      emoji = '👍';
      message = 'İyi gidiyor!';
    } else if (percentage >= 40) {
      status = 'low';
      emoji = '💧';
      message = 'Devam et!';
    } else {
      status = 'very_low';
      emoji = '🥤';
      message = 'Daha fazla su içmelisin!';
    }

    return {
      'status': status,
      'emoji': emoji,
      'message': message,
      'percentage': percentage,
      'remaining': targetAmount - currentAmount,
    };
  }
}
