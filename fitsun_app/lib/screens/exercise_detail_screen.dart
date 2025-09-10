import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/exercise_detail.dart';
import '../services/exercise_database_service.dart';
import 'video_recording_screen.dart';
import 'video_upload_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final ExerciseDetail? exerciseDetail;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    this.exerciseDetail,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadExerciseDetail();
    _initializeVideo();
  }

  void _loadExerciseDetail() {
    if (widget.exerciseDetail == null) {
      final detail = ExerciseDatabaseService.getExerciseDetail(
        widget.exerciseName,
      );
      if (detail != null) {
        setState(() {
          // ExerciseDetail'i güncelle
        });
      }
    }
  }

  void _initializeVideo() {
    if (widget.exerciseDetail?.videoUrl != null &&
        widget.exerciseDetail!.videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.exerciseDetail!.videoUrl),
      );
      _videoController!.initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
    }
  }

  void _recordVideo() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => VideoRecordingScreen(
          exerciseName: widget.exerciseName,
          onVideoRecorded: (videoPath) {
            // Video kaydedildiğinde yapılacak işlemler
            print('Video kaydedildi: $videoPath');
          },
        ),
      ),
    );

    if (result != null) {
      // Video kaydedildi, kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video kaydedildi: $result'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToVideoUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoUploadScreen(
          exerciseId: widget.exerciseDetail?.id ?? widget.exerciseName,
          exerciseName: widget.exerciseName,
          existingVideoUrl: widget.exerciseDetail?.videoUrl,
        ),
      ),
    ).then((_) {
      // Video yükleme sayfasından dönüldüğünde sayfayı yenile
      _loadExerciseDetail();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () => _navigateToVideoUpload(),
            tooltip: 'Video Yükle',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Favorilere ekleme özelliği
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorilere eklendi!')),
              );
            },
          ),
        ],
      ),
      body: widget.exerciseDetail != null
          ? _buildExerciseDetail()
          : _buildPlaceholder(),
    );
  }

  Widget _buildExerciseDetail() {
    final exercise = widget.exerciseDetail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Bölümü
          if (_isVideoInitialized) _buildVideoPlayer(),
          if (!_isVideoInitialized && exercise.videoUrl.isNotEmpty)
            _buildVideoPlaceholder(),

          const SizedBox(height: 24),

          // Egzersiz Bilgileri
          _buildExerciseInfo(exercise),
          const SizedBox(height: 24),

          // Açıklama
          _buildDescription(exercise),
          const SizedBox(height: 24),

          // Talimatlar
          _buildInstructions(exercise),
          const SizedBox(height: 24),

          // İpuçları
          if (exercise.tips.isNotEmpty) ...[
            _buildTips(exercise),
            const SizedBox(height: 24),
          ],

          // Yaygın Hatalar
          if (exercise.commonMistakes.isNotEmpty) ...[
            _buildCommonMistakes(exercise),
            const SizedBox(height: 24),
          ],

          // Kas Grupları ve Ekipman
          _buildMuscleGroupsAndEquipment(exercise),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Card(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayer(_videoController!),
          ),
          Container(
            color: Colors.black,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isVideoPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      if (_isVideoPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                      _isVideoPlaying = !_isVideoPlaying;
                    });
                  },
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  color: Colors.white,
                  onPressed: () {
                    // Tam ekran özelliği
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Card(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_library, size: 64, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Video yükleniyor...'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _recordVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Video Çek'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToVideoUpload,
                    icon: const Icon(Icons.upload),
                    label: const Text('Video Yükle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(ExerciseDetail exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  _getDifficultyText(exercise.difficulty),
                  Icons.trending_up,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(context, exercise.category, Icons.category),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(ExerciseDetail exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Açıklama',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.instructions,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(ExerciseDetail exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nasıl Yapılır?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.instructions,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTips(ExerciseDetail exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İpuçları',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...exercise.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonMistakes(ExerciseDetail exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yaygın Hatalar',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...exercise.commonMistakes.map(
              (mistake) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(mistake)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupsAndEquipment(ExerciseDetail exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kas Grupları',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.muscleGroups
                  .map(
                    (muscle) => Chip(
                      label: Text(muscle),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Gerekli Ekipman',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.equipment
                  .map(
                    (equip) => Chip(
                      label: Text(equip),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Egzersiz Detayları',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.exerciseName} egzersizinin detayları yakında eklenecek!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return difficulty;
    }
  }
}
