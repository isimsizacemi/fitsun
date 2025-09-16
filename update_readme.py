#!/usr/bin/env python3
"""
FitSun README.md Otomatik Güncelleme Scripti
Bu script, screenshots klasöründeki görselleri tespit eder ve README.md'yi günceller.
"""

import os
import re
from pathlib import Path

def get_screenshot_files():
    """Screenshots klasöründeki dosyaları tespit eder"""
    screenshots_dir = Path("screenshots")
    if not screenshots_dir.exists():
        return []
    
    image_extensions = {'.png', '.jpg', '.jpeg', '.gif', '.webp'}
    screenshots = []
    
    for file in screenshots_dir.iterdir():
        if file.is_file() and file.suffix.lower() in image_extensions:
            screenshots.append(file.name)
    
    return sorted(screenshots)

def update_readme_screenshots():
    """README.md dosyasındaki screenshot bölümünü günceller"""
    readme_path = Path("README.md")
    if not readme_path.exists():
        print("❌ README.md dosyası bulunamadı!")
        return False
    
    # README.md'yi oku
    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Screenshots klasöründeki dosyaları al
    screenshots = get_screenshot_files()
    
    if not screenshots:
        print("⚠️ Screenshots klasöründe görsel bulunamadı!")
        return False
    
    print(f"📸 {len(screenshots)} screenshot bulundu:")
    for screenshot in screenshots:
        print(f"  - {screenshot}")
    
    # Screenshot bölümünü güncelle
    # Önce mevcut screenshot bölümünü bul ve değiştir
    screenshot_section_pattern = r'## 📸 Ekran Görüntüleri.*?(?=## |$)'
    
    # Yeni screenshot bölümü oluştur
    new_screenshot_section = create_screenshot_section(screenshots)
    
    # Eğer screenshot bölümü varsa değiştir, yoksa ekle
    if re.search(screenshot_section_pattern, content, re.DOTALL):
        content = re.sub(screenshot_section_pattern, new_screenshot_section, content, flags=re.DOTALL)
    else:
        # Screenshot bölümü yoksa, özellikler bölümünden sonra ekle
        features_end = content.find('## 🛠️ Teknoloji Stack\'i')
        if features_end != -1:
            content = content[:features_end] + new_screenshot_section + '\n\n' + content[features_end:]
    
    # README.md'yi güncelle
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ README.md başarıyla güncellendi!")
    return True

def create_screenshot_section(screenshots):
    """Screenshot bölümünü oluşturur"""
    
    # Screenshot'ları kategorilere ayır
    auth_screens = [s for s in screenshots if any(keyword in s.lower() for keyword in ['auth', 'login', 'register', 'profile'])]
    workout_screens = [s for s in screenshots if any(keyword in s.lower() for keyword in ['workout', 'exercise', 'program', 'training'])]
    nutrition_screens = [s for s in screenshots if any(keyword in s.lower() for keyword in ['nutrition', 'diet', 'food', 'meal'])]
    tracking_screens = [s for s in screenshots if any(keyword in s.lower() for keyword in ['tracking', 'daily', 'statistics', 'progress'])]
    video_screens = [s for s in screenshots if any(keyword in s.lower() for keyword in ['video', 'recording', 'upload'])]
    other_screens = [s for s in screenshots if s not in auth_screens + workout_screens + nutrition_screens + tracking_screens + video_screens]
    
    section = "## 📸 Ekran Görüntüleri\n\n"
    
    # Kimlik Doğrulama Ekranları
    if auth_screens:
        section += "### 🔐 Kimlik Doğrulama Ekranları\n"
        section += "<div align=\"center\">\n\n"
        section += "| Giriş Yapma | Kayıt Olma | Profil Oluşturma |\n"
        section += "|-------------|------------|------------------|\n"
        
        # İlk 3 auth screenshot'ı al
        auth_display = auth_screens[:3]
        while len(auth_display) < 3:
            auth_display.append("")
        
        section += f"| ![Login Screen](screenshots/{auth_display[0]}) | ![Register Screen](screenshots/{auth_display[1]}) | ![Profile Screen](screenshots/{auth_display[2]}) |\n"
        section += "\n</div>\n\n"
    
    # Antrenman Özellikleri
    if workout_screens:
        section += "### 🏋️‍♂️ Antrenman Özellikleri\n"
        section += "<div align=\"center\">\n\n"
        section += "| AI Program Oluşturma | Egzersiz Detayları | Antrenman Takibi |\n"
        section += "|----------------------|-------------------|------------------|\n"
        
        # İlk 3 workout screenshot'ı al
        workout_display = workout_screens[:3]
        while len(workout_display) < 3:
            workout_display.append("")
        
        section += f"| ![Workout Generation](screenshots/{workout_display[0]}) | ![Exercise Details](screenshots/{workout_display[1]}) | ![Workout Tracking](screenshots/{workout_display[2]}) |\n"
        section += "\n</div>\n\n"
    
    # Beslenme ve Takip
    if nutrition_screens or tracking_screens:
        section += "### 🍎 Beslenme ve Takip\n"
        section += "<div align=\"center\">\n\n"
        section += "| Beslenme Planı | Su Takibi | İlerleme Takibi |\n"
        section += "|----------------|-----------|-----------------|\n"
        
        # Nutrition ve tracking screenshot'larını birleştir
        combined_screens = nutrition_screens + tracking_screens
        combined_display = combined_screens[:3]
        while len(combined_display) < 3:
            combined_display.append("")
        
        section += f"| ![Diet Plan](screenshots/{combined_display[0]}) | ![Water Tracking](screenshots/{combined_display[1]}) | ![Progress Tracking](screenshots/{combined_display[2]}) |\n"
        section += "\n</div>\n\n"
    
    # Video Özellikleri
    if video_screens:
        section += "### 🎥 Video Özellikleri\n"
        section += "<div align=\"center\">\n\n"
        section += "| Video Kayıt | Video Paylaşım |\n"
        section += "|-------------|---------------|\n"
        
        # İlk 2 video screenshot'ı al
        video_display = video_screens[:2]
        while len(video_display) < 2:
            video_display.append("")
        
        section += f"| ![Video Recording](screenshots/{video_display[0]}) | ![Video Sharing](screenshots/{video_display[1]}) |\n"
        section += "\n</div>\n\n"
    
    # Diğer Ekranlar
    if other_screens:
        section += "### 📱 Diğer Ekranlar\n"
        section += "<div align=\"center\">\n\n"
        
        # Diğer screenshot'ları grid olarak göster
        for i in range(0, len(other_screens), 3):
            row_screens = other_screens[i:i+3]
            while len(row_screens) < 3:
                row_screens.append("")
            
            section += f"| ![Screen {i+1}](screenshots/{row_screens[0]}) | ![Screen {i+2}](screenshots/{row_screens[1]}) | ![Screen {i+3}](screenshots/{row_screens[2]}) |\n"
        
        section += "\n</div>\n\n"
    
    return section

def main():
    """Ana fonksiyon"""
    print("🚀 FitSun README.md Güncelleme Scripti")
    print("=" * 50)
    
    if update_readme_screenshots():
        print("\n🎉 İşlem tamamlandı!")
        print("📝 README.md dosyası screenshot'larla güncellendi.")
        print("💡 GitHub'a push etmeden önce değişiklikleri kontrol edin.")
    else:
        print("\n❌ İşlem başarısız!")
        print("💡 Screenshots klasörüne görsel eklediğinizden emin olun.")

if __name__ == "__main__":
    main()
