import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/workout_program.dart';

class ProgramSharingService {
  // Programı sosyal medya ve diğer uygulamalarla paylaş
  static Future<void> shareProgram(WorkoutProgram program) async {
    try {
      final shareText = _generateShareText(program);
      
      await Share.share(
        shareText,
        subject: '${program.programName} - FitSun Spor Programı',
      );
    } catch (e) {
      print('Program paylaşma hatası: $e');
      rethrow;
    }
  }

  // Programı WhatsApp ile paylaş
  static Future<void> shareToWhatsApp(WorkoutProgram program) async {
    try {
      final shareText = _generateShareText(program);
      final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(shareText)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        throw Exception('WhatsApp yüklenmemiş');
      }
    } catch (e) {
      print('WhatsApp paylaşma hatası: $e');
      rethrow;
    }
  }

  // Programı Instagram ile paylaş
  static Future<void> shareToInstagram(WorkoutProgram program) async {
    try {
      final shareText = _generateShareText(program);
      final instagramUrl = 'instagram://story?text=${Uri.encodeComponent(shareText)}';
      
      if (await canLaunchUrl(Uri.parse(instagramUrl))) {
        await launchUrl(Uri.parse(instagramUrl));
      } else {
        // Instagram yoksa web versiyonunu aç
        final webUrl = 'https://www.instagram.com/?text=${Uri.encodeComponent(shareText)}';
        await launchUrl(Uri.parse(webUrl));
      }
    } catch (e) {
      print('Instagram paylaşma hatası: $e');
      rethrow;
    }
  }

  // Programı Twitter ile paylaş
  static Future<void> shareToTwitter(WorkoutProgram program) async {
    try {
      final shareText = _generateShareText(program);
      final twitterUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}';
      
      await launchUrl(Uri.parse(twitterUrl));
    } catch (e) {
      print('Twitter paylaşma hatası: $e');
      rethrow;
    }
  }

  // Programı Facebook ile paylaş
  static Future<void> shareToFacebook(WorkoutProgram program) async {
    try {
      final shareText = _generateShareText(program);
      final facebookUrl = 'https://www.facebook.com/sharer/sharer.php?u=&quote=${Uri.encodeComponent(shareText)}';
      
      await launchUrl(Uri.parse(facebookUrl));
    } catch (e) {
      print('Facebook paylaşma hatası: $e');
      rethrow;
    }
  }

  // Programı kopyala
  static Future<void> copyProgram(WorkoutProgram program) async {
    try {
      final shareText = _generateShareText(program);
      await Share.share(shareText);
    } catch (e) {
      print('Program kopyalama hatası: $e');
      rethrow;
    }
  }

  // Paylaşım metni oluştur
  static String _generateShareText(WorkoutProgram program) {
    final buffer = StringBuffer();
    
    buffer.writeln('🏋️ ${program.programName}');
    buffer.writeln('');
    buffer.writeln('📝 ${program.description}');
    buffer.writeln('');
    buffer.writeln('⏱️ Süre: ${program.durationWeeks} hafta');
    buffer.writeln('💪 Zorluk: ${_getDifficultyText(program.difficulty)}');
    buffer.writeln('📅 Gün sayısı: ${program.weeklySchedule.length} gün');
    buffer.writeln('');
    buffer.writeln('📋 Haftalık Program:');
    
    for (int i = 0; i < program.weeklySchedule.length; i++) {
      final day = program.weeklySchedule[i];
      buffer.writeln('${i + 1}. ${day.dayName} - ${day.focus}');
      
      for (int j = 0; j < day.exercises.length; j++) {
        final exercise = day.exercises[j];
        buffer.writeln('   • ${exercise.name} (${exercise.sets} x ${exercise.reps})');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('📱 FitSun uygulaması ile oluşturuldu');
    buffer.writeln('💪 #FitSun #Spor #Fitness #Workout');
    
    return buffer.toString();
  }

  // Zorluk seviyesi metni
  static String _getDifficultyText(String difficulty) {
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

  // Programı QR kod olarak paylaş (gelecekte eklenebilir)
  static Future<void> shareAsQRCode(WorkoutProgram program) async {
    // QR kod oluşturma özelliği buraya eklenebilir
    throw UnimplementedError('QR kod paylaşımı henüz implement edilmedi');
  }

  // Programı PDF olarak paylaş (gelecekte eklenebilir)
  static Future<void> shareAsPDF(WorkoutProgram program) async {
    // PDF oluşturma özelliği buraya eklenebilir
    throw UnimplementedError('PDF paylaşımı henüz implement edilmedi');
  }
}
