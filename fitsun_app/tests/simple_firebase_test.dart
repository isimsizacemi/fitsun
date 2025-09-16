import 'dart:convert';
import 'package:http/http.dart' as http;

class SimpleFirebaseTest {
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
    };
  }

  // AI ile spor programı oluştur
  static Future<bool> testCreateWorkoutProgram() async {
    try {
      print('🏋️ AI ile spor programı oluşturuluyor...');
      
      final testUser = createTestUser();
      print('👤 Test kullanıcısı:');
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
      
      // API bilgileri
      const String apiKey = 'AIzaSyBgCodouEn4KYNqFCSLxDOFI-qNE62V8O4';
      const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
      
      final prompt = '''
${testUser['age']} yaş, ${testUser['height']}cm, ${testUser['weight']}kg ${testUser['gender']} için ${testUser['weeklyFrequency']} günlük program.

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
      "duration": "45 dakika"
    }]
  }]
}

Sadece JSON ver.
''';

      print('🤖 AI program oluşturuyor...');
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          final content = candidate['content'];
          
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            final generatedText = content['parts'][0]['text'];
            print('✅ Spor programı başarıyla oluşturuldu!');
            print('📝 Generated Text Length: ${generatedText.length}');
            print('🔍 Generated Text Preview: ${generatedText.substring(0, 200)}...');

            // JSON parsing - markdown kod bloklarını temizle
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
              
              // Program detaylarını göster
              if (parsedData['weeks'] != null && parsedData['weeks'].isNotEmpty) {
                final week = parsedData['weeks'][0];
                if (week['days'] != null) {
                  print('🏋️ Program Detayları:');
                  for (var day in week['days']) {
                    print('  📅 ${day['title']}');
                    print('    💪 Kas Grupları: ${day['muscleGroups']?.join(', ') ?? 'N/A'}');
                    print('    ⏱️ Süre: ${day['duration'] ?? 'N/A'}');
                    if (day['exercises'] != null) {
                      print('    🏋️ Egzersizler:');
                      for (var exercise in day['exercises']) {
                        print('      - ${exercise['name']}: ${exercise['sets']} set x ${exercise['reps']} tekrar');
                      }
                    }
                  }
                }
              }
              
              return true;
            } catch (e) {
              print('❌ JSON parsing hatası: $e');
              print('🔍 Raw text: $generatedText');
              return false;
            }
          } else {
            print('❌ API yanıtında content/parts bulunamadı');
            print('🔍 Finish Reason: ${candidate['finishReason']}');
            return false;
          }
        } else {
          print('❌ API yanıtında candidates bulunamadı');
          return false;
        }
      } else {
        print('❌ API hatası: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Spor programı oluşturma hatası: $e');
      return false;
    }
  }

  // Test çalıştır
  static Future<void> runTest() async {
    print('🚀 Basit Firebase Test Başlatılıyor...\n');
    
    print('=' * 50);
    print('TEST: AI Spor Programı Oluşturma');
    print('=' * 50);
    
    final success = await testCreateWorkoutProgram();
    
    print('\n' + '=' * 50);
    print('TEST SONUÇLARI');
    print('=' * 50);
    
    if (success) {
      print('🎉 Test başarılı!');
      print('✅ AI spor programı oluşturma çalışıyor');
      print('✅ JSON parsing çalışıyor');
      print('✅ Kullanıcı verileri işleniyor');
      print('\n💡 Bu test, Firebase olmadan da AI program oluşturmanın çalıştığını gösteriyor!');
      print('💡 Firebase sadece veri saklama için kullanılıyor.');
    } else {
      print('❌ Test başarısız!');
      print('💡 API key veya internet bağlantısını kontrol edin.');
    }
  }
}

void main() async {
  await SimpleFirebaseTest.runTest();
}
