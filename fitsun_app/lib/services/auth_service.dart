import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Kullanıcı giriş yaptığında profil bilgilerini yükle
  Future<void> loadUserProfile() async {
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final doc = await FirebaseService.getUserProfile(user.uid);
        if (doc != null && doc.exists) {
          _currentUser = UserModel.fromMap(
            doc.data()! as Map<String, dynamic>,
            user.uid,
          );
        } else {
          // Profil yoksa temel bilgilerle oluştur
          _currentUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await FirebaseService.saveUserProfile(
            user.uid,
            _currentUser!.toMap(),
          );
        }
        notifyListeners(); // Profil yüklendiğinde UI'yi güncelle
      } else {
        _currentUser = null;
        notifyListeners();
      }
    } catch (e) {
      print('Profil yükleme hatası: $e');
      _currentUser = null;
      notifyListeners();
    }
  }

  // Kullanıcı profilini güncelle
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      print('Profil güncelleniyor: ${updatedUser.name}');
      
      await FirebaseService.updateUserProfile(
        updatedUser.id,
        updatedUser.toMap(),
      );
      
      _currentUser = updatedUser;
      notifyListeners();
      
      print('Profil başarıyla güncellendi');
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      print('Hata türü: ${e.runtimeType}');
      rethrow;
    }
  }

  // Kullanıcı çıkış yaptığında temizle
  void clearUser() {
    _currentUser = null;
  }

  // Kullanıcı giriş yaptığında çağır
  Future<void> onUserSignIn() async {
    await loadUserProfile();
    notifyListeners();
  }

  // Kullanıcı çıkış yaptığında çağır
  void onUserSignOut() {
    clearUser();
    notifyListeners();
  }
}
