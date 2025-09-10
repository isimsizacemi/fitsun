import '../models/exercise_detail.dart';

class ExerciseDatabaseService {
  // Örnek egzersiz verileri - gerçek uygulamada Firebase'den gelecek
  static final Map<String, ExerciseDetail> _exerciseDatabase = {
    'Bench Press': ExerciseDetail(
      id: 'bench_press',
      name: 'Bench Press',
      description: 'Göğüs kaslarını güçlendiren temel egzersiz',
      instructions: '''
1. Bench'e sırt üstü uzanın
2. Ayaklarınızı yerde sağlam şekilde konumlandırın
3. Bara omuz genişliğinde tutun
4. Barı göğsünüze indirin (kontrollü hareket)
5. Göğsünüzden yukarı itin
6. Başlangıç pozisyonuna dönün

Önemli: Sırtınızı bench'e yapıştırın ve core kaslarınızı sıkın.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=rT7DgCr-3pg', // Bench Press Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz'],
      equipment: ['Barbell', 'Bench'],
      difficulty: 'intermediate',
      tips: [
        'Barı kontrollü indirin, hızlı hareket etmeyin',
        'Nefes alırken indirin, verirken kaldırın',
        'Omuzlarınızı geriye çekin',
        'Ayaklarınızı yerde sağlam tutun',
      ],
      commonMistakes: [
        'Barı çok hızlı indirmek',
        'Sırtı bench\'ten kaldırmak',
        'Ayakları havada tutmak',
        'Çok ağır ağırlık kullanmak',
      ],
      category: 'Göğüs',
    ),

    'Squats': ExerciseDetail(
      id: 'squats',
      name: 'Squats',
      description: 'Bacak kaslarını güçlendiren temel egzersiz',
      instructions: '''
1. Ayaklarınızı omuz genişliğinde açın
2. Ayak parmaklarınızı hafif dışa çevirin
3. Göğsünüzü dik tutun
4. Kalçalarınızı geriye iterek çömelin
5. Dizlerinizi 90 dereceye kadar bükün
6. Topuklarınızdan güç alarak kalkın

Önemli: Dizleriniz ayak parmaklarınızı geçmesin.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=YaXPRqUwItQ', // Squats Video
      imageUrl:
          'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=500',
      muscleGroups: ['Quadriceps', 'Glutes', 'Hamstring', 'Core'],
      equipment: ['Bodyweight', 'Barbell (opsiyonel)'],
      difficulty: 'beginner',
      tips: [
        'Göğsünüzü dik tutun',
        'Ağırlık topuklarınızda olsun',
        'Dizlerinizi ayak parmaklarınızla hizalayın',
        'Derin nefes alın',
      ],
      commonMistakes: [
        'Dizleri içe doğru bükmek',
        'Çok hızlı hareket etmek',
        'Göğsü öne eğmek',
        'Yeterince derin çömelmemek',
      ],
      category: 'Bacak',
    ),

    'Pull-ups': ExerciseDetail(
      id: 'pull_ups',
      name: 'Pull-ups',
      description: 'Sırt kaslarını güçlendiren üst vücut egzersizi',
      instructions: '''
1. Pull-up barına asılın
2. Ellerinizi omuz genişliğinde tutun
3. Avuç içleriniz dışa bakacak şekilde tutun
4. Vücudunuzu yukarı çekin
5. Çenenizi barın üzerine getirin
6. Kontrollü şekilde aşağı inin

Önemli: Tam hareket aralığında çalışın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=eGo4IYlbE5g', // Pull-ups Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Latissimus Dorsi', 'Rhomboids', 'Biceps', 'Rear Delts'],
      equipment: ['Pull-up Bar'],
      difficulty: 'intermediate',
      tips: [
        'Core kaslarınızı sıkın',
        'Omuzlarınızı geriye çekin',
        'Tam hareket aralığında çalışın',
        'Nefes alırken yukarı, verirken aşağı',
      ],
      commonMistakes: [
        'Yarım hareket yapmak',
        'Sallanmak',
        'Çok hızlı hareket etmek',
        'Omuzları kulaklara çekmek',
      ],
      category: 'Sırt',
    ),

    'Deadlifts': ExerciseDetail(
      id: 'deadlifts',
      name: 'Deadlifts',
      description: 'Tüm vücut gücünü geliştiren temel egzersiz',
      instructions: '''
1. Ayaklarınızı kalça genişliğinde açın
2. Barı ayaklarınızın ortasında konumlandırın
3. Dizlerinizi bükerek barı tutun
4. Sırtınızı düz tutun
5. Barı kaldırırken kalçalarınızı öne itin
6. Dizlerinizi düzeltin ve göğsünüzü yukarı kaldırın
7. Kontrollü şekilde indirin

Önemli: Sırtınızı her zaman düz tutun.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=op9kVnSso6Q', // Deadlifts Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Hamstring', 'Glutes', 'Erector Spinae', 'Trapezius'],
      equipment: ['Barbell', 'Weight Plates'],
      difficulty: 'advanced',
      tips: [
        'Sırtınızı her zaman düz tutun',
        'Barı vücudunuza yakın tutun',
        'Kalçalarınızı öne itin',
        'Core kaslarınızı sıkın',
      ],
      commonMistakes: [
        'Sırtı yuvarlamak',
        'Barı vücuttan uzak tutmak',
        'Çok ağır ağırlık kullanmak',
        'Dizleri çok erken düzeltmek',
      ],
      category: 'Bacak',
    ),

