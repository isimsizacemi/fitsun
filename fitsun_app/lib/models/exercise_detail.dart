class ExerciseDetail {
  final String id;
  final String name;
  final String description;
  final String instructions;
  final String videoUrl;
  final String imageUrl;
  final List<String> muscleGroups;
  final List<String> equipment;
  final String difficulty;
  final List<String> tips;
  final List<String> commonMistakes;
  final String category;

  ExerciseDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.videoUrl,
    required this.imageUrl,
    required this.muscleGroups,
    required this.equipment,
    required this.difficulty,
    required this.tips,
    required this.commonMistakes,
    required this.category,
  });

  factory ExerciseDetail.fromMap(Map<String, dynamic> map) {
    return ExerciseDetail(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      instructions: map['instructions'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      muscleGroups: List<String>.from(map['muscleGroups'] ?? []),
      equipment: List<String>.from(map['equipment'] ?? []),
      difficulty: map['difficulty'] ?? 'beginner',
      tips: List<String>.from(map['tips'] ?? []),
      commonMistakes: List<String>.from(map['commonMistakes'] ?? []),
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'muscleGroups': muscleGroups,
      'equipment': equipment,
      'difficulty': difficulty,
      'tips': tips,
      'commonMistakes': commonMistakes,
      'category': category,
    };
  }
}
