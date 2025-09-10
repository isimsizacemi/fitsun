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

    // HIIT Egzersizleri
    'Burpees': ExerciseDetail(
      id: 'burpees',
      name: 'Burpees',
      description: 'Tüm vücut HIIT egzersizi - kardiyovasküler fitness ve güç geliştirir',
      instructions: '''
1. Ayakta başlayın, ayaklarınız omuz genişliğinde
2. Çömelin ve ellerinizi yere koyun
3. Ayaklarınızı geriye atarak plank pozisyonuna geçin
4. Bir push-up yapın (opsiyonel)
5. Ayaklarınızı ellerinizin yanına getirin
6. Patlayıcı bir hareketle yukarı zıplayın
7. Ellerinizi başınızın üzerine kaldırın

Önemli: Tempo tutarlı olsun ve nefes almayı unutmayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=TU8QYVW0gDU',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Tüm Vücut', 'Core', 'Bacak', 'Göğüs', 'Omuz'],
      equipment: ['Bodyweight'],
      difficulty: 'intermediate',
      tips: [
        'Tempo tutarlı olsun',
        'Nefes almayı unutmayın',
        'Core kaslarınızı sıkın',
        'Ayaklarınızı ellerinizin yanına getirin',
      ],
      commonMistakes: [
        'Çok hızlı hareket etmek',
        'Nefes tutmak',
        'Core kaslarını gevşetmek',
        'Tempo kaybetmek',
      ],
      category: 'HIIT',
    ),

    'Mountain Climbers': ExerciseDetail(
      id: 'mountain_climbers',
      name: 'Mountain Climbers',
      description: 'Yüksek yoğunluklu kardiyovasküler egzersiz - core ve bacak kaslarını güçlendirir',
      instructions: '''
1. Plank pozisyonunda başlayın
2. Ellerinizi omuz genişliğinde yere koyun
3. Core kaslarınızı sıkın
4. Sağ dizinizi göğsünüze doğru çekin
5. Hızlıca ayağınızı geriye atın
6. Sol dizinizi göğsünüze doğru çekin
7. Alternatif olarak devam edin

Önemli: Kalçalarınızı yukarı kaldırmayın, plank pozisyonunu koruyun.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=nmwgirgXLYM',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Core', 'Bacak', 'Omuz', 'Triceps'],
      equipment: ['Bodyweight'],
      difficulty: 'intermediate',
      tips: [
        'Plank pozisyonunu koruyun',
        'Core kaslarınızı sıkın',
        'Hızlı ve kontrollü hareket edin',
        'Nefes almayı unutmayın',
      ],
      commonMistakes: [
        'Kalçaları yukarı kaldırmak',
        'Çok yavaş hareket etmek',
        'Core kaslarını gevşetmek',
        'Dengesiz hareket etmek',
      ],
      category: 'HIIT',
    ),

    'Jumping Jacks': ExerciseDetail(
      id: 'jumping_jacks',
      name: 'Jumping Jacks',
      description: 'Klasik kardiyovasküler egzersiz - kalp atış hızını artırır ve koordinasyon geliştirir',
      instructions: '''
1. Ayakta başlayın, kollarınız yanlarda
2. Ayaklarınızı omuz genişliğinde açın
3. Kollarınızı yukarı kaldırın
4. Ayaklarınızı birleştirin
5. Kollarınızı aşağı indirin
6. Ritmik olarak tekrarlayın

Önemli: Dizlerinizi hafif bükük tutun ve yumuşak iniş yapın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=1b98WrRrmUs',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Bacak', 'Omuz', 'Core'],
      equipment: ['Bodyweight'],
      difficulty: 'beginner',
      tips: [
        'Dizlerinizi hafif bükük tutun',
        'Yumuşak iniş yapın',
        'Ritmik hareket edin',
        'Nefes almayı unutmayın',
      ],
      commonMistakes: [
        'Dizleri çok sert bükmek',
        'Çok hızlı hareket etmek',
        'Nefes tutmak',
        'Dengesiz hareket etmek',
      ],
      category: 'HIIT',
    ),

    // Yoga Egzersizleri
    'Downward Dog': ExerciseDetail(
      id: 'downward_dog',
      name: 'Downward Dog',
      description: 'Klasik yoga pozisyonu - omuzları, hamstringleri ve baldırları esnetir',
      instructions: '''
1. Dört ayak üzerinde başlayın
2. Ellerinizi omuz genişliğinde yere koyun
3. Dizlerinizi yerden kaldırın
4. Kalçalarınızı yukarı kaldırın
5. Vücudunuzu ters V şeklinde tutun
6. Dizlerinizi hafif bükük tutun
7. 5-10 nefes tutun

Önemli: Omuzlarınızı kulaklarınızdan uzak tutun ve nefes almayı unutmayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=BIQd9aLmXzE',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Hamstring', 'Baldır', 'Omuz', 'Core', 'Sırt'],
      equipment: ['Yoga Mat'],
      difficulty: 'beginner',
      tips: [
        'Omuzları kulaklardan uzak tutun',
        'Dizleri hafif bükük tutun',
        'Nefes almayı unutmayın',
        'Vücudu ters V şeklinde tutun',
      ],
      commonMistakes: [
        'Omuzları kulaklara çekmek',
        'Dizleri çok düz tutmak',
        'Nefes tutmak',
        'Çok zorlamak',
      ],
      category: 'Yoga',
    ),

    'Warrior I': ExerciseDetail(
      id: 'warrior_i',
      name: 'Warrior I',
      description: 'Güçlü yoga pozisyonu - bacakları güçlendirir ve göğsü açar',
      instructions: '''
1. Ayakta başlayın
2. Sağ ayağınızı öne atın
3. Sol ayağınızı 45 derece dışa çevirin
4. Sağ dizinizi 90 derece bükün
5. Kollarınızı yukarı kaldırın
6. Göğsünüzü açın
7. 5-10 nefes tutun
8. Diğer taraf için tekrarlayın

Önemli: Ön diziniz ayak bileğinizin üzerinde olsun.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=3P7XgZbQh8Y',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Quadriceps', 'Glutes', 'Omuz', 'Göğüs', 'Core'],
      equipment: ['Yoga Mat'],
      difficulty: 'beginner',
      tips: [
        'Ön dizinizi ayak bileğinizin üzerinde tutun',
        'Göğsünüzü açın',
        'Nefes almayı unutmayın',
        'Dengenizi koruyun',
      ],
      commonMistakes: [
        'Ön dizinizi çok ileriye atmak',
        'Göğsü kapatmak',
        'Nefes tutmak',
        'Dengesiz durmak',
      ],
      category: 'Yoga',
    ),

    'Child\'s Pose': ExerciseDetail(
      id: 'childs_pose',
      name: 'Child\'s Pose',
      description: 'Dinlendirici yoga pozisyonu - sırtı esnetir ve stresi azaltır',
      instructions: '''
1. Dizlerinizin üzerinde oturun
2. Ayak parmaklarınızı birleştirin
3. Dizlerinizi kalça genişliğinde açın
4. Öne doğru eğilin
5. Kollarınızı öne uzatın
6. Alnınızı yere koyun
7. 5-10 nefes tutun

Önemli: Nefes alırken sırtınızı genişletin, verirken rahatlayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=2m5nWg0a_aw',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Sırt', 'Omuz', 'Kalça', 'Baldır'],
      equipment: ['Yoga Mat'],
      difficulty: 'beginner',
      tips: [
        'Nefes alırken sırtınızı genişletin',
        'Rahatlayın',
        'Kollarınızı öne uzatın',
        'Alnınızı yere koyun',
      ],
      commonMistakes: [
        'Çok zorlamak',
        'Nefes tutmak',
        'Kolları çok sıkı tutmak',
        'Dizleri çok dar açmak',
      ],
      category: 'Yoga',
    ),

    // Pilates Egzersizleri
    'Hundred': ExerciseDetail(
      id: 'hundred',
      name: 'Hundred',
      description: 'Klasik Pilates egzersizi - core kaslarını güçlendirir ve nefes kontrolü sağlar',
      instructions: '''
1. Sırt üstü yatın
2. Dizlerinizi göğsünüze çekin
3. Kollarınızı yanlarda tutun
4. Başınızı ve omuzlarınızı kaldırın
5. Kollarınızı yukarı-aşağı hareket ettirin
6. 5 nefes alın, 5 nefes verin
7. 10 kez tekrarlayın (100 hareket)

Önemli: Core kaslarınızı sıkın ve nefes ritmini koruyun.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=g3dJhQy2h0g',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Core', 'Göğüs', 'Omuz'],
      equipment: ['Pilates Mat'],
      difficulty: 'intermediate',
      tips: [
        'Core kaslarınızı sıkın',
        'Nefes ritmini koruyun',
        'Kolları kontrollü hareket ettirin',
        'Boynu zorlamayın',
      ],
      commonMistakes: [
        'Boynu çok zorlamak',
        'Nefes ritmini kaybetmek',
        'Core kaslarını gevşetmek',
        'Çok hızlı hareket etmek',
      ],
      category: 'Pilates',
    ),

    'Roll Up': ExerciseDetail(
      id: 'roll_up',
      name: 'Roll Up',
      description: 'Pilates temel egzersizi - omurga esnekliğini ve core gücünü geliştirir',
      instructions: '''
1. Sırt üstü yatın, kollarınız başınızın üzerinde
2. Nefes alın ve kollarınızı yukarı kaldırın
3. Nefes verin ve başınızı kaldırın
4. Omuz bıçaklarınızı yerden kaldırın
5. Yavaşça oturma pozisyonuna gelin
6. Omurganızı tek tek yuvarlayın
7. Ters sırayla geri yatın

Önemli: Her omur kemiğini tek tek hareket ettirin.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=8XqHhGqJhJY',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Core', 'Sırt', 'Omuz'],
      equipment: ['Pilates Mat'],
      difficulty: 'intermediate',
      tips: [
        'Her omur kemiğini tek tek hareket ettirin',
        'Kontrollü hareket edin',
        'Nefes almayı unutmayın',
        'Core kaslarınızı sıkın',
      ],
      commonMistakes: [
        'Çok hızlı hareket etmek',
        'Omurganızı blok olarak hareket ettirmek',
        'Nefes tutmak',
        'Core kaslarını gevşetmek',
      ],
      category: 'Pilates',
    ),

    // Kardiyovasküler Egzersizler
    'Jump Rope': ExerciseDetail(
      id: 'jump_rope',
      name: 'Jump Rope',
      description: 'Yüksek yoğunluklu kardiyovasküler egzersiz - koordinasyon ve dayanıklılık geliştirir',
      instructions: '''
1. Ayakta başlayın, ipi arkada tutun
2. Dirseklerinizi vücudunuza yakın tutun
3. Bileklerinizle ipi çevirin
4. Ayak parmaklarınızla zıplayın
5. Dizlerinizi hafif bükük tutun
6. Yumuşak iniş yapın
7. Ritmik olarak devam edin

Önemli: Bileklerinizi kullanın, kollarınızı değil.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=1BZM2vReWS4',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Bacak', 'Baldır', 'Core', 'Omuz'],
      equipment: ['Jump Rope'],
      difficulty: 'intermediate',
      tips: [
        'Bileklerinizi kullanın',
        'Dizlerinizi hafif bükük tutun',
        'Yumuşak iniş yapın',
        'Ritmik hareket edin',
      ],
      commonMistakes: [
        'Kolları çok hareket ettirmek',
        'Çok yüksek zıplamak',
        'Dizleri çok sert bükmek',
        'Ritmi kaybetmek',
      ],
      category: 'Kardiyovasküler',
    ),

    'High Knees': ExerciseDetail(
      id: 'high_knees',
      name: 'High Knees',
      description: 'Yerinde koşu egzersizi - kalp atış hızını artırır ve bacak kaslarını güçlendirir',
      instructions: '''
1. Ayakta başlayın
2. Yerinde koşmaya başlayın
3. Dizlerinizi göğsünüze doğru çekin
4. Kollarınızı doğal olarak sallayın
5. Ayak parmaklarınızla zıplayın
6. Hızlı ve ritmik hareket edin
7. 30-60 saniye devam edin

Önemli: Dizlerinizi mümkün olduğunca yükseğe çekin.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=oDdkytliOqE',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Bacak', 'Baldır', 'Core', 'Kalça'],
      equipment: ['Bodyweight'],
      difficulty: 'beginner',
      tips: [
        'Dizlerinizi yükseğe çekin',
        'Kollarınızı doğal sallayın',
        'Ritmik hareket edin',
        'Nefes almayı unutmayın',
      ],
      commonMistakes: [
        'Dizleri çok düşük çekmek',
        'Çok yavaş hareket etmek',
        'Nefes tutmak',
        'Dengesiz hareket etmek',
      ],
      category: 'Kardiyovasküler',
    ),

    // Esneklik Egzersizleri
    'Hip Flexor Stretch': ExerciseDetail(
      id: 'hip_flexor_stretch',
      name: 'Hip Flexor Stretch',
      description: 'Kalça fleksör kaslarını esnetir - oturma pozisyonundan kaynaklanan gerginliği azaltır',
      instructions: '''
1. Diz üstünde başlayın
2. Sağ ayağınızı öne atın
3. Sol dizinizi yere koyun
4. Sağ dizinizi 90 derece bükün
5. Kalçalarınızı öne itin
6. Sol kalça fleksörünüzü esnetin
7. 30-60 saniye tutun
8. Diğer taraf için tekrarlayın

Önemli: Kalçalarınızı öne itin ve nefes almayı unutmayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=7Z741dD0_3I',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Hip Flexors', 'Quadriceps', 'Kalça'],
      equipment: ['Yoga Mat'],
      difficulty: 'beginner',
      tips: [
        'Kalçalarınızı öne itin',
        'Nefes almayı unutmayın',
        'Yavaşça esnetin',
        'Ağrı hissetmeyin',
      ],
      commonMistakes: [
        'Çok zorlamak',
        'Nefes tutmak',
        'Dizleri çok ileriye atmak',
        'Ağrı hissetmek',
      ],
      category: 'Esneklik',
    ),

    'Hamstring Stretch': ExerciseDetail(
      id: 'hamstring_stretch',
      name: 'Hamstring Stretch',
      description: 'Hamstring kaslarını esnetir - bacak arkası gerginliğini azaltır',
      instructions: '''
1. Oturun, bacaklarınızı öne uzatın
2. Sağ bacağınızı bükün, ayağınızı sol uyluğun içine koyun
3. Sol bacağınızı düz tutun
4. Öne doğru eğilin
5. Sol ayağınızı tutmaya çalışın
6. 30-60 saniye tutun
7. Diğer taraf için tekrarlayın

Önemli: Dizlerinizi bükük tutabilirsiniz, zorlamayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=7Z741dD0_3I',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Hamstring', 'Baldır', 'Sırt'],
      equipment: ['Yoga Mat'],
      difficulty: 'beginner',
      tips: [
        'Dizlerinizi bükük tutabilirsiniz',
        'Yavaşça esnetin',
        'Nefes almayı unutmayın',
        'Ağrı hissetmeyin',
      ],
      commonMistakes: [
        'Çok zorlamak',
        'Dizleri çok düz tutmaya çalışmak',
        'Nefes tutmak',
        'Ağrı hissetmek',
      ],
      category: 'Esneklik',
    ),

    // Fonksiyonel Egzersizler
    'Turkish Get-up': ExerciseDetail(
      id: 'turkish_get_up',
      name: 'Turkish Get-up',
      description: 'Kompleks fonksiyonel egzersiz - koordinasyon, güç ve stabilite geliştirir',
      instructions: '''
1. Sırt üstü yatın, sağ elinizde dambıl tutun
2. Dambılı yukarı kaldırın
3. Sol dizinizi bükün, ayağınızı yere koyun
4. Sağ dirseğinizle destek alın
5. Sol elinizi yere koyun
6. Kalçalarınızı kaldırın
7. Sol dizinizin üzerine oturun
8. Ayağa kalkın
9. Ters sırayla geri yatın

Önemli: Dambılı her zaman yukarıda tutun ve kontrollü hareket edin.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=0bWRPC49-KI',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Tüm Vücut', 'Core', 'Omuz', 'Bacak'],
      equipment: ['Dumbbell', 'Kettlebell'],
      difficulty: 'advanced',
      tips: [
        'Dambılı her zaman yukarıda tutun',
        'Kontrollü hareket edin',
        'Core kaslarınızı sıkın',
        'Nefes almayı unutmayın',
      ],
      commonMistakes: [
        'Dambılı aşağı indirmek',
        'Çok hızlı hareket etmek',
        'Core kaslarını gevşetmek',
        'Dengesiz hareket etmek',
      ],
      category: 'Fonksiyonel',
    ),

    'Farmer\'s Walk': ExerciseDetail(
      id: 'farmers_walk',
      name: 'Farmer\'s Walk',
      description: 'Fonksiyonel güç egzersizi - grip gücü, core stabilitesi ve dayanıklılık geliştirir',
      instructions: '''
1. Her elinde ağırlık tutun (dambıl, kettlebell, sandık)
2. Ayakta başlayın, omuzlarınızı geriye çekin
3. Core kaslarınızı sıkın
4. Yürümeye başlayın
5. Kısa, kontrollü adımlar atın
6. 20-50 metre yürüyün
7. Ağırlıkları yere bırakın

Önemli: Core kaslarınızı sıkın ve omuzlarınızı geriye çekin.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=Fkzk_RqlYig',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Core', 'Omuz', 'Grip', 'Bacak', 'Sırt'],
      equipment: ['Dumbbells', 'Kettlebells', 'Sandık'],
      difficulty: 'intermediate',
      tips: [
        'Core kaslarınızı sıkın',
        'Omuzlarınızı geriye çekin',
        'Kısa adımlar atın',
        'Nefes almayı unutmayın',
      ],
      commonMistakes: [
        'Core kaslarını gevşetmek',
        'Omuzları öne çekmek',
        'Çok uzun adımlar atmak',
        'Nefes tutmak',
      ],
      category: 'Fonksiyonel',
    ),

    // Güç Egzersizleri
    'Overhead Press': ExerciseDetail(
      id: 'overhead_press',
      name: 'Overhead Press',
      description: 'Omuz gücü ve stabilite geliştiren temel egzersiz',
      instructions: '''
1. Ayakta başlayın, dambılları omuz hizasında tutun
2. Dirseklerinizi 90 derece bükün
3. Core kaslarınızı sıkın
4. Dambılları yukarı itin
5. Başınızın üzerine kaldırın
6. Kollarınızı düz tutun
7. Kontrollü şekilde indirin

Önemli: Core kaslarınızı sıkın ve dambılları başınızın önünde tutun.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=QAEGgDpSqec',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Omuz', 'Triceps', 'Core', 'Bacak'],
      equipment: ['Dumbbells', 'Barbell'],
      difficulty: 'intermediate',
      tips: [
        'Core kaslarınızı sıkın',
        'Dambılları başınızın önünde tutun',
        'Kontrollü hareket edin',
        'Nefes alırken indirin, verirken itin',
      ],
      commonMistakes: [
        'Dambılları çok arkaya götürmek',
        'Core kaslarını gevşetmek',
        'Sallanmak',
        'Çok ağır ağırlık kullanmak',
      ],
      category: 'Güç',
    ),

    'Front Squat': ExerciseDetail(
      id: 'front_squat',
      name: 'Front Squat',
      description: 'Bacak gücü ve core stabilitesi geliştiren varyasyon',
      instructions: '''
1. Barbell\'i ön omuzlarınızda tutun
2. Ayaklarınızı omuz genişliğinde açın
3. Ayak parmaklarınızı hafif dışa çevirin
4. Core kaslarınızı sıkın
5. Kalçalarınızı geriye iterek çömelin
6. Dizlerinizi 90 dereceye kadar bükün
7. Topuklarınızdan güç alarak kalkın

Önemli: Barbell\'i ön omuzlarınızda tutun ve core kaslarınızı sıkın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=uYumuL_G_V0',
      imageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=500',
      muscleGroups: ['Quadriceps', 'Glutes', 'Core', 'Omuz', 'Sırt'],
      equipment: ['Barbell'],
      difficulty: 'advanced',
      tips: [
        'Barbell\'i ön omuzlarınızda tutun',
        'Core kaslarınızı sıkın',
        'Dizlerinizi ayak parmaklarınızla hizalayın',
        'Kontrollü hareket edin',
      ],
      commonMistakes: [
        'Barbell\'i çok aşağıda tutmak',
        'Core kaslarını gevşetmek',
        'Dizleri içe doğru bükmek',
        'Çok ağır ağırlık kullanmak',
      ],
      category: 'Güç',
    ),

    // Dayanıklılık Egzersizleri
    'Wall Sit': ExerciseDetail(
      id: 'wall_sit',
      name: 'Wall Sit',
      description: 'İzometrik dayanıklılık egzersizi - bacak kaslarını güçlendirir',
      instructions: '''
1. Duvara sırtınızı yaslayın
2. Ayaklarınızı duvardan 30-60 cm uzakta tutun
3. Sırtınızı duvara yaslayın
4. Dizlerinizi 90 derece bükün
5. Bu pozisyonu koruyun
6. 30-60 saniye tutun
7. Yavaşça ayağa kalkın

Önemli: Dizlerinizi 90 derece bükün ve sırtınızı duvara yaslayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=Yp3Zw1I3c0s',
      imageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=500',
      muscleGroups: ['Quadriceps', 'Glutes', 'Core'],
      equipment: ['Duvar'],
      difficulty: 'beginner',
      tips: [
        'Dizlerinizi 90 derece bükün',
        'Sırtınızı duvara yaslayın',
        'Nefes almayı unutmayın',
        'Core kaslarınızı sıkın',
      ],
      commonMistakes: [
        'Dizleri çok yüksekte tutmak',
        'Sırtı duvardan ayırmak',
        'Nefes tutmak',
        'Çok uzun süre tutmaya çalışmak',
      ],
      category: 'Dayanıklılık',
    ),

    'Plank Hold': ExerciseDetail(
      id: 'plank_hold',
      name: 'Plank Hold',
      description: 'İzometrik core egzersizi - karın kaslarını ve omuzları güçlendirir',
      instructions: '''
1. Yüz üstü yatın
2. Dirseklerinizi omuz hizasında yerleştirin
3. Ayak parmaklarınızla destek alın
4. Vücudunuzu düz bir çizgide tutun
5. Core kaslarınızı sıkın
6. Bu pozisyonu koruyun
7. 30-60 saniye tutun

Önemli: Kalçalarınızı çok yukarı veya aşağı kaldırmayın.
      ''',
      videoUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
      muscleGroups: ['Core', 'Omuz', 'Glutes', 'Sırt'],
      equipment: ['Yoga Mat'],
      difficulty: 'beginner',
      tips: [
        'Vücudunuzu düz tutun',
        'Core kaslarınızı sıkın',
        'Nefes almayı unutmayın',
        'Kalçalarınızı sabit tutun',
      ],
      commonMistakes: [
        'Kalçaları çok yukarı kaldırmak',
        'Nefes tutmak',
        'Core kaslarını gevşetmek',
        'Çok uzun süre tutmaya çalışmak',
      ],
      category: 'Dayanıklılık',
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
