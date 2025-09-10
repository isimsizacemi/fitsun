import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import '../services/firebase_storage_service.dart';
import '../services/exercise_database_service.dart';
import '../models/exercise_detail.dart';

class VideoUploadScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String? existingVideoUrl;

  const VideoUploadScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    this.existingVideoUrl,
  });

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  File? _selectedVideo;
  VideoPlayerController? _previewController;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;
  String? _uploadedVideoUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingVideo();
  }

  void _loadExistingVideo() {
    if (widget.existingVideoUrl != null && widget.existingVideoUrl!.isNotEmpty) {
      _uploadedVideoUrl = widget.existingVideoUrl;
    }
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        
        // Video formatını kontrol et
        if (!FirebaseStorageService.isValidVideoFormat(file.path)) {
          _showErrorSnackBar('Desteklenmeyen video formatı. Lütfen MP4, MOV, AVI veya MKV formatında bir video seçin.');
          return;
        }

        // Video boyutunu kontrol et
        if (!FirebaseStorageService.isValidVideoSize(file)) {
          _showErrorSnackBar('Video dosyası çok büyük. Maksimum 100MB olmalıdır.');
          return;
        }

        setState(() {
          _selectedVideo = file;
          _uploadError = null;
        });

        // Video önizlemesi için controller oluştur
        _previewController?.dispose();
        _previewController = VideoPlayerController.file(file);
        await _previewController!.initialize();
        setState(() {});
      }
    } catch (e) {
      _showErrorSnackBar('Video seçme hatası: $e');
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    try {
      // Upload progress'ini takip et
      final uploadStream = FirebaseStorageService.uploadVideoWithProgress(
        videoFile: _selectedVideo!,
        exerciseId: widget.exerciseId,
      );

      uploadStream.listen(
        (snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        },
        onError: (error) {
          setState(() {
            _uploadError = 'Upload hatası: $error';
            _isUploading = false;
          });
        },
      );

      // Upload'u bekle
      final videoUrl = await FirebaseStorageService.uploadVideo(
        videoFile: _selectedVideo!,
        exerciseId: widget.exerciseId,
      );

      setState(() {
        _uploadedVideoUrl = videoUrl;
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      // Egzersiz veritabanını güncelle
      await _updateExerciseVideo(videoUrl);

      _showSuccessSnackBar('Video başarıyla yüklendi!');
    } catch (e) {
      setState(() {
        _uploadError = 'Upload hatası: $e';
        _isUploading = false;
      });
    }
  }

  Future<void> _updateExerciseVideo(String videoUrl) async {
    try {
      // Egzersiz veritabanını güncelle
      ExerciseDatabaseService.updateExerciseVideo(widget.exerciseId, videoUrl);
      print('Video URL güncellendi: $videoUrl');
    } catch (e) {
      print('Veritabanı güncelleme hatası: $e');
    }
  }

  Future<void> _deleteVideo() async {
    if (_uploadedVideoUrl == null) return;

    try {
      await FirebaseStorageService.deleteVideo(_uploadedVideoUrl!);
      
      setState(() {
        _uploadedVideoUrl = null;
        _selectedVideo = null;
      });

      _previewController?.dispose();
      _previewController = null;

      _showSuccessSnackBar('Video silindi!');
    } catch (e) {
      _showErrorSnackBar('Video silme hatası: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exerciseName} - Video Yükle'),
        actions: [
          if (_uploadedVideoUrl != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteVideo,
              tooltip: 'Videoyu Sil',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mevcut video
            if (_uploadedVideoUrl != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Mevcut Video',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bu egzersiz için zaten bir video yüklenmiş.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Video seçimi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video Seç',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Egzersiz hareketinin nasıl yapıldığını gösteren bir video seçin.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    
                    // Video önizlemesi
                    if (_selectedVideo != null && _previewController != null) ...[
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: _previewController!.value.aspectRatio,
                            child: VideoPlayer(_previewController!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Video seç butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickVideo,
                        icon: const Icon(Icons.video_library),
                        label: Text(_selectedVideo != null ? 'Farklı Video Seç' : 'Video Seç'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Upload butonu
            if (_selectedVideo != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadVideo,
                  icon: _isUploading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Yükleniyor...' : 'Videoyu Yükle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload progress
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_uploadProgress * 100).toInt()}% yüklendi',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],

            // Hata mesajı
            if (_uploadError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Başarı mesajı
            if (_uploadedVideoUrl != null && !_isUploading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Video başarıyla yüklendi!',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
