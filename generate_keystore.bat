@echo off
REM This script generates a keystore for signing your Flutter app for Google Play
REM Make sure you have Java installed and added to your PATH

cd /d "%~dp0"
cd android\app

echo Generating keystore for CAFM app...
echo.

REM Check if keytool is available
where keytool >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: keytool not found. Make sure Java is installed and JAVA_HOME is set.
    pause
    exit /b 1
)

REM Generate keystore
keytool -genkey -v -keystore cafm_keystore.jks ^
    -keyalias cafm_key ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity 9125 ^
    -storepass admin123456 ^
    -keypass admin123456 ^
    -dname "CN=ADB Server, OU=Development, O=ADB World, L=Jazan, ST=Jazan, C=SA"

if %errorlevel% equ 0 (
    echo.
    echo SUCCESS! Keystore created: cafm_keystore.jks
    echo.
    echo IMPORTANT: Keep this file safe and never share it!
    echo Store a backup in a secure location.
) else (
    echo ERROR: Failed to create keystore
)

pause
