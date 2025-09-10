import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTest {
  static const String _apiKey = 'AIzaSyBgCodouEn4KYNqFCSLxDOFI-qNE62V8O4';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // Basit API bağlantı testi
  static Future<bool> testBasicConnection() async {
    try {
      print('🔍 Basit API bağlantı testi başlatılıyor...');

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Merhaba, bu bir test mesajıdır. Sadece "Test başarılı" yaz.',
                },
              ],
            },
          ],
        }),
      );

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        print('✅ API Test Başarılı!');
        print('🤖 AI Yanıtı: $generatedText');
        return true;
      } else {
        print('❌ API Test Başarısız! Status: ${response.statusCode}');
        print('❌ Hata: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Bağlantı Hatası: $e');
      return false;
    }
  }

  // Spor programı oluşturma testi
  static Future<bool> testWorkoutProgramGeneration() async {
    try {
      print('🏋️ Spor programı oluşturma testi başlatılıyor...');

      // Test kullanıcı verisi
      final testUser = {
        'age': 25,
        'height': 175,
        'weight': 70,
        'gender': 'Erkek',
        'goal': 'Kas kütlesi artırma',
        'fitnessLevel': 'Orta',
        'availableEquipment': ['Dambıl', 'Halter', 'Bench'],
      };

      // Test kullanıcı verisi - gerçekte Firebase'den gelecek
      final userData = {
        'age': 25,
        'height': 175,
        'weight': 70,
        'gender': 'Erkek',
        'goal': 'Kas kütlesi artırma',
        'fitnessLevel': 'Orta',
        'bodyFat': 15, // %15 yağ oranı
        'experience': '2 yıl',
        'availableEquipment': ['Dambıl', 'Halter', 'Bench'],
        'weeklyFrequency': 3, // haftada 3 gün
        'preferredTime': '45-60 dakika',
      };

      final prompt =
          '''
Kullanıcı: ${userData['age']} yaş, ${userData['height']}cm, ${userData['weight']}kg ${userData['gender']}
Hedef: ${userData['goal']} | Seviye: ${userData['fitnessLevel']} | Yağ: %${userData['bodyFat']}
Deneyim: ${userData['experience']} | Haftalık: ${userData['weeklyFrequency']} gün | Süre: ${userData['preferredTime']}
Ekipman: ${(userData['availableEquipment'] as List?)?.join(', ') ?? 'Yok'}

Bu bilgilere göre ${userData['weeklyFrequency']} günlük program oluştur.

JSON:
{
  "title": "Program",
  "duration": "1 hafta",
  "weeks": [{
    "weekNumber": 1,
    "days": [{
      "dayNumber": 1,
      "title": "Gün 1",
      "muscleGroups": ["Göğüs"],
      "exercises": [{
        "name": "Bench Press",
        "sets": 3,
        "reps": "8-12",
        "rest": "60s"
      }],
      "duration": "${userData['preferredTime']}"
    }]
  }]
}

Sadece JSON ver.
''';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'maxOutputTokens': 8192,
            'temperature': 0.7,
            'topP': 0.8,
            'topK': 40,
          },
        }),
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body Length: ${response.body.length}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          final content = candidate['content'];

          if (content != null &&
              content['parts'] != null &&
              content['parts'].isNotEmpty) {
            final generatedText = content['parts'][0]['text'];

            print('✅ Spor programı oluşturma testi başarılı!');
            print('📝 Generated Text Length: ${generatedText.length}');
            print(
              '🔍 Generated Text Preview: ${generatedText.substring(0, 200)}...',
            );

            // JSON parse testi - markdown kod bloklarını temizle
            try {
              String cleanText = generatedText;
              if (cleanText.startsWith('```json')) {
                cleanText = cleanText.substring(7);
              }
              if (cleanText.startsWith('```')) {
                cleanText = cleanText.substring(3);
              }
              if (cleanText.endsWith('```')) {
                cleanText = cleanText.substring(0, cleanText.length - 3);
              }
              cleanText = cleanText.trim();

              final parsedData = jsonDecode(cleanText);
              print('✅ JSON parsing başarılı');
              print('📋 Program Başlığı: ${parsedData['title']}');
              print('⏱️ Süre: ${parsedData['duration']}');
              print('📅 Hafta Sayısı: ${parsedData['weeks']?.length ?? 0}');
              return true;
            } catch (e) {
              print('❌ JSON parsing hatası: $e');
              print('🔍 Raw text: $generatedText');
              return false;
            }
          } else {
            print('❌ API yanıtında content/parts bulunamadı');
            print('🔍 Finish Reason: ${candidate['finishReason']}');
            print('🔍 Content: $content');
            return false;
          }
        } else {
          print('❌ API yanıtında candidates bulunamadı');
          print('🔍 Response: ${response.body}');
          return false;
        }
      } else {
        print('❌ Spor programı oluşturma testi başarısız!');
        print('❌ Status: ${response.statusCode}');
        print('❌ Hata: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Spor programı oluşturma hatası: $e');
      return false;
    }
  }

  // Hata durumu testi
  static Future<bool> testErrorHandling() async {
    try {
      print('🚨 Hata durumu testi başlatılıyor...');

      // Geçersiz API key ile test
      final response = await http.post(
        Uri.parse('$_apiUrl?key=invalid_key'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Test mesajı'},
              ],
            },
          ],
        }),
      );

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('✅ Hata durumu testi başarılı! (Beklenen hata alındı)');
        print('❌ Hata Mesajı: ${response.body}');
        return true;
      } else {
        print('❌ Hata durumu testi başarısız! (Hata bekleniyordu)');
        return false;
      }
    } catch (e) {
      print('✅ Hata durumu testi başarılı! (Exception yakalandı)');
      print('❌ Exception: $e');
      return true;
    }
  }

  // Tüm testleri çalıştır
  static Future<void> runAllTests() async {
    print('🚀 Tüm API testleri başlatılıyor...\n');

    int passedTests = 0;
    int totalTests = 3;

    // Test 1: Basit bağlantı
    print('=' * 50);
    print('TEST 1: Basit API Bağlantı Testi');
    print('=' * 50);
    if (await testBasicConnection()) {
      passedTests++;
    }
    print('');

    // Test 2: Spor programı oluşturma
    print('=' * 50);
    print('TEST 2: Spor Programı Oluşturma Testi');
    print('=' * 50);
    if (await testWorkoutProgramGeneration()) {
      passedTests++;
    }
    print('');

    // Test 3: Hata durumu
    print('=' * 50);
    print('TEST 3: Hata Durumu Testi');
    print('=' * 50);
    if (await testErrorHandling()) {
      passedTests++;
    }
    print('');

    // Sonuçlar
    print('=' * 50);
    print('TEST SONUÇLARI');
    print('=' * 50);
    print('✅ Başarılı Testler: $passedTests/$totalTests');
    print('❌ Başarısız Testler: ${totalTests - passedTests}/$totalTests');

    if (passedTests == totalTests) {
      print('🎉 Tüm testler başarılı!');
    } else {
      print('⚠️ Bazı testler başarısız!');
    }
  }
}

void main() async {
  await ApiTest.runAllTests();
}
