import 'package:flutter/material.dart';
import '../models/exercise_detail.dart';
import '../services/exercise_database_service.dart';
import 'exercise_detail_screen.dart';

class ExerciseGuideScreen extends StatefulWidget {
  const ExerciseGuideScreen({super.key});

  @override
  State<ExerciseGuideScreen> createState() => _ExerciseGuideScreenState();
}

class _ExerciseGuideScreenState extends State<ExerciseGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ExerciseDetail> _allExercises = [];
  List<ExerciseDetail> _filteredExercises = [];
  String _selectedCategory = 'Tümü';
  String _selectedDifficulty = 'Tümü';
  bool _isLoading = true;

  final List<String> _categories = [
    'Tümü',
    'Göğüs',
    'Sırt',
    'Bacak',
    'Omuz',
    'Kol',
    'Core',
    'HIIT',
    'Yoga',
    'Pilates',
    'Kardiyovasküler',
    'Esneklik',
    'Fonksiyonel',
    'Güç',
    'Dayanıklılık',
  ];

  final List<String> _difficulties = [
    'Tümü',
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      _isLoading = true;
    });

    // Simüle edilmiş yükleme süresi
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _allExercises = ExerciseDatabaseService.getAllExercises();
        _filteredExercises = _allExercises;
        _isLoading = false;
      });
    });
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        // Kategori filtresi
        bool categoryMatch = _selectedCategory == 'Tümü' || 
            exercise.category == _selectedCategory;
        
        // Zorluk filtresi
        bool difficultyMatch = _selectedDifficulty == 'Tümü' || 
            _getDifficultyText(exercise.difficulty) == _selectedDifficulty;
        
        // Arama filtresi
        bool searchMatch = _searchController.text.isEmpty ||
            exercise.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            exercise.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            exercise.muscleGroups.any((muscle) => 
                muscle.toLowerCase().contains(_searchController.text.toLowerCase()));
        
        return categoryMatch && difficultyMatch && searchMatch;
      }).toList();
    });
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersiz Rehberi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Filtreler
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Arama çubuğu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Egzersiz ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterExercises();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => _filterExercises(),
                ),
                const SizedBox(height: 16),
                
                // Filtreler
                Row(
                  children: [
                    // Kategori filtresi
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                          _filterExercises();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Zorluk filtresi
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Zorluk',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _difficulties.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                          _filterExercises();
                        },
                      ),
                    ),
                  ],
                ),
                
                // Sonuç sayısı
                const SizedBox(height: 16),
                Text(
                  '${_filteredExercises.length} egzersiz bulundu',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Egzersiz listesi
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Egzersizler yükleniyor...'),
                      ],
                    ),
                  )
                : _filteredExercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aradığınız kriterlere uygun egzersiz bulunamadı',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Farklı arama terimleri veya filtreler deneyin',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          return _buildExerciseCard(context, exercise);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseDetail exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToExerciseDetail(context, exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve zorluk
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 18,
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
                      color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDifficultyColor(exercise.difficulty),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getDifficultyText(exercise.difficulty),
                      style: TextStyle(
                        color: _getDifficultyColor(exercise.difficulty),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Açıklama
              Text(
                exercise.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Kategori ve kas grupları
              Row(
                children: [
                  // Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exercise.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Kas grupları
                  Expanded(
                    child: Text(
                      exercise.muscleGroups.join(', '),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Ekipman
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      exercise.equipment.join(', '),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExerciseDetail(BuildContext context, ExerciseDetail exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exerciseName: exercise.name,
          exerciseDetail: exercise,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
