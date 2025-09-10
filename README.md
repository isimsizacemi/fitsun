# FitSun - AI Destekli Spor Programı Uygulaması

FitSun, kullanıcıların profil bilgilerine göre kişiselleştirilmiş spor programları oluşturan AI destekli mobil uygulamadır.

## 🚀 Özellikler

- 🔐 **Kullanıcı Kimlik Doğrulama**: Firebase Authentication ile güvenli giriş/kayıt
- 👤 **Profil Yönetimi**: Detaylı kullanıcı profili oluşturma ve düzenleme
- 🤖 **AI Destekli Program Oluşturma**: Google Gemini AI ile kişiselleştirilmiş spor programları
- 📱 **Modern UI/UX**: Material Design 3 ile modern ve kullanıcı dostu arayüz
- 🔥 **Firebase Entegrasyonu**: Firestore ile veri saklama ve senkronizasyon
- 🏋️ **Detaylı Egzersiz Programları**: Haftalık ve günlük antrenman planları

## 🛠️ Teknolojiler

### Frontend (Flutter)
- **Flutter** - Cross-platform mobil uygulama geliştirme
- **Firebase Auth** - Kullanıcı kimlik doğrulama
- **Cloud Firestore** - NoSQL veritabanı
- **Google Fonts** - Tipografi
- **Provider** - State management

### Backend (Node.js)
- **Express.js** - Web framework
- **Firebase Admin SDK** - Firebase backend entegrasyonu
- **Google Gemini AI** - AI spor programı oluşturma
- **CORS** - Cross-origin resource sharing

## 📋 Kurulum

### 1. Flutter Uygulaması

```bash
cd fitsun_app
flutter pub get
```

### 2. Backend Servisi

```bash
cd backend
npm install
```

### 3. Environment Variables

Backend için `.env` dosyası oluşturun:

```env
PORT=3000
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY="your_private_key"
FIREBASE_CLIENT_EMAIL=your_client_email
GEMINI_API_KEY=your_gemini_api_key
```

## 🚀 Çalıştırma

### Backend Servisi
```bash
cd backend
npm start
# veya development için
npm run dev
```

### Flutter Uygulaması
```bash
cd fitsun_app
flutter run
```

## 📱 Kullanım

1. **Kayıt/Giriş**: E-posta ve şifre ile hesap oluşturun veya giriş yapın
2. **Profil Oluşturma**: Yaş, boy, kilo, cinsiyet, hedef, spor seviyesi ve ekipman bilgilerinizi girin
3. **Program Oluşturma**: "Yeni Program Oluştur" butonuna tıklayarak AI destekli spor programınızı oluşturun
4. **Program Görüntüleme**: Haftalık ve günlük antrenman planlarınızı inceleyin

## 🏗️ Proje Yapısı

```
fitSun/
├── fitsun_app/                 # Flutter uygulaması
│   ├── lib/
│   │   ├── models/            # Veri modelleri
│   │   ├── screens/           # UI ekranları
│   │   ├── services/          # API servisleri
│   │   ├── widgets/           # Özel widget'lar
│   │   └── utils/             # Yardımcı fonksiyonlar
│   ├── android/               # Android konfigürasyonu
│   └── ios/                   # iOS konfigürasyonu
└── backend/                   # Node.js backend
    ├── server.js              # Ana server dosyası
    ├── package.json           # NPM bağımlılıkları
    └── README.md              # Backend dokümantasyonu
```

## 🔧 API Endpoints

### Backend API

- `GET /` - Ana sayfa
- `POST /api/generate-workout` - Spor programı oluşturma
- `GET /api/health` - Sağlık kontrolü

## 📝 Geliştirme Notları

- Firebase konfigürasyon dosyaları (`google-services.json`, `GoogleService-Info.plist`) örnek dosyalardır
- Gerçek Firebase projesi oluşturup konfigürasyon dosyalarını güncelleyin
- Gemini API anahtarınızı backend `.env` dosyasına ekleyin
- CORS ayarlarını production için güncelleyin

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

Proje hakkında sorularınız için issue açabilirsiniz.

---

**Not**: Bu uygulama geliştirme amaçlıdır. Production kullanımı için güvenlik ve performans optimizasyonları yapılmalıdır.
