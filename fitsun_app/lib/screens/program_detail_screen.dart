import 'package:flutter/material.dart';
import '../models/workout_program.dart';
import '../services/program_sharing_service.dart';
import '../services/exercise_database_service.dart';
import 'exercise_detail_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  final WorkoutProgram program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(program.programName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleShareAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'general',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Paylaş'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'whatsapp',
                child: Row(
                  children: [
                    Icon(Icons.message, color: Colors.green),
                    SizedBox(width: 8),
                    Text('WhatsApp'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'instagram',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Instagram'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'twitter',
                child: Row(
                  children: [
                    Icon(Icons.alternate_email, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Twitter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'facebook',
                child: Row(
                  children: [
                    Icon(Icons.facebook, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Facebook'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Kopyala'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Başlığı ve Bilgileri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.programName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      program.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          '${program.durationWeeks} Hafta',
                          Icons.calendar_today,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          _getDifficultyText(program.difficulty),
                          Icons.trending_up,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          '${program.weeklySchedule.length} Gün',
                          Icons.schedule,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Oluşturulma Tarihi: ${_formatDate(program.createdAt)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
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

            ...program.weeklySchedule.map(
              (day) => _buildWorkoutDay(context, day),
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

  Widget _buildWorkoutDay(BuildContext context, WorkoutDay day) {
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
                ...day.exercises.map(
                  (exercise) => _buildExercise(context, exercise),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise(BuildContext context, Exercise exercise) {
    return InkWell(
      onTap: () => _navigateToExerciseDetail(context, exercise),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
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
                Row(
                  children: [
                    Text(
                      '${exercise.sets} x ${exercise.reps}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
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
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Detaylar için dokunun',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Egzersiz detay sayfasına yönlendir
  void _navigateToExerciseDetail(BuildContext context, Exercise exercise) {
    print('🔍 Egzersiz detayı aranıyor: ${exercise.name}');

    final exerciseDetail = ExerciseDatabaseService.getExerciseDetail(
      exercise.name,
    );

    if (exerciseDetail != null) {
      print('✅ Egzersiz detayı bulundu: ${exerciseDetail.name}');
    } else {
      print('❌ Egzersiz detayı bulunamadı: ${exercise.name}');
      print(
        '📋 Mevcut egzersizler: ${ExerciseDatabaseService.getAllExercises().map((e) => e.name).toList()}',
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exerciseName: exercise.name,
          exerciseDetail: exerciseDetail,
        ),
      ),
    );
  }

  // Paylaşma işlemlerini handle et
  static void _handleShareAction(BuildContext context, String action) async {
    final program = (context.widget as ProgramDetailScreen).program;

    try {
      switch (action) {
        case 'general':
          await ProgramSharingService.shareProgram(program);
          break;
        case 'whatsapp':
          await ProgramSharingService.shareToWhatsApp(program);
          break;
        case 'instagram':
          await ProgramSharingService.shareToInstagram(program);
          break;
        case 'twitter':
          await ProgramSharingService.shareToTwitter(program);
          break;
        case 'facebook':
          await ProgramSharingService.shareToFacebook(program);
          break;
        case 'copy':
          await ProgramSharingService.copyProgram(program);
          break;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program ${_getActionText(action)} başarıyla!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _getActionText(String action) {
    switch (action) {
      case 'general':
        return 'paylaşıldı';
      case 'whatsapp':
        return 'WhatsApp\'a gönderildi';
      case 'instagram':
        return 'Instagram\'a gönderildi';
      case 'twitter':
        return 'Twitter\'a gönderildi';
      case 'facebook':
        return 'Facebook\'a gönderildi';
      case 'copy':
        return 'kopyalandı';
      default:
        return 'işlendi';
    }
  }
}
