import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/workout_program.dart';
import '../services/gemini_service.dart';

class WorkoutProgramScreen extends StatefulWidget {
  final UserModel userProfile;

  const WorkoutProgramScreen({super.key, required this.userProfile});

  @override
  State<WorkoutProgramScreen> createState() => _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends State<WorkoutProgramScreen> {
  WorkoutProgram? _workoutProgram;
  bool _isLoading = false;

  Future<void> _generateWorkoutProgram() async {
    setState(() => _isLoading = true);

    print('🚀 Program oluşturma başlatılıyor...');
    print('👤 Kullanıcı: ${widget.userProfile.name}');
    print('🎯 Hedef: ${widget.userProfile.goal}');
    print('💪 Seviye: ${widget.userProfile.fitnessLevel}');

    try {
      final program = await GeminiService.generateWorkoutProgram(
        widget.userProfile,
      );

      if (program != null) {
        print('✅ Program başarıyla oluşturuldu!');
        print('📝 Program adı: ${program.programName}');
        print('📅 Süre: ${program.durationWeeks} hafta');
        print('🏋️ Gün sayısı: ${program.weeklySchedule.length}');

        setState(() => _workoutProgram = program);
        _showSuccessSnackBar('🎉 Program başarıyla oluşturuldu!');

        // Ana ekrana dön ve programları yenile
        Navigator.pop(context, true);
      } else {
        print('❌ Program oluşturulamadı');
        _showErrorSnackBar('❌ Program oluşturulamadı. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      print('💥 Program oluşturma hatası: $e');
      if (e.toString().contains('TimeoutException')) {
        _showErrorSnackBar('⏰ AI yanıt vermedi (30s timeout). Tekrar deneyin.');
      } else {
        _showErrorSnackBar('💥 Hata: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
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

  Future<void> _testApiConnection() async {
    setState(() => _isLoading = true);

    try {
      final isWorking = await GeminiService.testApiConnection();
      if (isWorking) {
        _showSuccessSnackBar('✅ API çalışıyor! Program oluşturabilirsiniz.');
      } else {
        _showErrorSnackBar(
          '❌ API çalışmıyor. Lütfen internet bağlantınızı kontrol edin.',
        );
      }
    } catch (e) {
      _showErrorSnackBar('❌ Test hatası: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPlansCollection() async {
    setState(() => _isLoading = true);

    try {
      await GeminiService.createPlansCollection();
      _showSuccessSnackBar('✅ Plans Collection oluşturuldu!');
    } catch (e) {
      _showErrorSnackBar(
        '❌ Plans Collection oluşturma hatası: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spor Programı')),
      body: _workoutProgram == null
          ? _buildGenerateScreen()
          : _buildProgramScreen(),
    );
  }

  Widget _buildGenerateScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Kişiselleştirilmiş Spor Programınız',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'AI teknolojisi kullanarak, profil bilgilerinize göre özel bir spor programı oluşturalım.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // API Test Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _testApiConnection,
              icon: const Icon(Icons.bug_report),
              label: const Text('API Test Et'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Plans Collection Oluştur Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _createPlansCollection,
              icon: const Icon(Icons.library_books),
              label: const Text('Plans Collection Oluştur'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateWorkoutProgram,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isLoading ? 'AI Program Oluşturuyor...' : 'Program Oluştur',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Text(
              'AI sizin için özel program hazırlıyor...\nBu işlem 10-30 saniye sürebilir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgramScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Başlığı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _workoutProgram!.programName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _workoutProgram!.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${_workoutProgram!.durationWeeks} Hafta',
                        Icons.calendar_today,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        _getDifficultyText(_workoutProgram!.difficulty),
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Yeniden Oluştur Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _generateWorkoutProgram,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _isLoading
                    ? 'Yeniden Oluşturuluyor...'
                    : 'Yeni Program Oluştur',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Haftalık Program
          Text(
            'Haftalık Program',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ..._workoutProgram!.weeklySchedule.map(
            (day) => _buildWorkoutDay(day),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildWorkoutDay(WorkoutDay day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          day.dayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(day.focus),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (day.estimatedDuration != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tahmini Süre: ${day.estimatedDuration} dakika',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (day.notes != null && day.notes!.isNotEmpty) ...[
                  Text(
                    'Notlar: ${day.notes}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Egzersizler:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...day.exercises.map((exercise) => _buildExercise(exercise)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${exercise.sets} x ${exercise.reps}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (exercise.weight != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ağırlık: ${exercise.weight}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (exercise.restSeconds != null) ...[
            const SizedBox(height: 4),
            Text(
              'Dinlenme: ${exercise.restSeconds} saniye',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Not: ${exercise.notes}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
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
