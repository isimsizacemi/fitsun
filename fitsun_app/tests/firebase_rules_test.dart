import 'dart:convert';
import 'dart:io';

class FirebaseRulesTest {
  // Firebase Rules test verisi oluştur
  static Map<String, dynamic> createTestData() {
    return {
      'test_user': {
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
        'isActive': true
      },
      'test_program': {
        'id': 'program_${DateTime.now().millisecondsSinceEpoch}',
        'userId': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
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
              }
            ]
          }
        ]
      }
    };
  }

  // Firebase Rules dosyasını oluştur
  static void createFirestoreRules() {
    print('🔐 Firebase Firestore Rules oluşturuluyor...\n');
    
    // Test rules (geliştirme için)
    final testRules = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Test için tüm erişimlere izin ver (GELİŞTİRME AŞAMASINDA)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''';

    // Production rules (güvenli)
    final productionRules = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Alt koleksiyonlar için aynı kural
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Genel programlar herkese açık (okuma)
    match /globalPrograms/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Test koleksiyonu (geliştirme için)
    match /test_users/{document} {
      allow read, write: if true;
    }
  }
}''';

    try {
      // Test rules dosyası
      final testFile = File('firestore_test.rules');
      testFile.writeAsStringSync(testRules);
      print('✅ Test rules dosyası oluşturuldu: firestore_test.rules');
      
      // Production rules dosyası
      final productionFile = File('firestore.rules');
      productionFile.writeAsStringSync(productionRules);
      print('✅ Production rules dosyası oluşturuldu: firestore.rules');
      
      print('\n📋 Rules Açıklaması:');
      print('  🔓 Test Rules: Tüm erişimlere izin verir (geliştirme için)');
      print('  🔒 Production Rules: Sadece kullanıcılar kendi verilerine erişebilir');
      print('\n💡 Firebase Console\'da Rules sekmesinden bu kuralları yükleyebilirsin!');
      
    } catch (e) {
      print('❌ Rules dosyası oluşturma hatası: $e');
    }
  }

  // Test verisi oluştur
  static void createTestDataFile() {
    print('📊 Test verisi oluşturuluyor...\n');
    
    final testData = createTestData();
    
    try {
      final file = File('firebase_test_data.json');
      final jsonString = JsonEncoder.withIndent('  ').convert(testData);
      file.writeAsStringSync(jsonString);
      print('✅ Test verisi firebase_test_data.json dosyasına kaydedildi!');
      
      print('\n📋 Test Verisi:');
      print('  👤 Kullanıcı: ${testData['test_user']['name']}');
      print('  🏋️ Program: ${testData['test_program']['programName']}');
      print('  📅 Gün Sayısı: ${testData['test_program']['weeklySchedule']?.length ?? 0}');
      
    } catch (e) {
      print('❌ Test verisi oluşturma hatası: $e');
    }
  }

  // Firebase kurulum rehberi
  static void showFirebaseSetupGuide() {
    print('\n🚀 Firebase Kurulum Rehberi:');
    print('=' * 50);
    print('1. Firebase Console\'a git: https://console.firebase.google.com/');
    print('2. Projeni seç: fitsun-9da11');
    print('3. Sol menüden "Firestore Database" seç');
    print('4. "Rules" sekmesine git');
    print('5. Aşağıdaki kuralları yapıştır:');
    print('\n' + '=' * 50);
    print('rules_version = \'2\';');
    print('service cloud.firestore {');
    print('  match /databases/{database}/documents {');
    print('    match /{document=**} {');
    print('      allow read, write: if true;');
    print('    }');
    print('  }');
    print('}');
    print('=' * 50);
    print('\n6. "Publish" butonuna tıkla');
    print('7. Uygulamayı test et!');
    print('\n💡 Bu kurallar geliştirme için güvenli değil, production\'da değiştir!');
  }

  // Tüm testleri çalıştır
  static void runAllTests() {
    print('🔐 Firebase Rules Test Suite Başlatılıyor...\n');
    
    createFirestoreRules();
    createTestDataFile();
    showFirebaseSetupGuide();
    
    print('\n✅ Firebase Rules testleri tamamlandı!');
    print('🎉 Artık Firebase\'e veri yazabilirsin!');
  }
}

void main() {
  FirebaseRulesTest.runAllTests();
}
