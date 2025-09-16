import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalWaterService {
  static const String _waterDataKey = 'water_tracking_data';

  // Su içme kaydı ekle
  static Future<bool> addWaterIntake(String userId, int amount) async {
    try {
      print('💧 Local su takibi ekleniyor: $amount ml');

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Mevcut verileri al
      final existingData = prefs.getString(_waterDataKey);
      Map<String, dynamic> waterData = {};

      if (existingData != null) {
        waterData = json.decode(existingData);
      }

      // Bugünün verilerini al veya oluştur
      if (waterData.containsKey(dateKey)) {
        final dayData = waterData[dateKey];
        dayData['totalAmount'] = (dayData['totalAmount'] ?? 0) + amount;
        dayData['intakes'].add({
          'amount': amount,
          'timestamp': now.toIso8601String(),
        });
      } else {
        waterData[dateKey] = {
          'date': today.toIso8601String(),
          'totalAmount': amount,
          'targetAmount': 2000,
          'intakes': [
            {'amount': amount, 'timestamp': now.toIso8601String()},
          ],
        };
      }

      // Verileri kaydet
      await prefs.setString(_waterDataKey, json.encode(waterData));

      print('✅ Local su takibi başarıyla eklendi: $amount ml');
      return true;
    } catch (e) {
      print('❌ Local su takibi ekleme hatası: $e');
      return false;
    }
  }

  // Günlük su miktarını getir
  static Future<Map<String, dynamic>?> getDailyWaterIntake(
    String userId,
    DateTime date,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final existingData = prefs.getString(_waterDataKey);
      if (existingData != null) {
        final waterData = json.decode(existingData);
        return waterData[dateKey];
      }
      return null;
    } catch (e) {
      print('❌ Local su takibi getirme hatası: $e');
      return null;
    }
  }

  // Haftalık su takibi getir
  static Future<List<Map<String, dynamic>>> getWeeklyWaterIntake(
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
      print('❌ Haftalık local su takibi getirme hatası: $e');
      return [];
    }
  }
}
