import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firebase_service.dart';
import 'services/gemini_service.dart';
import 'models/user_model.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const FitSunApp());
}

class FitSunApp extends StatelessWidget {
  const FitSunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSun - AI Spor Programı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Yeşil tema
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: StreamBuilder(
        stream: FirebaseService.auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const ProfileCheckScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

class ProfileCheckScreen extends StatefulWidget {
  const ProfileCheckScreen({super.key});

  @override
  State<ProfileCheckScreen> createState() => _ProfileCheckScreenState();
}

class _ProfileCheckScreenState extends State<ProfileCheckScreen> {
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final userProfile = await GeminiService.getUserProfile(user.uid);
        setState(() {
          _user = userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Profil kontrol hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Profil kontrol ediliyor...'),
            ],
          ),
        ),
      );
    }

    if (_user == null || !_user!.isProfileComplete) {
      return ProfileSetupScreen(
        userProfile: _user,
        onProfileUpdated: () {
          // Profil güncellendiğinde yeniden kontrol et
          _checkProfile();
        },
      );
    }

    return const HomeScreen();
  }
}
