# 🚀 FitSun Kurulum Rehberi

Bu dosya, FitSun uygulamasını yerel ortamınızda çalıştırmak için gerekli adımları içerir.

## 📋 Ön Gereksinimler

### 1. Flutter SDK
- Flutter SDK 3.8.1 veya üzeri
- Dart SDK (Flutter ile birlikte gelir)

### 2. Geliştirme Ortamı
- **Android**: Android Studio + Android SDK
- **iOS**: Xcode (sadece macOS)
- **Web**: Chrome browser

### 3. Firebase Projesi
- Firebase Console hesabı
- Yeni Firebase projesi oluşturma yetkisi

### 4. Google AI API
- Google AI Studio hesabı
- Gemini API erişimi

## 🔧 Detaylı Kurulum

### Adım 1: Flutter Kurulumu
```bash
# Flutter SDK'yı indirin ve kurun
# https://flutter.dev/docs/get-started/install

# Kurulumu doğrulayın
flutter doctor
```

### Adım 2: Proje Klonlama
```bash
git clone https://github.com/yourusername/fitsun-app.git
cd fitsun-app
```

### Adım 3: Bağımlılıkları Yükleme
```bash
flutter pub get
```

### Adım 4: Firebase Konfigürasyonu

#### 4.1 Firebase Projesi Oluşturma
1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" butonuna tıklayın
3. Proje adını girin (örn: `fitsun-app`)
4. Google Analytics'i etkinleştirin (isteğe bağlı)

#### 4.2 Authentication Kurulumu
1. Firebase Console'da "Authentication" sekmesine gidin
2. "Get started" butonuna tıklayın
3. "Sign-in method" sekmesinde Email/Password'u etkinleştirin

#### 4.3 Firestore Kurulumu
1. "Firestore Database" sekmesine gidin
2. "Create database" butonuna tıklayın
3. "Start in test mode" seçin (geliştirme için)
4. Konum seçin (örn: `europe-west1`)

#### 4.4 Storage Kurulumu
1. "Storage" sekmesine gidin
2. "Get started" butonuna tıklayın
3. "Start in test mode" seçin

#### 4.5 Android Konfigürasyonu
1. Firebase Console'da "Project settings" > "General" sekmesine gidin
2. "Add app" > "Android" seçin
3. Package name: `com.isimsizacemi.fitsun` girin
4. `google-services.json` dosyasını indirin
5. Dosyayı `android/app/` klasörüne yerleştirin

#### 4.6 iOS Konfigürasyonu (macOS kullanıcıları için)
1. Firebase Console'da "Add app" > "iOS" seçin
2. Bundle ID: `com.isimsizacemi.fitsun` girin
3. `GoogleService-Info.plist` dosyasını indirin
4. Dosyayı `ios/Runner/` klasörüne yerleştirin

### Adım 5: Google Gemini AI Konfigürasyonu

#### 5.1 API Key Alma
1. [Google AI Studio](https://aistudio.google.com/)'ya gidin
2. "Get API key" butonuna tıklayın
3. Yeni API key oluşturun
4. Key'i kopyalayın

#### 5.2 API Key'i Projeye Ekleme
1. `lib/services/gemini_service.dart` dosyasını açın
2. `YOUR_GEMINI_API_KEY_HERE` yerine gerçek API key'inizi yazın:

```dart
static const String _apiKey = 'AIzaSy...'; // Gerçek key'inizi buraya yazın
```

### Adım 6: Uygulamayı Çalıştırma

#### Android için:
```bash
flutter run
```

#### iOS için (macOS):
```bash
flutter run -d ios
```

#### Web için:
```bash
flutter run -d web
```

## 🔒 Güvenlik Notları

### API Key Güvenliği
- **ASLA** API key'lerinizi public repository'ye commit etmeyin
- Production ortamında environment variable kullanın
- API key'lerinizi düzenli olarak yenileyin

### Firebase Güvenlik Kuralları
- Geliştirme aşamasında test mode kullanın
- Production'a geçerken güvenlik kurallarını güncelleyin
- Kullanıcı yetkilendirmelerini kontrol edin

## 🐛 Sorun Giderme

### Yaygın Hatalar

#### 1. "No devices found"
```bash
# Android emülatörü başlatın
flutter emulators --launch <emulator_id>

# Veya fiziksel cihaz bağlayın
flutter devices
```

#### 2. "Firebase not initialized"
- `google-services.json` ve `GoogleService-Info.plist` dosyalarının doğru konumda olduğunu kontrol edin
- Firebase projesinin doğru konfigüre edildiğini kontrol edin

#### 3. "API key invalid"
- Gemini API key'inin doğru olduğunu kontrol edin
- API key'in aktif olduğunu kontrol edin
- Quota limitlerini kontrol edin

#### 4. Build hataları
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

## 📞 Destek

Sorun yaşıyorsanız:
1. [Issues](https://github.com/yourusername/fitsun-app/issues) sekmesinde arama yapın
2. Yeni issue oluşturun
3. Detaylı hata mesajlarını paylaşın

## 📚 Ek Kaynaklar

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Gemini AI Documentation](https://ai.google.dev/docs)
- [Material Design Guidelines](https://material.io/design)

---

**Not**: Bu kurulum rehberi geliştirme ortamı için hazırlanmıştır. Production ortamı için ek güvenlik önlemleri alınmalıdır.
