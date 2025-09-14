import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel? userProfile;
  final VoidCallback onProfileUpdated;

  const ProfileSetupScreen({
    super.key,
    this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _experienceController = TextEditingController();
  final _weeklyFrequencyController = TextEditingController();
  final _preferredTimeController = TextEditingController();

  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedFitnessLevel;
  String? _selectedWorkoutLocation;
  List<String> _selectedEquipment = [];
  bool _isLoading = false;

  final List<String> _equipmentOptions = [
    'Dambıl',
    'Barbell',
    'Resistance Bands',
    'Kettlebell',
    'Pull-up Bar',
    'Bench',
    'Cardio Machine',
    'Yoga Mat',
    'Medicine Ball',
    'TRX',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.userProfile != null) {
      _nameController.text = widget.userProfile!.name ?? '';
      _ageController.text = widget.userProfile!.age?.toString() ?? '';
      _heightController.text = widget.userProfile!.height?.toString() ?? '';
      _weightController.text = widget.userProfile!.weight?.toString() ?? '';
      _bodyFatController.text = widget.userProfile!.bodyFat?.toString() ?? '';
      _muscleMassController.text =
          widget.userProfile!.muscleMass?.toString() ?? '';
      _experienceController.text = widget.userProfile!.experience ?? '';
      _weeklyFrequencyController.text =
          widget.userProfile!.weeklyFrequency?.toString() ?? '';
      _preferredTimeController.text = widget.userProfile!.preferredTime ?? '';
      _selectedGender = widget.userProfile!.gender;
      _selectedGoal = widget.userProfile!.goal;
      _selectedFitnessLevel = widget.userProfile!.fitnessLevel;
      _selectedWorkoutLocation = widget.userProfile!.workoutLocation;
      _selectedEquipment = widget.userProfile!.availableEquipment ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _experienceController.dispose();
    _weeklyFrequencyController.dispose();
    _preferredTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null ||
        _selectedGoal == null ||
        _selectedFitnessLevel == null ||
        _selectedWorkoutLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final profileData = {
          'email': user.email,
          'name': _nameController.text.trim(),
          'age': int.parse(_ageController.text),
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'gender': _selectedGender,
          'goal': _selectedGoal,
          'fitnessLevel': _selectedFitnessLevel,
          'workoutLocation': _selectedWorkoutLocation,
          'availableEquipment': _selectedEquipment,
          'bodyFat': _bodyFatController.text.isNotEmpty
              ? double.parse(_bodyFatController.text)
              : null,
          'muscleMass': _muscleMassController.text.isNotEmpty
              ? double.parse(_muscleMassController.text)
              : null,
          'experience': _experienceController.text.trim().isNotEmpty
              ? _experienceController.text.trim()
              : null,
          'weeklyFrequency': _weeklyFrequencyController.text.isNotEmpty
              ? int.parse(_weeklyFrequencyController.text)
              : null,
          'preferredTime': _preferredTimeController.text.trim().isNotEmpty
              ? _preferredTimeController.text.trim()
              : null,
          'updatedAt': DateTime.now(),
        };

        await FirebaseService.saveUserProfile(user.uid, profileData);
        widget.onProfileUpdated();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Kurulumu'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spor programınızı oluşturmak için profil bilgilerinizi tamamlayın',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Kişisel Bilgiler
              _buildSectionTitle('Kişisel Bilgiler'),
              CustomTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad soyad gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'Yaş',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yaş gerekli';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 10 || age > 100) {
                          return 'Geçerli bir yaş girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _heightController,
                      label: 'Boy (cm)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Boy gerekli';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'Geçerli bir boy girin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _weightController,
                label: 'Kilo (kg)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kilo gerekli';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 300) {
                    return 'Geçerli bir kilo girin';
                  }
                  return null;
                },
              ),

              // Fiziksel Özellikler (İsteğe bağlı)
              _buildSectionTitle('Fiziksel Özellikler (İsteğe Bağlı)'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _bodyFatController,
                      label: 'Yağ Oranı (%)',
                      hintText: '15.0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _muscleMassController,
                      label: 'Kas Kütlesi (kg)',
                      hintText: '35.0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // Fitness Bilgileri (İsteğe bağlı)
              _buildSectionTitle('Fitness Bilgileri (İsteğe Bağlı)'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _experienceController,
                label: 'Deneyim Süresi',
                hintText: 'Örn: 2 yıl, 6 ay',
              ),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _weeklyFrequencyController,
                      label: 'Haftalık Antrenman Sıklığı',
                      hintText: '3',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _preferredTimeController,
                      label: 'Tercih Edilen Antrenman Süresi',
                      hintText: '45 dakika',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cinsiyet Seçimi
              _buildSectionTitle('Cinsiyet'),
              _buildGenderSelector(),
              const SizedBox(height: 24),

              // Hedef Seçimi
              _buildSectionTitle('Hedef'),
              _buildGoalSelector(),
              const SizedBox(height: 24),

              // Spor Seviyesi
              _buildSectionTitle('Spor Seviyesi'),
              _buildFitnessLevelSelector(),
              const SizedBox(height: 24),

              // Antrenman Yeri
              _buildSectionTitle('Antrenman Yeri'),
              _buildWorkoutLocationSelector(),
              const SizedBox(height: 24),

              // Ekipmanlar
              _buildSectionTitle('Mevcut Ekipmanlar'),
              _buildEquipmentSelector(),
              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Profili Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Erkek'),
            value: 'male',
            groupValue: _selectedGender,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Kadın'),
            value: 'female',
            groupValue: _selectedGender,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelector() {
    final goals = [
      {'value': 'weight_loss', 'label': 'Kilo Verme'},
      {'value': 'muscle_gain', 'label': 'Kas Kazanma'},
      {'value': 'endurance', 'label': 'Dayanıklılık'},
      {'value': 'general_fitness', 'label': 'Genel Fitness'},
    ];

    return Column(
      children: goals
          .map(
            (goal) => RadioListTile<String>(
              title: Text(goal['label']!),
              value: goal['value']!,
              groupValue: _selectedGoal,
              onChanged: (value) => setState(() => _selectedGoal = value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFitnessLevelSelector() {
    final levels = [
      {'value': 'beginner', 'label': 'Başlangıç'},
      {'value': 'intermediate', 'label': 'Orta'},
      {'value': 'advanced', 'label': 'İleri'},
    ];

    return Column(
      children: levels
          .map(
            (level) => RadioListTile<String>(
              title: Text(level['label']!),
              value: level['value']!,
              groupValue: _selectedFitnessLevel,
              onChanged: (value) =>
                  setState(() => _selectedFitnessLevel = value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWorkoutLocationSelector() {
    final locations = [
      {'value': 'home', 'label': 'Ev'},
      {'value': 'gym', 'label': 'Spor Salonu'},
      {'value': 'outdoor', 'label': 'Açık Hava'},
    ];

    return Column(
      children: locations
          .map(
            (location) => RadioListTile<String>(
              title: Text(location['label']!),
              value: location['value']!,
              groupValue: _selectedWorkoutLocation,
              onChanged: (value) =>
                  setState(() => _selectedWorkoutLocation = value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEquipmentSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _equipmentOptions
          .map(
            (equipment) => FilterChip(
              label: Text(equipment),
              selected: _selectedEquipment.contains(equipment),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(equipment);
                  } else {
                    _selectedEquipment.remove(equipment);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }
}
