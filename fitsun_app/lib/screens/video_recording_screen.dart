import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../services/video_recording_service.dart';

class VideoRecordingScreen extends StatefulWidget {
  final String exerciseName;
  final Function(String? videoPath)? onVideoRecorded;

  const VideoRecordingScreen({
    super.key,
    required this.exerciseName,
    this.onVideoRecorded,
  });

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _videoPath;
  String? _errorMessage;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final controller = await VideoRecordingService.initializeCamera();
      if (controller != null) {
        setState(() {
          _isInitialized = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Kamera başlatılamadı';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kamera hatası: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    final success = await VideoRecordingService.startRecording();
    if (success) {
      setState(() {
        _isRecording = true;
      });
    } else {
      _showErrorSnackBar('Video kaydı başlatılamadı');
    }
  }

  Future<void> _stopRecording() async {
    final videoPath = await VideoRecordingService.stopRecording();
    setState(() {
      _isRecording = false;
      _videoPath = videoPath;
    });

    if (videoPath != null) {
      _showSuccessSnackBar('Video kaydedildi');
      await _initializeVideoPlayer();
    } else {
      _showErrorSnackBar('Video kaydedilemedi');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _saveVideo() {
    if (_videoPath != null && widget.onVideoRecorded != null) {
      widget.onVideoRecorded!(_videoPath);
      Navigator.pop(context, _videoPath);
    }
  }

  void _discardVideo() {
    if (_videoPath != null) {
      // Video dosyasını sil
      try {
        File(_videoPath!).delete();
      } catch (e) {
        print('Video dosyası silinemedi: $e');
      }
    }
    Navigator.pop(context);
  }

  Widget _buildVideoPlayer() {
    if (_videoPath == null || _videoController == null) {
      return const Center(
        child: Text(
          'Video yükleniyor...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoPath != null) {
      _videoController = VideoPlayerController.file(File(_videoPath!));
      await _videoController!.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    VideoRecordingService.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exerciseName} - Video Çek'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_videoPath != null)
            TextButton(
              onPressed: _saveVideo,
              child: const Text(
                'Kaydet',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (!_isInitialized) {
      return _buildLoadingView();
    }

    if (_videoPath != null) {
      return _buildVideoPreview();
    }

    return _buildCameraView();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
              _initializeCamera();
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Kamera başlatılıyor...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Kamera önizlemesi
        Positioned.fill(
          child: CameraPreview(VideoRecordingService.cameraController!),
        ),

        // Alt kontroller
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Egzersiz adı
                Text(
                  widget.exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Kayıt butonu
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.play_arrow,
                      color: _isRecording ? Colors.white : Colors.red,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Durum metni
                Text(
                  _isRecording ? 'Kaydı Durdur' : 'Kaydı Başlat',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      children: [
        // Video önizlemesi
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _videoPath != null
                ? _buildVideoPlayer()
                : const Center(
                    child: Text(
                      'Video yükleniyor...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ),

        // Alt kontroller
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Video kaydedildi!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // İptal butonu
                  ElevatedButton.icon(
                    onPressed: _discardVideo,
                    icon: const Icon(Icons.delete),
                    label: const Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  // Kaydet butonu
                  ElevatedButton.icon(
                    onPressed: _saveVideo,
                    icon: const Icon(Icons.save),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
