@echo off
REM Build Release Bundle for Google Play Console

echo ============================================
echo CAFM App - Release Build Script
echo ============================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found. Please install Flutter and add it to PATH.
    pause
    exit /b 1
)

echo [1/4] Running flutter clean...
flutter clean

echo.
echo [2/4] Getting dependencies...
flutter pub get

echo.
echo [3/4] Building release app bundle...
echo This may take several minutes...
echo.
flutter build appbundle --release

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo BUILD SUCCESSFUL!
echo ============================================
echo.
echo App Bundle created at:
echo build\app\outputs\bundle\release\app-release.aab
echo.
echo Next steps:
echo 1. Upload app-release.aab to Google Play Console
echo 2. Complete store listing (screenshots, description, etc.)
echo 3. Submit for review
echo.
pause
