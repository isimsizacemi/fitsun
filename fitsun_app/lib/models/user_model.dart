class UserModel {
  final String id;
  final String email;
  final String? name;
  final int? age;
  final double? height; // cm
  final double? weight; // kg
  final String? gender; // 'male', 'female', 'other'
  final String?
  goal; // 'weight_loss', 'muscle_gain', 'endurance', 'general_fitness'
  final String? fitnessLevel; // 'beginner', 'intermediate', 'advanced'
  final String? workoutLocation; // 'home', 'gym', 'outdoor'
  final List<String>?
  availableEquipment; // ['dumbbells', 'barbell', 'resistance_bands', etc.]
  final double? bodyFat; // yağ oranı yüzdesi
  final double? muscleMass; // kas kütlesi (kg)
  final String? experience; // deneyim süresi
  final int? weeklyFrequency; // haftalık antrenman sıklığı
  final String? preferredTime; // tercih edilen antrenman süresi
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.goal,
    this.fitnessLevel,
    this.workoutLocation,
    this.availableEquipment,
    this.bodyFat,
    this.muscleMass,
    this.experience,
    this.weeklyFrequency,
    this.preferredTime,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'],
      age: map['age'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      gender: map['gender'],
      goal: map['goal'],
      fitnessLevel: map['fitnessLevel'],
      workoutLocation: map['workoutLocation'],
      availableEquipment: map['availableEquipment'] != null
          ? List<String>.from(map['availableEquipment'])
          : null,
      bodyFat: map['bodyFat']?.toDouble(),
      muscleMass: map['muscleMass']?.toDouble(),
      experience: map['experience'],
      weeklyFrequency: map['weeklyFrequency'],
      preferredTime: map['preferredTime'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'goal': goal,
      'fitnessLevel': fitnessLevel,
      'workoutLocation': workoutLocation,
      'availableEquipment': availableEquipment,
      'bodyFat': bodyFat,
      'muscleMass': muscleMass,
      'experience': experience,
      'weeklyFrequency': weeklyFrequency,
      'preferredTime': preferredTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? goal,
    String? fitnessLevel,
    String? workoutLocation,
    List<String>? availableEquipment,
    double? bodyFat,
    double? muscleMass,
    String? experience,
    int? weeklyFrequency,
    String? preferredTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      workoutLocation: workoutLocation ?? this.workoutLocation,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      bodyFat: bodyFat ?? this.bodyFat,
      muscleMass: muscleMass ?? this.muscleMass,
      experience: experience ?? this.experience,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      preferredTime: preferredTime ?? this.preferredTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isProfileComplete {
    return age != null &&
        height != null &&
        weight != null &&
        gender != null &&
        goal != null &&
        fitnessLevel != null &&
        workoutLocation != null;
  }
}
