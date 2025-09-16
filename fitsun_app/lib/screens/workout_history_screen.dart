import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/workout_tracking_service.dart';
import '../models/workout_model.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final UserModel userProfile;

  const WorkoutHistoryScreen({super.key, required this.userProfile});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<WorkoutSession> _workoutSessions = [];
  List<Map<String, dynamic>> _simpleWorkoutSessions = [];
  Map<String, dynamic> _workoutStats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkoutData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      // Detaylı antrenman oturumlarını yükle
      final sessions = await WorkoutTrackingService.getUserWorkoutSessions(
        userId: widget.userProfile.id,
        limit: 50,
      );

      // Basit antrenman oturumlarını yükle (workout_program_screen'den)
      final simpleSessions = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userProfile.id)
          .collection('workout_sessions')
          .orderBy('completedAt', descending: true)
          .limit(50)
          .get();

      // Antrenman istatistiklerini yükle
      final stats = await WorkoutTrackingService.getWorkoutStats(
        userId: widget.userProfile.id,
        daysBack: 30,
      );

      setState(() {
        _workoutSessions = sessions;
        _simpleWorkoutSessions = simpleSessions.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
        _workoutStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Antrenman verileri yükleme hatası: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Veriler yüklenirken hata oluştu');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenman Geçmişi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Oturumlar'),
            Tab(icon: Icon(Icons.analytics), text: 'İstatistikler'),
            Tab(icon: Icon(Icons.timeline), text: 'Grafikler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkoutData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSessionsTab(),
                _buildStatsTab(),
                _buildChartsTab(),
              ],
            ),
    );
  }

  Widget _buildSessionsTab() {
    final allSessions = [
      ..._workoutSessions.map((s) => _SessionItem(type: 'detailed', data: s)),
      ..._simpleWorkoutSessions.map(
        (s) => _SessionItem(type: 'simple', data: s),
      ),
    ];

    // Tarihe göre sırala
    allSessions.sort((a, b) {
      final dateA = a.type == 'detailed'
          ? (a.data as WorkoutSession).date
          : DateTime.parse((a.data as Map)['completedAt']);
      final dateB = b.type == 'detailed'
          ? (b.data as WorkoutSession).date
          : DateTime.parse((b.data as Map)['completedAt']);
      return dateB.compareTo(dateA);
    });

    if (allSessions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allSessions.length,
      itemBuilder: (context, index) {
        final session = allSessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(_SessionItem sessionItem) {
    if (sessionItem.type == 'detailed') {
      return _buildDetailedSessionCard(sessionItem.data as WorkoutSession);
    } else {
      return _buildSimpleSessionCard(sessionItem.data as Map<String, dynamic>);
    }
  }

  Widget _buildDetailedSessionCard(WorkoutSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          session.programName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gün: ${session.dayName}'),
            Text(_formatDate(session.date)),
            if (session.isCompleted)
              Text(
                'Süre: ${session.calculatedDuration ?? 0} dakika',
                style: TextStyle(color: Colors.green[600]),
              ),
          ],
        ),
        trailing: session.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.pending, color: Colors.orange),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSessionInfo(session),
                const SizedBox(height: 16),
                const Text(
                  'Egzersizler:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...session.exercises.map(
                  (exercise) => _buildExerciseCard(exercise),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSessionCard(Map<String, dynamic> session) {
    final exercises = session['exercises'] as List<dynamic>;
    final completedAt = DateTime.parse(session['completedAt']);
    final completedExercises = exercises
        .where((e) => e['completed'] == true)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          session['dayName'] ?? 'Antrenman',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odak: ${session['focus'] ?? 'Genel'}'),
            Text(_formatDate(completedAt)),
            Text(
              'Tamamlanan: $completedExercises/${exercises.length} egzersiz',
              style: TextStyle(color: Colors.green[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Egzersizler:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...exercises.map(
                  (exercise) => _buildSimpleExerciseCard(exercise),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(WorkoutSession session) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoChip(
            '${session.totalExercises} Egzersiz',
            Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoChip('${session.totalSets} Set', Icons.repeat),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoChip(
            '${session.completedExercises}/${session.totalExercises}',
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseSession exercise) {
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
                  exercise.exerciseName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${exercise.completedSets}/${exercise.plannedSets} set',
                style: TextStyle(
                  color: exercise.isCompleted ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (exercise.setDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...exercise.setDetails.map((set) => _buildSetDetail(set)),
          ],
        ],
      ),
    );
  }

  Widget _buildSetDetail(SetDetail set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            'Set ${set.setNumber}:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text('${set.reps} tekrar'),
          const SizedBox(width: 8),
          Text('${set.weight} kg'),
          const Spacer(),
          Icon(
            set.isCompleted ? Icons.check_circle : Icons.pending,
            size: 16,
            color: set.isCompleted ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] ?? 'Egzersiz',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${exercise['sets']} x ${exercise['reps']} tekrar'),
                if (exercise['weight'] != null)
                  Text('Ağırlık: ${exercise['weight']} kg'),
              ],
            ),
          ),
          Icon(
            exercise['completed'] == true ? Icons.check_circle : Icons.pending,
            color: exercise['completed'] == true ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genel İstatistikler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genel İstatistikler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    'Toplam Antrenman',
                    '${_workoutStats['totalSessions'] ?? 0}',
                    Icons.fitness_center,
                  ),
                  _buildStatRow(
                    'Tamamlanan Antrenman',
                    '${_workoutStats['completedSessions'] ?? 0}',
                    Icons.check_circle,
                  ),
                  _buildStatRow(
                    'Toplam Süre',
                    '${_workoutStats['totalDuration'] ?? 0} dakika',
                    Icons.timer,
                  ),
                  _buildStatRow(
                    'Ortalama Süre',
                    '${(_workoutStats['averageDuration'] ?? 0).toStringAsFixed(1)} dakika',
                    Icons.schedule,
                  ),
                  _buildStatRow(
                    'Antrenman Serisi',
                    '${_workoutStats['workoutStreak'] ?? 0} gün',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Egzersiz İstatistikleri
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Egzersiz İstatistikleri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    'Toplam Egzersiz',
                    '${_workoutStats['totalExercises'] ?? 0}',
                    Icons.fitness_center,
                  ),
                  _buildStatRow(
                    'Tamamlanan Egzersiz',
                    '${_workoutStats['completedExercises'] ?? 0}',
                    Icons.check_circle,
                  ),
                  _buildStatRow(
                    'Toplam Tekrar',
                    '${_workoutStats['totalReps'] ?? 0}',
                    Icons.repeat,
                  ),
                  _buildStatRow(
                    'Toplam Ağırlık',
                    '${(_workoutStats['totalWeight'] ?? 0).toStringAsFixed(1)} kg',
                    Icons.fitness_center,
                  ),
                  _buildStatRow(
                    'En Yüksek Ağırlık',
                    '${(_workoutStats['maxWeight'] ?? 0).toStringAsFixed(1)} kg',
                    Icons.trending_up,
                    Colors.red,
                  ),
                  if (_workoutStats['mostUsedExercise'] != null)
                    _buildStatRow(
                      'En Çok Yapılan Egzersiz',
                      _workoutStats['mostUsedExercise'],
                      Icons.star,
                      Colors.amber,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Başarı Oranı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Başarı Oranı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_workoutStats['completionRate'] ?? 0) / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (_workoutStats['completionRate'] ?? 0) >= 80
                          ? Colors.green
                          : (_workoutStats['completionRate'] ?? 0) >= 60
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tamamlama Oranı: %${(_workoutStats['completionRate'] ?? 0).toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Antrenman Grafikleri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Haftalık Antrenman Dağılımı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son 7 Gün',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Antrenman Trendi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Antrenman Trendi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTrendChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Son 7 günün verilerini al
    final now = DateTime.now();
    final weeklyData = <String, int>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      weeklyData[dayName] = 0;
    }

    // Antrenman verilerini say
    for (final session in _workoutSessions) {
      final daysDiff = now.difference(session.date).inDays;
      if (daysDiff >= 0 && daysDiff <= 6) {
        final dayName = _getDayName(session.date.weekday);
        weeklyData[dayName] = (weeklyData[dayName] ?? 0) + 1;
      }
    }

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.entries.map((entry) {
          final maxValue = weeklyData.values.reduce((a, b) => a > b ? a : b);
          final height = maxValue > 0 ? (entry.value / maxValue) * 150 : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(entry.key, style: const TextStyle(fontSize: 12)),
              Text(
                '${entry.value}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendChart() {
    // Son 30 günün trendini göster
    final now = DateTime.now();
    final trendData = <String, int>{};

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day}/${date.month}';
      trendData[dateStr] = 0;
    }

    // Antrenman verilerini say
    for (final session in _workoutSessions) {
      final daysDiff = now.difference(session.date).inDays;
      if (daysDiff >= 0 && daysDiff <= 29) {
        final dateStr = '${session.date.day}/${session.date.month}';
        trendData[dateStr] = (trendData[dateStr] ?? 0) + 1;
      }
    }

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trendData.entries.toList().skip(23).map((entry) {
          final maxValue = trendData.values.reduce((a, b) => a > b ? a : b);
          final height = maxValue > 0 ? (entry.value / maxValue) * 150 : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(entry.key, style: const TextStyle(fontSize: 8)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz antrenman kaydınız yok',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk antrenmanınızı yapın ve burada görün!',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Antrenman Yap'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Bugün';
    if (difference == 1) return 'Dün';
    if (difference < 7) return '$difference gün önce';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }
}

class _SessionItem {
  final String type; // 'detailed' or 'simple'
  final dynamic data;

  _SessionItem({required this.type, required this.data});
}
