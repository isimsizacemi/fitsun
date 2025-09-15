import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/nutrition_tracking_service.dart';
import '../models/diet_plan.dart';
import 'diet_creation_screen.dart';
import 'daily_diet_detail_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _nutritionStats;
  List<DietPlan> _dietPlans = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final stats = await NutritionTrackingService.getNutritionStats(userId);
      final dietPlans = await NutritionTrackingService.getUserDietPlans(
        userId: userId,
      );

      print('🔍 Diyet ekranı - Plan sayısı: ${dietPlans.length}');
      for (var plan in dietPlans) {
        print('📋 Plan: ${plan.title} - Aktif: ${plan.isActive}');
        print('🍽️ Plan öğün sayısı: ${plan.meals.length}');
        for (var meal in plan.meals.take(3)) {
          print(
            '🍴 Öğün örneği: ${meal.dayName} - ${meal.mealType} - ${meal.foodName}',
          );
        }
      }

      // Test için: Eğer hiç diyet planı yoksa, örnek plan ekle
      if (dietPlans.isEmpty) {
        print('⚠️ Hiç diyet planı yok, test planı ekleniyor...');
        final testPlan = DietPlan(
          id: 'test_plan',
          userId: userId,
          title: 'Test Diyet Planı',
          description: 'Test için oluşturulan örnek diyet planı',
          duration: 7,
          targetCalories: 2000,
          targetProtein: 150.0,
          targetCarbs: 250.0,
          targetFat: 65.0,
          isActive: true,
          meals: [
            Meal(
              dayName: 'Pazartesi',
              mealType: 'Kahvaltı',
              foodName: 'Yulaf Ezmesi + Muz',
              amount: '50g yulaf + 1 muz',
              calories: 300,
              protein: 12.0,
              carbs: 55.0,
              fat: 6.0,
              time: '08:00',
              notes: 'Süt ile karıştır',
            ),
            Meal(
              dayName: 'Pazartesi',
              mealType: 'Öğle Yemeği',
              foodName: 'Tavuk Göğsü + Bulgur',
              amount: '150g tavuk + 80g bulgur',
              calories: 450,
              protein: 50.0,
              carbs: 35.0,
              fat: 8.0,
              time: '13:00',
              notes: 'Izgara tavuk',
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        dietPlans.add(testPlan);
      }

      setState(() {
        _nutritionStats = stats;
        _dietPlans = dietPlans;
        _isLoading = false;
      });
    } catch (e) {
      print('Beslenme verisi yükleme hatası: $e');
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
      _loadNutritionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diyet Takibi',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DietCreationScreen(),
                ),
              );
            },
            tooltip: 'Diyet Programı Oluştur',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNutritionData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nutritionStats == null
          ? _buildEmptyState()
          : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DietCreationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Diyet Programı Oluştur'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Henüz beslenme planı yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Beslenme planı oluşturmak için\nana sayfadan bir plan seçebilirsiniz',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.home),
            label: const Text('Ana Sayfaya Git'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DietCreationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Gün Gün Diyet Programı Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final stats = _nutritionStats!;
    final completionRate = stats['completionRate'] ?? 0.0;

    if (_dietPlans.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Günlük Özet Kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.today, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Günlük Özet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Tamamlanma',
                          '${(completionRate ?? 0.0).toStringAsFixed(1)}%',
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Kalan',
                          '${(100 - (completionRate ?? 0.0)).toStringAsFixed(1)}%',
                          Colors.orange,
                          Icons.schedule,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Beslenme Hedefleri
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Beslenme Hedefleri',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionGoal(
                    'Kalori',
                    double.tryParse((stats['calories'] ?? 0).toString()) ?? 0.0,
                    double.tryParse(
                          (stats['targetCalories'] ?? 0).toString(),
                        ) ??
                        0.0,
                  ),
                  _buildNutritionGoal(
                    'Protein',
                    double.tryParse((stats['protein'] ?? 0).toString()) ?? 0.0,
                    double.tryParse((stats['targetProtein'] ?? 0).toString()) ??
                        0.0,
                  ),
                  _buildNutritionGoal(
                    'Karbonhidrat',
                    double.tryParse((stats['carbs'] ?? 0).toString()) ?? 0.0,
                    double.tryParse((stats['targetCarbs'] ?? 0).toString()) ??
                        0.0,
                  ),
                  _buildNutritionGoal(
                    'Yağ',
                    double.tryParse((stats['fat'] ?? 0).toString()) ?? 0.0,
                    double.tryParse((stats['targetFat'] ?? 0).toString()) ??
                        0.0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Diyet Planları - sadece planlar varsa göster
          if (_dietPlans.isNotEmpty) ...[
            _buildDietPlansSection(),
            const SizedBox(height: 16),
          ],

          // Hızlı Eylemler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_circle, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Hızlı Eylemler',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addMeal,
                          icon: const Icon(Icons.restaurant),
                          label: const Text('Öğün Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addSnack,
                          icon: const Icon(Icons.cookie),
                          label: const Text('Atıştırma'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGoal(String name, double current, double target) {
    final percentage = target > 0 ? (current / target) * 100 : 0;
    final color = percentage >= 100
        ? Colors.green
        : percentage >= 80
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              Text(
                '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  void _addMeal() {
    showDialog(context: context, builder: (context) => _buildMealDialog());
  }

  void _addSnack() {
    showDialog(context: context, builder: (context) => _buildSnackDialog());
  }

  Widget _buildMealDialog() {
    return AlertDialog(
      title: Text(
        'Öğün Ekle',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: const Text('Öğün ekleme özelliği yakında!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    );
  }

  Widget _buildSnackDialog() {
    return AlertDialog(
      title: Text(
        'Atıştırma Ekle',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: const Text('Atıştırma ekleme özelliği yakında!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tamam'),
        ),
      ],
    );
  }

  Widget _buildDietPlansSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Diyet Planlarım',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_dietPlans.length} plan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dietPlans.length,
              itemBuilder: (context, index) {
                final plan = _dietPlans[index];
                return _buildDietPlanCard(plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPlanCard(DietPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: plan.isActive ? Colors.green.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plan.isActive ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: plan.isActive ? Colors.green : Colors.black87,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plan.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aktif',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red[400],
                    onPressed: () => _deleteDietPlan(plan),
                    tooltip: 'Diyet Planını Sil',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPlanStat('${plan.duration} gün', Icons.calendar_today),
              _buildPlanStat(
                '${plan.targetCalories} kcal',
                Icons.local_fire_department,
              ),
              _buildPlanStat('${plan.meals.length} öğün', Icons.restaurant),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    print('🔍 Görüntüle butonuna tıklandı');
                    _viewDietPlan(plan);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Görüntüle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _activateDietPlan(plan),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Aktif Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _viewDietPlan(DietPlan plan) {
    print('🔍 Diyet planı detayına gidiliyor...');
    print('📋 Plan: ${plan.title}');
    print('🍽️ Öğün sayısı: ${plan.meals.length}');

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyDietDetailScreen(
            dietPlan: plan,
            selectedDate: DateTime.now(),
          ),
        ),
      );
      print('✅ Navigation başarılı');
    } catch (e) {
      print('❌ Navigation hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detay ekranına gidilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _activateDietPlan(DietPlan plan) {
    // TODO: Diyet planını aktif et
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan.title} aktif edildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteDietPlan(DietPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Diyet Planını Sil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${plan.title} diyet planını silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteDietPlan(plan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDietPlan(DietPlan plan) async {
    try {
      setState(() => _isLoading = true);

      print('🗑️ Diyet planı siliniyor: ${plan.title}');

      // NutritionTrackingService'den silme metodunu çağır
      await NutritionTrackingService.deleteDietPlan(plan.id);

      // Listeden kaldır
      setState(() {
        _dietPlans.removeWhere((p) => p.id == plan.id);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${plan.title} diyet planı silindi'),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Diyet planı başarıyla silindi');
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Diyet planı silme hatası: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diyet planı silinirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
