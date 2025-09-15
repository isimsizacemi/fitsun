import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/statistics_service.dart';
import '../services/water_tracking_service.dart';
import '../services/workout_tracking_service.dart';

class DailyTrackingScreen extends StatefulWidget {
  const DailyTrackingScreen({super.key});

  @override
  State<DailyTrackingScreen> createState() => _DailyTrackingScreenState();
}

class _DailyTrackingScreenState extends State<DailyTrackingScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dailyScores;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyScores();
  }

  Future<void> _loadDailyScores() async {
    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final scores = await StatisticsService.getDailyActivityScores(
        userId: userId,
        date: _selectedDate,
      );

      setState(() {
        _dailyScores = scores;
        _isLoading = false;
      });
    } catch (e) {
      print('Günlük skor yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadDailyScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük Takip',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDailyScores,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dailyScores == null
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.today_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Günlük veri bulunamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu tarih için aktivite verisi yok',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final scores = _dailyScores!['scores'] as Map<String, dynamic>;
    final goals = _dailyScores!['goals'] as Map<String, dynamic>;
    final summary = _dailyScores!['summary'] as Map<String, dynamic>;
    final achievements = _dailyScores!['achievements'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih Seçici
          _buildDateSelector(),
          const SizedBox(height: 20),

          // Genel Skor Kartı
          _buildOverallScoreCard(scores['overall'] as double),
          const SizedBox(height: 20),

          // Aktivite Kartları
          _buildActivityCards(scores, goals, summary),
          const SizedBox(height: 20),

          // Başarılar
          if (achievements.isNotEmpty) ...[
            _buildAchievementsSection(achievements),
            const SizedBox(height: 20),
          ],

          // Hızlı Eylemler
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seçilen Tarih',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.edit),
              label: const Text('Değiştir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(double overallScore) {
    Color scoreColor;
    String scoreText;
    String scoreEmoji;

    if (overallScore >= 80) {
      scoreColor = Colors.green;
      scoreText = 'Mükemmel Gün!';
      scoreEmoji = '🎉';
    } else if (overallScore >= 60) {
      scoreColor = Colors.blue;
      scoreText = 'İyi Gün';
      scoreEmoji = '👍';
    } else if (overallScore >= 40) {
      scoreColor = Colors.orange;
      scoreText = 'Orta Gün';
      scoreEmoji = '📈';
    } else {
      scoreColor = Colors.red;
      scoreText = 'Geliştirilebilir';
      scoreEmoji = '💪';
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              scoreEmoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Günlük Skor',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${overallScore.toStringAsFixed(1)}/100',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scoreText,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCards(
    Map<String, dynamic> scores,
    Map<String, dynamic> goals,
    Map<String, dynamic> summary,
  ) {
    return Column(
      children: [
        // Su Kartı
        _buildActivityCard(
          'Su Tüketimi',
          '💧',
          scores['water'] as double,
          goals['water'] as Map<String, dynamic>,
          summary['waterAmount'] as int,
          summary['waterTarget'] as int,
          Colors.blue,
        ),
        const SizedBox(height: 16),

        // Beslenme Kartı
        _buildActivityCard(
          'Beslenme',
          '🍽️',
          scores['nutrition'] as double,
          goals['nutrition'] as Map<String, dynamic>?,
          summary['nutritionCompleted'] as int,
          summary['nutritionTotal'] as int,
          Colors.green,
        ),
        const SizedBox(height: 16),

        // Antrenman Kartı
        _buildActivityCard(
          'Antrenman',
          '🏋️',
          scores['workout'] as double,
          goals['workout'] as Map<String, dynamic>?,
          summary['workoutDuration'] as int,
          60, // 1 saat hedef
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String emoji,
    double score,
    Map<String, dynamic>? goal,
    int current,
    int target,
    Color color,
  ) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final goalStatus = goal?['status'] as String? ?? 'unknown';
    final goalMessage = goal?['message'] as String? ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(1)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // İlerleme Çubuğu
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            
            // İlerleme Bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$current / $target',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
            
            // Hedef Durumu
            if (goalMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getGoalStatusColor(goalStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      goal?['emoji'] as String? ?? '📊',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goalMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _getGoalStatusColor(goalStatus),
                        ),
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

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Günlük Başarılar',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.1),
                Colors.amber.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Text(
                achievement['icon'] as String,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Eylemler',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Su Ekle',
                Icons.add,
                Colors.blue,
                () => _addWater(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                'Beslenme',
                Icons.restaurant,
                Colors.green,
                () => _addNutrition(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                'Antrenman',
                Icons.fitness_center,
                Colors.orange,
                () => _addWorkout(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGoalStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'almost':
        return Colors.blue;
      case 'good':
        return Colors.blue;
      case 'low':
        return Colors.orange;
      case 'very_low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addWater() {
    // Su ekleme dialog'u
    showDialog(
      context: context,
      builder: (context) => _buildWaterDialog(),
    );
  }

  Widget _buildWaterDialog() {
    int amount = 250;
    
    return AlertDialog(
      title: Text(
        'Su Ekle',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ne kadar su içtin?',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: amount.toDouble(),
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: '${amount}ml',
                  onChanged: (value) {
                    setState(() {
                      amount = value.round();
                    });
                  },
                ),
              ),
              Text(
                '${amount}ml',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _addWaterIntake(amount);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  Future<void> _addWaterIntake(int amount) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null || userId.isEmpty) return;

      await WaterTrackingService.addWaterIntake(
        userId: userId,
        amount: amount,
      );

      _loadDailyScores();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${amount}ml su eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNutrition() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Beslenme ekleme özelliği yakında!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _addWorkout() {
    showDialog(
      context: context,
      builder: (context) => _buildWorkoutDialog(),
    );
  }

  Widget _buildWorkoutDialog() {
    return AlertDialog(
      title: Text(
        'Antrenman Ekle',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bugün hangi antrenmanı yaptın?',
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToWorkoutPrograms();
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Antrenman Programı'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _addQuickWorkout();
            },
            icon: const Icon(Icons.add),
            label: const Text('Hızlı Antrenman'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
      ],
    );
  }

  void _navigateToWorkoutPrograms() {
    // Antrenman programları ekranına git
    Navigator.pushNamed(context, '/workout-programs');
  }

  void _addQuickWorkout() {
    // Hızlı antrenman ekleme dialog'u
    showDialog(
      context: context,
      builder: (context) => _buildQuickWorkoutDialog(),
    );
  }

  Widget _buildQuickWorkoutDialog() {
    return _QuickWorkoutDialog(
      onSave: _saveQuickWorkout,
    );
  }

  Future<void> _saveQuickWorkout(String exerciseName, int duration) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null || userId.isEmpty) return;

      // Basit bir antrenman oturumu oluştur
      final sessionId = await WorkoutTrackingService.startWorkoutSession(
        userId: userId,
        programId: 'quick_workout',
        programName: 'Hızlı Antrenman',
        dayName: 'Hızlı Antrenman',
        dayNumber: 1,
        date: _selectedDate,
      );

      // Antrenmanı tamamla
      await WorkoutTrackingService.completeWorkoutSession(
        sessionId: sessionId,
        notes: '$exerciseName - ${duration} dakika',
      );

      _loadDailyScores();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$exerciseName antrenmanı eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _QuickWorkoutDialog extends StatefulWidget {
  final Function(String exerciseName, int duration) onSave;

  const _QuickWorkoutDialog({required this.onSave});

  @override
  State<_QuickWorkoutDialog> createState() => _QuickWorkoutDialogState();
}

class _QuickWorkoutDialogState extends State<_QuickWorkoutDialog> {
  final exerciseController = TextEditingController();
  int duration = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Hızlı Antrenman',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: exerciseController,
            decoration: const InputDecoration(
              labelText: 'Egzersiz Adı',
              hintText: 'Örn: Push-up, Squat',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Süre: ${duration} dakika',
            style: GoogleFonts.poppins(),
          ),
          Slider(
            value: duration.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '${duration} dakika',
            onChanged: (value) {
              setState(() {
                duration = value.round();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (exerciseController.text.isNotEmpty) {
              Navigator.pop(context);
              widget.onSave(exerciseController.text, duration);
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    exerciseController.dispose();
    super.dispose();
  }
}
