import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/workout_program.dart';
import '../services/gemini_service.dart';

class WorkoutProgramScreen extends StatefulWidget {
  final UserModel userProfile;

  const WorkoutProgramScreen({super.key, required this.userProfile});

  @override
  State<WorkoutProgramScreen> createState() => _WorkoutProgramScreenState();
}

class _WorkoutProgramScreenState extends State<WorkoutProgramScreen> {
  WorkoutProgram? _workoutProgram;
  bool _isLoading = false;

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

        setState(() => _workoutProgram = program);
        _showSuccessSnackBar('🎉 Program başarıyla oluşturuldu!');

        // Ana ekrana dön ve programları yenile
        Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text('Spor Programı')),
      body: _workoutProgram == null
          ? _buildGenerateScreen()
          : _buildProgramScreen(),
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

  Widget _buildProgramScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Başlığı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _workoutProgram!.programName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _workoutProgram!.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${_workoutProgram!.durationWeeks} Hafta',
                        Icons.calendar_today,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        _getDifficultyText(_workoutProgram!.difficulty),
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Yeniden Oluştur Butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _generateWorkoutProgram,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _isLoading
                    ? 'Yeniden Oluşturuluyor...'
                    : 'Yeni Program Oluştur',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Haftalık Program
          Text(
            'Haftalık Program',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ..._workoutProgram!.weeklySchedule.map(
            (day) => _buildWorkoutDay(day),
          ),
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

  Widget _buildWorkoutDay(WorkoutDay day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          day.dayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(day.focus),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (day.estimatedDuration != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tahmini Süre: ${day.estimatedDuration} dakika',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (day.notes != null && day.notes!.isNotEmpty) ...[
                  Text(
                    'Notlar: ${day.notes}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Egzersizler:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...day.exercises.map((exercise) => _buildExercise(exercise)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise(Exercise exercise) {
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
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${exercise.sets} x ${exercise.reps}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (exercise.weight != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ağırlık: ${exercise.weight}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (exercise.restSeconds != null) ...[
            const SizedBox(height: 4),
            Text(
              'Dinlenme: ${exercise.restSeconds} saniye',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Not: ${exercise.notes}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  String _getDifficultyText(String difficulty) {
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
}
