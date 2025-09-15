import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/workout_program.dart';
import '../models/diet_plan.dart';
import 'nutrition_tracking_service.dart';

class GeminiService {
  // Google Gemini AI API URL - Güncel versiyon
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // API Key - güncellenmiş key
  static const String _apiKey = 'AIzaSyBgCodouEn4KYNqFCSLxDOFI-qNE62V8O4';

  // Kullanıcı profilini Firebase'e kaydet
  static Future<bool> saveUserProfile(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());
      return true;
    } catch (e) {
      print('Profil kaydetme hatası: $e');
      return false;
    }
  }

  // Kullanıcı profilini Firebase'den getir
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      print('Profil getirme hatası: $e');
      return null;
    }
  }

  // AI ile spor programı oluştur
  static Future<WorkoutProgram?> generateWorkoutProgram(
    UserModel user, {
    String? customPrompt,
  }) async {
    try {
      print('🔥 GeminiService: Program oluşturma başlatılıyor...');

      // Önce kullanıcı profilini Firebase'e kaydet
      print('💾 Kullanıcı profili Firebase\'e kaydediliyor...');
      await saveUserProfile(user);
      print('✅ Profil kaydedildi');

      // Gemini AI ile spor programı oluştur
      print('🤖 Gemini AI ile program oluşturuluyor...');
      final programData = await _generateWithGemini(
        user,
        customPrompt: customPrompt,
      );
      if (programData == null) {
        print('❌ Gemini AI\'dan veri alınamadı');
        return null;
      }
      print('✅ Gemini AI\'dan veri alındı');

      // Programı Firebase'e kaydet
      final program = WorkoutProgram(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        programName: programData['title'] ?? 'Yeni Program',
        description:
            programData['description'] ?? 'Kişiselleştirilmiş spor programı',
        durationWeeks:
            int.tryParse(
              programData['duration']?.toString().split(' ')[0] ?? '1',
            ) ??
            1,
        difficulty: _determineDifficulty(programData),
        weeklySchedule: _parseWeeklySchedule(programData['weeks']),
        createdAt: DateTime.now(),
        metadata: programData,
      );

      // Firebase'e kaydet - users/{userId}/programs subcollection'ına
      print('💾 Program Firebase\'e kaydediliyor...');
      print('👤 User ID: ${user.id}');
      print('📋 Program ID: ${program.id}');

      if (user.id.isEmpty) {
        print('❌ User ID boş, program kaydedilemiyor');
        throw Exception('User ID boş, program kaydedilemiyor');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .collection('programs')
          .doc(program.id)
          .set(program.toMap());
      print('✅ Program Firebase\'e kaydedildi');

      return program;
    } catch (e) {
      print('Spor programı oluşturma hatası: $e');
      return null;
    }
  }

  // Kullanıcının spor programlarını Firebase'den getir
  static Future<List<WorkoutProgram>> getUserWorkoutPrograms(
    String userId,
  ) async {
    try {
      print('🔍 Firebase\'den programlar getiriliyor... User ID: $userId');

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('programs')
          .orderBy('createdAt', descending: true)
          .get();

      print('📊 Firebase\'den ${snapshot.docs.length} döküman alındı');

      final programs = snapshot.docs.map((doc) {
        print('📝 Döküman ID: ${doc.id}');
        print('📄 Döküman verisi: ${doc.data()}');
        return WorkoutProgram.fromMap(doc.data(), doc.id);
      }).toList();

      print('✅ ${programs.length} program parse edildi');
      return programs;
    } catch (e) {
      print('❌ Programlar getirme hatası: $e');
      return [];
    }
  }

  // Belirli bir spor programını Firebase'den getir
  static Future<WorkoutProgram?> getWorkoutProgram(
    String userId,
    String programId,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('programs')
          .doc(programId)
          .get();

      if (doc.exists) {
        return WorkoutProgram.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Program getirme hatası: $e');
      return null;
    }
  }

  // Program durumunu Firebase'de güncelle
  static Future<bool> updateWorkoutProgramStatus(
    String userId,
    String programId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('programs')
          .doc(programId)
          .update({'status': status});
      return true;
    } catch (e) {
      print('Durum güncelleme hatası: $e');
      return false;
    }
  }

  // Programı Firebase'den sil
  static Future<bool> deleteWorkoutProgram(
    String userId,
    String programId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('programs')
          .doc(programId)
          .delete();
      return true;
    } catch (e) {
      print('Program silme hatası: $e');
      return false;
    }
  }

  // Plans collection'ını otomatik oluştur
  static Future<void> createPlansCollection() async {
    try {
      print('🏋️ Plans Collection oluşturuluyor...');

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
          'createdAt': DateTime.now(),
          'tags': ['kas-geliştirme', 'başlangıç', '4-hafta', 'tam-vücut'],
        },
        {
          'id': 'plan_intermediate_strength',
          'name': 'Orta Seviye Güç Geliştirme',
          'description':
              'Temel hareketleri bilenler için güç geliştirme odaklı program. 6 haftalık yoğun program.',
          'difficulty': 'intermediate',
          'durationWeeks': 6,
          'targetMuscles': ['Tüm Vücut', 'Core', 'Güç'],
          'equipment': [
            'Barbell',
            'Dambıl',
            'Bench',
            'Squat Rack',
            'Kettlebell',
          ],
          'createdBy': 'system',
          'isPublic': true,
          'createdAt': DateTime.now(),
          'tags': ['güç-geliştirme', 'orta-seviye', '6-hafta', 'compound'],
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
          'createdAt': DateTime.now(),
          'tags': ['hipertrofi', 'ileri-seviye', '8-hafta', 'kas-büyütme'],
        },
      ];

      // Her planı Firebase'e ekle
      for (var plan in plans) {
        await FirebaseFirestore.instance
            .collection('plans')
            .doc(plan['id'] as String)
            .set(plan);
        print('✅ Plan eklendi: ${plan['name']}');
      }

      print('🎉 Plans Collection başarıyla oluşturuldu!');
    } catch (e) {
      print('❌ Plans Collection oluşturma hatası: $e');
    }
  }

  // API test fonksiyonu
  static Future<bool> testApiConnection() async {
    try {
      print('🔍 Gemini API test ediliyor...');
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
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

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Gemini API çalışıyor!');
        return true;
      } else {
        print('❌ Gemini API hatası: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Gemini API bağlantı hatası: $e');
      return false;
    }
  }

  // Gemini AI ile spor programı oluştur
  static Future<Map<String, dynamic>?> _generateWithGemini(
    UserModel user, {
    String? customPrompt,
  }) async {
    try {
      print('📝 Prompt oluşturuluyor...');
      final prompt =
          '''
Kullanıcı Profil Bilgileri:
- Yaş: ${user.age} yaş
- Boy: ${user.height} cm
- Kilo: ${user.weight} kg
- Cinsiyet: ${user.gender}
- Hedef: ${user.goal}
- Fitness Seviyesi: ${user.fitnessLevel}
- Yağ Oranı: %${user.bodyFat ?? 'Belirtilmemiş'}
- Kas Kütlesi: ${user.muscleMass ?? 'Belirtilmemiş'} kg
- Deneyim Süresi: ${user.experience ?? 'Belirtilmemiş'}
- Haftalık Antrenman Sıklığı: ${user.weeklyFrequency ?? 3} gün
- Tercih Edilen Antrenman Süresi: ${user.preferredTime ?? '45-60 dakika'}
- Antrenman Yeri: ${user.workoutLocation ?? 'Belirtilmemiş'}
- Mevcut Ekipmanlar: ${user.availableEquipment?.join(', ') ?? 'Yok'}

Bu detaylı kullanıcı profil bilgilerine göre ${user.weeklyFrequency ?? 3} günlük, kişiselleştirilmiş bir spor programı oluştur. Program, kullanıcının fiziksel özelliklerini, hedeflerini, mevcut ekipmanlarını ve deneyim seviyesini dikkate almalıdır.

${customPrompt != null && customPrompt.isNotEmpty ? '''
ÖNEMLİ ÖZEL İSTEKLER:
$customPrompt

Bu özel istekleri MUTLAKA dikkate al:
- Eğer belirli bir günün boş kalması isteniyorsa, o günü "Dinlenme" olarak işaretle ve exercises listesini boş bırak []
- Eğer belirli egzersizler isteniyorsa, sadece o egzersizleri ekle
- Eğer belirli kas grupları odaklanılması isteniyorsa, sadece o kas gruplarına odaklan
- Özel istekler profil bilgilerinden önceliklidir
''' : ''}

JSON Format (SADECE BU FORMATI KULLAN - SAYILAR TIRNAK İÇİNDE OLMASIN):
{
  "title": "Program Adı",
  "description": "Program açıklaması",
  "duration": "1 hafta",
  "weeks": [{
    "weekNumber": 1,
    "days": [
      {
        "dayNumber": 1,
        "dayName": "Pazartesi",
        "focus": "Göğüs",
        "exercises": [
          {
            "name": "Bench Press",
            "sets": 3,
            "reps": 10,
            "restSeconds": 60
          }
        ],
        "estimatedDuration": 45
      },
      {
        "dayNumber": 2,
        "dayName": "Salı",
        "focus": "Dinlenme",
        "exercises": [],
        "estimatedDuration": 0
      }
    ]
  }]
}

ÖNEMLİ KURALLAR:
- TÜM SAYILAR TIRNAK İÇİNDE OLMASIN: "sets": 3 (doğru), "sets": "3" (yanlış)
- ARALIK KULLANMA: "reps": 8-12 (yanlış), "reps": 8 (doğru)
- BOŞ GÜNLER: "exercises": [] (boş liste)
- SADECE BU FORMATI KULLAN, BAŞKA FORMAT KULLANMA

Sadece JSON ver.
''';

      print('🌐 Gemini API\'ye istek gönderiliyor...');
      print('🔑 API Key: ${_apiKey.substring(0, 10)}...');
      print('📡 URL: $_geminiApiUrl');
      print('📝 AI\'ya gönderilen prompt:');
      print('=' * 80);
      print(prompt);
      print('=' * 80);

      final response = await http
          .post(
            Uri.parse('$_geminiApiUrl?key=$_apiKey'),
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
          )
          .timeout(const Duration(seconds: 60));

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        print('✅ Gemini API başarılı yanıt aldı');
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          final content = candidate['content'];

          if (content != null &&
              content['parts'] != null &&
              content['parts'].isNotEmpty) {
            final generatedText = content['parts'][0]['text'];
            print('📝 Generated Text Length: ${generatedText.length}');
            print('🤖 AI\'dan gelen yanıt:');
            print('=' * 80);
            print(generatedText);
            print('=' * 80);

            // AI'dan gelen tam JSON'u ayrıca yazdır
            print('📋 AI\'dan gelen TAM JSON:');
            print('🔸 JSON başlangıcı:');
            print(
              generatedText.substring(
                0,
                generatedText.length > 1000 ? 1000 : generatedText.length,
              ),
            );
            if (generatedText.length > 1000) {
              print('🔸 JSON ortası:');
              int middle = generatedText.length ~/ 2;
              print(generatedText.substring(middle - 500, middle + 500));
              print('🔸 JSON sonu:');
              print(generatedText.substring(generatedText.length - 1000));
            }
            print('📊 AI Yanıt Analizi:');
            print('  - Toplam karakter sayısı: ${generatedText.length}');
            print(
              '  - JSON başlangıcı: ${generatedText.substring(0, generatedText.length > 100 ? 100 : generatedText.length)}...',
            );
            print(
              '  - JSON sonu: ...${generatedText.length > 100 ? generatedText.substring(generatedText.length - 100) : generatedText}',
            );
            print(
              '  - Markdown kod bloğu var mı: ${generatedText.contains('```')}',
            );
            print('  - JSON başlıyor mu: ${generatedText.contains('{')}');
            print('  - JSON bitiyor mu: ${generatedText.contains('}')}');

            // JSON parsing - markdown kod bloklarını temizle
            try {
              String cleanText = generatedText;

              // Markdown kod bloklarını temizle - daha güçlü temizleme
              cleanText = cleanText.replaceAll(RegExp(r'^```(?:json)?\s*'), '');
              cleanText = cleanText.replaceAll(RegExp(r'\s*```$'), '');
              cleanText = cleanText.trim();

              print('🧹 Markdown temizleme sonrası:');
              print(
                cleanText.length > 200
                    ? cleanText.substring(0, 200) + '...'
                    : cleanText,
              );

              print('🔍 Temizleme öncesi JSON:');
              print(
                cleanText.length > 300
                    ? cleanText.substring(0, 300) + '...'
                    : cleanText,
              );

              // AI'nın verdiği geçersiz formatları düzelt
              cleanText = _fixAiJsonFormat(cleanText);

              print('🔍 Format düzeltme sonrası JSON:');
              print(
                cleanText.length > 300
                    ? cleanText.substring(0, 300) + '...'
                    : cleanText,
              );

              // JSON'u tamamlamak için eksik parantezleri ekle
              cleanText = _completeJsonStructure(cleanText);

              print('🔍 Parantez tamamlama sonrası JSON:');
              print(
                cleanText.length > 300
                    ? cleanText.substring(0, 300) + '...'
                    : cleanText,
              );

              final parsedData = jsonDecode(cleanText);
              print('✅ JSON parsing başarılı');
              return parsedData;
            } catch (e) {
              print('❌ JSON parsing hatası: $e');
              print('🔍 Hata detayı:');
              print('  - Hata türü: ${e.runtimeType}');
              print('  - Hata mesajı: $e');
              print('🔍 Raw AI yanıtı (TAM):');
              print('=' * 100);
              print(generatedText);
              print('=' * 100);

              // JSON'u manuel olarak düzeltmeyi dene
              print('🔧 Manuel JSON düzeltme deneniyor...');
              String fixedJson = _manualJsonFix(generatedText);
              if (fixedJson != generatedText) {
                print('✅ Manuel düzeltme yapıldı, tekrar parsing deneniyor...');
                try {
                  final parsedData = jsonDecode(fixedJson);
                  print('✅ Manuel düzeltme ile JSON parsing başarılı!');
                  return parsedData;
                } catch (e2) {
                  print('❌ Manuel düzeltme de başarısız: $e2');
                }
              }

              // Fallback: Basit bir program oluştur
              print('🔄 Fallback program oluşturuluyor...');
              return _createFallbackProgram(user, customPrompt: customPrompt);
            }
          } else {
            print('❌ API yanıtında content/parts bulunamadı');
            print('🔍 Finish Reason: ${candidate['finishReason']}');
            print('🔄 Fallback program oluşturuluyor...');
            return _createFallbackProgram(user, customPrompt: customPrompt);
          }
        } else {
          print('❌ API yanıtında candidates bulunamadı');
          print('🔄 Fallback program oluşturuluyor...');
          return _createFallbackProgram(user, customPrompt: customPrompt);
        }
      } else {
        print('❌ Gemini API hatası: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        print('🔄 Fallback program oluşturuluyor...');
        return _createFallbackProgram(user, customPrompt: customPrompt);
      }
    } catch (e) {
      print('❌ Gemini AI hatası: $e');
      print('🔄 Fallback program oluşturuluyor...');
      return _createFallbackProgram(user, customPrompt: customPrompt);
    }
  }

  // Haftalık programı parse et
  static List<WorkoutDay> _parseWeeklySchedule(List<dynamic>? weeks) {
    if (weeks == null) return [];

    List<WorkoutDay> allDays = [];
    for (var week in weeks) {
      final days = week['days'] as List?;
      if (days != null) {
        for (var day in days) {
          allDays.add(WorkoutDay.fromMap(day));
        }
      }
    }
    return allDays;
  }

  // Zorluk seviyesini belirle
  static String _determineDifficulty(Map<String, dynamic> data) {
    // Kullanıcının fitness seviyesine göre belirle
    final weeks = data['weeks'] as List?;
    if (weeks != null) {
      int totalExercises = 0;
      for (var week in weeks) {
        final days = week['days'] as List?;
        if (days != null) {
          for (var day in days) {
            final exercises = day['exercises'] as List?;
            if (exercises != null) {
              totalExercises += exercises.length;
            }
          }
        }
      }

      if (totalExercises > 20) return 'advanced';
      if (totalExercises > 12) return 'intermediate';
    }
    return 'beginner';
  }

  // JSON yapısını tamamla (eksik parantezleri ekle)
  static String _completeJsonStructure(String jsonText) {
    print('🔧 JSON yapısı tamamlanıyor...');

    // Parantez sayılarını kontrol et
    int openBraces = jsonText.split('{').length - 1;
    int closeBraces = jsonText.split('}').length - 1;
    int openBrackets = jsonText.split('[').length - 1;
    int closeBrackets = jsonText.split(']').length - 1;

    // Eksik kapanış parantezlerini ekle
    while (openBraces > closeBraces) {
      jsonText += '}';
      closeBraces++;
    }

    while (openBrackets > closeBrackets) {
      jsonText += ']';
      closeBrackets++;
    }

    print('✅ JSON yapısı tamamlandı');
    return jsonText;
  }

  // Manuel JSON düzeltme fonksiyonu
  static String _manualJsonFix(String jsonText) {
    print('🔧 Manuel JSON düzeltme başlatılıyor...');

    // 1. Markdown kalıntılarını temizle
    jsonText = jsonText.replaceAll(RegExp(r'^```(?:json)?\s*'), '');
    jsonText = jsonText.replaceAll(RegExp(r'\s*```$'), '');

    // 2. Satır sonlarını temizle
    jsonText = jsonText.replaceAll('\n', ' ').replaceAll('\r', '');

    // 3. Fazla boşlukları temizle
    jsonText = jsonText.replaceAll(RegExp(r'\s+'), ' ');

    // 4. JSON başlangıcını bul
    int jsonStart = jsonText.indexOf('{');
    if (jsonStart > 0) {
      jsonText = jsonText.substring(jsonStart);
    }

    // 5. JSON sonunu bul ve kes
    int lastBrace = jsonText.lastIndexOf('}');
    if (lastBrace > 0) {
      jsonText = jsonText.substring(0, lastBrace + 1);
    }

    // 6. Eksik parantezleri tamamla
    jsonText = _completeJsonStructure(jsonText);

    print('✅ Manuel JSON düzeltme tamamlandı');
    return jsonText.trim();
  }

  // AI'nın verdiği geçersiz JSON formatlarını düzelt
  static String _fixAiJsonFormat(String jsonText) {
    print('🔧 AI JSON formatı düzeltiliyor...');

    // "reps" için tüm olası formatları düzelt
    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"reps":\s*"(\d+)-(\d+)"'), // "8-12"
      (match) => '"reps": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"reps":\s*(\d+)-(\d+)'), // 8-12
      (match) => '"reps": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"reps":\s*"(\d+)"'), // "8"
      (match) => '"reps": ${match.group(1)}',
    );

    // "sets" için tüm olası formatları düzelt
    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"sets":\s*"(\d+)-(\d+)"'), // "3-4"
      (match) => '"sets": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"sets":\s*(\d+)-(\d+)'), // 3-4
      (match) => '"sets": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"sets":\s*"(\d+)"'), // "3"
      (match) => '"sets": ${match.group(1)}',
    );

    // "restSeconds" için de aynı düzeltmeyi yap
    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"restSeconds":\s*"(\d+)-(\d+)"'),
      (match) => '"restSeconds": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"restSeconds":\s*(\d+)-(\d+)'),
      (match) => '"restSeconds": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"restSeconds":\s*"(\d+)"'),
      (match) => '"restSeconds": ${match.group(1)}',
    );

    // "estimatedDuration" için de aynı düzeltmeyi yap
    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"estimatedDuration":\s*"(\d+)-(\d+)"'),
      (match) => '"estimatedDuration": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"estimatedDuration":\s*(\d+)-(\d+)'),
      (match) => '"estimatedDuration": ${match.group(1)}',
    );

    jsonText = jsonText.replaceAllMapped(
      RegExp(r'"estimatedDuration":\s*"(\d+)"'),
      (match) => '"estimatedDuration": ${match.group(1)}',
    );

    print('✅ AI JSON formatı düzeltildi');
    print('🔍 Düzeltilen JSON önizlemesi:');
    print(
      jsonText.length > 500 ? jsonText.substring(0, 500) + '...' : jsonText,
    );
    return jsonText;
  }

  // Fallback program oluştur (AI başarısız olursa)
  static Map<String, dynamic> _createFallbackProgram(
    UserModel user, {
    String? customPrompt,
  }) {
    print('🔄 Fallback program oluşturuluyor...');
    print('👤 Fallback için kullanıcı bilgileri:');
    print('  - Haftalık sıklık: ${user.weeklyFrequency ?? 3} gün');
    print('  - Hedef: ${user.goal ?? 'general_fitness'}');
    print('  - Seviye: ${user.fitnessLevel ?? 'beginner'}');
    if (customPrompt != null && customPrompt.isNotEmpty) {
      print('🎯 Kullanıcının özel istekleri: $customPrompt');
    }

    final weeklyFrequency = user.weeklyFrequency ?? 3;
    final goal = user.goal ?? 'general_fitness';
    final fitnessLevel = user.fitnessLevel ?? 'beginner';

    // Hedef bazlı program adı
    String programTitle = 'Kişiselleştirilmiş Program';
    String description = 'Size özel hazırlanmış spor programı';

    switch (goal) {
      case 'weight_loss':
        programTitle = 'Kilo Verme Programı';
        description = 'Kilo verme hedefli kardiyo ve güç antrenmanı programı';
        break;
      case 'muscle_gain':
        programTitle = 'Kas Geliştirme Programı';
        description = 'Kas kütlesi artırma odaklı güç antrenmanı programı';
        break;
      case 'endurance':
        programTitle = 'Dayanıklılık Programı';
        description = 'Kardiyovasküler dayanıklılık geliştirme programı';
        break;
      case 'general_fitness':
        programTitle = 'Genel Fitness Programı';
        description = 'Genel sağlık ve fitness geliştirme programı';
        break;
    }

    // Haftalık program oluştur
    List<Map<String, dynamic>> days = [];
    List<String> dayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    List<String> focuses = [
      'Üst Vücut',
      'Alt Vücut',
      'Kardiyo',
      'Tam Vücut',
      'Core',
      'Esneklik',
      'Dinlenme',
    ];

    for (int i = 0; i < weeklyFrequency; i++) {
      String dayName = dayNames[i % dayNames.length];
      String focus = focuses[i % focuses.length];

      List<Map<String, dynamic>> exercises = [];

      // Özel istekleri kontrol et - Belirli günleri boş bırak
      bool shouldSkipDay = false;
      if (customPrompt != null && customPrompt.isNotEmpty) {
        String lowerPrompt = customPrompt.toLowerCase();

        // Gün isimleri ve karşılıkları
        Map<String, String> dayMapping = {
          'pazartesi': 'Pazartesi',
          'salı': 'Salı',
          'çarşamba': 'Çarşamba',
          'perşembe': 'Perşembe',
          'cuma': 'Cuma',
          'cumartesi': 'Cumartesi',
          'pazar': 'Pazar',
        };

        // Hangi günün boş bırakılacağını kontrol et
        for (String dayKey in dayMapping.keys) {
          if (lowerPrompt.contains(dayKey) &&
              (lowerPrompt.contains('boş') ||
                  lowerPrompt.contains('dinlen') ||
                  lowerPrompt.contains('atla'))) {
            if (dayName == dayMapping[dayKey]) {
              shouldSkipDay = true;
              print('🎯 $dayName günü özel istek nedeniyle boş bırakılıyor');
              break;
            }
          }
        }

        // Dinlenme günü isteği kontrol et
        if (lowerPrompt.contains('dinlenme') && lowerPrompt.contains('gün')) {
          // Haftalık sıklıktan 1 gün çıkar ve son günü dinlenme yap
          if (i == weeklyFrequency - 1) {
            shouldSkipDay = true;
            print('🎯 Son gün ($dayName) dinlenme günü olarak ayarlandı');
          }
        }
      }

      // Günü atla
      if (shouldSkipDay) {
        days.add({
          'dayNumber': i + 1,
          'dayName': dayName,
          'focus': 'Dinlenme',
          'exercises': [],
          'estimatedDuration': 0,
        });
        continue;
      }

      // Seviye bazlı egzersizler
      if (fitnessLevel == 'beginner') {
        exercises = [
          {'name': 'Push-up', 'sets': 3, 'reps': 8, 'restSeconds': 60},
          {'name': 'Squat', 'sets': 3, 'reps': 10, 'restSeconds': 60},
          {'name': 'Plank', 'sets': 3, 'reps': 30, 'restSeconds': 60},
        ];
      } else if (fitnessLevel == 'intermediate') {
        exercises = [
          {'name': 'Bench Press', 'sets': 4, 'reps': 8, 'restSeconds': 90},
          {'name': 'Squat', 'sets': 4, 'reps': 8, 'restSeconds': 90},
          {'name': 'Deadlift', 'sets': 3, 'reps': 6, 'restSeconds': 120},
          {'name': 'Pull-up', 'sets': 3, 'reps': 6, 'restSeconds': 90},
        ];
      } else {
        exercises = [
          {
            'name': 'Barbell Bench Press',
            'sets': 5,
            'reps': 5,
            'restSeconds': 120,
          },
          {'name': 'Back Squat', 'sets': 5, 'reps': 5, 'restSeconds': 120},
          {'name': 'Deadlift', 'sets': 5, 'reps': 5, 'restSeconds': 180},
          {'name': 'Overhead Press', 'sets': 4, 'reps': 6, 'restSeconds': 120},
          {'name': 'Pull-up', 'sets': 4, 'reps': 8, 'restSeconds': 90},
        ];
      }

      // Antrenman süresi kontrolü
      int estimatedDuration = 45; // Varsayılan süre
      if (customPrompt != null && customPrompt.isNotEmpty) {
        String lowerPrompt = customPrompt.toLowerCase();
        if (lowerPrompt.contains('2 saat') ||
            lowerPrompt.contains('120 dakika')) {
          estimatedDuration = 120;
          print('🎯 Antrenman süresi 2 saat olarak ayarlandı');
        } else if (lowerPrompt.contains('1 saat') ||
            lowerPrompt.contains('60 dakika')) {
          estimatedDuration = 60;
          print('🎯 Antrenman süresi 1 saat olarak ayarlandı');
        } else if (lowerPrompt.contains('1.5 saat') ||
            lowerPrompt.contains('90 dakika')) {
          estimatedDuration = 90;
          print('🎯 Antrenman süresi 1.5 saat olarak ayarlandı');
        }
      }

      days.add({
        'dayNumber': i + 1,
        'dayName': dayName,
        'focus': focus,
        'exercises': exercises,
        'estimatedDuration': shouldSkipDay ? 0 : estimatedDuration,
      });
    }

    final fallbackProgram = {
      'title': programTitle,
      'description': description,
      'duration': '1 hafta',
      'weeks': [
        {'weekNumber': 1, 'days': days},
      ],
    };

    print('✅ Fallback program oluşturuldu:');
    print('📝 Program adı: $programTitle');
    print('📅 Süre: 1 hafta');
    print('🏋️ Gün sayısı: ${days.length}');
    print('🎯 Hedef: $goal');
    print('💪 Seviye: $fitnessLevel');

    return fallbackProgram;
  }

  // Gemini API isteği gönder
  static Future<Map<String, dynamic>?> _makeGeminiRequest(String prompt) async {
    try {
      print('🌐 Gemini API\'ye istek gönderiliyor...');

      final response = await http
          .post(
            Uri.parse('$_geminiApiUrl?key=$_apiKey'),
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
          )
          .timeout(const Duration(seconds: 60));

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ Gemini API hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Gemini API hatası: $e');
      return null;
    }
  }

  // Gemini AI ile diyet planı oluştur
  static Future<DietPlan?> generateDietPlan(
    UserModel user, {
    String? customPrompt,
  }) async {
    try {
      print('🍽️ Gemini AI ile diyet planı oluşturuluyor...');
      print('👤 User ID: ${user.id}');
      print('📋 Hedef: ${user.goal}');

      final prompt =
          '''
Kullanıcı Profil Bilgileri:
- Yaş: ${user.age} yaş
- Boy: ${user.height} cm
- Kilo: ${user.weight} kg
- Cinsiyet: ${user.gender}
- Hedef: ${user.goal}
- Fitness Seviyesi: ${user.fitnessLevel}
- Yağ Oranı: %${user.bodyFat ?? '25'} (ortalama)
- Kas Kütlesi: ${user.muscleMass ?? '35'} kg (ortalama)

Bu kullanıcı profil bilgilerine göre kişiselleştirilmiş bir beslenme planı oluştur. Plan, kullanıcının fiziksel özelliklerini, hedeflerini ve deneyim seviyesini dikkate almalıdır.

${customPrompt != null && customPrompt.isNotEmpty ? '''
🚨 KRİTİK ÖZEL İSTEKLER - MUTLAKA UYGULA:
$customPrompt

⚠️ BU ÖZEL İSTEKLER ÇOK ÖNEMLİ! MUTLAKA DİKKATE AL VE UYGULA!
⚠️ Kullanıcının özel istekleri her şeyden önce gelir!
⚠️ Bu istekleri görmezden gelme, tam olarak uygula!
''' : ''}

Lütfen aşağıdaki JSON formatında yanıt ver. Her gün için detaylı öğünler oluştur (Pazartesi'den Pazar'a kadar). Her gün farklı yemekler ve çeşitlilik olmalı:

🚨 KRİTİK GEREKSİNİMLER - MUTLAKA UYGULA:
1. MUTLAKA tüm 7 gün için öğünler oluştur: Pazartesi, Salı, Çarşamba, Perşembe, Cuma, Cumartesi, Pazar
2. Her gün için en az 5 öğün ekle (Kahvaltı, Ara Öğün, Öğle, Ara Öğün, Akşam)
3. Toplam en az 35 öğün olmalı (7 gün x 5 öğün)
4. Her öğün için "dayName" alanını ekle
5. Her günün öğünleri farklı olmalı - aynı yemekleri tekrarlama
6. JSON'da "meals" array'inde tüm günlerin öğünleri olmalı
7. Eksik gün varsa hata verir - tüm 7 günü mutlaka ekle

⚠️ ÖNEMLİ UYARI: Eğer kullanıcının özel istekleri varsa, onları MUTLAKA öncelikle uygula!
⚠️ Özel istekler her şeyden önce gelir!

{
  "title": "Kişiselleştirilmiş Beslenme Planı",
  "description": "Kullanıcının hedeflerine uygun beslenme planı",
  "duration": 7,
  "targetCalories": 2000,
  "targetProtein": 150.0,
  "targetCarbs": 250.0,
  "targetFat": 65.0,
  "meals": [
    {
      "dayName": "Pazartesi",
      "mealType": "Kahvaltı",
      "foodName": "Yulaf Ezmesi + Meyve",
      "amount": "50g yulaf + 1 muz",
      "calories": 300,
      "protein": 12.0,
      "carbs": 55.0,
      "fat": 6.0,
      "time": "08:00",
      "notes": "Süt ile karıştır, üzerine muz ekle"
    },
    {
      "dayName": "Pazartesi",
      "mealType": "Ara Öğün",
      "foodName": "Yoğurt + Ceviz",
      "amount": "150g yoğurt + 5 ceviz",
      "calories": 180,
      "protein": 8.0,
      "carbs": 12.0,
      "fat": 12.0,
      "time": "10:30",
      "notes": "Doğal yoğurt tercih et"
    },
    {
      "dayName": "Pazartesi",
      "mealType": "Öğle Yemeği",
      "foodName": "Tavuk Göğsü + Bulgur Pilavı",
      "amount": "150g tavuk + 80g bulgur",
      "calories": 450,
      "protein": 50.0,
      "carbs": 35.0,
      "fat": 8.0,
      "time": "13:00",
      "notes": "Izgara tavuk, az yağlı pilav"
    },
    {
      "dayName": "Pazartesi",
      "mealType": "Ara Öğün",
      "foodName": "Elma + Badem",
      "amount": "1 elma + 10 badem",
      "calories": 150,
      "protein": 4.0,
      "carbs": 20.0,
      "fat": 8.0,
      "time": "16:00",
      "notes": "Çiğ badem, kabuklu elma"
    },
    {
      "dayName": "Pazartesi",
      "mealType": "Akşam Yemeği",
      "foodName": "Somon + Sebze",
      "amount": "120g somon + karışık sebze",
      "calories": 320,
      "protein": 40.0,
      "carbs": 0.0,
      "fat": 8.0,
      "time": "19:00",
      "notes": "Izgara veya fırın"
    },
    {
      "dayName": "Pazartesi",
      "mealType": "Gece Atıştırması",
      "foodName": "Yunan Yoğurdu",
      "amount": "150g",
      "calories": 130,
      "protein": 15.0,
      "carbs": 8.0,
      "fat": 5.0,
      "time": "21:00",
      "notes": "Az yağlı"
    },
    {
      "dayName": "Salı",
      "mealType": "Kahvaltı",
      "foodName": "Omlet + Avokado",
      "amount": "3 yumurta + 1/2 avokado",
      "calories": 350,
      "protein": 20.0,
      "carbs": 8.0,
      "fat": 28.0,
      "time": "08:00",
      "notes": "Tereyağı ile pişir"
    },
    {
      "dayName": "Salı",
      "mealType": "Ara Öğün",
      "foodName": "Meyve + Ceviz",
      "amount": "1 elma + 8 ceviz",
      "calories": 200,
      "protein": 5.0,
      "carbs": 25.0,
      "fat": 12.0,
      "time": "10:30",
      "notes": "Doğal meyve"
    },
    {
      "dayName": "Salı",
      "mealType": "Öğle Yemeği",
      "foodName": "Balık + Pilav",
      "amount": "150g balık + 100g pilav",
      "calories": 400,
      "protein": 35.0,
      "carbs": 40.0,
      "fat": 10.0,
      "time": "13:00",
      "notes": "Izgara balık"
    },
    {
      "dayName": "Salı",
      "mealType": "Ara Öğün",
      "foodName": "Yoğurt + Meyve",
      "amount": "200g yoğurt + çilek",
      "calories": 150,
      "protein": 10.0,
      "carbs": 20.0,
      "fat": 4.0,
      "time": "16:00",
      "notes": "Doğal yoğurt"
    },
    {
      "dayName": "Salı",
      "mealType": "Kahvaltı",
      "foodName": "Peynirli Omlet + Ekmek",
      "amount": "3 yumurta + 50g peynir + 2 dilim ekmek",
      "calories": 400,
      "protein": 25.0,
      "carbs": 30.0,
      "fat": 20.0,
      "time": "08:00",
      "notes": "Tereyağı ile pişir"
    },
    {
      "dayName": "Salı",
      "mealType": "Ara Öğün",
      "foodName": "Muz + Fıstık Ezmesi",
      "amount": "1 muz + 1 yemek kaşığı fıstık ezmesi",
      "calories": 180,
      "protein": 6.0,
      "carbs": 30.0,
      "fat": 8.0,
      "time": "10:30",
      "notes": "Doğal fıstık ezmesi"
    },
    {
      "dayName": "Salı",
      "mealType": "Öğle Yemeği",
      "foodName": "Köfte + Pilav",
      "amount": "4 köfte + 100g pilav",
      "calories": 500,
      "protein": 40.0,
      "carbs": 45.0,
      "fat": 15.0,
      "time": "13:00",
      "notes": "Izgara köfte"
    },
    {
      "dayName": "Salı",
      "mealType": "Ara Öğün",
      "foodName": "Yoğurt + Ceviz",
      "amount": "150g yoğurt + 5 ceviz",
      "calories": 180,
      "protein": 8.0,
      "carbs": 12.0,
      "fat": 12.0,
      "time": "16:00",
      "notes": "Doğal yoğurt"
    },
    {
      "dayName": "Salı",
      "mealType": "Akşam Yemeği",
      "foodName": "Et + Salata",
      "amount": "120g et + yeşil salata",
      "calories": 300,
      "protein": 35.0,
      "carbs": 5.0,
      "fat": 12.0,
      "time": "19:00",
      "notes": "Izgara et"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Kahvaltı",
      "foodName": "Yulaf Ezmesi + Meyve",
      "amount": "50g yulaf + 1 muz",
      "calories": 300,
      "protein": 12.0,
      "carbs": 55.0,
      "fat": 6.0,
      "time": "08:00",
      "notes": "Süt ile karıştır"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Ara Öğün",
      "foodName": "Elma + Badem",
      "amount": "1 elma + 10 badem",
      "calories": 150,
      "protein": 4.0,
      "carbs": 20.0,
      "fat": 8.0,
      "time": "10:30",
      "notes": "Çiğ badem"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Öğle Yemeği",
      "foodName": "Tavuk Göğsü + Bulgur Pilavı",
      "amount": "150g tavuk + 80g bulgur",
      "calories": 450,
      "protein": 50.0,
      "carbs": 35.0,
      "fat": 8.0,
      "time": "13:00",
      "notes": "Izgara tavuk"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Ara Öğün",
      "foodName": "Yoğurt + Ceviz",
      "amount": "150g yoğurt + 5 ceviz",
      "calories": 180,
      "protein": 8.0,
      "carbs": 12.0,
      "fat": 12.0,
      "time": "16:00",
      "notes": "Doğal yoğurt"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Akşam Yemeği",
      "foodName": "Somon + Sebze",
      "amount": "120g somon + karışık sebze",
      "calories": 320,
      "protein": 40.0,
      "carbs": 0.0,
      "fat": 8.0,
      "time": "19:00",
      "notes": "Izgara somon"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Ara Öğün",
      "foodName": "Muz + Fıstık Ezmesi",
      "amount": "1 muz + 1 yemek kaşığı fıstık ezmesi",
      "calories": 180,
      "protein": 6.0,
      "carbs": 30.0,
      "fat": 8.0,
      "time": "10:30",
      "notes": "Doğal fıstık ezmesi"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Öğle Yemeği",
      "foodName": "Köfte + Pilav",
      "amount": "4 köfte + 100g pilav",
      "calories": 500,
      "protein": 40.0,
      "carbs": 45.0,
      "fat": 15.0,
      "time": "13:00",
      "notes": "Izgara köfte"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Ara Öğün",
      "foodName": "Yoğurt + Bal",
      "amount": "200g yoğurt + 1 tatlı kaşığı bal",
      "calories": 160,
      "protein": 12.0,
      "carbs": 20.0,
      "fat": 4.0,
      "time": "16:00",
      "notes": "Doğal bal"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Akşam Yemeği",
      "foodName": "Balık + Sebze",
      "amount": "150g balık + karışık sebze",
      "calories": 280,
      "protein": 35.0,
      "carbs": 10.0,
      "fat": 8.0,
      "time": "19:00",
      "notes": "Izgara balık"
    },
    {
      "dayName": "Perşembe",
      "mealType": "Kahvaltı",
      "foodName": "Menemen + Ekmek",
      "amount": "3 yumurta + domates + biber + 2 dilim ekmek",
      "calories": 350,
      "protein": 20.0,
      "carbs": 25.0,
      "fat": 18.0,
      "time": "08:00",
      "notes": "Zeytinyağı ile pişir"
    },
    {
      "dayName": "Perşembe",
      "mealType": "Ara Öğün",
      "foodName": "Elma + Badem",
      "amount": "1 elma + 10 badem",
      "calories": 150,
      "protein": 4.0,
      "carbs": 20.0,
      "fat": 8.0,
      "time": "10:30",
      "notes": "Çiğ badem"
    },
    {
      "dayName": "Perşembe",
      "mealType": "Öğle Yemeği",
      "foodName": "Tavuk Döner + Ayran",
      "amount": "150g tavuk döner + 1 bardak ayran",
      "calories": 450,
      "protein": 45.0,
      "carbs": 25.0,
      "fat": 18.0,
      "time": "13:00",
      "notes": "Az yağlı döner"
    },
    {
      "dayName": "Perşembe",
      "mealType": "Ara Öğün",
      "foodName": "Çilek + Yoğurt",
      "amount": "100g çilek + 150g yoğurt",
      "calories": 120,
      "protein": 8.0,
      "carbs": 15.0,
      "fat": 3.0,
      "time": "16:00",
      "notes": "Doğal çilek"
    },
    {
      "dayName": "Perşembe",
      "mealType": "Akşam Yemeği",
      "foodName": "Et Sote + Bulgur",
      "amount": "120g et + 80g bulgur",
      "calories": 380,
      "protein": 40.0,
      "carbs": 35.0,
      "fat": 10.0,
      "time": "19:00",
      "notes": "Sebzeli et sote"
    },
    {
      "dayName": "Cuma",
      "mealType": "Kahvaltı",
      "foodName": "Pancake + Bal",
      "amount": "3 pancake + 2 yemek kaşığı bal",
      "calories": 320,
      "protein": 12.0,
      "carbs": 50.0,
      "fat": 8.0,
      "time": "08:00",
      "notes": "Tam buğday unu"
    },
    {
      "dayName": "Cuma",
      "mealType": "Ara Öğün",
      "foodName": "Portakal + Ceviz",
      "amount": "1 portakal + 8 ceviz",
      "calories": 200,
      "protein": 5.0,
      "carbs": 25.0,
      "fat": 12.0,
      "time": "10:30",
      "notes": "Taze portakal"
    },
    {
      "dayName": "Cuma",
      "mealType": "Öğle Yemeği",
      "foodName": "Mantı + Yoğurt",
      "amount": "15 adet mantı + yoğurt sosu",
      "calories": 400,
      "protein": 20.0,
      "carbs": 45.0,
      "fat": 12.0,
      "time": "13:00",
      "notes": "Ev yapımı mantı"
    },
    {
      "dayName": "Cuma",
      "mealType": "Ara Öğün",
      "foodName": "Armut + Badem",
      "amount": "1 armut + 10 badem",
      "calories": 180,
      "protein": 5.0,
      "carbs": 25.0,
      "fat": 10.0,
      "time": "16:00",
      "notes": "Olgun armut"
    },
    {
      "dayName": "Cuma",
      "mealType": "Akşam Yemeği",
      "foodName": "Izgara Tavuk + Salata",
      "amount": "150g tavuk + yeşil salata",
      "calories": 300,
      "protein": 45.0,
      "carbs": 8.0,
      "fat": 8.0,
      "time": "19:00",
      "notes": "Baharatlı tavuk"
    },
    {
      "dayName": "Cumartesi",
      "mealType": "Kahvaltı",
      "foodName": "Krep + Meyve",
      "amount": "2 krep + muz + çilek",
      "calories": 350,
      "protein": 15.0,
      "carbs": 45.0,
      "fat": 12.0,
      "time": "09:00",
      "notes": "Hafta sonu kahvaltısı"
    },
    {
      "dayName": "Cumartesi",
      "mealType": "Ara Öğün",
      "foodName": "Kuru İncir + Ceviz",
      "amount": "3 kuru incir + 6 ceviz",
      "calories": 220,
      "protein": 6.0,
      "carbs": 35.0,
      "fat": 10.0,
      "time": "11:00",
      "notes": "Doğal kuru incir"
    },
    {
      "dayName": "Cumartesi",
      "mealType": "Öğle Yemeği",
      "foodName": "Balık Çorbası + Ekmek",
      "amount": "1 kase çorba + 2 dilim ekmek",
      "calories": 380,
      "protein": 25.0,
      "carbs": 40.0,
      "fat": 12.0,
      "time": "13:30",
      "notes": "Ev yapımı çorba"
    },
    {
      "dayName": "Cumartesi",
      "mealType": "Ara Öğün",
      "foodName": "Meyve Salatası",
      "amount": "Karışık meyve + yoğurt",
      "calories": 150,
      "protein": 6.0,
      "carbs": 30.0,
      "fat": 2.0,
      "time": "16:30",
      "notes": "Taze meyveler"
    },
    {
      "dayName": "Cumartesi",
      "mealType": "Akşam Yemeği",
      "foodName": "Et Güveç + Pilav",
      "amount": "120g et + 80g pilav",
      "calories": 420,
      "protein": 35.0,
      "carbs": 40.0,
      "fat": 12.0,
      "time": "19:30",
      "notes": "Sebzeli güveç"
    },
    {
      "dayName": "Pazar",
      "mealType": "Kahvaltı",
      "foodName": "Peynir Tabağı + Zeytin",
      "amount": "Çeşitli peynirler + zeytin + ekmek",
      "calories": 400,
      "protein": 20.0,
      "carbs": 30.0,
      "fat": 22.0,
      "time": "09:30",
      "notes": "Zengin kahvaltı"
    },
    {
      "dayName": "Pazar",
      "mealType": "Ara Öğün",
      "foodName": "Kuru Kayısı + Badem",
      "amount": "5 kuru kayısı + 8 badem",
      "calories": 180,
      "protein": 6.0,
      "carbs": 30.0,
      "fat": 8.0,
      "time": "11:30",
      "notes": "Doğal kurutulmuş meyve"
    },
    {
      "dayName": "Pazar",
      "mealType": "Öğle Yemeği",
      "foodName": "Kuzu Tandır + Bulgur",
      "amount": "150g kuzu + 100g bulgur",
      "calories": 500,
      "protein": 45.0,
      "carbs": 40.0,
      "fat": 15.0,
      "time": "14:00",
      "notes": "Geleneksel tandır"
    },
    {
      "dayName": "Pazar",
      "mealType": "Ara Öğün",
      "foodName": "Meyve + Yoğurt",
      "amount": "Karışık meyve + 200g yoğurt",
      "calories": 160,
      "protein": 10.0,
      "carbs": 25.0,
      "fat": 3.0,
      "time": "17:00",
      "notes": "Hafif ara öğün"
    },
    {
      "dayName": "Pazar",
      "mealType": "Akşam Yemeği",
      "foodName": "Balık Izgara + Sebze",
      "amount": "150g balık + karışık sebze",
      "calories": 280,
      "protein": 35.0,
      "carbs": 12.0,
      "fat": 8.0,
      "time": "20:00",
      "notes": "Hafta sonu balık"
    }
  ]
}

ÖNEMLİ KURALLAR:
1. Sadece JSON formatında yanıt ver, başka açıklama ekleme
2. Kalori hesaplamasını kullanıcının hedefine göre ayarla
3. Protein, karbonhidrat ve yağ oranlarını dengeli tut
4. Her gün için 5-6 öğün planla (Kahvaltı, Ara Öğün, Öğle, Ara Öğün, Akşam, Gece Atıştırması)
5. MUTLAKA tüm 7 gün için öğünler oluştur: Pazartesi, Salı, Çarşamba, Perşembe, Cuma, Cumartesi, Pazar
6. Her öğün için "dayName" alanını ekle (Pazartesi, Salı, Çarşamba, Perşembe, Cuma, Cumartesi, Pazar)
7. Sağlıklı ve besleyici gıdalar seç
8. Türk mutfağına uygun gıdalar öner
9. Her öğün için detaylı miktar bilgisi ver (gram, adet, porsiyon)
10. Besin değerlerini gerçekçi tut
11. Öğün saatlerini mantıklı aralıklarla dağıt
12. Her gün farklı yemekler öner (çeşitlilik)
13. Ara öğünlerde sağlıklı atıştırmalıklar ekle
14. Spor programındaki gibi gün gün detaylı planlar oluştur
15. Her gün için en az 5 öğün ekle
16. Toplam en az 35 öğün olmalı (7 gün x 5 öğün)
17. KRİTİK: Her gün için ayrı ayrı öğünler oluştur - Pazartesi, Salı, Çarşamba, Perşembe, Cuma, Cumartesi, Pazar
18. Her günün öğünleri farklı olmalı - aynı yemekleri tekrarlama
19. JSON'da "meals" array'inde tüm günlerin öğünleri olmalı
20. Eksik gün varsa hata verir - tüm 7 günü mutlaka ekle
''';

      // Prompt'u log'a yaz
      print('📝 Gemini Prompt:');
      print('=' * 80);
      print(prompt);
      print('=' * 80);

      final response = await _makeGeminiRequest(prompt);

      if (response != null) {
        final dietPlan = await _parseDietPlanResponse(response, user);
        if (dietPlan != null) {
          print('✅ Gemini AI diyet planı oluşturuldu');
          return dietPlan;
        }
      }

      print('⚠️ Gemini AI yanıtı işlenemedi, fallback plan oluşturuluyor...');
      return await _createFallbackDietPlan(user);
    } catch (e) {
      print('❌ Gemini AI diyet planı oluşturma hatası: $e');
      return await _createFallbackDietPlan(user);
    }
  }

  // Gemini AI yanıtını diyet planına çevir
  static Future<DietPlan?> _parseDietPlanResponse(
    Map<String, dynamic> response,
    UserModel user,
  ) async {
    try {
      final content =
          response['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (content == null) return null;

      print('📝 Gemini AI Yanıtı: $content');

      // JSON'u temizle ve tamamla
      String cleanJson = content.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      // JSON içindeki yorum satırlarını temizle
      cleanJson = _removeJsonComments(cleanJson);

      // JSON'un tamamlanmamış olup olmadığını kontrol et
      print('🔍 JSON uzunluğu: ${cleanJson.length}');
      print(
        '🔍 JSON son karakterler: ${cleanJson.length > 50 ? cleanJson.substring(cleanJson.length - 50) : cleanJson}',
      );

      // Eğer JSON yarım kaldıysa, manuel olarak tamamla
      if (!cleanJson.endsWith('}') && !cleanJson.endsWith(']')) {
        print('⚠️ JSON yarım kaldı, tamamlanıyor...');
        cleanJson = _completeIncompleteJson(cleanJson);
      }

      final data = jsonDecode(cleanJson) as Map<String, dynamic>;
      print(
        '🔍 Öğün sayısı: ${(data['meals'] as List<dynamic>?)?.length ?? 0}',
      );

      final meals =
          (data['meals'] as List<dynamic>?)
              ?.map(
                (mealData) => Meal.fromMap(mealData as Map<String, dynamic>),
              )
              .toList() ??
          [];

      // Debug: Öğünlerin günlere göre dağılımı
      print('📅 Günlere göre öğün dağılımı:');
      final days = [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar',
      ];
      for (String day in days) {
        final dayMeals = meals.where((meal) => meal.dayName == day).toList();
        print('  $day: ${dayMeals.length} öğün');
        for (var meal in dayMeals) {
          print('    - ${meal.mealType}: ${meal.foodName}');
        }
      }

      final dietPlan = DietPlan(
        id: 'diet_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        title: data['title'] ?? 'Kişiselleştirilmiş Beslenme Planı',
        description:
            data['description'] ?? 'AI tarafından oluşturulan beslenme planı',
        duration: data['duration'] ?? 7,
        targetCalories: data['targetCalories'] ?? 2000,
        targetProtein: (data['targetProtein'] ?? 150.0).toDouble(),
        targetCarbs: (data['targetCarbs'] ?? 250.0).toDouble(),
        targetFat: (data['targetFat'] ?? 65.0).toDouble(),
        isActive: true,
        meals: meals,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Firebase'e otomatik kaydet
      await NutritionTrackingService.createDietPlan(
        userId: user.id,
        title: dietPlan.title,
        description: dietPlan.description,
        duration: dietPlan.duration,
        targetCalories: dietPlan.targetCalories,
        targetProtein: dietPlan.targetProtein,
        targetCarbs: dietPlan.targetCarbs,
        targetFat: dietPlan.targetFat,
        meals: dietPlan.meals,
      );

      return dietPlan;
    } catch (e) {
      print('❌ Diyet planı parse hatası: $e');
      return null;
    }
  }

  // JSON içindeki yorum satırlarını temizle
  static String _removeJsonComments(String json) {
    try {
      // // ile başlayan yorum satırlarını kaldır
      List<String> lines = json.split('\n');
      List<String> cleanLines = [];

      for (String line in lines) {
        String trimmedLine = line.trim();
        // Yorum satırı değilse ve boş değilse ekle
        if (!trimmedLine.startsWith('//') && trimmedLine.isNotEmpty) {
          cleanLines.add(line);
        }
      }

      String cleanedJson = cleanLines.join('\n');
      print('🧹 JSON yorumları temizlendi');
      return cleanedJson;
    } catch (e) {
      print('❌ JSON yorum temizleme hatası: $e');
      return json; // Hata olursa orijinal JSON'u döndür
    }
  }

  // Yarım kalan JSON'u tamamla
  static String _completeIncompleteJson(String incompleteJson) {
    try {
      // JSON'un nerede kaldığını bul
      int lastCompleteMeal = incompleteJson.lastIndexOf('}');
      if (lastCompleteMeal == -1) {
        // Hiç tamamlanmış öğün yok, fallback döndür
        return _getFallbackDietJson();
      }

      // Son tamamlanmış öğünden sonrasını kes
      String completePart = incompleteJson.substring(0, lastCompleteMeal + 1);

      // Eksik kısımları tamamla
      String completedJson = completePart;

      // Eğer meals array'i açıksa kapat
      if (completePart.contains('"meals": [') && !completePart.contains(']')) {
        completedJson += ']';
      }

      // Ana JSON objesini kapat
      if (!completedJson.endsWith('}')) {
        completedJson += '}';
      }

      print('✅ JSON tamamlandı');
      return completedJson;
    } catch (e) {
      print('❌ JSON tamamlama hatası: $e');
      return _getFallbackDietJson();
    }
  }

  // Fallback JSON döndür
  static String _getFallbackDietJson() {
    return '''
{
  "title": "Kişiselleştirilmiş Beslenme Planı",
  "description": "AI tarafından oluşturulan beslenme planı",
  "duration": 7,
  "targetCalories": 2000,
  "targetProtein": 150.0,
  "targetCarbs": 250.0,
  "targetFat": 65.0,
  "meals": [
    {
      "dayName": "Pazartesi",
      "mealType": "Kahvaltı",
      "foodName": "Yulaf Ezmesi + Meyve",
      "amount": "50g yulaf + 1 muz",
      "calories": 300,
      "protein": 12.0,
      "carbs": 55.0,
      "fat": 6.0,
      "time": "08:00",
      "notes": "Süt ile karıştır"
    },
    {
      "dayName": "Salı",
      "mealType": "Kahvaltı",
      "foodName": "Peynirli Omlet + Ekmek",
      "amount": "3 yumurta + 50g peynir + 2 dilim ekmek",
      "calories": 400,
      "protein": 25.0,
      "carbs": 30.0,
      "fat": 20.0,
      "time": "08:00",
      "notes": "Tereyağı ile pişir"
    },
    {
      "dayName": "Çarşamba",
      "mealType": "Kahvaltı",
      "foodName": "Yulaf Ezmesi + Meyve",
      "amount": "50g yulaf + 1 muz",
      "calories": 300,
      "protein": 12.0,
      "carbs": 55.0,
      "fat": 6.0,
      "time": "08:00",
      "notes": "Süt ile karıştır"
    }
  ]
}
''';
  }

  // Fallback diyet planı oluştur
  static Future<DietPlan> _createFallbackDietPlan(UserModel user) async {
    print('🔄 Fallback diyet planı oluşturuluyor...');

    final goal = user.goal ?? 'Genel Fitness';
    final age = user.age ?? 25;
    final weight = user.weight ?? 70.0;
    final height = user.height ?? 170.0;

    // Basit kalori hesaplaması
    double bmr = 0;
    if (user.gender == 'Erkek') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    int targetCalories = (bmr * 1.4).round(); // Hafif aktif
    if (goal.contains('Kilo Verme')) {
      targetCalories = (targetCalories * 0.8).round();
    } else if (goal.contains('Kas Kazanımı')) {
      targetCalories = (targetCalories * 1.2).round();
    }

    final meals = [
      Meal(
        dayName: 'Pazartesi',
        mealType: 'Kahvaltı',
        foodName: 'Yulaf Ezmesi + Muz',
        amount: '50g yulaf + 1 muz',
        calories: 300,
        protein: 12.0,
        carbs: 55.0,
        fat: 6.0,
        time: '08:00',
        notes: 'Süt ile karıştır',
      ),
      Meal(
        dayName: 'Pazartesi',
        mealType: 'Ara Öğün',
        foodName: 'Badem',
        amount: '20g',
        calories: 120,
        protein: 4.0,
        carbs: 4.0,
        fat: 10.0,
        time: '10:00',
        notes: 'Çiğ badem',
      ),
      Meal(
        dayName: 'Pazartesi',
        mealType: 'Öğle Yemeği',
        foodName: 'Tavuk Göğsü + Bulgur',
        amount: '150g tavuk + 80g bulgur',
        calories: 400,
        protein: 50.0,
        carbs: 35.0,
        fat: 8.0,
        time: '13:00',
        notes: 'Izgara tavuk',
      ),
      Meal(
        dayName: 'Pazartesi',
        mealType: 'Ara Öğün',
        foodName: 'Elma',
        amount: '1 adet',
        calories: 80,
        protein: 0.5,
        carbs: 20.0,
        fat: 0.3,
        time: '16:00',
        notes: 'Doğal şeker',
      ),
      Meal(
        dayName: 'Pazartesi',
        mealType: 'Akşam Yemeği',
        foodName: 'Somon + Sebze',
        amount: '120g somon + karışık sebze',
        calories: 350,
        protein: 35.0,
        carbs: 15.0,
        fat: 18.0,
        time: '19:00',
        notes: 'Izgara somon',
      ),
      Meal(
        dayName: 'Pazartesi',
        mealType: 'Gece Atıştırması',
        foodName: 'Yunan Yoğurdu',
        amount: '150g',
        calories: 130,
        protein: 15.0,
        carbs: 8.0,
        fat: 5.0,
        time: '21:00',
        notes: 'Az yağlı',
      ),
    ];

    final fallbackDietPlan = DietPlan(
      id: 'diet_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      title: '$goal Beslenme Planı',
      description: 'AI tarafından oluşturulan temel beslenme planı',
      duration: 7,
      targetCalories: targetCalories,
      targetProtein: (targetCalories * 0.25 / 4).roundToDouble(), // %25 protein
      targetCarbs: (targetCalories * 0.45 / 4)
          .roundToDouble(), // %45 karbonhidrat
      targetFat: (targetCalories * 0.30 / 9).roundToDouble(), // %30 yağ
      isActive: true,
      meals: meals,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Firebase'e otomatik kaydet
    await NutritionTrackingService.createDietPlan(
      userId: user.id,
      title: fallbackDietPlan.title,
      description: fallbackDietPlan.description,
      duration: fallbackDietPlan.duration,
      targetCalories: fallbackDietPlan.targetCalories,
      targetProtein: fallbackDietPlan.targetProtein,
      targetCarbs: fallbackDietPlan.targetCarbs,
      targetFat: fallbackDietPlan.targetFat,
      meals: fallbackDietPlan.meals,
    );

    print('✅ Fallback diyet planı oluşturuldu:');
    print('📝 Plan adı: ${fallbackDietPlan.title}');
    print('📅 Süre: ${fallbackDietPlan.duration} gün');
    print('🎯 Hedef kalori: ${fallbackDietPlan.targetCalories}');
    print('🍽️ Öğün sayısı: ${meals.length}');

    return fallbackDietPlan;
  }
}
