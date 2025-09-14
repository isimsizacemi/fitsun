import 'package:cloud_firestore/cloud_firestore.dart';

class DietPlan {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int duration; // hafta
  final int targetCalories;
  final double targetProtein; // gram
  final double targetCarbs; // gram
  final double targetFat; // gram
  final bool isActive;
  final String? programId; // hangi spor programına bağlı
  final List<Meal> meals;
  final DateTime createdAt;
  final DateTime updatedAt;

  DietPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.duration,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    this.isActive = true,
    this.programId,
    this.meals = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore'dan veri okuma
  factory DietPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return DietPlan(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      targetCalories: data['targetCalories'] ?? 0,
      targetProtein: (data['targetProtein'] ?? 0.0).toDouble(),
      targetCarbs: (data['targetCarbs'] ?? 0.0).toDouble(),
      targetFat: (data['targetFat'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      programId: data['programId'],
      meals: (data['meals'] as List<dynamic>?)
          ?.map((e) => Meal.fromMap(e))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore'a veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'duration': duration,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
      'isActive': isActive,
      'programId': programId,
      'meals': meals.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Kopyalama
  DietPlan copyWith({
    String? id,
    String? userId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DietPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      isActive: isActive ?? this.isActive,
      programId: programId ?? this.programId,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Belirli bir günün yemekleri
  List<Meal> getMealsForDay(String dayName) {
    return meals.where((meal) => meal.dayName == dayName).toList();
  }

  // Günlük kalori hedefi
  int get dailyCalorieTarget => targetCalories;

  // Günlük protein hedefi
  double get dailyProteinTarget => targetProtein;

  // Günlük karbonhidrat hedefi
  double get dailyCarbsTarget => targetCarbs;

  // Günlük yağ hedefi
  double get dailyFatTarget => targetFat;
}

class Meal {
  final String dayName;
  final String mealType; // "Kahvaltı", "Öğle", "Akşam", "Ara Öğün"
  final String foodName;
  final int calories;
  final double protein; // gram
  final double carbs; // gram
  final double fat; // gram
  final String amount; // "1 porsiyon", "200g" vs.
  final String time; // "08:00"
  final String? notes;

  Meal({
    required this.dayName,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.amount,
    required this.time,
    this.notes,
  });

  factory Meal.fromMap(Map<String, dynamic> data) {
    return Meal(
      dayName: data['dayName'] ?? '',
      mealType: data['mealType'] ?? '',
      foodName: data['foodName'] ?? '',
      calories: data['calories'] ?? 0,
      protein: (data['protein'] ?? 0.0).toDouble(),
      carbs: (data['carbs'] ?? 0.0).toDouble(),
      fat: (data['fat'] ?? 0.0).toDouble(),
      amount: data['amount'] ?? '',
      time: data['time'] ?? '',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'amount': amount,
      'time': time,
      'notes': notes,
    };
  }

  Meal copyWith({
    String? dayName,
    String? mealType,
    String? foodName,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? amount,
    String? time,
    String? notes,
  }) {
    return Meal(
      dayName: dayName ?? this.dayName,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      amount: amount ?? this.amount,
      time: time ?? this.time,
      notes: notes ?? this.notes,
    );
  }

  // Öğün türü emoji
  String get mealTypeEmoji {
    switch (mealType.toLowerCase()) {
      case 'kahvaltı':
        return '🌅';
      case 'öğle':
        return '☀️';
      case 'akşam':
        return '🌙';
      case 'ara öğün':
        return '🍎';
      default:
        return '🍽️';
    }
  }

  // Besin değerleri özeti
  String get nutritionSummary {
    return '${calories}kcal | P:${protein}g | K:${carbs}g | Y:${fat}g';
  }
}

class DietIntake {
  final String id;
  final String userId;
  final String dietPlanId;
  final String mealId;
  final DateTime date;
  final DateTime time;
  final bool isCompleted;
  final String? actualAmount;
  final String? notes;
  final DateTime createdAt;

  DietIntake({
    required this.id,
    required this.userId,
    required this.dietPlanId,
    required this.mealId,
    required this.date,
    required this.time,
    this.isCompleted = false,
    this.actualAmount,
    this.notes,
    required this.createdAt,
  });

  factory DietIntake.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return DietIntake(
      id: doc.id,
      userId: data['userId'] ?? '',
      dietPlanId: data['dietPlanId'] ?? '',
      mealId: data['mealId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: (data['time'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      actualAmount: data['actualAmount'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'dietPlanId': dietPlanId,
      'mealId': mealId,
      'date': Timestamp.fromDate(date),
      'time': Timestamp.fromDate(time),
      'isCompleted': isCompleted,
      'actualAmount': actualAmount,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DietIntake copyWith({
    String? id,
    String? userId,
    String? dietPlanId,
    String? mealId,
    DateTime? date,
    DateTime? time,
    bool? isCompleted,
    String? actualAmount,
    String? notes,
    DateTime? createdAt,
  }) {
    return DietIntake(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dietPlanId: dietPlanId ?? this.dietPlanId,
      mealId: mealId ?? this.mealId,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      actualAmount: actualAmount ?? this.actualAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
