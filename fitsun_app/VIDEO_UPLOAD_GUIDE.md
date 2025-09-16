# Video Yükleme Rehberi

## Özellikler

### 🎥 Video Yükleme
- Firebase Storage'a video yükleme
- Video formatı kontrolü (MP4, MOV, AVI, MKV)
- Video boyutu kontrolü (max 100MB)
- Upload progress takibi
- Video önizleme

### 🏋️ Egzersiz Rehberi
- Her egzersiz için video desteği
- Video oynatıcı entegrasyonu
- Video yükleme/silme işlemleri
- Mevcut video kontrolü

## Kullanım

### 1. Video Yükleme
1. Egzersiz detay sayfasına gidin
2. "Video Yükle" butonuna tıklayın
3. Video dosyasını seçin
4. Upload progress'ini takip edin
5. Video başarıyla yüklendiğinde egzersiz rehberinde görünecek

### 2. Video Oynatma
1. Egzersiz rehberinde video olan egzersizleri bulun
2. Egzersiz detay sayfasına gidin
3. Video otomatik olarak yüklenecek
4. Play/pause, progress bar ve tam ekran kontrollerini kullanın

### 3. Video Yönetimi
- **Video Silme**: Video yükleme sayfasında "Videoyu Sil" butonunu kullanın
- **Video Güncelleme**: Yeni video yükleyerek eski videoyu değiştirin
- **Video Kontrolü**: Mevcut video varsa uyarı mesajı gösterilir

## Teknik Detaylar

### Firebase Storage Yapısı
```
exercise_videos/
├── bench_press/
│   ├── bench_press_1234567890.mp4
│   └── bench_press_1234567891.mp4
├── squats/
│   └── squats_1234567892.mp4
└── ...
```

### Desteklenen Formatlar
- MP4 (önerilen)
- MOV
- AVI
- MKV

### Boyut Limiti
- Maksimum 100MB

### Güvenlik
- Sadece kimlik doğrulaması yapmış kullanıcılar video yükleyebilir
- Video dosyaları sadece uygun format ve boyutta yüklenebilir
- Her video egzersiz ID'si ile ilişkilendirilir

## Geliştirici Notları

### Yeni Video Servisi Ekleme
```dart
// Firebase Storage servisini kullanın
final videoUrl = await FirebaseStorageService.uploadVideo(
  videoFile: selectedFile,
  exerciseId: 'exercise_id',
);

// Veritabanını güncelleyin
ExerciseDatabaseService.updateExerciseVideo('exercise_id', videoUrl);
```

### Video Oynatıcı Ekleme
```dart
// Video controller oluşturun
final controller = VideoPlayerController.networkUrl(
  Uri.parse(videoUrl),
);

// Initialize edin
await controller.initialize();

// Widget'ta kullanın
VideoPlayer(controller)
```

## Sorun Giderme

### Video Yüklenmiyor
- İnternet bağlantınızı kontrol edin
- Video formatının desteklendiğinden emin olun
- Video boyutunun 100MB'den küçük olduğunu kontrol edin

### Video Oynatılmıyor
- Video URL'inin doğru olduğunu kontrol edin
- İnternet bağlantınızı kontrol edin
- Video dosyasının bozuk olmadığından emin olun

### Upload Progress Takip Edilmiyor
- `uploadVideoWithProgress` metodunu kullanın
- Stream'i dinleyin ve UI'ı güncelleyin
