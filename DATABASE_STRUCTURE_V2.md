# FitSun Database Structure V2

## 📁 Collections

### 1. **plans** (Genel Program Şablonları)
```json
{
  "id": "plan_001",
  "name": "Başlangıç Seviye Kas Geliştirme",
  "description": "Yeni başlayanlar için temel kas geliştirme programı",
  "difficulty": "beginner",
  "durationWeeks": 4,
  "targetMuscles": ["Göğüs", "Sırt", "Bacak", "Kol"],
  "equipment": ["Dambıl", "Barbell", "Bench"],
  "createdBy": "system",
  "isPublic": true,
  "createdAt": "2024-01-15T10:00:00Z",
  "tags": ["kas-geliştirme", "başlangıç", "4-hafta"]
}
```

### 2. **users/{userId}** (Kullanıcı Profilleri)
```json
{
  "id": "user_123",
  "name": "Ahmet Yılmaz",
  "email": "ahmet@example.com",
  "age": 25,
  "height": 175,
  "weight": 70,
  "gender": "male",
  "goal": "muscle_gain",
  "fitnessLevel": "beginner",
  "bodyFat": 15.0,
  "experience": "1 yıl",
  "weeklyFrequency": 3,
  "preferredTime": "45-60 dakika",
  "availableEquipment": ["Dambıl", "Barbell"],
  "createdAt": "2024-01-15T10:00:00Z",
  "lastLogin": "2024-01-20T15:30:00Z"
}
```

### 3. **users/{userId}/programs** (Kullanıcının Kişisel Programları)
```json
{
  "id": "program_456",
  "userId": "user_123",
  "planId": "plan_001", // Hangi şablondan oluşturuldu
  "programName": "Ahmet'in Kas Geliştirme Programı",
  "description": "AI tarafından kişiselleştirilmiş program",
  "difficulty": "beginner",
  "durationWeeks": 4,
  "status": "active", // active, completed, paused, cancelled
  "weeklySchedule": [...], // WorkoutDay array
  "createdAt": "2024-01-20T10:00:00Z",
  "startedAt": "2024-01-20T10:00:00Z",
  "completedAt": null,
  "metadata": {
    "aiGenerated": true,
    "userPreferences": {...},
    "customizations": {...}
  }
}
```

### 4. **users/{userId}/progress** (Antrenman İlerlemesi)
```json
{
  "id": "progress_789",
  "userId": "user_123",
  "programId": "program_456",
  "workoutDate": "2024-01-20T10:00:00Z",
  "dayNumber": 1,
  "exercises": [
    {
      "exerciseName": "Bench Press",
      "sets": 3,
      "reps": 10,
      "weight": "60kg",
      "completed": true,
      "notes": "İyi gitti"
    }
  ],
  "duration": 45, // dakika
  "caloriesBurned": 300,
  "notes": "İlk antrenman, çok iyi hissettim"
}
```

### 5. **users/{userId}/settings** (Kullanıcı Ayarları)
```json
{
  "id": "settings_123",
  "userId": "user_123",
  "notifications": {
    "workoutReminders": true,
    "progressUpdates": true,
    "achievements": true
  },
  "units": {
    "weight": "kg",
    "height": "cm",
    "temperature": "celsius"
  },
  "preferences": {
    "theme": "light",
    "language": "tr",
    "timezone": "Europe/Istanbul"
  }
}
```

### 6. **users/{userId}/achievements** (Başarılar)
```json
{
  "id": "achievement_456",
  "userId": "user_123",
  "type": "streak",
  "title": "7 Günlük Seri",
  "description": "7 gün üst üste antrenman yaptın!",
  "icon": "🔥",
  "earnedAt": "2024-01-27T10:00:00Z",
  "points": 100
}
```

## 🔐 Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Genel planlar - herkese açık okuma
    match /plans/{planId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Kullanıcı profilleri - sadece kendi verisi
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Alt koleksiyonlar için aynı kural
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Test koleksiyonu (geliştirme için)
    match /test_users/{document} {
      allow read, write: if true;
    }
  }
}
```

## 📊 Avantajlar

1. **Organize Yapı**: Her kullanıcının programları ayrı subcollection'da
2. **Genel Şablonlar**: `plans` collection'ında hazır programlar
3. **İlerleme Takibi**: Her antrenman için detaylı progress
4. **Ölçeklenebilir**: Yeni özellikler kolayca eklenebilir
5. **Güvenli**: Kullanıcılar sadece kendi verilerine erişebilir
