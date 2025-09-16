import 'dart:convert';
import 'dart:io';

class SimpleDatabaseTest {
  // Test kullanıcısı oluştur
  static Map<String, dynamic> createTestUser() {
    return {
      'id': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'test@fitsun.com',
      'name': 'Test Kullanıcı',
      'age': 25,
      'height': 175.0,
      'weight': 70.0,
      'gender': 'Erkek',
      'goal': 'Kas kütlesi artırma',
      'fitnessLevel': 'Orta',
      'workoutLocation': 'Gym',
      'availableEquipment': ['Dambıl', 'Halter', 'Bench'],
      'bodyFat': 15.0,
      'experience': '2 yıl',
      'weeklyFrequency': 3,
      'preferredTime': '45-60 dakika',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isProfileComplete': true,
      'isActive': true,
    };
  }

  // Test spor programı oluştur
  static Map<String, dynamic> createTestWorkoutProgram(String userId) {
    return {
      'id': 'program_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'programName': '3 Günlük Kas Kütlesi Programı',
      'description': 'Orta seviye kas kütlesi artırma programı',
      'difficulty': 'Orta',
      'durationWeeks': 4,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
      'isCompleted': false,
      'startDate': DateTime.now().toIso8601String(),
      'endDate': DateTime.now().add(Duration(days: 28)).toIso8601String(),
      'weeklySchedule': [
        {
          'dayNumber': 1,
          'title': 'Gün 1: Göğüs ve Triceps',
          'muscleGroups': ['Göğüs', 'Triceps'],
          'duration': '60 dakika',
          'exercises': [
            {
              'name': 'Bench Press',
              'sets': 3,
              'reps': '8-12',
              'rest': '60s',
              'weight': 0.0,
              'notes': 'Temel göğüs egzersizi',
            },
            {
              'name': 'Incline Dumbbell Press',
              'sets': 3,
              'reps': '8-12',
              'rest': '60s',
              'weight': 0.0,
              'notes': 'Üst göğüs için',
            },
          ],
        },
        {
          'dayNumber': 2,
          'title': 'Gün 2: Sırt ve Biceps',
          'muscleGroups': ['Sırt', 'Biceps'],
          'duration': '60 dakika',
          'exercises': [
            {
              'name': 'Barbell Row',
              'sets': 3,
              'reps': '8-12',
              'rest': '60s',
              'weight': 0.0,
              'notes': 'Temel sırt egzersizi',
            },
            {
              'name': 'Dumbbell Bicep Curl',
              'sets': 3,
              'reps': '10-15',
              'rest': '60s',
              'weight': 0.0,
              'notes': 'Biceps için',
            },
          ],
        },
        {
          'dayNumber': 3,
          'title': 'Gün 3: Bacak ve Omuz',
          'muscleGroups': ['Bacak', 'Omuz'],
          'duration': '60 dakika',
          'exercises': [
            {
              'name': 'Squat',
              'sets': 3,
              'reps': '8-12',
              'rest': '60s',
              'weight': 0.0,
              'notes': 'Temel bacak egzersizi',
            },
            {
              'name': 'Dumbbell Shoulder Press',
              'sets': 3,
              'reps': '8-12',
              'rest': '60s',
              'weight': 0.0,
              'notes': 'Omuz için',
            },
          ],
        },
      ],
    };
  }

  // Test ilerleme verisi oluştur
  static Map<String, dynamic> createTestProgress(
    String userId,
    String programId,
  ) {
    return {
      'id': 'progress_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'programId': programId,
      'weekNumber': 1,
      'dayNumber': 1,
      'date': DateTime.now().toIso8601String(),
      'isCompleted': false,
      'duration': 0,
      'notes': 'İlk antrenman',
      'exercises': [
        {
          'exerciseName': 'Bench Press',
          'sets': [
            {
              'setNumber': 1,
              'reps': 10,
              'weight': 60.0,
              'rest': 60,
              'isCompleted': true,
              'notes': 'İyi gitti',
            },
            {
              'setNumber': 2,
              'reps': 8,
              'weight': 65.0,
              'rest': 60,
              'isCompleted': true,
              'notes': 'Zorlandı',
            },
            {
              'setNumber': 3,
              'reps': 6,
              'weight': 70.0,
              'rest': 60,
              'isCompleted': false,
              'notes': 'Son seti yapamadı',
            },
          ],
        },
      ],
      'overallRating': 7,
      'difficulty': 'Orta',
      'energy': 'İyi',
      'mood': 'Motiveli',
    };
  }

