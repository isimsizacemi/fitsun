import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/water_tracking_service.dart';
import '../services/local_water_service.dart';

class DailyTrackingScreen extends StatefulWidget {
  const DailyTrackingScreen({super.key});

  @override
  State<DailyTrackingScreen> createState() => _DailyTrackingScreenState();
}

class _DailyTrackingScreenState extends State<DailyTrackingScreen> {
  Map<String, dynamic>? _todayWaterData;
  bool _isLoading = true;
  final TextEditingController _waterAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodayWaterData();
  }

  @override
  void dispose() {
    _waterAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayWaterData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId != null) {
        final waterData = await WaterTrackingService.getDailyWaterIntake(
          userId,
          DateTime.now(),
        );
        setState(() {
          _todayWaterData = waterData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Su verisi yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWaterIntake(int amount) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId != null) {
        // Önce Firebase'i dene
        bool success = await WaterTrackingService.addWaterIntake(
          userId,
          amount,
        );

        // Firebase başarısız olursa local storage kullan
        if (!success) {
          print('🔄 Firebase başarısız, local storage kullanılıyor...');
          success = await LocalWaterService.addWaterIntake(userId, amount);
        }

        if (success) {
          _showSuccessMessage('$amount ml su eklendi! 💧');
          await _loadTodayWaterData();
        } else {
          _showErrorMessage('Su eklenirken hata oluştu');
        }
      }
    } catch (e) {
      print('Su ekleme hatası: $e');
      _showErrorMessage('Su eklenirken hata oluştu');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCustomWaterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Su Miktarı Gir',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _waterAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Su miktarı (ml)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.water_drop),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(_waterAmountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _addWaterIntake(amount);
                _waterAmountController.clear();
              } else {
                _showErrorMessage('Geçerli bir miktar girin');
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük Takip',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Su Takibi Kartı
                  _buildWaterTrackingCard(),
                  const SizedBox(height: 24),

                  // Hızlı Su Ekleme Butonları
                  _buildQuickWaterButtons(),
                  const SizedBox(height: 24),

                  // Bugünkü Su İçme Geçmişi
                  _buildWaterHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildWaterTrackingCard() {
    final totalAmount = _todayWaterData?['totalAmount'] ?? 0;
    final targetAmount = _todayWaterData?['targetAmount'] ?? 2000;
    final progress = targetAmount > 0
        ? (totalAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Su Takibi',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bugünkü su tüketiminiz',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${totalAmount}ml / ${targetAmount}ml',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.blue.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade600,
                  ),
                  minHeight: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickWaterButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı Su Ekle',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWaterButton('250ml', 250, Colors.blue.shade100),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWaterButton('500ml', 500, Colors.blue.shade200),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWaterButton(
                    '1000ml',
                    1000,
                    Colors.blue.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showCustomWaterDialog,
                icon: const Icon(Icons.add),
                label: const Text('Özel Miktar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(String label, int amount, Color color) {
    return ElevatedButton(
      onPressed: () => _addWaterIntake(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildWaterHistory() {
    final intakes = _todayWaterData?['intakes'] ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugünkü Su İçme Geçmişi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            if (intakes.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Henüz su içmediniz',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...intakes.reversed
                  .map((intake) => _buildWaterHistoryItem(intake))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterHistoryItem(dynamic intake) {
    final amount = intake['amount'] ?? 0;
    final timestamp = intake['timestamp']?.toDate() ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$amount ml',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          Text(
            _formatTime(timestamp),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
