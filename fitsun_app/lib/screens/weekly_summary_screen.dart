import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/weekly_summary_service.dart';

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  bool _isLoading = true;
  List<WeeklySummary> _summaries = [];
  WeeklySummary? _currentWeekSummary;

  @override
  void initState() {
    super.initState();
    _loadWeeklySummaries();
  }

  Future<void> _loadWeeklySummaries() async {
    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Geçmiş haftalık özetleri oluştur
      await WeeklySummaryService.generatePastWeeklySummaries(userId: userId);

      // Haftalık özetleri getir
      final summaries = await WeeklySummaryService.getUserWeeklySummaries(
        userId: userId,
        limit: 8,
      );

      setState(() {
        _summaries = summaries;
        _currentWeekSummary = summaries.isNotEmpty ? summaries.first : null;
        _isLoading = false;
      });
    } catch (e) {
      print('Haftalık özet yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Haftalık Özetler',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeeklySummaries,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
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
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz haftalık özet yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bir hafta boyunca aktivite yaptıktan sonra\nözetlerinizi burada görebilirsiniz',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bu Hafta Özeti
          if (_currentWeekSummary != null) ...[
            _buildCurrentWeekCard(_currentWeekSummary!),
            const SizedBox(height: 20),
          ],

          // Geçmiş Haftalar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Geçmiş Haftalar',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._summaries
              .skip(1)
              .map((summary) => _buildWeekSummaryCard(summary)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentWeekCard(WeeklySummary summary) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                _getScoreColor(summary.overallScore).withOpacity(0.1),
                _getScoreColor(summary.overallScore).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('📅', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Bu Hafta',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(summary.overallScore),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${summary.overallScore.toStringAsFixed(1)}/100',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                summary.weekFormatted,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildWeeklyStats(summary),
              const SizedBox(height: 20),
              if (summary.achievements.isNotEmpty) ...[
                _buildAchievementsSection(summary.achievements),
                const SizedBox(height: 16),
              ],
              if (summary.insights.isNotEmpty) ...[
                _buildInsightsSection(summary.insights),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSummaryCard(WeeklySummary summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showWeekDetails(summary),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      summary.weekFormatted,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(
                          summary.overallScore,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${summary.overallScore.toStringAsFixed(1)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(summary.overallScore),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatItem(
                        '💧',
                        'Su',
                        '${(summary.waterData['average'] as double).toStringAsFixed(0)}ml',
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStatItem(
                        '🍽️',
                        'Beslenme',
                        '${(summary.nutritionData['completionRate'] as double).toStringAsFixed(1)}%',
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStatItem(
                        '🏋️',
                        'Antrenman',
                        '${summary.workoutData['days']} gün',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                if (summary.achievements.isNotEmpty ||
                    summary.insights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (summary.achievements.isNotEmpty) ...[
                        const Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.achievements.length} başarı',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.amber[700],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (summary.insights.isNotEmpty) ...[
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.insights.length} içgörü',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStats(WeeklySummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Su Tüketimi',
            '${(summary.waterData['average'] as double).toStringAsFixed(0)}ml',
            '${summary.waterData['days']} gün',
            Colors.blue,
            Icons.water_drop,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Beslenme',
            '${(summary.nutritionData['completionRate'] as double).toStringAsFixed(1)}%',
            '${summary.nutritionData['days']} gün',
            Colors.green,
            Icons.restaurant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Antrenman',
            '${summary.workoutData['sessions']} oturum',
            '${summary.workoutData['days']} gün',
            Colors.orange,
            Icons.fitness_center,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Bu Haftanın Başarıları',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...achievements.map(
          (achievement) => _buildAchievementItem(achievement),
        ),
      ],
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            achievement['icon'] as String,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  achievement['description'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(List<Map<String, dynamic>> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              'İçgörüler',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _buildInsightItem(insight)),
      ],
    );
  }

  Widget _buildInsightItem(Map<String, dynamic> insight) {
    final type = insight['type'] as String;
    final isPositive = type == 'positive';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(insight['icon'] as String, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                Text(
                  insight['description'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  void _showWeekDetails(WeeklySummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWeekDetailsModal(summary),
    );
  }

  Widget _buildWeekDetailsModal(WeeklySummary summary) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.weekFormatted,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildWeeklyStats(summary),
                const SizedBox(height: 20),
                if (summary.achievements.isNotEmpty) ...[
                  _buildAchievementsSection(summary.achievements),
                  const SizedBox(height: 20),
                ],
                if (summary.insights.isNotEmpty) ...[
                  _buildInsightsSection(summary.insights),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
