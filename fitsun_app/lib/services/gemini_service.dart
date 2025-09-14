import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/workout_program.dart';

class GeminiService {
  // Google Gemini AI API URL - Güncel versiyon
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // API Key - yeni key
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
  static Future<WorkoutProgram?> generateWorkoutProgram(UserModel user) async {
    try {
      print('🔥 GeminiService: Program oluşturma başlatılıyor...');

      // Önce kullanıcı profilini Firebase'e kaydet
      print('💾 Kullanıcı profili Firebase\'e kaydediliyor...');
      await saveUserProfile(user);
      print('✅ Profil kaydedildi');

      // Gemini AI ile spor programı oluştur
      print('🤖 Gemini AI ile program oluşturuluyor...');
      final programData = await _generateWithGemini(user);
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
    UserModel user,
  ) async {
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

JSON:
{
  "title": "Program",
  "description": "Kişiselleştirilmiş spor programı",
  "duration": "1 hafta",
  "weeks": [{
    "weekNumber": 1,
    "days": [{
      "dayNumber": 1,
      "dayName": "Gün 1",
      "focus": "Göğüs",
      "exercises": [{
        "name": "Bench Press",
        "sets": 3,
        "reps": 10,
        "restSeconds": 60
      }],
      "estimatedDuration": 45
    }]
  }]
}

Sadece JSON ver.
''';

      print('🌐 Gemini API\'ye istek gönderiliyor...');
      print('🔑 API Key: ${_apiKey.substring(0, 10)}...');
      print('📡 URL: $_geminiApiUrl');

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
          .timeout(const Duration(seconds: 30));

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
            print(
              '🔍 Generated Text Preview: ${generatedText.substring(0, 100)}...',
            );

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
              return parsedData;
            } catch (e) {
              print('❌ JSON parsing hatası: $e');
              print('🔍 Raw text: $generatedText');
              return null;
            }
          } else {
            print('❌ API yanıtında content/parts bulunamadı');
            print('🔍 Finish Reason: ${candidate['finishReason']}');
            return null;
          }
        } else {
          print('❌ API yanıtında candidates bulunamadı');
          return null;
        }
      } else {
        print('❌ Gemini API hatası: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Gemini AI hatası: $e');
      return null;
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
}
