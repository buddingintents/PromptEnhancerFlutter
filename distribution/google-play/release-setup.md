# Release Setup Notes

## Keys and Configurations Needed Before Production

### 1. Google Play
- Google Play Console developer account
- Play App Signing enrollment
- internal testing track created

### 2. Android Signing
- upload keystore
- store password
- key alias
- key password

These are already configured locally through:
- `android/upload-keystore.jks`
- `android/key.properties`

### 3. Firebase
- Android app configured for `com.buddingintents.promptenhancer`
- Realtime Database enabled
- Anonymous Authentication enabled
- Analytics enabled
- Crashlytics enabled

### 4. AdMob
- App ID configured
- screen-level banner unit IDs configured
- test devices verified before production rollout

### 5. Policy and Listing
- privacy policy URL
- data safety declaration
- ads declaration
- content rating
- screenshots and feature graphic

## Build Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

## Automatic Version Code

Android `versionCode` is now generated automatically for release builds so Google Play uploads do not reuse an older code.

- `versionName` still follows `pubspec.yaml`
- `versionCode` auto-generates from build time
- optional manual override: `ANDROID_VERSION_CODE`

## Output

```text
build/app/outputs/bundle/release/app-release.aab
```
