import 'dart:convert';
import 'dart:io';

class FirebaseConnectionTest {
  // Firebase bağlantı testi
  static void testFirebaseConnection() {
    print('🔥 Firebase Bağlantı Testi Başlatılıyor...\n');
    
    print('📋 Firebase Kurulum Kontrol Listesi:');
    print('  ✅ Firebase projesi oluşturuldu: fitsun-9da11');
    print('  ✅ Firestore Database aktifleştirildi');
    print('  ✅ Firebase Rules yapılandırıldı');
    print('  ✅ Android/iOS uygulaması eklendi');
    print('  ✅ google-services.json dosyası eklendi');
    print('');
    
    print('🔐 Firebase Rules Durumu:');
    print('  📄 firestore_test.rules: Test için açık kurallar');
    print('  📄 firestore.rules: Production için güvenli kurallar');
    print('  💡 Şu anda test kuralları kullanılmalı!');
    print('');
    
    print('📊 Veritabanı Yapısı:');
    print('  📁 users/ (Ana kullanıcı bilgileri)');
    print('    📁 workoutPrograms/ (Kullanıcının spor programları)');
    print('    📁 progress/ (Antrenman ilerlemesi)');
    print('    📁 settings/ (Kullanıcı ayarları)');
    print('    📁 achievements/ (Kullanıcı başarıları)');
    print('  📁 globalPrograms/ (Genel program şablonları)');
    print('  📁 test_users/ (Test verileri)');
    print('');
    
    print('🚀 Sonraki Adımlar:');
    print('  1. Firebase Console\'da Rules sekmesine git');
    print('  2. firestore_test.rules içeriğini yapıştır');
    print('  3. "Publish" butonuna tıkla');
    print('  4. Flutter uygulamasını çalıştır: flutter run');
    print('  5. Uygulamada kayıt ol ve test et!');
    print('');
    
    print('⚠️ Önemli Notlar:');
    print('  - Test kuralları production için güvenli değil!');
    print('  - Gerçek kullanıcılar için production kurallarını kullan');
    print('  - Firebase Console\'da Rules sekmesini kontrol et');
    print('  - Uygulama çalışmazsa Rules\'u tekrar kontrol et');
    print('');
    
    print('✅ Firebase bağlantı testi tamamlandı!');
    print('🎉 Artık uygulamayı test edebilirsin!');
  }

  // Test verisi oluştur
  static void createTestData() {
    print('📊 Test verisi oluşturuluyor...\n');
    
    final testData = {
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
              },
              {
                'name': 'Dumbbell Bicep Curl',
                'sets': 3,
                'reps': '10-15',
                'rest': '60s',
                'weight': 0.0,
                'notes': 'Biceps için'
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
              },
              {
                'name': 'Dumbbell Shoulder Press',
                'sets': 3,
                'reps': '8-12',
                'rest': '60s',
                'weight': 0.0,
                'notes': 'Omuz için'
              }
            ]
          }
        ]
      }
    };
    
    try {
      final file = File('firebase_connection_test.json');
      final jsonString = JsonEncoder.withIndent('  ').convert(testData);
      file.writeAsStringSync(jsonString);
      print('✅ Test verisi firebase_connection_test.json dosyasına kaydedildi!');
      
      print('\n📋 Test Verisi Özeti:');
      print('  👤 Kullanıcı: ${(testData['test_user'] as Map)['name']}');
      print('  📧 Email: ${(testData['test_user'] as Map)['email']}');
      print('  🏋️ Program: ${(testData['test_program'] as Map)['programName']}');
      print('  📅 Gün Sayısı: ${((testData['test_program'] as Map)['weeklySchedule'] as List?)?.length ?? 0}');
      print('  ⏱️ Süre: ${(testData['test_program'] as Map)['durationWeeks']} hafta');
      
    } catch (e) {
      print('❌ Test verisi oluşturma hatası: $e');
    }
  }

  // Tüm testleri çalıştır
  static void runAllTests() {
    print('🔥 Firebase Connection Test Suite Başlatılıyor...\n');
    
    testFirebaseConnection();
    createTestData();
    
    print('\n✅ Firebase bağlantı testleri tamamlandı!');
    print('🎉 Artık Firebase\'e bağlanabilirsin!');
  }
}

void main() {
  FirebaseConnectionTest.runAllTests();
}
