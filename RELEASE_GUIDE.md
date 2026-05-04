# CAFM Mobile App - Google Play Console Release Guide

## ✅ Completed Configuration

Your Flutter app has been configured for Google Play release with the following updates:

- ✅ Package name updated: `adbserver.com.cafm_jazan`
- ✅ Version updated: `1.0.0+4`
- ✅ Signing configuration added
- ✅ ProGuard rules for code obfuscation created
- ✅ Release build types configured

---

## 📋 Step-by-Step Release Process

### Step 1: Generate Signing Keystore (ONE TIME ONLY)

This creates the certificate that signs your app for Google Play.

**Option A: Using Batch Script (Windows)**
```bash
double-click generate_keystore.bat
```

**Option B: Manual Command (Windows PowerShell)**
```powershell
cd android/app
keytool -genkey -v -keystore cafm_keystore.jks `
    -keyalias cafm_key `
    -keyalg RSA `
    -keysize 2048 `
    -validity 9125 `
    -storepass admin123456 `
    -keypass admin123456 `
    -dname "CN=ADB Server, OU=Development, O=ADB World, L=Jazan, ST=Jazan, C=SA"
```

**⚠️ CRITICAL:** After generation, the `cafm_keystore.jks` file will appear in `android/app/`
- ✅ DO: Keep this file safe, never delete it, backup to secure location
- ❌ DON'T: Commit to Git, don't share with anyone, don't lose it
- ❌ Note: If lost, you'll need a new package name to re-release

---

### Step 2: Build Release App Bundle (AAB Format - Preferred)

App Bundles are required by Google Play Console and optimized for each device.

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

✅ Output location: `build/app/outputs/bundle/release/app-release.aab`

---

### Step 3: Build Release APK (Alternative - Direct Installation)

For testing or backup, you can also build APK:

```bash
flutter build apk --release --split-per-abi
```

✅ Output locations:
- `build/app/outputs/apk/release/app-arm64-v8a-release.apk`
- `build/app/outputs/apk/release/app-armeabi-v7a-release.apk`
- `build/app/outputs/apk/release/app-x86_64-release.apk`

---

## 🚀 Upload to Google Play Console

### Prerequisites:
1. ✅ Google Play Developer Account ($25 one-time fee)
2. ✅ Your app bundle (AAB file) ready from Step 2
3. ✅ App icons and screenshots
4. ✅ App description, privacy policy, etc.

### Upload Steps:

1. **Go to Google Play Console**
   - Visit: https://play.google.com/console
   - Sign in with your Google account

2. **Create New App**
   - Click "Create app"
   - Enter app name: "CAFM App"
   - Select category and content rating
   - Accept agreements

3. **Set Up Signing**
   - Google Play will generate a signing key for you
   - This is separate from your upload key (cafm_keystore.jks)

4. **Upload App Bundle**
   - Go to "Release" → "Production"
   - Click "Create new release"
   - Upload your `.aab` file from Step 2
   - Review version, permissions, and app info

5. **Complete Store Listing**
   - Add app title, description, keywords
   - Upload app icon, screenshots, promotional graphics
   - Set content rating questionnaire
   - Add privacy policy URL
   - Set pricing (free or paid)
   - Set target countries/regions

6. **Content Rating**
   - Fill out content rating questionnaire
   - Get rating classification

7. **Review & Publish**
   - Review all information
   - Submit for review
   - Google will review (usually 24-48 hours)
   - Once approved, your app goes live! 🎉

---

## 📊 App Configuration Summary

| Setting | Value |
|---------|-------|
| **Package Name** | adbserver.com.cafm_jazan |
| **App Version** | 1.0.0 |
| **Version Code** | 4 |
| **Min SDK** | 21 (Android 5.0) |
| **Target SDK** | Latest (Flutter managed) |
| **Signing Key Alias** | cafm_key |
| **Keystore File** | cafm_keystore.jks |

---

## 🔒 Security Checklist

- [ ] Generated keystore (`cafm_keystore.jks`)
- [ ] Backed up keystore to secure location
- [ ] Added `.gitignore` entry for keystore (if using Git)
- [ ] Verified keystore password saved securely
- [ ] Tested release build locally
- [ ] Reviewed app permissions
- [ ] Added privacy policy
- [ ] Verified content rating

---

## 🐛 Troubleshooting

### Build fails with "Keystore not found"
- Ensure `cafm_keystore.jks` is in `android/app/` directory
- Verify file permissions

### Build fails with "Invalid keystore password"
- Check password: `admin123456`
- Regenerate keystore if forgotten

### App rejected by Google Play
- Check Google Play's policy guidelines
- Review app permissions
- Ensure privacy policy is clear
- Verify screenshots and descriptions

### Large app size
- Run `flutter build appbundle --release`
- Code is obfuscated with ProGuard
- Use App Bundle for optimized size

---

## 📝 Next Steps After Release

1. Monitor app reviews and ratings
2. Fix bugs reported by users
3. Plan updates with incremented version codes:
   - Version: `1.0.1+5` for next minor update
   - Version: `2.0.0+6` for major update
4. Use Firebase/Analytics to track user behavior
5. Set up crash reporting

---

## 📞 Additional Resources

- Flutter Release Documentation: https://flutter.dev/docs/deployment/android
- Google Play Console Help: https://support.google.com/googleplay/android-developer
- Android App Signing: https://developer.android.com/studio/publish/app-signing

---

**Your app is now ready for Google Play! 🚀**
