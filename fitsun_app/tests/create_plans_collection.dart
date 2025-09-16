import 'dart:convert';
import 'dart:io';

void main() async {
  print('🏋️ Plans Collection Oluşturuluyor...\n');

  // Örnek plan verileri
  final plans = [
    {
      'id': 'plan_beginner_muscle',
      'name': 'Başlangıç Seviye Kas Geliştirme',
      'description':
          'Yeni başlayanlar için temel kas geliştirme programı. 4 haftalık program ile temel hareketleri öğrenin.',
      'difficulty': 'beginner',
      'durationWeeks': 4,
      'targetMuscles': ['Göğüs', 'Sırt', 'Bacak', 'Kol', 'Omuz'],
      'equipment': ['Dambıl', 'Barbell', 'Bench', 'Pull-up Bar'],
      'createdBy': 'system',
      'isPublic': true,
      'createdAt': DateTime.now().toIso8601String(),
      'tags': ['kas-geliştirme', 'başlangıç', '4-hafta', 'tam-vücut'],
      'weeklySchedule': [
        {
          'dayName': 'Pazartesi',
          'focus': 'Göğüs ve Triceps',
          'exercises': [
            {'name': 'Bench Press', 'sets': 3, 'reps': 8, 'restSeconds': 60},
            {
              'name': 'Incline Dumbbell Press',
              'sets': 3,
              'reps': 10,
              'restSeconds': 45,
            },
            {
              'name': 'Dumbbell Flyes',
              'sets': 3,
              'reps': 12,
              'restSeconds': 45,
            },
            {'name': 'Tricep Dips', 'sets': 3, 'reps': 8, 'restSeconds': 45},
          ],
          'estimatedDuration': 45,
        },
        {
          'dayName': 'Çarşamba',
          'focus': 'Sırt ve Biceps',
          'exercises': [
            {'name': 'Pull-ups', 'sets': 3, 'reps': 6, 'restSeconds': 60},
            {
              'name': 'Bent-over Rows',
              'sets': 3,
              'reps': 10,
              'restSeconds': 60,
            },
            {'name': 'Lat Pulldowns', 'sets': 3, 'reps': 12, 'restSeconds': 45},
            {'name': 'Bicep Curls', 'sets': 3, 'reps': 12, 'restSeconds': 45},
          ],
          'estimatedDuration': 45,
        },
        {
          'dayName': 'Cuma',
          'focus': 'Bacak ve Omuz',
          'exercises': [
            {'name': 'Squats', 'sets': 4, 'reps': 10, 'restSeconds': 90},
            {'name': 'Lunges', 'sets': 3, 'reps': 12, 'restSeconds': 60},
            {'name': 'Leg Press', 'sets': 3, 'reps': 15, 'restSeconds': 60},
            {
              'name': 'Shoulder Press',
              'sets': 3,
              'reps': 10,
              'restSeconds': 60,
            },
            {
              'name': 'Lateral Raises',
              'sets': 3,
              'reps': 12,
              'restSeconds': 45,
            },
          ],
          'estimatedDuration': 60,
        },
      ],
    },
    {
      'id': 'plan_intermediate_strength',
      'name': 'Orta Seviye Güç Geliştirme',
      'description':
          'Temel hareketleri bilenler için güç geliştirme odaklı program. 6 haftalık yoğun program.',
      'difficulty': 'intermediate',
      'durationWeeks': 6,
      'targetMuscles': ['Tüm Vücut', 'Core', 'Güç'],
      'equipment': ['Barbell', 'Dambıl', 'Bench', 'Squat Rack', 'Kettlebell'],
      'createdBy': 'system',
      'isPublic': true,
      'createdAt': DateTime.now().toIso8601String(),
      'tags': ['güç-geliştirme', 'orta-seviye', '6-hafta', 'compound'],
      'weeklySchedule': [
        {
          'dayName': 'Pazartesi',
          'focus': 'Güç - Göğüs ve Triceps',
          'exercises': [
            {
              'name': 'Barbell Bench Press',
              'sets': 5,
              'reps': 5,
              'restSeconds': 120,
            },
            {
              'name': 'Incline Barbell Press',
              'sets': 4,
              'reps': 6,
              'restSeconds': 90,
            },
            {'name': 'Weighted Dips', 'sets': 4, 'reps': 8, 'restSeconds': 90},
            {
              'name': 'Close-Grip Bench Press',
              'sets': 3,
              'reps': 8,
              'restSeconds': 60,
            },
          ],
          'estimatedDuration': 75,
        },
        {
          'dayName': 'Çarşamba',
          'focus': 'Güç - Sırt ve Biceps',
          'exercises': [
            {'name': 'Deadlifts', 'sets': 5, 'reps': 5, 'restSeconds': 180},
            {'name': 'Barbell Rows', 'sets': 4, 'reps': 6, 'restSeconds': 90},
            {
              'name': 'Weighted Pull-ups',
              'sets': 4,
              'reps': 6,
              'restSeconds': 90,
            },
            {'name': 'Barbell Curls', 'sets': 3, 'reps': 8, 'restSeconds': 60},
          ],
          'estimatedDuration': 75,
        },
        {
          'dayName': 'Cuma',
          'focus': 'Güç - Bacak ve Omuz',
          'exercises': [
            {'name': 'Back Squats', 'sets': 5, 'reps': 5, 'restSeconds': 180},
            {
              'name': 'Romanian Deadlifts',
              'sets': 4,
              'reps': 6,
              'restSeconds': 120,
            },
            {'name': 'Overhead Press', 'sets': 4, 'reps': 6, 'restSeconds': 90},
            {
              'name': 'Kettlebell Swings',
              'sets': 3,
              'reps': 15,
              'restSeconds': 60,
            },
          ],
          'estimatedDuration': 75,
        },
      ],
    },
    {
      'id': 'plan_advanced_hypertrophy',
      'name': 'İleri Seviye Hipertrofi',
      'description':
          'Deneyimli sporcular için kas büyütme odaklı program. 8 haftalık yoğun hipertrofi programı.',
      'difficulty': 'advanced',
      'durationWeeks': 8,
      'targetMuscles': ['Tüm Vücut', 'Hipertrofi', 'Detay'],
      'equipment': [
        'Barbell',
        'Dambıl',
        'Cable Machine',
        'Bench',
        'Squat Rack',
      ],
      'createdBy': 'system',
      'isPublic': true,
      'createdAt': DateTime.now().toIso8601String(),
      'tags': ['hipertrofi', 'ileri-seviye', '8-hafta', 'kas-büyütme'],
      'weeklySchedule': [
        {
          'dayName': 'Pazartesi',
          'focus': 'Göğüs ve Triceps',
          'exercises': [
            {
              'name': 'Barbell Bench Press',
              'sets': 4,
              'reps': 8,
              'restSeconds': 90,
            },
            {
              'name': 'Incline Dumbbell Press',
              'sets': 4,
              'reps': 10,
              'restSeconds': 75,
            },
            {
              'name': 'Dumbbell Flyes',
              'sets': 3,
              'reps': 12,
              'restSeconds': 60,
            },
            {
              'name': 'Cable Crossover',
              'sets': 3,
              'reps': 15,
              'restSeconds': 45,
            },
            {
              'name': 'Close-Grip Bench Press',
              'sets': 4,
              'reps': 10,
              'restSeconds': 75,
            },
            {
              'name': 'Overhead Tricep Extension',
              'sets': 3,
              'reps': 12,
              'restSeconds': 60,
            },
          ],
          'estimatedDuration': 90,
        },
        {
          'dayName': 'Salı',
          'focus': 'Sırt ve Biceps',
          'exercises': [
            {'name': 'Deadlifts', 'sets': 4, 'reps': 6, 'restSeconds': 120},
            {'name': 'Pull-ups', 'sets': 4, 'reps': 8, 'restSeconds': 90},
            {'name': 'Barbell Rows', 'sets': 4, 'reps': 10, 'restSeconds': 75},
            {'name': 'Lat Pulldowns', 'sets': 3, 'reps': 12, 'restSeconds': 60},
            {'name': 'Barbell Curls', 'sets': 4, 'reps': 10, 'restSeconds': 60},
            {'name': 'Hammer Curls', 'sets': 3, 'reps': 12, 'restSeconds': 45},
          ],
          'estimatedDuration': 90,
        },
        {
          'dayName': 'Çarşamba',
          'focus': 'Bacak',
          'exercises': [
            {'name': 'Back Squats', 'sets': 4, 'reps': 8, 'restSeconds': 120},
            {
              'name': 'Romanian Deadlifts',
              'sets': 4,
              'reps': 10,
              'restSeconds': 90,
            },
            {
              'name': 'Bulgarian Split Squats',
              'sets': 3,
              'reps': 12,
              'restSeconds': 60,
            },
            {'name': 'Leg Press', 'sets': 4, 'reps': 15, 'restSeconds': 60},
            {'name': 'Leg Curls', 'sets': 3, 'reps': 15, 'restSeconds': 45},
            {'name': 'Calf Raises', 'sets': 4, 'reps': 20, 'restSeconds': 30},
          ],
          'estimatedDuration': 90,
        },
        {
          'dayName': 'Perşembe',
          'focus': 'Omuz ve Core',
          'exercises': [
            {'name': 'Overhead Press', 'sets': 4, 'reps': 8, 'restSeconds': 90},
            {
              'name': 'Lateral Raises',
              'sets': 4,
              'reps': 12,
              'restSeconds': 60,
            },
            {
              'name': 'Rear Delt Flyes',
              'sets': 3,
              'reps': 15,
              'restSeconds': 45,
            },
            {'name': 'Plank', 'sets': 3, 'reps': 60, 'restSeconds': 60},
            {
              'name': 'Russian Twists',
              'sets': 3,
              'reps': 20,
              'restSeconds': 45,
            },
            {
              'name': 'Mountain Climbers',
              'sets': 3,
              'reps': 30,
              'restSeconds': 45,
            },
          ],
          'estimatedDuration': 75,
        },
        {
          'dayName': 'Cuma',
          'focus': 'Arms ve Core',
          'exercises': [
            {'name': 'Barbell Curls', 'sets': 4, 'reps': 10, 'restSeconds': 60},
            {'name': 'Hammer Curls', 'sets': 3, 'reps': 12, 'restSeconds': 45},
            {
              'name': 'Preacher Curls',
              'sets': 3,
              'reps': 12,
              'restSeconds': 45,
            },
            {
              'name': 'Close-Grip Bench Press',
              'sets': 4,
              'reps': 10,
              'restSeconds': 75,
            },
            {
              'name': 'Tricep Pushdowns',
              'sets': 3,
              'reps': 15,
              'restSeconds': 45,
            },
            {
              'name': 'Overhead Tricep Extension',
              'sets': 3,
              'reps': 12,
              'restSeconds': 45,
            },
          ],
          'estimatedDuration': 75,
        },
      ],
    },
  ];

  // JSON dosyasına kaydet
  final jsonData = {
    'plans': plans,
    'createdAt': DateTime.now().toIso8601String(),
    'description': 'FitSun Plans Collection - Örnek program şablonları',
  };

  final file = File('plans_collection.json');
  await file.writeAsString(jsonEncode(jsonData));

  print('✅ Plans Collection oluşturuldu!');
  print('📁 Dosya: plans_collection.json');
  print('📊 Toplam plan sayısı: ${plans.length}');

  print('\n📋 Plan Özeti:');
  for (var plan in plans) {
    print(
      '  🏋️ ${plan['name']} (${plan['difficulty']}) - ${plan['durationWeeks']} hafta',
    );
    print('     💪 Hedef: ${(plan['targetMuscles'] as List).join(', ')}');
    print('     🏷️ Etiketler: ${(plan['tags'] as List).join(', ')}');
    print(
      '     📅 Haftalık gün sayısı: ${(plan['weeklySchedule'] as List).length}',
    );
    print('');
  }

  print('🔧 Firebase Console\'da yapılacaklar:');
  print('1. Firestore Database > Rules');
  print('2. firestore_test.rules içeriğini yapıştır');
  print('3. Publish et');
  print('4. Plans collection\'ını oluştur');
  print('5. plans_collection.json\'daki verileri ekle');
}
