import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Firebase Rules Test ve Güncelleme\n');

  // Güncel rules
  final rules = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Test için tüm erişimlere izin ver (GELİŞTİRME AŞAMASINDA)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''';

  // Rules dosyasını güncelle
  final rulesFile = File('firestore_test.rules');
  await rulesFile.writeAsString(rules);

  print('✅ Rules dosyası güncellendi: firestore_test.rules');
  print('\n📋 Rules İçeriği:');
  print(rules);

  print('\n🔧 Firebase Console\'da yapılacaklar:');
  print('1. https://console.firebase.google.com/ adresine git');
  print('2. fitsun-9da11 projesini seç');
  print('3. Sol menüden "Firestore Database" seç');
  print('4. "Rules" sekmesine tıkla');
  print('5. Yukarıdaki rules içeriğini yapıştır');
  print('6. "Publish" butonuna tıkla');
  print('7. 1-2 dakika bekle');

  print('\n🧪 Test Adımları:');
  print('1. Uygulamayı çalıştır: flutter run');
  print('2. "Plans Collection Oluştur" butonuna tıkla');
  print('3. "Program Oluştur" butonuna tıkla');
  print('4. Firebase Console\'da plans collection\'ını kontrol et');

  print('\n📊 Beklenen Sonuç:');
  print('✅ Plans Collection oluşturuldu!');
  print('✅ Program başarıyla oluşturuldu!');
  print('✅ Firebase Console\'da plans/ ve users/{userId}/programs/ görünür');
}
