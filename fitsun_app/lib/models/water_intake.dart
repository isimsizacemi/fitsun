import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntake {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime time;
  final int amount; // ml cinsinden
  final String? notes;
  final int? dailyTotal; // o günün toplamı
  final DateTime createdAt;

  WaterIntake({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.amount,
    this.notes,
    this.dailyTotal,
    required this.createdAt,
  });

  // Firestore'dan veri okuma
  factory WaterIntake.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WaterIntake(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: (data['time'] as Timestamp).toDate(),
      amount: data['amount'] ?? 0,
      notes: data['notes'],
      dailyTotal: data['dailyTotal'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'time': Timestamp.fromDate(time),
      'amount': amount,
      'notes': notes,
      'dailyTotal': dailyTotal,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Kopyalama (update için)
  WaterIntake copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? time,
    int? amount,
    String? notes,
    int? dailyTotal,
    DateTime? createdAt,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      dailyTotal: dailyTotal ?? this.dailyTotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Su miktarını litre cinsinden al
  double get amountInLiters => amount / 1000.0;

  // Su miktarını bardak cinsinden al (1 bardak = 250ml)
  double get amountInGlasses => amount / 250.0;

  // Tarih formatı (sadece tarih)
  String get dateFormatted {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Saat formatı
  String get timeFormatted {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Günlük hedefe göre yüzde (varsayılan 2.5L = 2500ml)
  double get dailyPercentage {
    if (dailyTotal == null) return 0.0;
    return (dailyTotal! / 2500.0) * 100;
  }
}

// Günlük su özeti
class DailyWaterSummary {
  final DateTime date;
  final int totalAmount; // ml
  final int intakeCount; // kaç kez su içildi
  final double percentage; // günlük hedefe göre yüzde
  final List<WaterIntake> intakes;

  DailyWaterSummary({
    required this.date,
    required this.totalAmount,
    required this.intakeCount,
    required this.percentage,
    required this.intakes,
  });

  // Toplam miktarı litre cinsinden al
  double get totalInLiters => totalAmount / 1000.0;

  // Toplam miktarı bardak cinsinden al
  double get totalInGlasses => totalAmount / 250.0;

  // Tarih formatı
  String get dateFormatted {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Hedef durumu
  String get goalStatus {
    if (percentage >= 100) return 'Hedef tamamlandı! 🎉';
    if (percentage >= 80) return 'Neredeyse tamamlandı! 💪';
    if (percentage >= 60) return 'İyi gidiyor! 👍';
    if (percentage >= 40) return 'Devam et! 💧';
    return 'Daha fazla su içmelisin! 🥤';
  }

  // Renk kodu (UI için)
  String get statusColor {
    if (percentage >= 100) return 'green';
    if (percentage >= 80) return 'lightgreen';
    if (percentage >= 60) return 'yellow';
    if (percentage >= 40) return 'orange';
    return 'red';
  }
}
