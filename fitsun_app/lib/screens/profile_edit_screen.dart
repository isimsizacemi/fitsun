import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bodyFatController;
  late TextEditingController _muscleMassController;
  late TextEditingController _experienceController;
  late TextEditingController _weeklyFrequencyController;
  late TextEditingController _preferredTimeController;

  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedFitnessLevel;
  String? _selectedWorkoutLocation;
  List<String> _selectedEquipment = [];

  final List<String> _genderOptions = ['Erkek', 'Kadın', 'Diğer'];
  final List<String> _goalOptions = [
    'Kilo Verme',
    'Kas Kazanımı',
    'Dayanıklılık',
    'Genel Fitness',
  ];

  final Map<String, String> _genderValueMap = {
    'Erkek': 'male',
    'Kadın': 'female',
    'Diğer': 'other',
  };

  final Map<String, String> _genderDisplayMap = {
    'male': 'Erkek',
    'female': 'Kadın',
    'other': 'Diğer',
  };

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
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _bodyFatController = TextEditingController();
    _muscleMassController = TextEditingController();
    _experienceController = TextEditingController();
    _weeklyFrequencyController = TextEditingController();
    _preferredTimeController = TextEditingController();
  }

  void _loadUserData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Profil verilerini yükle
      await authService.loadUserProfile();

      final user = authService.currentUser;
      if (user != null) {
        // Text controller'ları güncelle
        _nameController.text = user.name ?? '';
        _ageController.text = user.age?.toString() ?? '';
        _heightController.text = user.height?.toString() ?? '';
        _weightController.text = user.weight?.toString() ?? '';
        _bodyFatController.text = user.bodyFat?.toString() ?? '';
        _muscleMassController.text = user.muscleMass?.toString() ?? '';
        _experienceController.text = user.experience ?? '';
        _weeklyFrequencyController.text =
            user.weeklyFrequency?.toString() ?? '';
        _preferredTimeController.text = user.preferredTime ?? '';

        // Dropdown değerlerini güncelle
        _selectedGender = _genderDisplayMap[user.gender] ?? user.gender;
        _selectedGoal = _goalDisplayMap[user.goal] ?? user.goal;
        _selectedFitnessLevel =
            _fitnessLevelDisplayMap[user.fitnessLevel] ?? user.fitnessLevel;
        _selectedWorkoutLocation = _workoutLocationDisplayMap[user.workoutLocation] ?? user.workoutLocation;
        _selectedEquipment = List<String>.from(user.availableEquipment ?? []);

        print('✅ Profil verileri yüklendi: ${user.name}');
        print('✅ Cinsiyet: $_selectedGender');
        print('✅ Hedef: $_selectedGoal');
        print('✅ Fitness Seviyesi: $_selectedFitnessLevel');
        print('✅ Antrenman Yeri: $_selectedWorkoutLocation');
        print('✅ Ekipmanlar: $_selectedEquipment');

        if (mounted) {
          setState(() {});
        }
      } else {
        print('❌ Kullanıcı bilgisi bulunamadı');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Profil yükleme hatası: $e');
      if (mounted) {
        String errorMessage = 'Profil yüklenirken hata oluştu';
        if (e.toString().contains('SocketException')) {
          errorMessage =
              'İnternet bağlantısı hatası. Bağlantınızı kontrol edin.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Bağlantı zaman aşımı. Tekrar deneyin.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
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

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        age: _ageController.text.trim().isEmpty
            ? null
            : int.tryParse(_ageController.text),
        height: _heightController.text.trim().isEmpty
            ? null
            : double.tryParse(_heightController.text),
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text),
        gender: _selectedGender != null
            ? (_genderValueMap[_selectedGender] ?? _selectedGender)
            : null,
        goal: _selectedGoal != null
            ? (_goalValueMap[_selectedGoal] ?? _selectedGoal)
            : null,
        fitnessLevel: _selectedFitnessLevel != null
            ? (_fitnessLevelValueMap[_selectedFitnessLevel] ??
                  _selectedFitnessLevel)
            : null,
        workoutLocation: _selectedWorkoutLocation != null ? (_workoutLocationValueMap[_selectedWorkoutLocation] ?? _selectedWorkoutLocation) : null,
        availableEquipment: _selectedEquipment.isEmpty
            ? null
            : _selectedEquipment,
        bodyFat: _bodyFatController.text.trim().isEmpty
            ? null
            : double.tryParse(_bodyFatController.text),
        muscleMass: _muscleMassController.text.trim().isEmpty
            ? null
            : double.tryParse(_muscleMassController.text),
        experience: _experienceController.text.trim().isEmpty
            ? null
            : _experienceController.text.trim(),
        weeklyFrequency: _weeklyFrequencyController.text.trim().isEmpty
            ? null
            : int.tryParse(_weeklyFrequencyController.text),
        preferredTime: _preferredTimeController.text.trim().isEmpty
            ? null
            : _preferredTimeController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await authService.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Profil kaydetme hatası: $e');
      if (mounted) {
        String errorMessage = 'Profil kaydedilirken hata oluştu';
        if (e.toString().contains('SocketException')) {
          errorMessage =
              'İnternet bağlantısı hatası. Bağlantınızı kontrol edin.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Bağlantı zaman aşımı. Tekrar deneyin.';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'Yetki hatası. Lütfen tekrar giriş yapın.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Ana Sayfa',
          ),
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              Navigator.pushNamed(context, '/workout-program');
            },
            tooltip: 'Spor Programı',
          ),
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kişisel Bilgiler
              _buildSectionTitle('Kişisel Bilgiler'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                hint: 'Adınızı ve soyadınızı girin',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 2) {
                      return 'Ad soyad en az 2 karakter olmalıdır';
                    }
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _ageController,
                label: 'Yaş',
                hint: 'Yaşınızı girin',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 13 || age > 100) {
                      return 'Geçerli bir yaş girin (13-100)';
                    }
                  }
                  return null;
                },
              ),

              _buildDropdownField(
                label: 'Cinsiyet',
                value: _selectedGender,
                items: _genderOptions,
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: null, // Cinsiyet zorunlu değil
              ),

              const SizedBox(height: 24),

              // Fiziksel Özellikler
              _buildSectionTitle('Fiziksel Özellikler'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Boy (cm)',
                      hint: '170',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final height = double.tryParse(value);
                          if (height == null || height < 100 || height > 250) {
                            return 'Geçerli boy girin (100-250 cm)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Kilo (kg)',
                      hint: '70',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 30 || weight > 300) {
                            return 'Geçerli kilo girin (30-300 kg)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _bodyFatController,
                      label: 'Yağ Oranı (%)',
                      hint: '15.0',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final bodyFat = double.tryParse(value);
                          if (bodyFat == null || bodyFat < 0 || bodyFat > 50) {
                            return 'Geçerli yağ oranı girin (0-50%)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _muscleMassController,
                      label: 'Kas Kütlesi (kg)',
                      hint: '35.0',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final muscleMass = double.tryParse(value);
                          if (muscleMass == null ||
                              muscleMass < 0 ||
                              muscleMass > 100) {
                            return 'Geçerli kas kütlesi girin (0-100 kg)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Fitness Bilgileri
              _buildSectionTitle('Fitness Bilgileri'),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Hedef',
                value: _selectedGoal,
                items: _goalOptions,
                onChanged: (value) => setState(() => _selectedGoal = value),
                validator: null, // Hedef zorunlu değil
              ),

              _buildDropdownField(
                label: 'Fitness Seviyesi',
                value: _selectedFitnessLevel,
                items: _fitnessLevelOptions,
                onChanged: (value) =>
                    setState(() => _selectedFitnessLevel = value),
                validator: null, // Fitness seviyesi zorunlu değil
              ),

              _buildDropdownField(
                label: 'Antrenman Yeri',
                value: _selectedWorkoutLocation,
                items: _workoutLocationOptions,
                onChanged: (value) =>
                    setState(() => _selectedWorkoutLocation = value),
                validator: null, // Antrenman yeri zorunlu değil
              ),

              _buildTextField(
                controller: _experienceController,
                label: 'Deneyim Süresi',
                hint: 'Örn: 2 yıl, 6 ay',
                validator: null, // Deneyim süresi zorunlu değil
              ),

              _buildTextField(
                controller: _weeklyFrequencyController,
                label: 'Haftalık Antrenman Sıklığı',
                hint: '3',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final frequency = int.tryParse(value);
                    if (frequency == null || frequency < 1 || frequency > 7) {
                      return 'Geçerli sıklık girin (1-7)';
                    }
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _preferredTimeController,
                label: 'Tercih Edilen Antrenman Süresi',
                hint: 'Örn: 45 dakika, 1 saat',
                validator: null, // Antrenman süresi zorunlu değil
              ),

              const SizedBox(height: 24),

              // Ekipman Seçimi
              _buildSectionTitle('Mevcut Ekipmanlar'),
              const SizedBox(height: 16),

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

              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Profili Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
