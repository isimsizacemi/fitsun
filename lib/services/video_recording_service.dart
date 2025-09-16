import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoRecordingService {
  static CameraController? _cameraController;
  static bool _isRecording = false;
  static String? _videoPath;

  // Kamera izinlerini kontrol et
  static Future<bool> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    if (cameraStatus.isDenied) {
      final result = await Permission.camera.request();
      if (result.isDenied) return false;
    }

    if (microphoneStatus.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isDenied) return false;
    }

    return true;
  }

  // Kamerayı başlat
  static Future<CameraController?> initializeCamera() async {
    try {
      // İzinleri kontrol et
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        throw Exception('Kamera ve mikrofon izinleri gerekli');
      }

      // Mevcut kameraları al
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('Kamera bulunamadı');
      }

      // Arka kamera kullan (genellikle daha iyi kalite)
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Kamera kontrolcüsünü oluştur
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      return _cameraController;
    } catch (e) {
      print('❌ Kamera başlatma hatası: $e');
      return null;
    }
  }

  // Video kaydını başlat
  static Future<bool> startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return false;
    }

    try {
      // Video dosya yolunu oluştur
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videoDir = '${appDir.path}/videos';
      await Directory(videoDir).create(recursive: true);
      
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _videoPath = '$videoDir/exercise_video_$timestamp.mp4';

      // Kaydı başlat
      await _cameraController!.startVideoRecording();
      _isRecording = true;
      
      print('🎥 Video kaydı başlatıldı: $_videoPath');
      return true;
    } catch (e) {
      print('❌ Video kaydı başlatma hatası: $e');
      return false;
    }
  }

  // Video kaydını durdur
  static Future<String?> stopRecording() async {
    if (_cameraController == null || !_isRecording) {
      return null;
    }

    try {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      _isRecording = false;
      
      // Video dosyasını taşı
      if (_videoPath != null) {
        await videoFile.saveTo(_videoPath!);
        print('✅ Video kaydı tamamlandı: $_videoPath');
        return _videoPath;
      }
      
      return videoFile.path;
    } catch (e) {
      print('❌ Video kaydı durdurma hatası: $e');
      _isRecording = false;
      return null;
    }
  }

  // Kamerayı serbest bırak
  static Future<void> disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    _isRecording = false;
    _videoPath = null;
  }

  // Kayıt durumunu kontrol et
  static bool get isRecording => _isRecording;

  // Kamera kontrolcüsünü al
  static CameraController? get cameraController => _cameraController;

  // Video dosya yolunu al
  static String? get videoPath => _videoPath;
}
