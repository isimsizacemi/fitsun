# 📱 FitSun Ekran Dokümantasyonu

Bu dosya, FitSun uygulamasındaki tüm ekranları ve özelliklerini detaylı olarak açıklar.

## 🔐 Kimlik Doğrulama Ekranları

### 1. Auth Screen (`auth_screen.dart`)
- **Amaç**: Kullanıcı girişi ve kayıt işlemleri
- **Özellikler**:
  - Email/şifre ile giriş
  - Yeni hesap oluşturma
  - Şifre sıfırlama
  - Firebase Authentication entegrasyonu
- **Screenshot**: `auth_screen.png`

### 2. Profile Setup Screen (`profile_setup_screen.dart`)
- **Amaç**: İlk kez giriş yapan kullanıcılar için profil oluşturma
- **Özellikler**:
  - Kişisel bilgiler (yaş, boy, kilo, cinsiyet)
  - Fitness hedefleri seçimi
  - Aktivite seviyesi belirleme
  - Profil fotoğrafı yükleme
- **Screenshot**: `profile_setup.png`

### 3. Profile Edit Screen (`profile_edit_screen.dart`)
- **Amaç**: Mevcut profil bilgilerini düzenleme
- **Özellikler**:
  - Profil bilgilerini güncelleme
  - Hedef değiştirme
  - Profil fotoğrafı değiştirme
- **Screenshot**: `profile_edit.png`

## 🏠 Ana Ekranlar

### 4. Home Screen (`home_screen.dart`)
- **Amaç**: Ana dashboard ve hızlı erişim merkezi
- **Özellikler**:
  - Kullanıcı karşılama mesajı
  - Aktif antrenman programı özeti
  - Hızlı erişim kartları (Su takibi, Antrenman, Beslenme)
  - Günlük hedefler ve ilerleme
  - Program oluşturma butonu
- **Screenshot**: `home_screen.png`

### 5. Statistics Screen (`statistics_screen.dart`)
- **Amaç**: Detaylı istatistikler ve analizler
- **Özellikler**:
  - Kilo değişimi grafikleri
  - Su tüketimi istatistikleri
  - Antrenman sıklığı analizi
  - Beslenme takibi özeti
- **Screenshot**: `statistics.png`

## 🏋️‍♂️ Antrenman Ekranları

### 6. Workout Program Screen (`workout_program_screen.dart`)
- **Amaç**: AI destekli antrenman programı oluşturma
- **Özellikler**:
  - Kullanıcı tercihleri formu
  - Hedef seçimi (kilo verme, kas kazanımı, dayanıklılık)
  - Fitness seviyesi belirleme
  - Ekipman tercihleri
  - Özel istekler alanı
  - Gemini AI ile program oluşturma
- **Screenshot**: `workout_program.png`

### 7. Program Detail Screen (`program_detail_screen.dart`)
- **Amaç**: Oluşturulan antrenman programının detaylarını görüntüleme
- **Özellikler**:
  - Haftalık program görünümü
  - Egzersiz detayları
  - Set ve tekrar bilgileri
  - Programı aktifleştirme/pasifleştirme
  - Programı paylaşma
- **Screenshot**: `program_detail.png`

### 8. Exercise Guide Screen (`exercise_guide_screen.dart`)
- **Amaç**: Egzersiz rehberi ve açıklamaları
- **Özellikler**:
  - Egzersiz kategorileri
  - Detaylı egzersiz açıklamaları
  - Video rehberleri
  - Kas grupları bilgisi
- **Screenshot**: `exercise_guide.png`

### 9. Exercise Detail Screen (`exercise_detail_screen.dart`)
- **Amaç**: Tek bir egzersizin detaylı açıklaması
- **Özellikler**:
  - Egzersiz açıklaması
  - Doğru form teknikleri
  - Hedeflenen kas grupları
  - Alternatif egzersizler
- **Screenshot**: `exercise_detail.png`

### 10. Workout History Screen (`workout_history_screen.dart`)
- **Amaç**: Geçmiş antrenman kayıtları
- **Özellikler**:
  - Tamamlanan antrenmanlar listesi
  - Antrenman detayları
  - Performans analizi
  - İlerleme takibi
- **Screenshot**: `workout_history.png`

## 🍎 Beslenme Ekranları

### 11. Nutrition Screen (`nutrition_screen.dart`)
- **Amaç**: Beslenme takibi ana ekranı
- **Özellikler**:
  - Günlük kalori takibi
  - Makro besin analizi
  - Beslenme istatistikleri
  - Diyet planları listesi
- **Screenshot**: `nutrition.png`

### 12. Diet Creation Screen (`diet_creation_screen.dart`)
- **Amaç**: AI destekli beslenme planı oluşturma
- **Özellikler**:
  - Beslenme tercihleri formu
  - Alerji ve kısıtlamalar
  - Hedef kalori belirleme
  - Gemini AI ile diyet planı oluşturma
- **Screenshot**: `diet_creation.png`

### 13. Daily Diet Detail Screen (`daily_diet_detail_screen.dart`)
- **Amaç**: Günlük beslenme planının detayları
- **Özellikler**:
  - Günlük öğün listesi
  - Besin değerleri
  - Kalori hesaplaması
  - Beslenme takibi
- **Screenshot**: `daily_diet_detail.png`

## 📊 Takip Ekranları

### 14. Daily Tracking Screen (`daily_tracking_screen.dart`)
- **Amaç**: Günlük aktivite ve su takibi
- **Özellikler**:
  - Su tüketimi takibi
  - Günlük adım sayısı
  - Kalori yakımı
  - Aktivite kayıtları
- **Screenshot**: `daily_tracking.png`

## 🎥 Video Özellikleri

### 15. Video Recording Screen (`video_recording_screen.dart`)
- **Amaç**: Antrenman videoları kaydetme
- **Özellikler**:
  - Kamera ile video kaydı
  - Antrenman sırasında kayıt
  - Video önizleme
  - Kayıt durdurma/başlatma
- **Screenshot**: `video_recording.png`

### 16. Video Upload Screen (`video_upload_screen.dart`)
- **Amaç**: Kaydedilen videoları yükleme ve paylaşma
- **Özellikler**:
  - Video yükleme
  - Sosyal medya paylaşımı
  - Video açıklaması ekleme
  - Topluluk ile paylaşma
- **Screenshot**: `video_upload.png`

## 📸 Screenshot Gereksinimleri

### Önerilen Screenshot Boyutları:
- **Mobil**: 1080x1920 (9:16 aspect ratio)
- **Tablet**: 1200x1600 (3:4 aspect ratio)
- **Format**: PNG (şeffaf arka plan tercih edilir)

### Screenshot Alma Talimatları:
1. Uygulamayı emülatörde veya gerçek cihazda çalıştırın
2. Her ekran için temiz, net görüntüler alın
3. Dosyaları `screenshots/` klasörüne kaydedin
4. Dosya adlarını yukarıdaki önerilen isimlerle eşleştirin

### Önemli Notlar:
- Screenshots ekledikten sonra README.md otomatik olarak güncellenecek
- Her ekran için en az 1 screenshot gerekli
- Ana ekranlar için birden fazla screenshot alınabilir
- Screenshot'lar uygulamanın en güncel halini yansıtmalı
