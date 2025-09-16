@echo off
echo 🚀 FitSun README.md Screenshot Güncelleme
echo ========================================
echo.

REM Python'un yüklü olup olmadığını kontrol et
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python bulunamadı! Lütfen Python'u yükleyin.
    pause
    exit /b 1
)

REM Screenshots klasörünün varlığını kontrol et
if not exist "screenshots" (
    echo ❌ Screenshots klasörü bulunamadı!
    echo 💡 Önce screenshots klasörünü oluşturun ve görselleri ekleyin.
    pause
    exit /b 1
)

REM Screenshots klasöründeki dosyaları listele
echo 📸 Screenshots klasöründeki dosyalar:
dir /b screenshots\*.png screenshots\*.jpg screenshots\*.jpeg 2>nul
if errorlevel 1 (
    echo ⚠️ Screenshots klasöründe görsel bulunamadı!
    echo 💡 PNG, JPG veya JPEG formatında görseller ekleyin.
    pause
    exit /b 1
)

echo.
echo 🔄 README.md güncelleniyor...
python update_readme.py

if errorlevel 1 (
    echo ❌ Güncelleme başarısız!
    pause
    exit /b 1
)

echo.
echo ✅ README.md başarıyla güncellendi!
echo 📝 Değişiklikleri kontrol edin ve GitHub'a push edin.
echo.
pause
