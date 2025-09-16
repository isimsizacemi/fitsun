import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';

class DietCreationScreen extends StatefulWidget {
  const DietCreationScreen({super.key});

  @override
  State<DietCreationScreen> createState() => _DietCreationScreenState();
}

class _DietCreationScreenState extends State<DietCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customPromptController = TextEditingController();

  int _duration = 7;
  int _targetCalories = 2000;
  double _targetProtein = 150.0;
  double _targetCarbs = 250.0;
  double _targetFat = 65.0;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gün Gün Diyet Programı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildForm(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Gün Gün Diyet Programı Hazırlanıyor...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI, günlük öğünlerinizi ve ara öğünlerinizi planlıyor',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildNutritionGoals(),
            const SizedBox(height: 24),
            _buildCustomPrompt(),
            const SizedBox(height: 32),
            _buildCreateButton(),
            const SizedBox(height: 16),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: const Color(0xFF2E7D32)),
          const SizedBox(height: 12),
          Text(
            'Gün Gün Diyet Programı Oluştur',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'AI ile gün gün ne yiyeceğini planla!\nKahvaltı, öğle, akşam ve ara öğünler dahil',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temel Bilgiler',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Plan Adı',
                hintText: 'Örn: Kilo Verme Planı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Plan adı gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Planınız hakkında kısa açıklama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Açıklama gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Süre: $_duration gün',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 3,
                    max: 30,
                    divisions: 27,
                    label: '$_duration gün',
                    onChanged: (value) {
                      setState(() {
                        _duration = value.round();
                      });
                    },
                    activeColor: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionGoals() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beslenme Hedefleri',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            _buildNutritionSlider(
              'Hedef Kalori',
              _targetCalories.toDouble(),
              1000,
              4000,
              'kcal',
              (value) => setState(() => _targetCalories = value.round()),
            ),
            const SizedBox(height: 16),
            _buildNutritionSlider(
              'Protein',
              _targetProtein,
              50,
              300,
              'g',
              (value) => setState(() => _targetProtein = value),
            ),
            const SizedBox(height: 16),
            _buildNutritionSlider(
              'Karbonhidrat',
              _targetCarbs,
              100,
              500,
              'g',
              (value) => setState(() => _targetCarbs = value),
            ),
            const SizedBox(height: 16),
            _buildNutritionSlider(
              'Yağ',
              _targetFat,
              30,
              150,
              'g',
              (value) => setState(() => _targetFat = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSlider(
    String label,
    double value,
    double min,
    double max,
    String unit,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 16)),
            Text(
              '${value.toStringAsFixed(0)} $unit',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 10).round(),
          label: '${value.toStringAsFixed(0)} $unit',
          onChanged: onChanged,
          activeColor: const Color(0xFF2E7D32),
        ),
      ],
    );
  }

  Widget _buildCustomPrompt() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Özel İstekler (İsteğe Bağlı)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Özel beslenme tercihlerinizi, alerjilerinizi veya istemediğiniz gıdaları belirtin',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customPromptController,
              decoration: InputDecoration(
                labelText: 'Özel İstekler',
                hintText: 'Örn: Vejetaryen, glutensiz, süt ürünleri yok',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _createDietPlan,
        icon: const Icon(Icons.restaurant_menu, size: 24),
        label: Text(
          'Gün Gün Diyet Programı Oluştur',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Geri Dön'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          side: const BorderSide(color: Color(0xFF2E7D32)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _createDietPlan() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null || currentUser.id.isEmpty) {
        _showErrorSnackBar('Lütfen önce giriş yapın');
        return;
      }

      // Gemini AI ile diyet planı oluştur
      final dietPlan = await GeminiService.generateDietPlan(
        currentUser,
        customPrompt: _customPromptController.text.isNotEmpty
            ? _customPromptController.text
            : null,
      );

      if (dietPlan != null) {
        _showSuccessSnackBar('${_titleController.text} oluşturuldu!');
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('Diyet planı oluşturulamadı');
      }
    } catch (e) {
      _showErrorSnackBar('Hata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