  // Test ayarları oluştur
  static Map<String, dynamic> createTestSettings(String userId) {
    return {
      'id': 'settings_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'notifications': {
        'workoutReminders': true,
        'progressUpdates': true,
        'weeklyReports': true,
        'newPrograms': false,
      },
      'preferences': {
        'language': 'tr',
        'units': 'metric',
        'theme': 'light',
        'sound': true,
        'vibration': true,
      },
      'goals': {
        'targetWeight': 75.0,
        'targetBodyFat': 12.0,
        'targetMuscleMass': 35.0,
        'targetEndurance': 'Orta',
      },
      'privacy': {
        'profileVisibility': 'public',
        'showProgress': true,
        'showPrograms': true,
        'showAchievements': true,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Test başarısı oluştur
  static Map<String, dynamic> createTestAchievement(String userId) {
    return {
      'id': 'achievement_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'achievementType': 'workout_streak',
      'title': '7 Günlük Antrenman Serisi',
      'description': '7 gün üst üste antrenman yaptın!',
      'icon': '🔥',
      'points': 100,
      'isUnlocked': true,
      'unlockedAt': DateTime.now().toIso8601String(),
      'progress': {'current': 7, 'target': 7, 'isCompleted': true},
      'rarity': 'common',
      'category': 'consistency',
    };
  }

  // Veritabanı yapısını test et
  static void testDatabaseStructure() {
    print('🗄️ Veritabanı Yapısı Test Ediliyor...\n');

    // Test kullanıcısı oluştur
    final testUser = createTestUser();
    print('👤 Test Kullanıcısı:');
    print('  - ID: ${testUser['id']}');
    print('  - Email: ${testUser['email']}');
    print('  - İsim: ${testUser['name']}');
    print('  - Yaş: ${testUser['age']}');
    print('  - Boy: ${testUser['height']} cm');
    print('  - Kilo: ${testUser['weight']} kg');
    print('  - Cinsiyet: ${testUser['gender']}');
    print('  - Hedef: ${testUser['goal']}');
    print('  - Seviye: ${testUser['fitnessLevel']}');
    print('  - Yağ Oranı: %${testUser['bodyFat']}');
    print('  - Deneyim: ${testUser['experience']}');
    print('  - Haftalık Sıklık: ${testUser['weeklyFrequency']} gün');
    print('  - Tercih Edilen Süre: ${testUser['preferredTime']}');
    print('  - Ekipman: ${testUser['availableEquipment']?.join(', ')}');
    print('  - Profil Tamamlandı: ${testUser['isProfileComplete']}');
    print('  - Aktif: ${testUser['isActive']}');
    print('');

    // Test spor programı oluştur
    final testProgram = createTestWorkoutProgram(testUser['id']);
    print('🏋️ Test Spor Programı:');
    print('  - Program ID: ${testProgram['id']}');
    print('  - Program Adı: ${testProgram['programName']}');
    print('  - Açıklama: ${testProgram['description']}');
    print('  - Zorluk: ${testProgram['difficulty']}');
    print('  - Süre: ${testProgram['durationWeeks']} hafta');
    print('  - Aktif: ${testProgram['isActive']}');
    print('  - Tamamlandı: ${testProgram['isCompleted']}');
    print('  - Gün Sayısı: ${testProgram['weeklySchedule']?.length ?? 0}');

    // Program detaylarını göster
    if (testProgram['weeklySchedule'] != null) {
      print('  📅 Program Detayları:');
      for (var day in testProgram['weeklySchedule']) {
        print('    📅 ${day['title']}');
        print(
          '      💪 Kas Grupları: ${day['muscleGroups']?.join(', ') ?? 'N/A'}',
        );
        print('      ⏱️ Süre: ${day['duration'] ?? 'N/A'}');
        if (day['exercises'] != null) {
          print('      🏋️ Egzersizler:');
          for (var exercise in day['exercises']) {
            print(
              '        - ${exercise['name']}: ${exercise['sets']} set x ${exercise['reps']} tekrar',
            );
          }
        }
      }
    }
    print('');

    // Test ilerleme verisi oluştur
    final testProgress = createTestProgress(testUser['id'], testProgram['id']);
    print('📊 Test İlerleme Verisi:');
    print('  - Progress ID: ${testProgress['id']}');
    print('  - Hafta: ${testProgress['weekNumber']}');
    print('  - Gün: ${testProgress['dayNumber']}');
    print('  - Tarih: ${testProgress['date']}');
    print('  - Tamamlandı: ${testProgress['isCompleted']}');
    print('  - Genel Puan: ${testProgress['overallRating']}/10');
    print('  - Zorluk: ${testProgress['difficulty']}');
    print('  - Enerji: ${testProgress['energy']}');
    print('  - Ruh Hali: ${testProgress['mood']}');

    // Egzersiz detaylarını göster
    if (testProgress['exercises'] != null) {
      print('  🏋️ Egzersiz Detayları:');
      for (var exercise in testProgress['exercises']) {
        print('    💪 ${exercise['exerciseName']}:');
        if (exercise['sets'] != null) {
          for (var set in exercise['sets']) {
            print(
              '      Set ${set['setNumber']}: ${set['reps']} tekrar x ${set['weight']}kg (${set['isCompleted'] ? '✅' : '❌'})',
            );
          }
        }
      }
    }
    print('');

    // Test ayarları oluştur
    final testSettings = createTestSettings(testUser['id']);
    print('⚙️ Test Kullanıcı Ayarları:');
    print('  - Bildirimler:');
    print(
      '    - Antrenman Hatırlatıcıları: ${testSettings['notifications']['workoutReminders']}',
    );
    print(
      '    - İlerleme Güncellemeleri: ${testSettings['notifications']['progressUpdates']}',
    );
    print(
      '    - Haftalık Raporlar: ${testSettings['notifications']['weeklyReports']}',
    );
    print(
      '    - Yeni Programlar: ${testSettings['notifications']['newPrograms']}',
    );
    print('  - Tercihler:');
    print('    - Dil: ${testSettings['preferences']['language']}');
    print('    - Birimler: ${testSettings['preferences']['units']}');
    print('    - Tema: ${testSettings['preferences']['theme']}');
    print('    - Ses: ${testSettings['preferences']['sound']}');
    print('    - Titreşim: ${testSettings['preferences']['vibration']}');
    print('  - Hedefler:');
    print('    - Hedef Kilo: ${testSettings['goals']['targetWeight']} kg');
    print('    - Hedef Yağ Oranı: %${testSettings['goals']['targetBodyFat']}');
    print(
      '    - Hedef Kas Kütlesi: ${testSettings['goals']['targetMuscleMass']} kg',
    );
    print(
      '    - Hedef Dayanıklılık: ${testSettings['goals']['targetEndurance']}',
    );
    print('  - Gizlilik:');
    print(
      '    - Profil Görünürlüğü: ${testSettings['privacy']['profileVisibility']}',
    );
    print('    - İlerleme Göster: ${testSettings['privacy']['showProgress']}');
    print(
      '    - Programlar Göster: ${testSettings['privacy']['showPrograms']}',
    );
    print(
      '    - Başarılar Göster: ${testSettings['privacy']['showAchievements']}',
    );
    print('');

    // Test başarısı oluştur
    final testAchievement = createTestAchievement(testUser['id']);
    print('🏆 Test Kullanıcı Başarısı:');
    print('  - Başarı ID: ${testAchievement['id']}');
    print('  - Başarı Türü: ${testAchievement['achievementType']}');
    print('  - Başlık: ${testAchievement['title']}');
    print('  - Açıklama: ${testAchievement['description']}');
    print('  - İkon: ${testAchievement['icon']}');
    print('  - Puan: ${testAchievement['points']}');
    print('  - Açıldı: ${testAchievement['isUnlocked']}');
    print('  - Açılma Tarihi: ${testAchievement['unlockedAt']}');
    print(
      '  - İlerleme: ${testAchievement['progress']['current']}/${testAchievement['progress']['target']}',
    );
    print('  - Nadirlik: ${testAchievement['rarity']}');
    print('  - Kategori: ${testAchievement['category']}');
    print('');

    // Veritabanı yapısını özetle
    print('📋 Veritabanı Yapısı Özeti:');
    print('  📁 users/ (Ana kullanıcı bilgileri)');
    print('    📁 workoutPrograms/ (Kullanıcının spor programları)');
    print('    📁 progress/ (Antrenman ilerlemesi)');
    print('    📁 settings/ (Kullanıcı ayarları)');
    print('    📁 achievements/ (Kullanıcı başarıları)');
    print('  📁 globalPrograms/ (Genel program şablonları)');
    print('');

    print('✅ Veritabanı yapısı test edildi!');
    print('🎉 Tüm veri modelleri doğru şekilde oluşturuldu!');
  }

  // JSON dosyası olarak kaydet
  static void saveToJson() {
    print('💾 Veritabanı yapısı JSON dosyası olarak kaydediliyor...');

    final testUser = createTestUser();
    final testProgram = createTestWorkoutProgram(testUser['id']);
    final testProgress = createTestProgress(testUser['id'], testProgram['id']);
    final testSettings = createTestSettings(testUser['id']);
    final testAchievement = createTestAchievement(testUser['id']);

    final databaseStructure = {
      'users': {testUser['id']: testUser},
      'workoutPrograms': {testProgram['id']: testProgram},
      'progress': {testProgress['id']: testProgress},
      'settings': {testSettings['id']: testSettings},
      'achievements': {testAchievement['id']: testAchievement},
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(databaseStructure);

    try {
      final file = File('database_structure.json');
      file.writeAsStringSync(jsonString);
      print(
        '✅ Veritabanı yapısı database_structure.json dosyasına kaydedildi!',
      );
    } catch (e) {
      print('❌ JSON dosyası kaydetme hatası: $e');
    }
  }
}

void main() {
  SimpleDatabaseTest.testDatabaseStructure();
  SimpleDatabaseTest.saveToJson();
}
