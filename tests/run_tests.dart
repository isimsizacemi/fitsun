import 'api_test.dart';
import 'gemini_service_test.dart';

void main() async {
  print('🚀 FitSun Test Suite Başlatılıyor...\n');
  
  // API Testleri
  print('=' * 60);
  print('API TESTLERİ');
  print('=' * 60);
  await ApiTest.runAllTests();
  
  print('\n' + '=' * 60);
  print('GEMINI SERVICE TESTLERİ');
  print('=' * 60);
  await GeminiServiceTest.runAllTests();
  
  print('\n' + '=' * 60);
  print('TÜM TESTLER TAMAMLANDI');
  print('=' * 60);
  print('🎯 Test raporu hazır!');
}
