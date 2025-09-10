import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/services/firebase_service.dart';
import '../lib/services/gemini_service.dart';
import '../lib/models/user_model.dart';

class DatabaseDesignTest {
  // Test kullanıcısı oluştur
  static UserModel createTestUser() {
    return UserModel(
      id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'test@fitsun.com',
      name: 'Test Kullanıcı',
      age: 25,
      height: 175.0,
      weight: 70.0,
      gender: 'Erkek',
      goal: 'Kas kütlesi artırma',
      fitnessLevel: 'Orta',
      workoutLocation: 'Gym',
      availableEquipment: ['Dambıl', 'Halter', 'Bench'],
      bodyFat: 15.0,
      experience: '2 yıl',
      weeklyFrequency: 3,
      preferredTime: '45-60 dakika',
      createdAt: DateTime.now(),
    );
  }

  // 1. Users koleksiyonu - Ana kullanıcı bilgileri
  static Future<bool> testUsersCollection() async {
    try {
      print('👤 Users koleksiyonu test ediliyor...');
      
      final testUser = createTestUser();
      
      // Kullanıcıyı kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(testUser.id)
          .set(testUser.toMap());
      print('✅ Kullanıcı users koleksiyonuna kaydedildi');
      
      // Kullanıcıyı getir
      final doc = await FirebaseService.firestore
          .collection('users')
          .doc(testUser.id)
          .get();
      
      if (doc.exists) {
        print('✅ Kullanıcı başarıyla getirildi');
        print('📋 Kullanıcı verisi: ${doc.data()}');
        return true;
      } else {
        print('❌ Kullanıcı getirilemedi');
        return false;
      }
    } catch (e) {
      print('❌ Users koleksiyonu hatası: $e');
      return false;
    }
  }

