import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../services/program_sharing_service.dart';
import '../models/user_model.dart';
import '../models/workout_program.dart';
import 'profile_setup_screen.dart';
import 'profile_edit_screen.dart';
import 'workout_program_screen.dart';
import 'program_detail_screen.dart';
import 'exercise_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _userProfile;
  List<WorkoutProgram> _userPrograms = [];
  bool _isLoading = true;
  bool _isLoadingPrograms = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserPrograms();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.loadUserProfile();

      setState(() {
        _userProfile = authService.currentUser;
        _isLoading = false;
      });
    } catch (e) {
      print('Profil yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPrograms() async {
    if (_userProfile == null) {
      print('❌ UserProfile null, programlar yüklenemiyor');
      return;
    }

    print('🔄 Programlar yükleniyor... User ID: ${_userProfile!.id}');
    setState(() => _isLoadingPrograms = true);

    try {
      final programs = await GeminiService.getUserWorkoutPrograms(
        _userProfile!.id,
      );
      print('✅ ${programs.length} program yüklendi');
      for (var program in programs) {
        print('  📝 ${program.programName} - ${program.durationWeeks} hafta');
      }
      setState(() => _userPrograms = programs);
    } catch (e) {
      print('❌ Programlar yüklenirken hata: $e');
    } finally {
      setState(() => _isLoadingPrograms = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // AuthService'den güncel profil bilgisini al
        final currentUser = authService.currentUser;
        if (currentUser != null) {
          _userProfile = currentUser;
        }

        // Eğer profil tamamlanmamışsa profil kurulum ekranına yönlendir
        if (_userProfile == null || !_userProfile!.isProfileComplete) {
          return ProfileSetupScreen(
            userProfile: _userProfile,
            onProfileUpdated: _loadUserProfile,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('FitSun'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  ).then((_) {
                    // Profil düzenleme sayfasından dönüldüğünde profili yenile
                    _loadUserProfile();
                  });
                },
                tooltip: 'Profil Düzenle',
              ),
              IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hoş Geldin Mesajı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş geldin, ${_userProfile!.name ?? 'Sporcu'}!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hedefin: ${_getGoalText(_userProfile!.goal!)}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            'Seviyen: ${_getLevelText(_userProfile!.fitnessLevel!)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Program Oluştur Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutProgramScreen(
                              userProfile: _userProfile!,
                            ),
                          ),
                        );

                        // Program oluşturulduysa programları yenile
                        if (result == true) {
                          _loadUserPrograms();
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Yeni Program Oluştur'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Egzersiz Rehberi Butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExerciseGuideScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sports_gymnastics),
                      label: const Text('Egzersiz Rehberi'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hızlı Erişim Kartları
                  Text(
                    'Hızlı Erişim',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hızlı Erişim Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      // Su Takibi Kartı
                      _buildQuickAccessCard(
                        context: context,
                        title: 'Su Takibi',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                        onTap: () {
                          // Su takibi ekranına git
                          _showWaterTrackingDialog(context);
                        },
                      ),

                      // Antrenman Takibi Kartı
                      _buildQuickAccessCard(
                        context: context,
                        title: 'Antrenman',
                        icon: Icons.fitness_center,
                        color: Colors.orange,
                        onTap: () {
                          // Antrenman takibi ekranına git
                          _showWorkoutTrackingDialog(context);
                        },
                      ),

                      // Beslenme Takibi Kartı
                      _buildQuickAccessCard(
                        context: context,
                        title: 'Beslenme',
                        icon: Icons.restaurant,
                        color: Colors.green,
                        onTap: () {
                          // Beslenme takibi ekranına git
                          _showNutritionTrackingDialog(context);
                        },
                      ),

                      // İstatistikler Kartı
                      _buildQuickAccessCard(
                        context: context,
                        title: 'İstatistikler',
                        icon: Icons.analytics,
                        color: Colors.purple,
                        onTap: () {
                          // İstatistikler ekranına git
                          _showStatisticsDialog(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Programlarım Kısmı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Programlarım',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadUserPrograms,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Yenile',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingPrograms)
                    const Center(child: CircularProgressIndicator())
                  else if (_userPrograms.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz program oluşturmadın',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yukarıdaki butona tıklayarak ilk programını oluştur!',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._userPrograms.map(
                      (program) => _buildProgramCard(program),
                    ),

                  const SizedBox(height: 24),

                  // Profil Bilgileri
                  Text(
                    'Profil Bilgileri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildProfileRow('Yaş', '${_userProfile!.age}'),
                          _buildProfileRow('Boy', '${_userProfile!.height} cm'),
                          _buildProfileRow(
                            'Kilo',
                            '${_userProfile!.weight} kg',
                          ),
                          _buildProfileRow(
                            'Cinsiyet',
                            _getGenderText(_userProfile!.gender!),
                          ),
                          _buildProfileRow(
                            'Antrenman Yeri',
                            _getLocationText(_userProfile!.workoutLocation!),
                          ),
                          if (_userProfile!.availableEquipment != null &&
                              _userProfile!.availableEquipment!.isNotEmpty)
                            _buildProfileRow(
                              'Ekipmanlar',
                              _userProfile!.availableEquipment!.join(', '),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgramCard(WorkoutProgram program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(Icons.fitness_center, color: Colors.white),
        ),
        title: Text(
          program.programName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(program.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildProgramChip(
                  '${program.durationWeeks} hafta',
                  Icons.calendar_today,
                ),
                const SizedBox(width: 8),
                _buildProgramChip(
                  _getDifficultyText(program.difficulty),
                  Icons.trending_up,
                ),
                const SizedBox(width: 8),
                _buildProgramChip(
                  '${program.weeklySchedule.length} gün',
                  Icons.schedule,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewProgram(program);
                break;
              case 'share':
                _shareProgram(program);
                break;
              case 'delete':
                _deleteProgram(program);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Görüntüle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Paylaş', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _viewProgram(program),
      ),
    );
  }

  Widget _buildProgramChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _viewProgram(WorkoutProgram program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramDetailScreen(program: program),
      ),
    );
  }

  Future<void> _shareProgram(WorkoutProgram program) async {
    try {
      await ProgramSharingService.shareProgram(program);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program başarıyla paylaşıldı!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProgram(WorkoutProgram program) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Programı Sil'),
        content: Text(
          '${program.programName} programını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GeminiService.deleteWorkoutProgram(_userProfile!.id, program.id);
        _loadUserPrograms(); // Programları yeniden yükle
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Program başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Program silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Kilo Verme';
      case 'muscle_gain':
        return 'Kas Kazanma';
      case 'endurance':
        return 'Dayanıklılık';
      case 'general_fitness':
        return 'Genel Fitness';
      default:
        return goal;
    }
  }

  String _getLevelText(String level) {
    switch (level) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return level;
    }
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

  String _getGenderText(String gender) {
    switch (gender) {
      case 'male':
        return 'Erkek';
      case 'female':
        return 'Kadın';
      case 'other':
        return 'Diğer';
      default:
        return gender;
    }
  }

  String _getLocationText(String location) {
    switch (location) {
      case 'home':
        return 'Ev';
      case 'gym':
        return 'Spor Salonu';
      case 'outdoor':
        return 'Açık Hava';
      default:
        return location;
    }
  }

  // Hızlı Erişim Kartı Widget'ı
  Widget _buildQuickAccessCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Su Takibi Dialog'u
  void _showWaterTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Su Takibi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Su tüketiminizi takip edin ve hedeflerinize ulaşın!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Su ekleme ekranına git
                    _showAddWaterDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Su Ekle'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Su geçmişi ekranına git
                    _showWaterHistoryDialog(context);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Geçmiş'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Antrenman Takibi Dialog'u
  void _showWorkoutTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antrenman Takibi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Antrenmanlarınızı kaydedin ve ilerlemenizi takip edin!',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Yeni antrenman ekranına git
                    _showNewWorkoutDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Antrenman'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Antrenman geçmişi ekranına git
                    _showWorkoutHistoryDialog(context);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Geçmiş'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Beslenme Takibi Dialog'u
  void _showNutritionTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beslenme Takibi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Beslenme planınızı takip edin ve hedeflerinize ulaşın!',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Beslenme ekleme ekranına git
                    _showAddNutritionDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Yemek Ekle'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Beslenme geçmişi ekranına git
                    _showNutritionHistoryDialog(context);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Geçmiş'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // İstatistikler Dialog'u
  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İstatistikler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('İlerlemenizi ve başarılarınızı görün!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Haftalık istatistikler ekranına git
                    _showWeeklyStatsDialog(context);
                  },
                  icon: const Icon(Icons.calendar_view_week),
                  label: const Text('Haftalık'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Aylık istatistikler ekranına git
                    _showMonthlyStatsDialog(context);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Aylık'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Su Ekleme Dialog'u
  void _showAddWaterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Su Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ne kadar su içtiniz?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('250ml su eklendi! 💧');
                  },
                  child: const Text('250ml'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('500ml su eklendi! 💧');
                  },
                  child: const Text('500ml'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('1000ml su eklendi! 💧');
                  },
                  child: const Text('1000ml'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  // Su Geçmişi Dialog'u
  void _showWaterHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Su Geçmişi'),
        content: const Text('Su tüketim geçmişiniz burada görünecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Yeni Antrenman Dialog'u
  void _showNewWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Antrenman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hangi tür antrenman yaptınız?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Kardiyo antrenmanı kaydedildi! 🏃‍♂️');
                  },
                  icon: const Icon(Icons.directions_run),
                  label: const Text('Kardiyo'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Güç antrenmanı kaydedildi! 💪');
                  },
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Güç'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  // Antrenman Geçmişi Dialog'u
  void _showWorkoutHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Antrenman Geçmişi'),
        content: const Text('Antrenman geçmişiniz burada görünecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Beslenme Ekleme Dialog'u
  void _showAddNutritionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beslenme Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hangi öğünü eklemek istiyorsunuz?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Kahvaltı eklendi! 🍳');
                  },
                  icon: const Icon(Icons.breakfast_dining),
                  label: const Text('Kahvaltı'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Öğle yemeği eklendi! 🍽️');
                  },
                  icon: const Icon(Icons.lunch_dining),
                  label: const Text('Öğle'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSuccessMessage('Akşam yemeği eklendi! 🍽️');
                  },
                  icon: const Icon(Icons.dinner_dining),
                  label: const Text('Akşam'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  // Beslenme Geçmişi Dialog'u
  void _showNutritionHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beslenme Geçmişi'),
        content: const Text('Beslenme geçmişiniz burada görünecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Haftalık İstatistikler Dialog'u
  void _showWeeklyStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Haftalık İstatistikler'),
        content: const Text('Bu haftaki ilerlemeniz burada görünecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Aylık İstatistikler Dialog'u
  void _showMonthlyStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aylık İstatistikler'),
        content: const Text('Bu ayki ilerlemeniz burada görünecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Başarı Mesajı Göster
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
