import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/diet_plan.dart';

class DailyDietDetailScreen extends StatefulWidget {
  final DietPlan dietPlan;
  final DateTime selectedDate;

  const DailyDietDetailScreen({
    super.key,
    required this.dietPlan,
    required this.selectedDate,
  });

  @override
  State<DailyDietDetailScreen> createState() => _DailyDietDetailScreenState();
}

class _DailyDietDetailScreenState extends State<DailyDietDetailScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late String _selectedDayName;
  late TabController _tabController;
  int _selectedDayIndex = 0;

  final List<String> _days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedDayName = _getDayName(_selectedDate);
    _selectedDayIndex = _days.indexOf(_selectedDayName);
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: _selectedDayIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedDayIndex = _tabController.index;
          _selectedDayName = _days[_selectedDayIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getDayName(DateTime date) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[date.weekday - 1];
  }

  Map<String, List<Meal>> _groupMealsByType(List<Meal> meals) {
    Map<String, List<Meal>> groupedMeals = {};

    for (var meal in meals) {
      if (!groupedMeals.containsKey(meal.mealType)) {
        groupedMeals[meal.mealType] = [];
      }
      groupedMeals[meal.mealType]!.add(meal);
    }

    // Öğünleri zaman sırasına göre sırala
    groupedMeals.forEach((key, value) {
      value.sort((a, b) => a.time.compareTo(b.time));
    });

    return groupedMeals;
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedDayName = _getDayName(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Program bilgilerini yazdır
    print('🔍 Diyet Detay Ekranı');
    print('📋 Program: ${widget.dietPlan.title}');
    print('📝 Açıklama: ${widget.dietPlan.description}');
    print('⏱️ Süre: ${widget.dietPlan.duration} gün');
    print('🔥 Hedef Kalori: ${widget.dietPlan.targetCalories}');
    print('🍽️ Toplam Öğün: ${widget.dietPlan.meals.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dietPlan.title,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Tarih Seç',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) => _buildDayContent(day)).toList(),
      ),
    );
  }

  Widget _buildDayContent(String dayName) {
    final meals = widget.dietPlan.getMealsForDay(dayName);
    final groupedMeals = _groupMealsByType(meals);

    // Debug: Gün ve öğün bilgilerini yazdır
    print('🔍 Gün: $dayName');
    print('🍽️ Bu gün için öğün sayısı: ${meals.length}');
    for (var meal in meals) {
      print('  - ${meal.mealType}: ${meal.foodName} (${meal.dayName})');
    }
    print('📋 Tüm öğünler:');
    for (var meal in widget.dietPlan.meals) {
      print('  - ${meal.dayName}: ${meal.mealType} - ${meal.foodName}');
    }

    // Günlük toplam besin değerleri
    final totalCalories = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.calories,
    );
    final totalProtein = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.protein,
    );
    final totalCarbs = meals.fold<double>(0, (sum, meal) => sum + meal.carbs);
    final totalFat = meals.fold<double>(0, (sum, meal) => sum + meal.fat);

    return meals.isEmpty
        ? _buildEmptyState(dayName)
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Program Bilgileri Header
                _buildProgramHeader(),
                const SizedBox(height: 16),

                // Gün Bilgisi
                _buildDayHeader(dayName),
                const SizedBox(height: 16),

                // Günlük Besin Değerleri Özeti
                _buildNutritionSummary(
                  totalCalories,
                  totalProtein,
                  totalCarbs,
                  totalFat,
                ),
                const SizedBox(height: 16),

                // Öğünler
                _buildMealsSection(groupedMeals),
                const SizedBox(height: 16),

                // Hızlı Eylemler
                _buildQuickActions(),
              ],
            ),
          );
  }

  Widget _buildProgramHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.dietPlan.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.dietPlan.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AKTİF',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.dietPlan.description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildProgramStat(
                  '${widget.dietPlan.duration} gün',
                  Icons.calendar_today,
                ),
                const SizedBox(width: 16),
                _buildProgramStat(
                  '${widget.dietPlan.targetCalories} kcal',
                  Icons.local_fire_department,
                ),
                const SizedBox(width: 16),
                _buildProgramStat(
                  '${widget.dietPlan.meals.length} öğün',
                  Icons.restaurant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramStat(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(String dayName) {
    final meals = widget.dietPlan.getMealsForDay(dayName);
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
                    dayName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${meals.length} öğün planlandı',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Gün ${_days.indexOf(dayName) + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String dayName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '$dayName için planlanmış öğün yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Başka bir gün seçmeyi deneyin',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Geri Dön'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(
    int totalCalories,
    double totalProtein,
    double totalCarbs,
    double totalFat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Günlük Besin Değerleri',
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
                  child: _buildNutritionCard(
                    'Kalori',
                    '$totalCalories',
                    'kcal',
                    Colors.red,
                    Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutritionCard(
                    'Protein',
                    totalProtein.toStringAsFixed(1),
                    'g',
                    Colors.blue,
                    Icons.fitness_center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionCard(
                    'Karbonhidrat',
                    totalCarbs.toStringAsFixed(1),
                    'g',
                    Colors.orange,
                    Icons.grain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutritionCard(
                    'Yağ',
                    totalFat.toStringAsFixed(1),
                    'g',
                    Colors.purple,
                    Icons.opacity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
    String title,
    String value,
    String unit,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$title ($unit)',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection(Map<String, List<Meal>> groupedMeals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Öğünler',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...groupedMeals.entries.map((entry) {
              return _buildMealTypeSection(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSection(String mealType, List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 8),
        ...meals.map((meal) => _buildMealCard(meal)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMealCard(Meal meal) {
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
            children: [
              Text(meal.mealTypeEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meal.foodName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                meal.time,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Miktar: ${meal.amount}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Text(
                meal.nutritionSummary,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (meal.notes != null && meal.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal.notes!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
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
                    onPressed: _markMealAsCompleted,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Öğünü Tamamla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addCustomMeal,
                    icon: const Icon(Icons.add),
                    label: const Text('Özel Öğün'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markMealAsCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Öğün tamamlama özelliği yakında!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addCustomMeal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Özel öğün ekleme özelliği yakında!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
