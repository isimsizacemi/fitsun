import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _overallStats;
  List<Map<String, dynamic>>? _achievements;
  Map<String, dynamic>? _weeklyTrends;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Paralel olarak tüm verileri yükle
      final futures = await Future.wait([
        StatisticsService.getOverallStats(userId: userId),
        StatisticsService.getUserAchievements(userId: userId),
        StatisticsService.getWeeklyTrends(userId: userId),
      ]);

      setState(() {
        _overallStats = futures[0] as Map<String, dynamic>;
        _achievements = futures[1] as List<Map<String, dynamic>>;
        _weeklyTrends = futures[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      print('İstatistik yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İstatistikler',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Genel'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trendler'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Başarılar'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverallTab(),
                _buildTrendsTab(),
                _buildAchievementsTab(),
              ],
            ),
    );
  }

  Widget _buildOverallTab() {
    if (_overallStats == null) {
      return const Center(
        child: Text('Veri bulunamadı'),
      );
    }

    final overallScore = _overallStats!['overallScore'] as double;
    final summary = _overallStats!['summary'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genel Skor Kartı
          _buildScoreCard(overallScore),
          const SizedBox(height: 20),

          // Su İstatistikleri
          _buildWaterStatsCard(summary),
          const SizedBox(height: 16),

          // Beslenme İstatistikleri
          _buildNutritionStatsCard(summary),
          const SizedBox(height: 16),

          // Antrenman İstatistikleri
          _buildWorkoutStatsCard(summary),
          const SizedBox(height: 20),

          // Detaylı İstatistikler
          _buildDetailedStatsCard(),
        ],
      ),
    );
  }

  Widget _buildScoreCard(double score) {
    Color scoreColor;
    String scoreText;
    String scoreEmoji;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreText = 'Mükemmel';
      scoreEmoji = '🎉';
    } else if (score >= 60) {
      scoreColor = Colors.blue;
      scoreText = 'İyi';
      scoreEmoji = '👍';
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreText = 'Orta';
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
              'Genel Skor',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${score.toStringAsFixed(1)}/100',
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

  Widget _buildWaterStatsCard(Map<String, dynamic> summary) {
    final totalWater = summary['totalWaterIntake'] as int;
    final averageWater = summary['averageDailyWater'] as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Su Tüketimi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Toplam',
                  '${(totalWater / 1000).toStringAsFixed(1)}L',
                  Colors.blue,
                ),
                _buildStatItem(
                  'Ortalama',
                  '${averageWater.toStringAsFixed(0)}ml',
                  Colors.blue,
                ),
                _buildStatItem(
                  'Hedef',
                  '2.5L',
                  Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStatsCard(Map<String, dynamic> summary) {
    final hasActivePlan = summary['hasActiveDietPlan'] as bool;
    final completionRate = summary['nutritionCompletionRate'] as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Beslenme',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Plan',
                  hasActivePlan ? 'Aktif' : 'Yok',
                  hasActivePlan ? Colors.green : Colors.grey,
                ),
                _buildStatItem(
                  'Tamamlanma',
                  '${completionRate.toStringAsFixed(1)}%',
                  Colors.green,
                ),
                _buildStatItem(
                  'Durum',
                  hasActivePlan ? 'İyi' : 'Plan Gerekli',
                  hasActivePlan ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutStatsCard(Map<String, dynamic> summary) {
    final totalSessions = summary['totalWorkoutSessions'] as int;
    final totalDuration = summary['totalWorkoutDuration'] as int;
    final workoutStreak = summary['workoutStreak'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Antrenman',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Oturum',
                  '$totalSessions',
                  Colors.orange,
                ),
                _buildStatItem(
                  'Süre',
                  '${(totalDuration / 60).toStringAsFixed(1)}s',
                  Colors.orange,
                ),
                _buildStatItem(
                  'Seri',
                  '$workoutStreak gün',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatsCard() {
    final waterStats = _overallStats!['waterStats'] as Map<String, dynamic>;
    final nutritionStats = _overallStats!['nutritionStats'] as Map<String, dynamic>;
    final workoutStats = _overallStats!['workoutStats'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detaylı İstatistikler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailedStatRow('Su - Toplam Gün', '${waterStats['totalDays']}'),
            _buildDetailedStatRow('Su - Ortalama', '${waterStats['averageDailyWater']?.toStringAsFixed(0) ?? 0}ml'),
            _buildDetailedStatRow('Beslenme - Toplam Gün', '${nutritionStats['totalDays'] ?? 0}'),
            _buildDetailedStatRow('Beslenme - Tamamlanma', '${nutritionStats['completionRate']?.toStringAsFixed(1) ?? 0}%'),
            _buildDetailedStatRow('Antrenman - Toplam Oturum', '${workoutStats['totalSessions'] ?? 0}'),
            _buildDetailedStatRow('Antrenman - Ortalama Süre', '${workoutStats['averageDuration']?.toStringAsFixed(1) ?? 0}dk'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_weeklyTrends == null) {
      return const Center(
        child: Text('Trend verisi bulunamadı'),
      );
    }

    final trends = _weeklyTrends!['trends'] as List<Map<String, dynamic>>;
    final analysis = _weeklyTrends!['analysis'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trend Analizi
          _buildTrendAnalysisCard(analysis),
          const SizedBox(height: 20),

          // Haftalık Trendler
          Text(
            'Haftalık Trendler',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...trends.map((trend) => _buildWeekTrendCard(trend)),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysisCard(Map<String, dynamic> analysis) {
    final waterTrend = analysis['waterTrend'] as String;
    final nutritionTrend = analysis['nutritionTrend'] as String;
    final workoutTrend = analysis['workoutTrend'] as String;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analizi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendRow('Su Tüketimi', waterTrend),
            _buildTrendRow('Beslenme', nutritionTrend),
            _buildTrendRow('Antrenman', workoutTrend),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendRow(String label, String trend) {
    String emoji;
    Color color;

    switch (trend) {
      case 'increasing':
        emoji = '📈';
        color = Colors.green;
        break;
      case 'decreasing':
        emoji = '📉';
        color = Colors.red;
        break;
      default:
        emoji = '➡️';
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          Text(
            trend == 'increasing' ? 'Artıyor' : trend == 'decreasing' ? 'Azalıyor' : 'Sabit',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekTrendCard(Map<String, dynamic> trend) {
    final week = trend['week'] as int;
    final water = trend['water'] as Map<String, dynamic>;
    final nutrition = trend['nutrition'] as Map<String, dynamic>;
    final workout = trend['workout'] as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hafta $week',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTrendStatItem('Su', '${water['average'].toStringAsFixed(0)}ml', Colors.blue),
                ),
                Expanded(
                  child: _buildTrendStatItem('Beslenme', '${nutrition['completionRate'].toStringAsFixed(1)}%', Colors.green),
                ),
                Expanded(
                  child: _buildTrendStatItem('Antrenman', '${workout['sessions']} oturum', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    if (_achievements == null || _achievements!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Henüz başarı rozeti yok',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedeflerinizi tamamlayarak rozet kazanın!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _achievements!.length,
      itemBuilder: (context, index) {
        final achievement = _achievements![index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final title = achievement['title'] as String;
    final description = achievement['description'] as String;
    final icon = achievement['icon'] as String;
    final category = achievement['category'] as String;

    Color categoryColor;
    switch (category) {
      case 'water':
        categoryColor = Colors.blue;
        break;
      case 'nutrition':
        categoryColor = Colors.green;
        break;
      case 'workout':
        categoryColor = Colors.orange;
        break;
      default:
        categoryColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [categoryColor.withOpacity(0.1), categoryColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
