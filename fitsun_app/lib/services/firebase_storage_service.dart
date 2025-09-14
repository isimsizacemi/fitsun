import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Video dosyasını Firebase Storage'a yükler
  static Future<String> uploadVideo({
    required File videoFile,
    required String exerciseId,
    String? customFileName,
  }) async {
    try {
      print('Video yükleme başlatılıyor...');
      print('Dosya yolu: ${videoFile.path}');
      print('Dosya boyutu: ${videoFile.lengthSync()} bytes');
      print('Egzersiz ID: $exerciseId');
      
      // Dosya adını oluştur
      final fileName = customFileName ?? 
          '${exerciseId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      print('Dosya adı: $fileName');
      
      // Storage referansı oluştur
      final Reference ref = _storage
          .ref()
          .child('exercise_videos')
          .child(exerciseId)
          .child(fileName);

      print('Storage referansı oluşturuldu: ${ref.fullPath}');

      // Upload task oluştur
      final UploadTask uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'exerciseId': exerciseId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      print('Upload task oluşturuldu');

      // Upload'u takip et
      final TaskSnapshot snapshot = await uploadTask;
      
      print('Upload tamamlandı');
      
      // Download URL'ini al
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Download URL alındı: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('Video yükleme hatası: $e');
      print('Hata türü: ${e.runtimeType}');
      throw Exception('Video yükleme hatası: $e');
    }
  }

  /// Video dosyasını siler
  static Future<void> deleteVideo(String videoUrl) async {
    try {
      final Reference ref = _storage.refFromURL(videoUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Video silme hatası: $e');
    }
  }

  /// Egzersiz videosunu günceller (eski videoyu siler, yenisini yükler)
  static Future<String> updateVideo({
    required File newVideoFile,
    required String exerciseId,
    String? oldVideoUrl,
    String? customFileName,
  }) async {
    try {
      // Eski videoyu sil
      if (oldVideoUrl != null && oldVideoUrl.isNotEmpty) {
        await deleteVideo(oldVideoUrl);
      }

      // Yeni videoyu yükle
      return await uploadVideo(
        videoFile: newVideoFile,
        exerciseId: exerciseId,
        customFileName: customFileName,
      );
    } catch (e) {
      throw Exception('Video güncelleme hatası: $e');
    }
  }

  /// Egzersiz ID'sine göre tüm videoları listeler
  static Future<List<Reference>> getExerciseVideos(String exerciseId) async {
    try {
      final Reference folderRef = _storage
          .ref()
          .child('exercise_videos')
          .child(exerciseId);
      
      final ListResult result = await folderRef.listAll();
      return result.items;
    } catch (e) {
      throw Exception('Video listesi alma hatası: $e');
    }
  }

  /// Video dosyasının boyutunu kontrol eder (max 100MB)
  static bool isValidVideoSize(File videoFile) {
    const int maxSizeInBytes = 100 * 1024 * 1024; // 100MB
    return videoFile.lengthSync() <= maxSizeInBytes;
  }

  /// Video dosyasının formatını kontrol eder
  static bool isValidVideoFormat(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv'].contains(extension);
  }

  /// Upload progress'ini takip eder
  static Stream<TaskSnapshot> uploadVideoWithProgress({
    required File videoFile,
    required String exerciseId,
    String? customFileName,
  }) {
    final fileName = customFileName ?? 
        '${exerciseId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    
    final Reference ref = _storage
        .ref()
        .child('exercise_videos')
        .child(exerciseId)
        .child(fileName);

    final UploadTask uploadTask = ref.putFile(
      videoFile,
      SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {
          'exerciseId': exerciseId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      ),
    );

    return uploadTask.snapshotEvents;
  }
}
