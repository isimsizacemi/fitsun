import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/services/gemini_service.dart';
import '../lib/models/user_model.dart';

class GeminiServiceTest {
  // Test kullanıcı verisi oluştur
  static UserModel createTestUser() {
    return UserModel(
      id: 'test_user_123',
      name: 'Test Kullanıcı',
      email: 'test@example.com',
      age: 25,
      height: 175,
      weight: 70,
      gender: 'Erkek',
      goal: 'Kas kütlesi artırma',
      fitnessLevel: 'Orta',
      availableEquipment: ['Dambıl', 'Halter', 'Bench'],
      createdAt: DateTime.now(),
    );
  }

  // GeminiService test fonksiyonunu test et
  static Future<bool> testApiConnection() async {
    try {
      print('🔍 GeminiService.testApiConnection() testi başlatılıyor...');

      final result = await GeminiService.testApiConnection();

      if (result) {
        print('✅ GeminiService.testApiConnection() başarılı!');
        return true;
      } else {
        print('❌ GeminiService.testApiConnection() başarısız!');
        return false;
      }
    } catch (e) {
      print('❌ GeminiService.testApiConnection() hatası: $e');
      return false;
    }
  }

  // Spor programı oluşturma testi
  static Future<bool> testWorkoutProgramGeneration() async {
    try {
      print('🏋️ Spor programı oluşturma testi başlatılıyor...');

      final testUser = createTestUser();
      print('👤 Test kullanıcısı oluşturuldu: ${testUser.name}');

      final program = await GeminiService.generateWorkoutProgram(testUser);

      if (program != null) {
        print('✅ Spor programı başarıyla oluşturuldu!');
        print('📋 Program Adı: ${program.programName}');
        print('📝 Açıklama: ${program.description}');
        print('⏱️ Süre: ${program.durationWeeks} hafta');
        print('🎯 Zorluk: ${program.difficulty}');
        print('📅 Gün Sayısı: ${program.weeklySchedule.length}');
        print('💾 Firebase\'e kaydedildi: ${program.id}');
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

  // Kullanıcı profili kaydetme testi
  static Future<bool> testUserProfileSave() async {
    try {
      print('💾 Kullanıcı profili kaydetme testi başlatılıyor...');

      final testUser = createTestUser();
      final result = await GeminiService.saveUserProfile(testUser);

      if (result) {
        print('✅ Kullanıcı profili başarıyla kaydedildi!');
        return true;
      } else {
        print('❌ Kullanıcı profili kaydedilemedi!');
        return false;
      }
    } catch (e) {
      print('❌ Kullanıcı profili kaydetme hatası: $e');
      return false;
    }
  }

  // Kullanıcı profili getirme testi
  static Future<bool> testUserProfileGet() async {
    try {
      print('📖 Kullanıcı profili getirme testi başlatılıyor...');

      final testUser = createTestUser();

      // Önce kaydet
      await GeminiService.saveUserProfile(testUser);

      // Sonra getir
      final retrievedUser = await GeminiService.getUserProfile(testUser.id);

      if (retrievedUser != null) {
        print('✅ Kullanıcı profili başarıyla getirildi!');
        print('👤 İsim: ${retrievedUser.name}');
        print('📧 Email: ${retrievedUser.email}');
        print('🎯 Hedef: ${retrievedUser.goal}');
        return true;
      } else {
        print('❌ Kullanıcı profili getirilemedi!');
        return false;
      }
    } catch (e) {
      print('❌ Kullanıcı profili getirme hatası: $e');
      return false;
    }
  }

  // Spor programları listesi testi
  static Future<bool> testWorkoutProgramsList() async {
    try {
      print('📋 Spor programları listesi testi başlatılıyor...');

      final testUser = createTestUser();

      // Önce bir program oluştur
      await GeminiService.generateWorkoutProgram(testUser);

      // Programları listele
      final programs = await GeminiService.getUserWorkoutPrograms(testUser.id);

      if (programs.isNotEmpty) {
        print('✅ Spor programları başarıyla listelendi!');
        print('📊 Program Sayısı: ${programs.length}');
        for (var program in programs) {
          print('  - ${program.programName} (${program.durationWeeks} hafta)');
        }
        return true;
      } else {
        print('❌ Spor programları listelenemedi!');
        return false;
      }
    } catch (e) {
      print('❌ Spor programları listesi hatası: $e');
      return false;
    }
  }

  // Tüm testleri çalıştır
  static Future<void> runAllTests() async {
    print('🚀 GeminiService testleri başlatılıyor...\n');

    int passedTests = 0;
    int totalTests = 5;

    // Test 1: API Bağlantı
    print('=' * 50);
    print('TEST 1: API Bağlantı Testi');
    print('=' * 50);
    if (await testApiConnection()) {
      passedTests++;
    }
    print('');

    // Test 2: Kullanıcı Profili Kaydetme
    print('=' * 50);
    print('TEST 2: Kullanıcı Profili Kaydetme Testi');
    print('=' * 50);
    if (await testUserProfileSave()) {
      passedTests++;
    }
    print('');

    // Test 3: Kullanıcı Profili Getirme
    print('=' * 50);
    print('TEST 3: Kullanıcı Profili Getirme Testi');
    print('=' * 50);
    if (await testUserProfileGet()) {
      passedTests++;
    }
    print('');

    // Test 4: Spor Programı Oluşturma
    print('=' * 50);
    print('TEST 4: Spor Programı Oluşturma Testi');
    print('=' * 50);
    if (await testWorkoutProgramGeneration()) {
      passedTests++;
    }
    print('');

    // Test 5: Spor Programları Listesi
    print('=' * 50);
    print('TEST 5: Spor Programları Listesi Testi');
    print('=' * 50);
    if (await testWorkoutProgramsList()) {
      passedTests++;
    }
    print('');

    // Sonuçlar
    print('=' * 50);
    print('GEMINISERVICE TEST SONUÇLARI');
    print('=' * 50);
    print('✅ Başarılı Testler: $passedTests/$totalTests');
    print('❌ Başarısız Testler: ${totalTests - passedTests}/$totalTests');

    if (passedTests == totalTests) {
      print('🎉 Tüm GeminiService testleri başarılı!');
    } else {
      print('⚠️ Bazı GeminiService testleri başarısız!');
    }
  }
}

void main() async {
  await GeminiServiceTest.runAllTests();
}
