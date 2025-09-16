# FitSun Veritabanı Tasarımı

## 📋 Genel Yapı

Firebase Firestore'da esnek ve ölçeklenebilir bir veritabanı yapısı tasarladık. Bu yapı, kullanıcı verilerini, spor programlarını, ilerleme takibini ve tüm ilişkileri tutacak şekilde organize edilmiştir.

## 🗂️ Koleksiyon Yapısı

### 1. `users` - Ana Kullanıcı Koleksiyonu
```
users/{userId}
├── Temel kullanıcı bilgileri
├── workoutPrograms/ (alt koleksiyon)
├── progress/ (alt koleksiyon)
├── settings/ (alt koleksiyon)
└── achievements/ (alt koleksiyon)
```

**Ana Kullanıcı Verisi:**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "name": "Kullanıcı Adı",
  "age": 25,
  "height": 175.0,
  "weight": 70.0,
  "gender": "Erkek",
  "goal": "Kas kütlesi artırma",
  "fitnessLevel": "Orta",
  "workoutLocation": "Gym",
  "availableEquipment": ["Dambıl", "Halter", "Bench"],
  "bodyFat": 15.0,
  "experience": "2 yıl",
  "weeklyFrequency": 3,
  "preferredTime": "45-60 dakika",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "isProfileComplete": true,
  "isActive": true
}
```

### 2. `users/{userId}/workoutPrograms` - Kullanıcının Spor Programları
```
users/{userId}/workoutPrograms/{programId}
```

**Program Verisi:**
```json
{
  "id": "program_123",
  "userId": "user_123",
  "programName": "3 Günlük Kas Kütlesi Programı",
  "description": "Orta seviye kas kütlesi artırma programı",
  "difficulty": "Orta",
  "durationWeeks": 4,
  "createdAt": "2024-01-01T00:00:00Z",
  "isActive": true,
  "isCompleted": false,
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-01-28T00:00:00Z",
  "weeklySchedule": [
    {
      "dayNumber": 1,
      "title": "Gün 1: Göğüs ve Triceps",
      "muscleGroups": ["Göğüs", "Triceps"],
      "duration": "60 dakika",
      "exercises": [
        {
          "name": "Bench Press",
          "sets": 3,
          "reps": "8-12",
          "rest": "60s",
          "weight": 0.0,
          "notes": "Temel göğüs egzersizi"
        }
      ]
    }
  ]
}
```

### 3. `users/{userId}/progress` - Antrenman İlerlemesi
```
users/{userId}/progress/{progressId}
```

**İlerleme Verisi:**
```json
{
  "id": "progress_123",
  "userId": "user_123",
  "programId": "program_123",
  "weekNumber": 1,
  "dayNumber": 1,
  "date": "2024-01-01T00:00:00Z",
  "isCompleted": false,
  "duration": 0,
  "notes": "İlk antrenman",
  "exercises": [
    {
      "exerciseName": "Bench Press",
      "sets": [
        {
          "setNumber": 1,
          "reps": 10,
          "weight": 60.0,
          "rest": 60,
          "isCompleted": true,
          "notes": "İyi gitti"
        }
      ]
    }
  ],
  "overallRating": 7,
  "difficulty": "Orta",
  "energy": "İyi",
  "mood": "Motiveli"
}
```

### 4. `users/{userId}/settings` - Kullanıcı Ayarları
```
users/{userId}/settings/preferences
```

**Ayarlar Verisi:**
```json
{
  "id": "settings_123",
  "userId": "user_123",
  "notifications": {
    "workoutReminders": true,
    "progressUpdates": true,
    "weeklyReports": true,
    "newPrograms": false
  },
  "preferences": {
    "language": "tr",
    "units": "metric",
    "theme": "light",
    "sound": true,
    "vibration": true
  },
  "goals": {
    "targetWeight": 75.0,
    "targetBodyFat": 12.0,
    "targetMuscleMass": 35.0,
    "targetEndurance": "Orta"
  },
  "privacy": {
    "profileVisibility": "public",
    "showProgress": true,
    "showPrograms": true,
    "showAchievements": true
  },
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 5. `users/{userId}/achievements` - Kullanıcı Başarıları
```
users/{userId}/achievements/{achievementId}
```

**Başarı Verisi:**
```json
{
  "id": "achievement_123",
  "userId": "user_123",
  "achievementType": "workout_streak",
  "title": "7 Günlük Antrenman Serisi",
  "description": "7 gün üst üste antrenman yaptın!",
  "icon": "🔥",
  "points": 100,
  "isUnlocked": true,
  "unlockedAt": "2024-01-01T00:00:00Z",
  "progress": {
    "current": 7,
    "target": 7,
    "isCompleted": true
  },
  "rarity": "common",
  "category": "consistency"
}
```

### 6. `globalPrograms` - Genel Program Şablonları
```
globalPrograms/{programId}
```

**Genel Program Verisi:**
```json
{
  "id": "global_program_123",
  "name": "Başlangıç Seviyesi 3 Günlük Program",
  "description": "Yeni başlayanlar için temel kas kütlesi programı",
  "difficulty": "Başlangıç",
  "durationWeeks": 4,
  "targetAudience": "Yeni başlayanlar",
  "equipment": ["Dambıl", "Halter", "Bench"],
  "muscleGroups": ["Göğüs", "Sırt", "Bacak", "Omuz", "Kol"],
  "isTemplate": true,
  "isPublic": true,
  "createdBy": "system",
  "createdAt": "2024-01-01T00:00:00Z",
  "usageCount": 0,
  "rating": 0.0,
  "tags": ["başlangıç", "kas kütlesi", "3 gün"],
  "weeklySchedule": [...]
}
```

## 🔄 Veri Akışı

### 1. Kullanıcı Kaydı
1. Kullanıcı kayıt olur → `users` koleksiyonuna eklenir
2. Profil bilgileri tamamlanır → `users/{userId}` güncellenir
3. Varsayılan ayarlar oluşturulur → `users/{userId}/settings/preferences`

### 2. Spor Programı Oluşturma
1. AI ile program oluşturulur
2. Program `users/{userId}/workoutPrograms` alt koleksiyonuna kaydedilir
3. Program aktif hale getirilir

### 3. Antrenman Takibi
1. Kullanıcı antrenman yapar
2. İlerleme `users/{userId}/progress` alt koleksiyonuna kaydedilir
3. Başarılar kontrol edilir ve `achievements` alt koleksiyonuna eklenir

### 4. Program Değişikliği
1. Kullanıcı yeni program ister
2. Eski programlar arşivlenir
3. Yeni program oluşturulur ve aktif hale getirilir

## 🎯 Özellikler

### ✅ Mevcut Özellikler
- Kullanıcı profil yönetimi
- AI ile spor programı oluşturma
- Antrenman ilerleme takibi
- Kullanıcı ayarları
- Başarı sistemi
- Genel program şablonları

### 🚀 Gelecek Özellikler
- Sosyal özellikler (arkadaş ekleme, paylaşım)
- Beslenme takibi
- Hedef belirleme ve takip
- İstatistikler ve raporlar
- Bildirim sistemi
- Çoklu dil desteği

## 🔧 Teknik Detaylar

### Güvenlik Kuralları
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Alt koleksiyonlar için aynı kural
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Genel programlar herkese açık
    match /globalPrograms/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### İndeksler
- `users`: `email` (unique), `createdAt`
- `workoutPrograms`: `userId`, `isActive`, `createdAt`
- `progress`: `userId`, `programId`, `date`
- `achievements`: `userId`, `isUnlocked`, `category`
- `globalPrograms`: `difficulty`, `isPublic`, `rating`

## 📊 Performans Optimizasyonu

1. **Alt Koleksiyonlar**: Kullanıcı verilerini alt koleksiyonlara böldük
2. **Lazy Loading**: Sadece gerekli veriler yüklenir
3. **Caching**: Sık kullanılan veriler cache'lenir
4. **Pagination**: Büyük listeler sayfalara bölünür
5. **Real-time Updates**: Sadece gerekli yerlerde real-time dinleme

## 🔍 Veri Tutarlılığı

1. **Transaction Kullanımı**: Kritik işlemler transaction ile korunur
2. **Batch Operations**: Toplu işlemler batch ile yapılır
3. **Data Validation**: Veri girişinde validasyon yapılır
4. **Backup Strategy**: Düzenli yedekleme stratejisi

Bu veritabanı tasarımı, FitSun uygulamasının tüm ihtiyaçlarını karşılayacak ve gelecekteki özellik eklemelerine uyum sağlayacak şekilde tasarlanmıştır.
