import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/services/firebase_service.dart';
import '../lib/services/gemini_service.dart';
import '../lib/models/user_model.dart';

class FirebaseTest {
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

  // Firebase'e kullanıcı ekle
  static Future<bool> testAddUser() async {
    try {
      print('👤 Test kullanıcısı oluşturuluyor...');

      final testUser = createTestUser();
      print('📝 Kullanıcı bilgileri:');
      print('  - ID: ${testUser.id}');
      print('  - Email: ${testUser.email}');
      print('  - İsim: ${testUser.name}');
      print('  - Yaş: ${testUser.age}');
      print('  - Boy: ${testUser.height} cm');
      print('  - Kilo: ${testUser.weight} kg');
      print('  - Cinsiyet: ${testUser.gender}');
      print('  - Hedef: ${testUser.goal}');
      print('  - Seviye: ${testUser.fitnessLevel}');
      print('  - Yağ Oranı: %${testUser.bodyFat}');
      print('  - Deneyim: ${testUser.experience}');
      print('  - Haftalık Sıklık: ${testUser.weeklyFrequency} gün');
      print('  - Tercih Edilen Süre: ${testUser.preferredTime}');
      print('  - Ekipman: ${testUser.availableEquipment?.join(', ')}');

      print('💾 Firebase\'e kaydediliyor...');
      final result = await GeminiService.saveUserProfile(testUser);

      if (result) {
        print('✅ Kullanıcı başarıyla Firebase\'e eklendi!');
        return true;
      } else {
        print('❌ Kullanıcı Firebase\'e eklenemedi!');
        return false;
      }
    } catch (e) {
      print('❌ Kullanıcı ekleme hatası: $e');
      return false;
    }
  }

  // Firebase'den kullanıcı getir
  static Future<bool> testGetUser() async {
    try {
      print('📖 Firebase\'den kullanıcı getiriliyor...');

      final testUser = createTestUser();

      // Önce kaydet
      await GeminiService.saveUserProfile(testUser);
      print('✅ Kullanıcı kaydedildi');

      // Sonra getir
      final retrievedUser = await GeminiService.getUserProfile(testUser.id);

      if (retrievedUser != null) {
        print('✅ Kullanıcı başarıyla getirildi!');
        print('📋 Getirilen bilgiler:');
        print('  - ID: ${retrievedUser.id}');
        print('  - Email: ${retrievedUser.email}');
        print('  - İsim: ${retrievedUser.name}');
        print('  - Yaş: ${retrievedUser.age}');
        print('  - Boy: ${retrievedUser.height} cm');
        print('  - Kilo: ${retrievedUser.weight} kg');
        print('  - Cinsiyet: ${retrievedUser.gender}');
        print('  - Hedef: ${retrievedUser.goal}');
        print('  - Seviye: ${retrievedUser.fitnessLevel}');
        print('  - Yağ Oranı: %${retrievedUser.bodyFat}');
        print('  - Deneyim: ${retrievedUser.experience}');
        print('  - Haftalık Sıklık: ${retrievedUser.weeklyFrequency} gün');
        print('  - Tercih Edilen Süre: ${retrievedUser.preferredTime}');
        print('  - Ekipman: ${retrievedUser.availableEquipment?.join(', ')}');
        print('  - Oluşturulma Tarihi: ${retrievedUser.createdAt}');
        return true;
      } else {
        print('❌ Kullanıcı getirilemedi!');
        return false;
      }
    } catch (e) {
      print('❌ Kullanıcı getirme hatası: $e');
      return false;
    }
  }

  // AI ile spor programı oluştur
  static Future<bool> testCreateWorkoutProgram() async {
    try {
      print('🏋️ AI ile spor programı oluşturuluyor...');

      final testUser = createTestUser();

      // Önce kullanıcıyı kaydet
      await GeminiService.saveUserProfile(testUser);
      print('✅ Kullanıcı kaydedildi');

      // AI ile program oluştur
      print('🤖 AI program oluşturuyor...');
      final program = await GeminiService.generateWorkoutProgram(testUser);

      if (program != null) {
        print('✅ Spor programı başarıyla oluşturuldu!');
        print('📋 Program Detayları:');
        print('  - Program ID: ${program.id}');
        print('  - Program Adı: ${program.programName}');
        print('  - Açıklama: ${program.description}');
        print('  - Süre: ${program.durationWeeks} hafta');
        print('  - Zorluk: ${program.difficulty}');
        print('  - Gün Sayısı: ${program.weeklySchedule.length}');
        print('  - Oluşturulma Tarihi: ${program.createdAt}');

        // Program detaylarını göster
        for (int i = 0; i < program.weeklySchedule.length; i++) {
          final day = program.weeklySchedule[i];
          print('  📅 Gün ${day.dayNumber}: ${day.title}');
          print('    💪 Kas Grupları: ${day.muscleGroups.join(', ')}');
          print('    ⏱️ Süre: ${day.duration}');
          print('    🏋️ Egzersiz Sayısı: ${day.exercises.length}');

          for (int j = 0; j < day.exercises.length; j++) {
            final exercise = day.exercises[j];
            print(
              '      ${j + 1}. ${exercise.name} - ${exercise.sets} set x ${exercise.reps} tekrar',
            );
          }
        }

        return true;
      } else {
        print('❌ Spor programı oluşturulamadı!');
        return false;
      }
    } catch (e) {
      print('❌ Spor programı oluşturma hatası: $e');
      return false;
    }
  }

