---
description: Build and Release Android App
---
# Build and Release Android App

This workflow guides you through the process of building your Flutter app for Android and preparing it for release.

## 1. Update Version
Ensure your `pubspec.yaml` has the correct version.
Current version: `1.0.0+1`
- `1.0.0` is the version name (visible to users).
- `+1` is the version code (internal, must be incremented for each update).

## 2. Check Permissions
Ensure `android/app/src/main/AndroidManifest.xml` has necessary permissions:
- Internet: `<uses-permission android:name="android.permission.INTERNET"/>`
- Storage (for image saving): `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>`

## 3. Build APK (for testing/sideloading)
Run the following command to build a release APK:
```bash
flutter build apk --release
```
The output file will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Build App Bundle (for Play Store)
Run the following command to build an Android App Bundle (AAB):
```bash
flutter build appbundle --release
```
The output file will be at: `build/app/outputs/bundle/release/app-release.aab`

## 5. Sign the App (Crucial for Play Store)
To publish to the Play Store, you must sign your app with a keystore.
1. Create a keystore if you haven't:
   ```bash
   keytool -genkey -v -keystore c:\Users\RiteshKumar\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` file with your keystore details.
3. Update `android/app/build.gradle` to use the keystore configuration.

## 6. Test the Release Build
Always test the release build on a real device before uploading.
```bash
flutter run --release
```
