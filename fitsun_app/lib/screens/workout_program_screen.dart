import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/workout_program.dart';
import '../models/workout_model.dart';
import '../services/gemini_service.dart';
import '../services/workout_tracking_service.dart';

class WorkoutProgramScreen extends StatefulWidget {
  final UserModel userProfile;

  const WorkoutProgramScreen({super.key, required this.userProfile});

  @override
  State<WorkoutProgramScreen> createState() => _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends State<WorkoutProgramScreen> {
  WorkoutProgram? _workoutProgram;
  bool _isLoading = false;
  List<WorkoutProgram> _userPrograms = [];
  bool _isLoadingPrograms = false;
  bool _showCreateForm = false;

  // Ek kullanıcı verileri için form alanları
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _experienceController = TextEditingController();
  final _weeklyFrequencyController = TextEditingController();
  final _preferredTimeController = TextEditingController();
  final _customPromptController = TextEditingController();

  String? _selectedGoal;
  String? _selectedFitnessLevel;
  String? _selectedWorkoutLocation;
  List<String> _selectedEquipment = [];

  final List<String> _goalOptions = [
    'Kilo Verme',
    'Kas Kazanımı',
    'Dayanıklılık',
    'Genel Fitness',
  ];

  final Map<String, String> _goalValueMap = {
    'Kilo Verme': 'weight_loss',
    'Kas Kazanımı': 'muscle_gain',
    'Dayanıklılık': 'endurance',
    'Genel Fitness': 'general_fitness',
  };

  final Map<String, String> _goalDisplayMap = {
    'weight_loss': 'Kilo Verme',
    'muscle_gain': 'Kas Kazanımı',
    'endurance': 'Dayanıklılık',
    'general_fitness': 'Genel Fitness',
  };

  final List<String> _fitnessLevelOptions = ['Başlangıç', 'Orta', 'İleri'];

  final Map<String, String> _fitnessLevelValueMap = {
    'Başlangıç': 'beginner',
    'Orta': 'intermediate',
    'İleri': 'advanced',
  };

  final Map<String, String> _fitnessLevelDisplayMap = {
    'beginner': 'Başlangıç',
    'intermediate': 'Orta',
    'advanced': 'İleri',
  };

  final List<String> _workoutLocationOptions = [
    'Ev',
    'Spor Salonu',
    'Açık Hava',
  ];

  final Map<String, String> _workoutLocationValueMap = {
    'Ev': 'home',
    'Spor Salonu': 'gym',
    'Açık Hava': 'outdoor',
  };

  final Map<String, String> _workoutLocationDisplayMap = {
    'home': 'Ev',
    'gym': 'Spor Salonu',
    'outdoor': 'Açık Hava',
  };

  final List<String> _equipmentOptions = [
    'Dambıl',
    'Barbell',
    'Direnç Bandı',
    'Kettlebell',
    'TRX',
    'Yoga Matı',
    'Koşu Bandı',
    'Bisiklet',
    'Kardiyo Makineleri',
    'Serbest Ağırlık',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _loadUserPrograms();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _experienceController.dispose();
    _weeklyFrequencyController.dispose();
    _preferredTimeController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    // Mevcut kullanıcı verilerini form alanlarına yükle
    _weightController.text = widget.userProfile.weight?.toString() ?? '';
    _bodyFatController.text = widget.userProfile.bodyFat?.toString() ?? '';
    _muscleMassController.text =
        widget.userProfile.muscleMass?.toString() ?? '';
    _experienceController.text = widget.userProfile.experience ?? '';
    _weeklyFrequencyController.text =
        widget.userProfile.weeklyFrequency?.toString() ?? '';
    _preferredTimeController.text = widget.userProfile.preferredTime ?? '';

    _selectedGoal =
        _goalDisplayMap[widget.userProfile.goal] ??
        (widget.userProfile.goal != null ? _goalOptions.first : null);
    _selectedFitnessLevel =
        _fitnessLevelDisplayMap[widget.userProfile.fitnessLevel] ??
        _fitnessLevelOptions.first;
    _selectedWorkoutLocation =
        _workoutLocationDisplayMap[widget.userProfile.workoutLocation] ??
        _workoutLocationOptions.first;
    _selectedEquipment = widget.userProfile.availableEquipment ?? [];
  }

  Future<void> _generateWorkoutProgram() async {
    setState(() => _isLoading = true);

    print('🚀 Program oluşturma başlatılıyor...');
    print('👤 Kullanıcı: ${widget.userProfile.name}');
    print('🎯 Hedef: ${_selectedGoal ?? widget.userProfile.goal}');
    print(
      '💪 Seviye: ${_selectedFitnessLevel ?? widget.userProfile.fitnessLevel}',
    );

    try {
      // Form validasyonu
      if (_weightController.text.isNotEmpty &&
          double.tryParse(_weightController.text) == null) {
        _showErrorSnackBar('Lütfen geçerli bir kilo değeri girin.');
        setState(() => _isLoading = false);
        return;
      }

      if (_bodyFatController.text.isNotEmpty &&
          double.tryParse(_bodyFatController.text) == null) {
        _showErrorSnackBar('Lütfen geçerli bir yağ oranı değeri girin.');
        setState(() => _isLoading = false);
        return;
      }

      if (_muscleMassController.text.isNotEmpty &&
          double.tryParse(_muscleMassController.text) == null) {
        _showErrorSnackBar('Lütfen geçerli bir kas kütlesi değeri girin.');
        setState(() => _isLoading = false);
        return;
      }

      if (_weeklyFrequencyController.text.isNotEmpty &&
          int.tryParse(_weeklyFrequencyController.text) == null) {
        _showErrorSnackBar('Lütfen geçerli bir haftalık sıklık değeri girin.');
        setState(() => _isLoading = false);
        return;
      }

      // Güncellenmiş kullanıcı profili oluştur
      final updatedUser = widget.userProfile.copyWith(
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : widget.userProfile.weight,
        bodyFat: _bodyFatController.text.isNotEmpty
            ? double.tryParse(_bodyFatController.text)
            : widget.userProfile.bodyFat,
        muscleMass: _muscleMassController.text.isNotEmpty
            ? double.tryParse(_muscleMassController.text)
            : widget.userProfile.muscleMass,
        experience: _experienceController.text.isNotEmpty
            ? _experienceController.text
            : widget.userProfile.experience,
        weeklyFrequency: _weeklyFrequencyController.text.isNotEmpty
            ? int.tryParse(_weeklyFrequencyController.text)
            : widget.userProfile.weeklyFrequency,
        preferredTime: _preferredTimeController.text.isNotEmpty
            ? _preferredTimeController.text
            : widget.userProfile.preferredTime,
        goal:
            _goalValueMap[_selectedGoal] ??
            _selectedGoal ??
            widget.userProfile.goal,
        fitnessLevel:
            _fitnessLevelValueMap[_selectedFitnessLevel] ??
            _selectedFitnessLevel ??
            widget.userProfile.fitnessLevel,
        workoutLocation:
            _workoutLocationValueMap[_selectedWorkoutLocation] ??
            _selectedWorkoutLocation ??
            widget.userProfile.workoutLocation,
        availableEquipment: _selectedEquipment.isNotEmpty
            ? _selectedEquipment
            : widget.userProfile.availableEquipment,
      );

      print('👤 Updated User ID: ${updatedUser.id}');
      print('📧 Updated User Email: ${updatedUser.email}');

      if (updatedUser.id.isEmpty) {
        print('❌ User ID boş, program oluşturulamıyor');
        _showErrorSnackBar(
          '❌ Kullanıcı bilgileri eksik. Lütfen profil ayarlarını kontrol edin.',
        );
        return;
      }

      final program = await GeminiService.generateWorkoutProgram(
        updatedUser,
        customPrompt: _customPromptController.text.trim().isNotEmpty
            ? _customPromptController.text.trim()
            : null,
      );

      if (program != null) {
        print('✅ Program başarıyla oluşturuldu!');
        print('📝 Program adı: ${program.programName}');
        print('📅 Süre: ${program.durationWeeks} hafta');
        print('🏋️ Gün sayısı: ${program.weeklySchedule.length}');

        setState(() {
          _workoutProgram = program;
          _showCreateForm = false; // Form ekranından çık
        });
        _showSuccessSnackBar('🎉 Program başarıyla oluşturuldu!');

        // Program listesini yenile
        _loadUserPrograms();
      } else {
        print('❌ Program oluşturulamadı');
        _showErrorSnackBar('❌ Program oluşturulamadı. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      print('💥 Program oluşturma hatası: $e');
      if (e.toString().contains('TimeoutException')) {
        _showErrorSnackBar('⏰ AI yanıt vermedi (30s timeout). Tekrar deneyin.');
      } else if (e.toString().contains('SocketException')) {
        _showErrorSnackBar(
          '🌐 İnternet bağlantısı hatası. Bağlantınızı kontrol edin.',
        );
      } else if (e.toString().contains('FormatException')) {
        _showErrorSnackBar(
          '📝 AI yanıtı işlenirken hata oluştu. Tekrar deneyin.',
        );
      } else {
        _showErrorSnackBar('💥 Hata: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _testApiConnection() async {
    setState(() => _isLoading = true);

    try {
      final isWorking = await GeminiService.testApiConnection();
      if (isWorking) {
        _showSuccessSnackBar('✅ API çalışıyor! Program oluşturabilirsiniz.');
      } else {
        _showErrorSnackBar(
          '❌ API çalışmıyor. Lütfen internet bağlantınızı kontrol edin.',
        );
      }
    } catch (e) {
      _showErrorSnackBar('❌ Test hatası: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPlansCollection() async {
    setState(() => _isLoading = true);

    try {
      await GeminiService.createPlansCollection();
      _showSuccessSnackBar('✅ Plans Collection oluşturuldu!');
    } catch (e) {
      _showErrorSnackBar(
        '❌ Plans Collection oluşturma hatası: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spor Programı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Ana Sayfa',
          ),
          IconButton(
            icon: const Icon(Icons.sports_gymnastics),
            onPressed: () {
              Navigator.pushNamed(context, '/exercise-guide');
            },
            tooltip: 'Egzersiz Rehberi',
          ),
        ],
      ),
      body: _workoutProgram != null
          ? _buildProgramDetailScreen(_workoutProgram!)
          : _showCreateForm
          ? _buildGenerateScreen()
          : _buildProgramListScreen(),
    );
  }

  // Program listesi ekranı
  Widget _buildProgramListScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Yeni Program Butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spor Programlarım',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showCreateForm = true; // Create form'a git
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Yeni Program'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Program listesi
          if (_isLoadingPrograms)
            const Center(child: CircularProgressIndicator())
          else if (_userPrograms.isEmpty)
            _buildEmptyState()
          else
            ..._userPrograms
                .map((program) => _buildProgramCard(program))
                .toList(),
        ],
      ),
    );
  }

  // Boş durum ekranı
  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz programınız yok',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'AI ile size özel bir spor programı oluşturun',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _workoutProgram = null; // Generate screen'e git
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('İlk Programımı Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Açıklama
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Kişiselleştirilmiş Spor Programı',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'AI ile size özel bir spor programı oluşturalım',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Mevcut Profil Bilgileri
          _buildCurrentProfileCard(),
          const SizedBox(height: 24),

          // Ek Bilgiler Formu
          _buildAdditionalInfoForm(),
          const SizedBox(height: 32),

          // Program Oluştur Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateWorkoutProgram,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isLoading ? 'Program Oluşturuluyor...' : 'Program Oluştur',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // API Test Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _testApiConnection,
              icon: const Icon(Icons.bug_report),
              label: const Text('API Test Et'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Plans Collection Oluştur Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _createPlansCollection,
              icon: const Icon(Icons.library_books),
              label: const Text('Plans Collection Oluştur'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateWorkoutProgram,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isLoading ? 'AI Program Oluşturuyor...' : 'Program Oluştur',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Text(
              'AI sizin için özel program hazırlıyor...\nBu işlem 10-30 saniye sürebilir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildCurrentProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mevcut Profil Bilgileri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileInfoRow(
              'Ad Soyad',
              widget.userProfile.name ?? 'Belirtilmemiş',
            ),
            _buildProfileInfoRow(
              'Yaş',
              widget.userProfile.age?.toString() ?? 'Belirtilmemiş',
            ),
            _buildProfileInfoRow(
              'Boy',
              '${widget.userProfile.height?.toString() ?? 'Belirtilmemiş'} cm',
            ),
            _buildProfileInfoRow(
              'Kilo',
              '${widget.userProfile.weight?.toString() ?? 'Belirtilmemiş'} kg',
            ),
            _buildProfileInfoRow(
              'Cinsiyet',
              widget.userProfile.gender ?? 'Belirtilmemiş',
            ),
            _buildProfileInfoRow(
              'Hedef',
              widget.userProfile.goal ?? 'Belirtilmemiş',
            ),
            _buildProfileInfoRow(
              'Fitness Seviyesi',
              widget.userProfile.fitnessLevel ?? 'Belirtilmemiş',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Program İçin Ek Bilgiler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Daha kişiselleştirilmiş bir program için aşağıdaki bilgileri güncelleyebilirsiniz:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Fiziksel Özellikler
            Text(
              'Fiziksel Özellikler',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Kilo (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bodyFatController,
                    decoration: const InputDecoration(
                      labelText: 'Yağ Oranı (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _muscleMassController,
                    decoration: const InputDecoration(
                      labelText: 'Kas Kütlesi (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weeklyFrequencyController,
                    decoration: const InputDecoration(
                      labelText: 'Haftalık Sıklık',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hedef ve Seviye
            Text(
              'Hedef ve Seviye',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGoal,
                    decoration: const InputDecoration(
                      labelText: 'Hedef',
                      border: OutlineInputBorder(),
                    ),
                    items: _goalOptions.map((goal) {
                      return DropdownMenuItem<String>(
                        value: goal,
                        child: Text(goal),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGoal = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFitnessLevel,
                    decoration: const InputDecoration(
                      labelText: 'Fitness Seviyesi',
                      border: OutlineInputBorder(),
                    ),
                    items: _fitnessLevelOptions.map((level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedFitnessLevel = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Antrenman Yeri
            DropdownButtonFormField<String>(
              value: _selectedWorkoutLocation,
              decoration: const InputDecoration(
                labelText: 'Antrenman Yeri',
                border: OutlineInputBorder(),
              ),
              items: _workoutLocationOptions.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedWorkoutLocation = value),
            ),
            const SizedBox(height: 16),

            // Ekipman Seçimi
            Text(
              'Mevcut Ekipmanlar',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _equipmentOptions.map((equipment) {
                final isSelected = _selectedEquipment.contains(equipment);
                return FilterChip(
                  label: Text(equipment),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEquipment.add(equipment);
                      } else {
                        _selectedEquipment.remove(equipment);
                      }
                    });
                  },
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Özel Prompt Alanı
            Text(
              'Özel İstekler (Opsiyonel)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _customPromptController,
              decoration: const InputDecoration(
                labelText: 'AI\'ya özel isteklerinizi yazın',
                hintText:
                    'Örn: Daha fazla kardiyo egzersizi, belirli kas gruplarına odaklan, vb.',
                border: OutlineInputBorder(),
                helperText:
                    'Bu alan boş bırakılabilir. AI programı oluştururken bu istekleri dikkate alacaktır.',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcının programlarını yükle
  Future<void> _loadUserPrograms() async {
    if (widget.userProfile.id.isEmpty) return;

    setState(() => _isLoadingPrograms = true);

    try {
      print('📋 Kullanıcı programları yükleniyor...');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userProfile.id)
          .collection('programs')
          .orderBy('createdAt', descending: true)
          .get();

      final programs = querySnapshot.docs
          .map((doc) => WorkoutProgram.fromMap(doc.data(), doc.id))
          .toList();

      setState(() {
        _userPrograms = programs;
        _isLoadingPrograms = false;
      });

      print('✅ ${programs.length} program yüklendi');
    } catch (e) {
      print('❌ Program yükleme hatası: $e');
      setState(() => _isLoadingPrograms = false);
    }
  }

  // Program kartı widget'ı
  Widget _buildProgramCard(WorkoutProgram program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() => _workoutProgram = program);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      program.programName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${program.durationWeeks} hafta',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                program.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${program.weeklySchedule.length} gün/hafta',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(program.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Program detay ekranı
  Widget _buildProgramDetailScreen(WorkoutProgram program) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program başlığı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.programName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${program.durationWeeks} hafta',
                        Icons.schedule,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        '${program.weeklySchedule.length} gün/hafta',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Haftalık program
          Text(
            'Haftalık Program',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...program.weeklySchedule.asMap().entries.map((entry) {
            final dayIndex = entry.key;
            final day = entry.value;

            return _buildDayCard(day, dayIndex);
          }).toList(),
        ],
      ),
    );
  }

  // Gün kartı
  Widget _buildDayCard(WorkoutDay day, int dayIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${dayIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    day.focus,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (day.exercises.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _startWorkout(day),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Başla'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
        children: [
          if (day.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Dinlenme günü',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...day.exercises
                .map((exercise) => _buildExerciseTile(exercise))
                .toList(),
        ],
      ),
    );
  }

  // Egzersiz tile'ı
  Widget _buildExerciseTile(Exercise exercise) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.fitness_center),
      ),
      title: Text(exercise.name),
      subtitle: Text('${exercise.sets} set x ${exercise.reps} tekrar'),
      trailing: Text('${exercise.restSeconds ?? 60}s dinlenme'),
    );
  }

  // Antrenman başlatma
  void _startWorkout(WorkoutDay day) {
    showDialog(
      context: context,
      builder: (context) => WorkoutSessionDialog(
        day: day,
        onWorkoutCompleted: (completedExercises) {
          _saveWorkoutSession(day, completedExercises);
        },
      ),
    );
  }

  // Antrenman oturumu kaydetme
  Future<void> _saveWorkoutSession(
    WorkoutDay day,
    List<CompletedExercise> completedExercises,
  ) async {
    try {
      print('💾 Antrenman oturumu kaydediliyor...');

      // WorkoutTrackingService kullanarak kaydet
      final sessionId = await WorkoutTrackingService.startWorkoutSession(
        userId: widget.userProfile.id,
        programId: _workoutProgram?.id ?? 'unknown',
        programName: _workoutProgram?.programName ?? 'Bilinmeyen Program',
        dayName: day.dayName,
        dayNumber: 1, // Basit olarak 1 kullanıyoruz
        date: DateTime.now(),
      );

      // Egzersizleri ekle
      for (final exercise in completedExercises) {
        if (exercise.completed) {
          await WorkoutTrackingService.updateExerciseInSession(
            sessionId: sessionId,
            exerciseName: exercise.name,
            exerciseSession: ExerciseSession(
              exerciseName: exercise.name,
              plannedSets: exercise.sets,
              completedSets: exercise.sets,
              plannedReps: exercise.reps,
              completedReps: exercise.reps,
              plannedWeight: exercise.weight?.toDouble() ?? 0.0,
              completedWeight: exercise.weight?.toDouble() ?? 0.0,
              restTime: exercise.restSeconds,
              setDetails: [
                SetDetail(
                  setNumber: 1,
                  reps: exercise.reps,
                  weight: exercise.weight?.toDouble() ?? 0.0,
                  restTime: exercise.restSeconds,
                  isCompleted: true,
                  notes: 'Tamamlandı',
                ),
              ],
              isCompleted: true,
            ),
          );
        }
      }

      // Antrenmanı tamamla
      await WorkoutTrackingService.completeWorkoutSession(
        sessionId: sessionId,
        notes: '${day.dayName} - ${day.focus}',
      );

      _showSuccessSnackBar('✅ Antrenman tamamlandı ve kaydedildi!');
      print('✅ Antrenman oturumu kaydedildi');
    } catch (e) {
      print('❌ Antrenman kaydetme hatası: $e');
      _showErrorSnackBar('❌ Antrenman kaydedilemedi');
    }
  }

  // Tarih formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Bugün';
    if (difference == 1) return 'Dün';
    if (difference < 7) return '$difference gün önce';

    return '${date.day}/${date.month}/${date.year}';
  }
}

// Tamamlanan egzersiz modeli
class CompletedExercise {
  final String name;
  final int sets;
  final int reps;
  final int? weight; // kg
  final int restSeconds;
  final bool completed;

  CompletedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    required this.restSeconds,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'completed': completed,
    };
  }
}

// Antrenman oturumu dialog'u
class WorkoutSessionDialog extends StatefulWidget {
  final WorkoutDay day;
  final Function(List<CompletedExercise>) onWorkoutCompleted;

  const WorkoutSessionDialog({
    super.key,
    required this.day,
    required this.onWorkoutCompleted,
  });

  @override
  State<WorkoutSessionDialog> createState() => _WorkoutSessionDialogState();
}

class _WorkoutSessionDialogState extends State<WorkoutSessionDialog> {
  List<CompletedExercise> _completedExercises = [];
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeExercises();
  }

  void _initializeExercises() {
    _completedExercises = widget.day.exercises.map((exercise) {
      return CompletedExercise(
        name: exercise.name,
        sets: exercise.sets,
        reps: exercise.reps,
        weight: null,
        restSeconds: exercise.restSeconds ?? 60,
        completed: false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentExerciseIndex >= _completedExercises.length) {
      return _buildCompletionScreen();
    }

    final currentExercise = _completedExercises[_currentExerciseIndex];

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Başlık
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Antrenman: ${widget.day.dayName}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.day.focus,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // İlerleme
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_currentExerciseIndex + 1}/${_completedExercises.length}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        (_currentExerciseIndex + 1) /
                        _completedExercises.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mevcut egzersiz
            Expanded(child: _buildExerciseScreen(currentExercise)),

            // Butonlar
            Row(
              children: [
                if (_currentExerciseIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousExercise,
                      child: const Text('Önceki'),
                    ),
                  ),
                if (_currentExerciseIndex > 0) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextExercise,
                    child: Text(
                      _currentExerciseIndex == _completedExercises.length - 1
                          ? 'Tamamla'
                          : 'Sonraki',
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

  Widget _buildExerciseScreen(CompletedExercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Egzersiz adı
            Text(
              exercise.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Set bilgileri
            Text(
              '${exercise.sets} set x ${exercise.reps} tekrar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Ağırlık girişi (opsiyonel)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ağırlık (kg) - Opsiyonel',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _completedExercises[_currentExerciseIndex] =
                      CompletedExercise(
                        name: exercise.name,
                        sets: exercise.sets,
                        reps: exercise.reps,
                        weight: value.isNotEmpty ? int.tryParse(value) : null,
                        restSeconds: exercise.restSeconds,
                        completed: exercise.completed,
                      );
                });
              },
            ),
            const SizedBox(height: 16),

            // Tamamlandı checkbox
            CheckboxListTile(
              title: const Text('Bu egzersizi tamamladım'),
              value: exercise.completed,
              onChanged: (value) {
                setState(() {
                  _completedExercises[_currentExerciseIndex] =
                      CompletedExercise(
                        name: exercise.name,
                        sets: exercise.sets,
                        reps: exercise.reps,
                        weight: exercise.weight,
                        restSeconds: exercise.restSeconds,
                        completed: value ?? false,
                      );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final completedCount = _completedExercises.where((e) => e.completed).length;
    final completionPercentage =
        (completedCount / _completedExercises.length) * 100;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Antrenman Tamamlandı!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$completedCount/${_completedExercises.length} egzersiz tamamlandı',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${completionPercentage.toStringAsFixed(1)}% Tamamlandı',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onWorkoutCompleted(_completedExercises);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _previousExercise() {
    setState(() {
      _currentExerciseIndex--;
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _completedExercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      // Son egzersiz, tamamlama ekranına git
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }
}