  // 2. User Workout Programs - Kullanıcının spor programları
  static Future<bool> testUserWorkoutPrograms() async {
    try {
      print('🏋️ User Workout Programs test ediliyor...');
      
      final testUser = createTestUser();
      final userId = testUser.id;
      
      // Kullanıcıyı kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .set(testUser.toMap());
      
      // Spor programı oluştur
      final programData = {
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
                'notes': 'Temel göğüs egzersizi'
              },
              {
                'name': 'Incline Dumbbell Press',
                'sets': 3,
                'reps': '8-12',
                'rest': '60s',
                'weight': 0.0,
                'notes': 'Üst göğüs için'
              }
            ]
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
                'notes': 'Temel sırt egzersizi'
              }
            ]
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
                'notes': 'Temel bacak egzersizi'
              }
            ]
          }
        ]
      };
      
      // Programı kullanıcının alt koleksiyonuna kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPrograms')
          .doc(programData['id'])
          .set(programData);
      
      print('✅ Spor programı kullanıcı alt koleksiyonuna kaydedildi');
      
      // Programı getir
      final programDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPrograms')
          .doc(programData['id'])
          .get();
      
      if (programDoc.exists) {
        print('✅ Spor programı başarıyla getirildi');
        print('📋 Program verisi: ${programDoc.data()}');
        return true;
      } else {
        print('❌ Spor programı getirilemedi');
        return false;
      }
    } catch (e) {
      print('❌ User Workout Programs hatası: $e');
      return false;
    }
  }

  // 3. User Progress - Kullanıcı ilerleme takibi
  static Future<bool> testUserProgress() async {
    try {
      print('📊 User Progress test ediliyor...');
      
      final testUser = createTestUser();
      final userId = testUser.id;
      final programId = 'program_${DateTime.now().millisecondsSinceEpoch}';
      
      // Kullanıcıyı kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .set(testUser.toMap());
      
      // İlerleme verisi oluştur
      final progressData = {
        'id': 'progress_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'programId': programId,
        'weekNumber': 1,
        'dayNumber': 1,
        'date': DateTime.now().toIso8601String(),
        'isCompleted': false,
        'duration': 0, // dakika
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
                'notes': 'İyi gitti'
              },
              {
                'setNumber': 2,
                'reps': 8,
                'weight': 65.0,
                'rest': 60,
                'isCompleted': true,
                'notes': 'Zorlandı'
              },
              {
                'setNumber': 3,
                'reps': 6,
                'weight': 70.0,
                'rest': 60,
                'isCompleted': false,
                'notes': 'Son seti yapamadı'
              }
            ]
          }
        ],
        'overallRating': 7, // 1-10 arası
        'difficulty': 'Orta',
        'energy': 'İyi',
        'mood': 'Motiveli'
      };
      
      // İlerleme verisini kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(progressData['id'])
          .set(progressData);
      
      print('✅ İlerleme verisi kaydedildi');
      
      // İlerleme verisini getir
      final progressDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(progressData['id'])
          .get();
      
      if (progressDoc.exists) {
        print('✅ İlerleme verisi başarıyla getirildi');
        print('📋 Progress verisi: ${progressDoc.data()}');
        return true;
      } else {
        print('❌ İlerleme verisi getirilemedi');
        return false;
      }
    } catch (e) {
      print('❌ User Progress hatası: $e');
      return false;
    }
  }

  // 4. User Settings - Kullanıcı ayarları
  static Future<bool> testUserSettings() async {
    try {
      print('⚙️ User Settings test ediliyor...');
      
      final testUser = createTestUser();
      final userId = testUser.id;
      
      // Kullanıcıyı kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .set(testUser.toMap());
      
      // Ayarlar verisi oluştur
      final settingsData = {
        'id': 'settings_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'notifications': {
          'workoutReminders': true,
          'progressUpdates': true,
          'weeklyReports': true,
          'newPrograms': false
        },
        'preferences': {
          'language': 'tr',
          'units': 'metric', // metric/imperial
          'theme': 'light', // light/dark
          'sound': true,
          'vibration': true
        },
        'goals': {
          'targetWeight': 75.0,
          'targetBodyFat': 12.0,
          'targetMuscleMass': 35.0,
          'targetEndurance': 'Orta'
        },
        'privacy': {
          'profileVisibility': 'public', // public/private/friends
          'showProgress': true,
          'showPrograms': true,
          'showAchievements': true
        },
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String()
      };
      
      // Ayarları kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set(settingsData);
      
      print('✅ Kullanıcı ayarları kaydedildi');
      
      // Ayarları getir
      final settingsDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();
      
      if (settingsDoc.exists) {
        print('✅ Kullanıcı ayarları başarıyla getirildi');
        print('📋 Settings verisi: ${settingsDoc.data()}');
        return true;
      } else {
        print('❌ Kullanıcı ayarları getirilemedi');
        return false;
      }
    } catch (e) {
      print('❌ User Settings hatası: $e');
      return false;
    }
  }

  // 5. User Achievements - Kullanıcı başarıları
  static Future<bool> testUserAchievements() async {
    try {
      print('🏆 User Achievements test ediliyor...');
      
      final testUser = createTestUser();
      final userId = testUser.id;
      
      // Kullanıcıyı kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .set(testUser.toMap());
      
      // Başarı verisi oluştur
      final achievementData = {
        'id': 'achievement_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'achievementType': 'workout_streak',
        'title': '7 Günlük Antrenman Serisi',
        'description': '7 gün üst üste antrenman yaptın!',
        'icon': '🔥',
        'points': 100,
        'isUnlocked': true,
        'unlockedAt': DateTime.now().toIso8601String(),
        'progress': {
          'current': 7,
          'target': 7,
          'isCompleted': true
        },
        'rarity': 'common', // common/rare/epic/legendary
        'category': 'consistency'
      };
      
      // Başarıyı kaydet
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementData['id'])
          .set(achievementData);
      
      print('✅ Kullanıcı başarısı kaydedildi');
      
      // Başarıyı getir
      final achievementDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementData['id'])
          .get();
      
      if (achievementDoc.exists) {
        print('✅ Kullanıcı başarısı başarıyla getirildi');
        print('📋 Achievement verisi: ${achievementDoc.data()}');
        return true;
      } else {
        print('❌ Kullanıcı başarısı getirilemedi');
        return false;
      }
    } catch (e) {
      print('❌ User Achievements hatası: $e');
      return false;
    }
  }

  // 6. Global Programs - Genel program şablonları
  static Future<bool> testGlobalPrograms() async {
    try {
      print('🌍 Global Programs test ediliyor...');
      
      // Genel program şablonu oluştur
      final globalProgramData = {
        'id': 'global_program_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Başlangıç Seviyesi 3 Günlük Program',
        'description': 'Yeni başlayanlar için temel kas kütlesi programı',
        'difficulty': 'Başlangıç',
        'durationWeeks': 4,
        'targetAudience': 'Yeni başlayanlar',
        'equipment': ['Dambıl', 'Halter', 'Bench'],
        'muscleGroups': ['Göğüs', 'Sırt', 'Bacak', 'Omuz', 'Kol'],
        'isTemplate': true,
        'isPublic': true,
        'createdBy': 'system',
        'createdAt': DateTime.now().toIso8601String(),
        'usageCount': 0,
        'rating': 0.0,
        'tags': ['başlangıç', 'kas kütlesi', '3 gün'],
        'weeklySchedule': [
          {
            'dayNumber': 1,
            'title': 'Gün 1: Üst Vücut',
            'muscleGroups': ['Göğüs', 'Triceps'],
            'duration': '45 dakika',
            'exercises': [
              {
                'name': 'Push-up',
                'sets': 3,
                'reps': '8-12',
                'rest': '60s',
                'notes': 'Temel göğüs egzersizi'
              }
            ]
          }
        ]
      };
      
      // Genel programı kaydet
      await FirebaseService.firestore
          .collection('globalPrograms')
          .doc(globalProgramData['id'])
          .set(globalProgramData);
      
      print('✅ Genel program şablonu kaydedildi');
      
      // Genel programı getir
      final globalProgramDoc = await FirebaseService.firestore
          .collection('globalPrograms')
          .doc(globalProgramData['id'])
          .get();
      
      if (globalProgramDoc.exists) {
        print('✅ Genel program şablonu başarıyla getirildi');
        print('📋 Global Program verisi: ${globalProgramDoc.data()}');
        return true;
      } else {
        print('❌ Genel program şablonu getirilemedi');
        return false;
      }
    } catch (e) {
      print('❌ Global Programs hatası: $e');
      return false;
    }
  }

  // Tüm testleri çalıştır
  static Future<void> runAllTests() async {
    print('🚀 Database Design Test Suite Başlatılıyor...\n');
    
    int passedTests = 0;
    int totalTests = 6;
    
    // Test 1: Users Collection
    print('=' * 60);
    print('TEST 1: Users Collection');
    print('=' * 60);
    if (await testUsersCollection()) {
      passedTests++;
    }
    print('');
    
    // Test 2: User Workout Programs
    print('=' * 60);
    print('TEST 2: User Workout Programs');
    print('=' * 60);
    if (await testUserWorkoutPrograms()) {
      passedTests++;
    }
    print('');
    
    // Test 3: User Progress
    print('=' * 60);
    print('TEST 3: User Progress');
    print('=' * 60);
    if (await testUserProgress()) {
      passedTests++;
    }
    print('');
    
    // Test 4: User Settings
    print('=' * 60);
    print('TEST 4: User Settings');
    print('=' * 60);
    if (await testUserSettings()) {
      passedTests++;
    }
    print('');
    
    // Test 5: User Achievements
    print('=' * 60);
    print('TEST 5: User Achievements');
    print('=' * 60);
    if (await testUserAchievements()) {
      passedTests++;
    }
    print('');
    
    // Test 6: Global Programs
    print('=' * 60);
    print('TEST 6: Global Programs');
    print('=' * 60);
    if (await testGlobalPrograms()) {
      passedTests++;
    }
    print('');
    
    // Sonuçlar
    print('=' * 60);
    print('DATABASE DESIGN TEST SONUÇLARI');
    print('=' * 60);
    print('✅ Başarılı Testler: $passedTests/$totalTests');
    print('❌ Başarısız Testler: ${totalTests - passedTests}/$totalTests');
    
    if (passedTests == totalTests) {
      print('🎉 Tüm veritabanı testleri başarılı!');
      print('🚀 Veritabanı yapısı tamamen hazır!');
      print('\n📋 Veritabanı Yapısı:');
      print('  📁 users/ (Ana kullanıcı bilgileri)');
      print('    📁 workoutPrograms/ (Kullanıcının spor programları)');
      print('    📁 progress/ (Antrenman ilerlemesi)');
      print('    📁 settings/ (Kullanıcı ayarları)');
      print('    📁 achievements/ (Kullanıcı başarıları)');
      print('  📁 globalPrograms/ (Genel program şablonları)');
    } else {
      print('⚠️ Bazı veritabanı testleri başarısız!');
      print('💡 Firebase Console\'da Firestore kurulumunu kontrol edin');
    }
  }
}

void main() async {
  await DatabaseDesignTest.runAllTests();
}
