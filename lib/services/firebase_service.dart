import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<void> initialize() async {
    try {
      print('🔥 Firebase başlatılıyor...');
      await Firebase.initializeApp();
      print('✅ Firebase başarıyla başlatıldı');

      // Firebase bağlantısını test et
      await _testFirebaseConnection();
    } catch (e) {
      print('❌ Firebase başlatma hatası: $e');
      print('🔧 Hata türü: ${e.runtimeType}');

      // Google API hatası için özel mesaj
      if (e.toString().contains('GoogleApiManager') ||
          e.toString().contains('Unknown calling package')) {
        print('⚠️ Google API Manager hatası tespit edildi');
        print(
          '💡 Bu hata genellikle Google Play Services güncellemesi gerektirir',
        );
      }

      // Firebase'i tekrar başlatmayı dene
      try {
        print('🔄 Firebase tekrar başlatılıyor...');
        await Firebase.initializeApp();
        print('✅ Firebase ikinci denemede başarılı');
      } catch (retryError) {
        print('❌ Firebase ikinci deneme de başarısız: $retryError');
        // Uygulama çalışmaya devam etsin, sadece Firebase özellikleri çalışmayabilir
      }
    }
  }

  static Future<void> _testFirebaseConnection() async {
    try {
      print('🔍 Firebase bağlantısı test ediliyor...');

      // Firestore bağlantısını test et
      await firestore.collection('test').limit(1).get();
      print('✅ Firestore bağlantısı başarılı');

      // Auth bağlantısını test et
      final currentUser = auth.currentUser;
      print(
        '✅ Auth bağlantısı başarılı - Mevcut kullanıcı: ${currentUser?.uid ?? 'Yok'}',
      );
    } catch (e) {
      print('⚠️ Firebase bağlantı testi hatası: $e');
      // Bu hata kritik değil, uygulama çalışmaya devam edebilir
    }
  }

  // Google API hatası kontrolü
  static bool _isGoogleApiError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('googleapimanager') ||
        errorString.contains('unknown calling package') ||
        errorString.contains('securityexception') ||
        errorString.contains('google play services');
  }

  // Auth methods
  static Future<UserCredential?> signUp(String email, String password) async {
    try {
      print('Attempting to sign up with email: $email');
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign up successful: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('Sign up error: $e');
      print('Error type: ${e.runtimeType}');

      if (_isGoogleApiError(e)) {
        print('⚠️ Google API hatası tespit edildi');
        print('💡 Çözüm önerileri:');
        print('   1. Google Play Services güncelleyin');
        print('   2. Cihazı yeniden başlatın');
        print('   3. Google hesabınızı yeniden ekleyin');
      }

      if (e is FirebaseAuthException) {
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
      }
      return null;
    }
  }

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');

      if (_isGoogleApiError(e)) {
        print('⚠️ Google API hatası tespit edildi');
        print('💡 Çözüm önerileri:');
        print('   1. Google Play Services güncelleyin');
        print('   2. Cihazı yeniden başlatın');
        print('   3. Google hesabınızı yeniden ekleyin');
      }

      return null;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static User? get currentUser => auth.currentUser;

  // Firestore methods
  static Future<void> saveUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await firestore.collection('users').doc(userId).set(profileData);
    } catch (e) {
      print('Save profile error: $e');
    }
  }

  static Future<DocumentSnapshot?> getUserProfile(String userId) async {
    try {
      return await firestore.collection('users').doc(userId).get();
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Update profile error: $e');
    }
  }
}
