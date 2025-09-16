import 'package:cloud_firestore/cloud_firestore.dart';

class UserSummary {
  final String id;
  final String userId;
  final int totalWorkouts;
  final int totalWorkoutTime; // dakika
  final double averageWorkoutDuration;
  final String? favoriteExercise;
  final int totalWaterIntake; // ml
  final double averageDailyWater; // ml
  final int totalCaloriesBurned;
  final DateTime? lastWorkoutDate;
  final DateTime? lastWaterIntakeDate;
  final int currentStreak; // gün
  final int longestStreak; // gün
  final String summaryText; // AI tarafından oluşturulan özet
  final DateTime lastUpdated;
  final DateTime createdAt;

  UserSummary({
    required this.id,
    required this.userId,
    this.totalWorkouts = 0,
    this.totalWorkoutTime = 0,
    this.averageWorkoutDuration = 0.0,
    this.favoriteExercise,
    this.totalWaterIntake = 0,
    this.averageDailyWater = 0.0,
    this.totalCaloriesBurned = 0,
    this.lastWorkoutDate,
    this.lastWaterIntakeDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.summaryText = '',
    required this.lastUpdated,
    required this.createdAt,
  });

  // Firestore'dan veri okuma
  factory UserSummary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserSummary(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalWorkouts: data['totalWorkouts'] ?? 0,
      totalWorkoutTime: data['totalWorkoutTime'] ?? 0,
      averageWorkoutDuration: (data['averageWorkoutDuration'] ?? 0.0)
          .toDouble(),
      favoriteExercise: data['favoriteExercise'],
      totalWaterIntake: data['totalWaterIntake'] ?? 0,
      averageDailyWater: (data['averageDailyWater'] ?? 0.0).toDouble(),
      totalCaloriesBurned: data['totalCaloriesBurned'] ?? 0,
      lastWorkoutDate: data['lastWorkoutDate'] != null
          ? (data['lastWorkoutDate'] as Timestamp).toDate()
          : null,
      lastWaterIntakeDate: data['lastWaterIntakeDate'] != null
          ? (data['lastWaterIntakeDate'] as Timestamp).toDate()
          : null,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      summaryText: data['summaryText'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalWorkouts': totalWorkouts,
      'totalWorkoutTime': totalWorkoutTime,
      'averageWorkoutDuration': averageWorkoutDuration,
      'favoriteExercise': favoriteExercise,
      'totalWaterIntake': totalWaterIntake,
      'averageDailyWater': averageDailyWater,
      'totalCaloriesBurned': totalCaloriesBurned,
      'lastWorkoutDate': lastWorkoutDate != null
          ? Timestamp.fromDate(lastWorkoutDate!)
          : null,
      'lastWaterIntakeDate': lastWaterIntakeDate != null
          ? Timestamp.fromDate(lastWaterIntakeDate!)
          : null,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'summaryText': summaryText,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Kopyalama
  UserSummary copyWith({
    String? id,
    String? userId,
    int? totalWorkouts,
    int? totalWorkoutTime,
    double? averageWorkoutDuration,
    String? favoriteExercise,
    int? totalWaterIntake,
    double? averageDailyWater,
    int? totalCaloriesBurned,
    DateTime? lastWorkoutDate,
    DateTime? lastWaterIntakeDate,
    int? currentStreak,
    int? longestStreak,
    String? summaryText,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return UserSummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalWorkoutTime: totalWorkoutTime ?? this.totalWorkoutTime,
      averageWorkoutDuration:
          averageWorkoutDuration ?? this.averageWorkoutDuration,
      favoriteExercise: favoriteExercise ?? this.favoriteExercise,
      totalWaterIntake: totalWaterIntake ?? this.totalWaterIntake,
      averageDailyWater: averageDailyWater ?? this.averageDailyWater,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      lastWaterIntakeDate: lastWaterIntakeDate ?? this.lastWaterIntakeDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      summaryText: summaryText ?? this.summaryText,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Toplam antrenman süresini saat cinsinden al
  double get totalWorkoutHours => totalWorkoutTime / 60.0;

  // Ortalama antrenman süresini saat cinsinden al
  double get averageWorkoutHours => averageWorkoutDuration / 60.0;

  // Toplam su tüketimini litre cinsinden al
  double get totalWaterLiters => totalWaterIntake / 1000.0;

  // Ortalama günlük su tüketimini litre cinsinden al
  double get averageDailyWaterLiters => averageDailyWater / 1000.0;

  // Son antrenman tarihi formatı
  String? get lastWorkoutDateFormatted {
    if (lastWorkoutDate == null) return null;
    return '${lastWorkoutDate!.day}/${lastWorkoutDate!.month}/${lastWorkoutDate!.year}';
  }

  // Son su içme tarihi formatı
  String? get lastWaterIntakeDateFormatted {
    if (lastWaterIntakeDate == null) return null;
    return '${lastWaterIntakeDate!.day}/${lastWaterIntakeDate!.month}/${lastWaterIntakeDate!.year}';
  }

  // Streak durumu
  String get streakStatus {
    if (currentStreak == 0) return 'Henüz başlamadın';
    if (currentStreak < 3) return 'Yeni başladın! 💪';
    if (currentStreak < 7) return 'İyi gidiyor! 🔥';
    if (currentStreak < 14) return 'Harika! ⭐';
    if (currentStreak < 30) return 'Mükemmel! 🏆';
    return 'Efsanevi! 👑';
  }

  // Streak emoji
  String get streakEmoji {
    if (currentStreak == 0) return '😴';
    if (currentStreak < 3) return '💪';
    if (currentStreak < 7) return '🔥';
    if (currentStreak < 14) return '⭐';
    if (currentStreak < 30) return '🏆';
    return '👑';
  }

  // Fitness seviyesi (antrenman sayısına göre)
  String get fitnessLevel {
    if (totalWorkouts == 0) return 'Başlangıç';
    if (totalWorkouts < 10) return 'Yeni Başlayan';
    if (totalWorkouts < 30) return 'Gelişen';
    if (totalWorkouts < 50) return 'Orta Seviye';
    if (totalWorkouts < 100) return 'İleri Seviye';
    return 'Uzman';
  }

  // Su tüketim durumu
  String get waterStatus {
    if (averageDailyWater < 1500) return 'Daha fazla su içmelisin';
    if (averageDailyWater < 2000) return 'Su tüketimin düşük';
    if (averageDailyWater < 2500) return 'İyi gidiyor';
    if (averageDailyWater < 3000) return 'Mükemmel';
    return 'Çok iyi!';
  }

  // AI için özet metni oluştur
  String generateSummaryForAI() {
    String summary = 'Kullanıcı Özeti:\n';
    summary += '- Toplam antrenman sayısı: $totalWorkouts\n';
    summary +=
        '- Toplam antrenman süresi: ${totalWorkoutHours.toStringAsFixed(1)} saat\n';
    summary +=
        '- Ortalama antrenman süresi: ${averageWorkoutHours.toStringAsFixed(1)} saat\n';
    summary +=
        '- En sevdiği egzersiz: ${favoriteExercise ?? "Belirtilmemiş"}\n';
    summary +=
        '- Toplam su tüketimi: ${totalWaterLiters.toStringAsFixed(1)}L\n';
    summary +=
        '- Ortalama günlük su: ${averageDailyWaterLiters.toStringAsFixed(1)}L\n';
    summary += '- Mevcut spor serisi: $currentStreak gün\n';
    summary += '- En uzun spor serisi: $longestStreak gün\n';
    summary += '- Son antrenman: ${lastWorkoutDateFormatted ?? "Henüz yok"}\n';
    summary += '- Fitness seviyesi: $fitnessLevel\n';

    return summary;
  }

  // Boş özet oluştur (yeni kullanıcılar için)
  factory UserSummary.empty(String userId) {
    final now = DateTime.now();
    return UserSummary(
      id: 'summary_$userId',
      userId: userId,
      lastUpdated: now,
      createdAt: now,
    );
  }
}