  // Firebase bağlantısını test et
  static Future<bool> testFirebaseConnection() async {
    try {
      print('🔍 Firebase bağlantısı test ediliyor...');

      // Firebase'i başlat
      await FirebaseService.initialize();
      print('✅ Firebase başlatıldı');

      // Test kullanıcısı oluştur
      final testUser = createTestUser();

      // Firestore'a yazma testi
      print('📝 Firestore\'a yazma testi...');
      await FirebaseService.firestore
          .collection('test_users')
          .doc(testUser.id)
          .set(testUser.toMap());
      print('✅ Firestore\'a yazma başarılı');

      // Firestore'dan okuma testi
      print('📖 Firestore\'dan okuma testi...');
      final doc = await FirebaseService.firestore
          .collection('test_users')
          .doc(testUser.id)
          .get();

      if (doc.exists) {
        print('✅ Firestore\'dan okuma başarılı');
        print('📋 Okunan veri: ${doc.data()}');

        // Test verisini sil
        await FirebaseService.firestore
            .collection('test_users')
            .doc(testUser.id)
            .delete();
        print('🗑️ Test verisi silindi');

        return true;
      } else {
        print('❌ Firestore\'dan veri okunamadı');
        return false;
      }
    } catch (e) {
      print('❌ Firebase bağlantı hatası: $e');
      if (e.toString().contains('NOT_FOUND')) {
        print('💡 Çözüm: Firebase Console\'da Firestore\'u aktifleştirin');
        print(
          '🔗 https://console.cloud.google.com/datastore/setup?project=fitsun-9da11',
        );
      }
      return false;
    }
  }

  // Tüm testleri çalıştır
  static Future<void> runAllTests() async {
    print('🚀 Firebase Test Suite Başlatılıyor...\n');

    int passedTests = 0;
    int totalTests = 4;

    // Test 1: Firebase Bağlantısı
    print('=' * 50);
    print('TEST 1: Firebase Bağlantı Testi');
    print('=' * 50);
    if (await testFirebaseConnection()) {
      passedTests++;
    }
    print('');

    // Test 2: Kullanıcı Ekleme
    print('=' * 50);
    print('TEST 2: Kullanıcı Ekleme Testi');
    print('=' * 50);
    if (await testAddUser()) {
      passedTests++;
    }
    print('');

    // Test 3: Kullanıcı Getirme
    print('=' * 50);
    print('TEST 3: Kullanıcı Getirme Testi');
    print('=' * 50);
    if (await testGetUser()) {
      passedTests++;
    }
    print('');

    // Test 4: AI Program Oluşturma
    print('=' * 50);
    print('TEST 4: AI Program Oluşturma Testi');
    print('=' * 50);
    if (await testCreateWorkoutProgram()) {
      passedTests++;
    }
    print('');

    // Sonuçlar
    print('=' * 50);
    print('FIREBASE TEST SONUÇLARI');
    print('=' * 50);
    print('✅ Başarılı Testler: $passedTests/$totalTests');
    print('❌ Başarısız Testler: ${totalTests - passedTests}/$totalTests');

    if (passedTests == totalTests) {
      print('🎉 Tüm Firebase testleri başarılı!');
      print('🚀 Uygulama tamamen hazır!');
    } else {
      print('⚠️ Bazı Firebase testleri başarısız!');
      if (passedTests == 0) {
        print('💡 Çözüm: Firebase Console\'da Firestore\'u aktifleştirin');
        print(
          '🔗 https://console.cloud.google.com/datastore/setup?project=fitsun-9da11',
        );
      }
    }
  }
}

void main() async {
  await FirebaseTest.runAllTests();
}