    // Göğüs Egzersizleri
    'Push-ups': ExerciseDetail(
      id: 'push_ups',
      name: 'Push-ups',
      description: 'Vücut ağırlığı ile göğüs kaslarını güçlendiren egzersiz',
      instructions: '''
1. Yüz üstü yatın, eller omuz genişliğinde
2. Ayak parmaklarınızla destek alın
3. Vücudunuzu düz bir çizgide tutun
4. Göğsünüzü yere yaklaştırın
5. Başlangıç pozisyonuna dönün

Önemli: Core kaslarınızı sıkın ve vücudunuzu düz tutun.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4', // Push-ups Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Göğüs', 'Triceps', 'Omuz', 'Core'],
      equipment: ['Bodyweight'],
      difficulty: 'beginner',
      tips: [
        'Vücudunuzu düz tutun',
        'Nefes alırken aşağı, verirken yukarı',
        'Ellerinizi omuz genişliğinde tutun',
        'Core kaslarınızı sıkın',
      ],
      commonMistakes: [
        'Kalçaları çok yukarı kaldırmak',
        'Çok hızlı hareket etmek',
        'Yarım hareket yapmak',
        'Nefes tutmak',
      ],
      category: 'Göğüs',
    ),

    'Dumbbell Flyes': ExerciseDetail(
      id: 'dumbbell_flyes',
      name: 'Dumbbell Flyes',
      description: 'Göğüs kaslarını izole eden egzersiz',
      instructions: '''
1. Bench'e sırt üstü uzanın
2. Her elinde bir dambıl tutun
3. Kollarınızı hafif bükük tutun
4. Dambılları yanlara açın
5. Göğsünüzü sıkarak kaldırın

Önemli: Kollarınızı çok düz tutmayın, hafif bükük olsun.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=eozdVDA78K0', // Dumbbell Flyes Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Göğüs', 'Ön Omuz'],
      equipment: ['Dumbbells', 'Bench'],
      difficulty: 'intermediate',
      tips: [
        'Kontrollü hareket edin',
        'Çok ağır ağırlık kullanmayın',
        'Göğsünüzü sıkın',
        'Nefes alırken açın, verirken kapatın',
      ],
      commonMistakes: [
        'Çok ağır ağırlık kullanmak',
        'Kolları çok düz tutmak',
        'Hızlı hareket etmek',
        'Omuzları öne çekmek',
      ],
      category: 'Göğüs',
    ),

    // Sırt Egzersizleri
    'Bent-over Rows': ExerciseDetail(
      id: 'bent_over_rows',
      name: 'Bent-over Rows',
      description: 'Sırt kaslarını güçlendiren temel egzersiz',
      instructions: '''
1. Ayaklarınızı omuz genişliğinde açın
2. Hafifçe öne eğilin
3. Barı tutun ve göğsünüze çekin
4. Omuz bıçaklarınızı sıkın
5. Kontrollü şekilde indirin

Önemli: Sırtınızı düz tutun ve core kaslarınızı sıkın.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=9efgcAjQe7E', // Bent-over Rows Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Latissimus Dorsi', 'Rhomboids', 'Biceps', 'Rear Delts'],
      equipment: ['Barbell'],
      difficulty: 'intermediate',
      tips: [
        'Sırtınızı düz tutun',
        'Omuz bıçaklarını sıkın',
        'Barı göğsünüze çekin',
        'Core kaslarınızı sıkın',
      ],
      commonMistakes: [
        'Sırtı yuvarlamak',
        'Çok ağır ağırlık kullanmak',
        'Barı çok yukarı çekmek',
        'Dizleri bükmek',
      ],
      category: 'Sırt',
    ),

    'Lat Pulldowns': ExerciseDetail(
      id: 'lat_pulldowns',
      name: 'Lat Pulldowns',
      description: 'Lat kaslarını hedefleyen makine egzersizi',
      instructions: '''
1. Lat pulldown makinesine oturun
2. Barı geniş tutuşla tutun
3. Barı göğsünüze çekin
4. Omuz bıçaklarınızı aşağı çekin
5. Kontrollü şekilde yukarı bırakın

Önemli: Barı boynunuzun arkasına değil, göğsünüze çekin.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=CAwf7n6Luuc', // Lat Pulldowns Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Latissimus Dorsi', 'Rhomboids', 'Biceps'],
      equipment: ['Cable Machine', 'Lat Pulldown Bar'],
      difficulty: 'beginner',
      tips: [
        'Barı göğsünüze çekin',
        'Omuz bıçaklarını sıkın',
        'Kontrollü hareket edin',
        'Nefes alırken çekin, verirken bırakın',
      ],
      commonMistakes: [
        'Barı boynun arkasına çekmek',
        'Sallanmak',
        'Çok hızlı hareket etmek',
        'Çok ağır ağırlık kullanmak',
      ],
      category: 'Sırt',
    ),

    // Bacak Egzersizleri
    'Lunges': ExerciseDetail(
      id: 'lunges',
      name: 'Lunges',
      description: 'Bacak kaslarını güçlendiren fonksiyonel egzersiz',
      instructions: '''
1. Ayakta durun, ayaklarınız kalça genişliğinde
2. Bir ayağınızı öne atın
3. Arka dizinizi yere yaklaştırın
4. Ön dizinizi 90 dereceye bükün
5. Başlangıç pozisyonuna dönün

Önemli: Ön diziniz ayak parmağınızı geçmesin.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=3XDriUn0udo', // Lunges Video
      imageUrl:
          'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=500',
      muscleGroups: ['Quadriceps', 'Glutes', 'Hamstring', 'Calves'],
      equipment: ['Bodyweight', 'Dumbbells (opsiyonel)'],
      difficulty: 'beginner',
      tips: [
        'Göğsünüzü dik tutun',
        'Ön dizinizi ayak parmağınızla hizalayın',
        'Kontrollü hareket edin',
        'Her iki bacağı eşit çalıştırın',
      ],
      commonMistakes: [
        'Ön dizinizi çok ileriye atmak',
        'Göğsü öne eğmek',
        'Dengesiz hareket etmek',
        'Çok hızlı hareket etmek',
      ],
      category: 'Bacak',
    ),

    'Leg Press': ExerciseDetail(
      id: 'leg_press',
      name: 'Leg Press',
      description:
          'Bacak kaslarını güvenli şekilde güçlendiren makine egzersizi',
      instructions: '''
1. Leg press makinesine oturun
2. Ayaklarınızı omuz genişliğinde yerleştirin
3. Ayak parmaklarınızı hafif dışa çevirin
4. Ağırlığı kontrollü şekilde indirin
5. Topuklarınızdan güç alarak itin

Önemli: Dizlerinizi çok bükmeyin, 90 derece yeterli.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=IZxyjW7MPJQ', // Leg Press Video
      imageUrl:
          'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=500',
      muscleGroups: ['Quadriceps', 'Glutes', 'Hamstring'],
      equipment: ['Leg Press Machine'],
      difficulty: 'beginner',
      tips: [
        'Ayaklarınızı omuz genişliğinde tutun',
        'Dizlerinizi ayak parmaklarınızla hizalayın',
        'Kontrollü hareket edin',
        'Nefes alırken indirin, verirken itin',
      ],
      commonMistakes: [
        'Dizleri çok bükmek',
        'Ayakları çok dar tutmak',
        'Çok ağır ağırlık kullanmak',
        'Hızlı hareket etmek',
      ],
      category: 'Bacak',
    ),

    // Omuz Egzersizleri
    'Shoulder Press': ExerciseDetail(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      description: 'Omuz kaslarını güçlendiren temel egzersiz',
      instructions: '''
1. Dambılları omuz hizasında tutun
2. Dirseklerinizi 90 derece bükün
3. Dambılları yukarı itin
4. Başınızın üzerine kaldırın
5. Kontrollü şekilde indirin

Önemli: Dambılları başınızın önünde tutun, arkaya değil.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=QAEGgDpSqec', // Shoulder Press Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Anterior Delts', 'Medial Delts', 'Triceps'],
      equipment: ['Dumbbells', 'Bench (opsiyonel)'],
      difficulty: 'intermediate',
      tips: [
        'Dambılları kontrollü hareket ettirin',
        'Core kaslarınızı sıkın',
        'Nefes alırken indirin, verirken itin',
        'Dambılları başınızın önünde tutun',
      ],
      commonMistakes: [
        'Dambılları çok arkaya götürmek',
        'Çok ağır ağırlık kullanmak',
        'Sallanmak',
        'Hızlı hareket etmek',
      ],
      category: 'Omuz',
    ),

    'Lateral Raises': ExerciseDetail(
      id: 'lateral_raises',
      name: 'Lateral Raises',
      description: 'Yan omuz kaslarını izole eden egzersiz',
      instructions: '''
1. Her elinde hafif dambıl tutun
2. Kollarınızı yanlarda tutun
3. Dambılları yanlara kaldırın
4. Omuz hizasına kadar yükseltin
5. Kontrollü şekilde indirin

Önemli: Kollarınızı hafif bükük tutun ve sallanmayın.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=3VcKXnn1XmU', // Lateral Raises Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Medial Delts', 'Anterior Delts'],
      equipment: ['Dumbbells'],
      difficulty: 'beginner',
      tips: [
        'Hafif ağırlık kullanın',
        'Kontrollü hareket edin',
        'Sallanmayın',
        'Omuz hizasına kadar kaldırın',
      ],
      commonMistakes: [
        'Çok ağır ağırlık kullanmak',
        'Sallanmak',
        'Çok yükseğe kaldırmak',
        'Hızlı hareket etmek',
      ],
      category: 'Omuz',
    ),

    // Kol Egzersizleri
    'Bicep Curls': ExerciseDetail(
      id: 'bicep_curls',
      name: 'Bicep Curls',
      description: 'Biceps kaslarını güçlendiren temel egzersiz',
      instructions: '''
1. Her elinde dambıl tutun
2. Kollarınızı yanlarda tutun
3. Dambılları yukarı kaldırın
4. Biceps kaslarınızı sıkın
5. Kontrollü şekilde indirin

Önemli: Dirseklerinizi sabit tutun ve sallanmayın.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=ykJmrZ5v0Oo', // Bicep Curls Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Biceps', 'Forearms'],
      equipment: ['Dumbbells'],
      difficulty: 'beginner',
      tips: [
        'Dirseklerinizi sabit tutun',
        'Kontrollü hareket edin',
        'Biceps kaslarınızı sıkın',
        'Sallanmayın',
      ],
      commonMistakes: [
        'Sallanmak',
        'Çok ağır ağırlık kullanmak',
        'Hızlı hareket etmek',
        'Dirsekleri hareket ettirmek',
      ],
      category: 'Kol',
    ),

    'Tricep Dips': ExerciseDetail(
      id: 'tricep_dips',
      name: 'Tricep Dips',
      description: 'Triceps kaslarını güçlendiren vücut ağırlığı egzersizi',
      instructions: '''
1. Dip barına veya bench kenarına oturun
2. Ellerinizi omuz genişliğinde yerleştirin
3. Vücudunuzu aşağı indirin
4. Triceps kaslarınızı kullanarak yukarı itin
5. Başlangıç pozisyonuna dönün

Önemli: Dirseklerinizi vücudunuza yakın tutun.
      ''',
      videoUrl:
          'https://www.youtube.com/watch?v=6kALZikXxLc', // Tricep Dips Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Triceps', 'Anterior Delts', 'Chest'],
      equipment: ['Dip Bar', 'Bench'],
      difficulty: 'intermediate',
      tips: [
        'Dirseklerinizi vücudunuza yakın tutun',
        'Kontrollü hareket edin',
        'Core kaslarınızı sıkın',
        'Nefes alırken indirin, verirken itin',
      ],
      commonMistakes: [
        'Dirsekleri çok açmak',
        'Çok derin inmek',
        'Sallanmak',
        'Hızlı hareket etmek',
      ],
      category: 'Kol',
    ),

    // Core Egzersizleri
    'Plank': ExerciseDetail(
      id: 'plank',
      name: 'Plank',
      description: 'Core kaslarını güçlendiren statik egzersiz',
      instructions: '''
1. Yüz üstü yatın
2. Dirseklerinizi omuz hizasında yerleştirin
3. Ayak parmaklarınızla destek alın
4. Vücudunuzu düz bir çizgide tutun
5. Bu pozisyonu koruyun

Önemli: Kalçalarınızı çok yukarı veya aşağı kaldırmayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw', // Plank Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Core', 'Shoulders', 'Glutes'],
      equipment: ['Bodyweight'],
      difficulty: 'beginner',
      tips: [
        'Vücudunuzu düz tutun',
        'Nefes almayı unutmayın',
        'Core kaslarınızı sıkın',
        'Kalçalarınızı sabit tutun',
      ],
      commonMistakes: [
        'Kalçaları çok yukarı kaldırmak',
        'Nefes tutmak',
        'Çok uzun süre tutmaya çalışmak',
        'Sırtı yuvarlamak',
      ],
      category: 'Core',
    ),

    'Crunches': ExerciseDetail(
      id: 'crunches',
      name: 'Crunches',
      description: 'Karın kaslarını hedefleyen temel egzersiz',
      instructions: '''
1. Sırt üstü yatın, dizlerinizi bükün
2. Ellerinizi başınızın arkasında tutun
3. Omuz bıçaklarınızı yerden kaldırın
4. Karın kaslarınızı sıkın
5. Başlangıç pozisyonuna dönün

Önemli: Boynunuzu çekmeyin, sadece omuz bıçaklarını kaldırın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=Xyd_fa5zoEU', // Crunches Video
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Rectus Abdominis', 'Obliques'],
      equipment: ['Bodyweight'],
      difficulty: 'beginner',
      tips: [
        'Boynunuzu çekmeyin',
        'Karın kaslarınızı sıkın',
        'Kontrollü hareket edin',
        'Nefes alırken inin, verirken kalkın',
      ],
      commonMistakes: [
        'Boynu çekmek',
        'Çok hızlı hareket etmek',
        'Çok yükseğe kalkmaya çalışmak',
        'Nefes tutmak',
      ],
      category: 'Core',
    ),
  };

  // Egzersiz adına göre detay getir
  static ExerciseDetail? getExerciseDetail(String exerciseName) {
    return _exerciseDatabase[exerciseName];
  }

  // Tüm egzersizleri getir
  static List<ExerciseDetail> getAllExercises() {
    return _exerciseDatabase.values.toList();
  }

  // Kategoriye göre egzersizleri getir
  static List<ExerciseDetail> getExercisesByCategory(String category) {
    return _exerciseDatabase.values
        .where((exercise) => exercise.category == category)
        .toList();
  }

  // Zorluk seviyesine göre egzersizleri getir
  static List<ExerciseDetail> getExercisesByDifficulty(String difficulty) {
    return _exerciseDatabase.values
        .where((exercise) => exercise.difficulty == difficulty)
        .toList();
  }

  // Egzersiz ara
  static List<ExerciseDetail> searchExercises(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _exerciseDatabase.values
        .where(
          (exercise) =>
              exercise.name.toLowerCase().contains(lowercaseQuery) ||
              exercise.description.toLowerCase().contains(lowercaseQuery) ||
              exercise.muscleGroups.any(
                (muscle) => muscle.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  // Egzersiz video URL'ini güncelle
  static void updateExerciseVideo(String exerciseId, String videoUrl) {
    final exercise = _exerciseDatabase.values
        .where((e) => e.id == exerciseId)
        .firstOrNull;
    
    if (exercise != null) {
      // Yeni ExerciseDetail oluştur (immutable olduğu için)
      final updatedExercise = ExerciseDetail(
        id: exercise.id,
        name: exercise.name,
        description: exercise.description,
        instructions: exercise.instructions,
        videoUrl: videoUrl, // Video URL'ini güncelle
        imageUrl: exercise.imageUrl,
        muscleGroups: exercise.muscleGroups,
        equipment: exercise.equipment,
        difficulty: exercise.difficulty,
        tips: exercise.tips,
        commonMistakes: exercise.commonMistakes,
        category: exercise.category,
      );
      
      _exerciseDatabase[exercise.name] = updatedExercise;
    }
  }

  // Egzersiz video URL'ini sil
  static void removeExerciseVideo(String exerciseId) {
    final exercise = _exerciseDatabase.values
        .where((e) => e.id == exerciseId)
        .firstOrNull;
    
    if (exercise != null) {
      // Video URL'ini boş string yap
      updateExerciseVideo(exerciseId, '');
    }
  }
}
