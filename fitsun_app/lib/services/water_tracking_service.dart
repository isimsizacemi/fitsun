import 'package:cloud_firestore/cloud_firestore.dart';

class WaterTrackingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Su içme kaydı ekle
  static Future<bool> addWaterIntake(String userId, int amount) async {
    try {
      print('💧 Su takibi ekleniyor: $amount ml, User: $userId');
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final docId = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      print('📅 Doküman ID: $docId');

      // Önce mevcut dokümanı kontrol et
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('water_tracking')
          .doc(docId);

      final doc = await docRef.get();
      
      if (doc.exists) {
        // Mevcut günlük su miktarını güncelle
        final currentAmount = doc.data()?['totalAmount'] ?? 0;
        final newAmount = currentAmount + amount;
        
        print('📊 Mevcut miktar: $currentAmount ml, Yeni miktar: $newAmount ml');
        
        await docRef.update({
          'totalAmount': newAmount,
          'lastUpdated': FieldValue.serverTimestamp(),
          'intakes': FieldValue.arrayUnion([
            {'amount': amount, 'timestamp': DateTime.now()},
          ]),
        });
      } else {
        // Yeni günlük su takibi oluştur
        print('🆕 Yeni günlük su takibi oluşturuluyor');
        
        await docRef.set({
          'date': today,
          'totalAmount': amount,
          'targetAmount': 2000, // Varsayılan hedef 2L
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'intakes': [
            {'amount': amount, 'timestamp': DateTime.now()},
          ],
        });
      }

      print('✅ Su takibi başarıyla eklendi: $amount ml');
      return true;
    } catch (e) {
      print('❌ Su takibi ekleme hatası: $e');
      print('❌ Hata türü: ${e.runtimeType}');
      print('❌ Hata detayı: ${e.toString()}');
      
      // Firebase bağlantı hatası için özel mesaj
      if (e.toString().contains('cloud_firestore/unknown')) {
        print('🔧 Firestore bağlantı hatası tespit edildi');
        print('💡 Firebase bağlantısını kontrol edin');
      }
      
      return false;
    }
  }

  // Günlük su miktarını getir
  static Future<Map<String, dynamic>?> getDailyWaterIntake(
    String userId,
    DateTime date,
  ) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('water_tracking')
          .doc(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          );

      final doc = await docRef.get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Su takibi getirme hatası: $e');
      return null;
    }
  }

  // Haftalık su takibi getir
  static Future<List<Map<String, dynamic>>> getWeeklyWaterIntake(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final List<Map<String, dynamic>> weeklyData = [];

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dailyData = await getDailyWaterIntake(userId, date);

        weeklyData.add({
          'date': date,
          'totalAmount': dailyData?['totalAmount'] ?? 0,
          'targetAmount': dailyData?['targetAmount'] ?? 2000,
          'intakes': dailyData?['intakes'] ?? [],
        });
      }

      return weeklyData;
    } catch (e) {
      print('Haftalık su takibi getirme hatası: $e');
      return [];
    }
  }

  // Su hedefini güncelle
  static Future<bool> updateWaterTarget(String userId, int targetAmount) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('water_tracking')
          .doc(
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
          );

      await docRef.set({
        'targetAmount': targetAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Su hedefi güncelleme hatası: $e');
      return false;
    }
  }
}
