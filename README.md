# Prompt Enhancer

Prompt Enhancer is a Flutter app for turning rough prompt ideas into cleaner, reusable prompts with secure provider setup, saved history, world trends, and usage insights.

It is designed as a production-ready mobile app with:
- Clean Architecture
- feature-first modules
- Riverpod state management
- GoRouter navigation
- Dio networking
- Hive local storage
- secure API key storage
- Firebase-backed syncing and telemetry
- AdMob banner placement

## Current Product Scope

Prompt Enhancer currently ships with five core user flows:

### Prompt Studio
- Enter a raw prompt
- detect topic
- refine it with the selected provider/model
- optionally request structured JSON-only output
- view tokens, provider, latency, confidence, and reasoning depth
- save successful runs into history

### History
- Save prompt runs locally
- sync history to Firebase Realtime Database
- filter by topic, provider, and date
- copy, delete, or rerun older prompts

### Trending
- Pull synced history from Firebase
- identify the top three most-used categories
- render them as a rotating world-trend word cloud

### Metrics
- total prompts
- total tokens
- average response time
- prompts-per-day charts
- provider-level usage and latency breakdowns

### Settings
- manage API keys securely
- choose default provider and default model
- theme mode: light, dark, system
- language: English / Hindi
- provider onboarding guidance for first-time users

## Supported Providers

- OpenAI
- Gemini
- Claude
- Hugging Face
- Perplexity

The app uses a normalized LLM abstraction so features do not depend on provider-specific UI logic.

## Architecture

```text
lib/
  app/
    providers/
    router/
  core/
    constants/
    di/
    firebase/
    network/
    storage/
    theme/
    utils/
  features/
    prompt/
      data/
      domain/
      presentation/
    history/
      data/
      domain/
      presentation/
    settings/
      data/
      domain/
      presentation/
    trending/
      data/
      domain/
      presentation/
    metrics/
      data/
      domain/
      presentation/
  shared/
    widgets/
```

### Layering Rules
- `presentation` contains pages, widgets, Riverpod controllers, and UI state
- `domain` contains entities, repository contracts, and use cases
- `data` contains repository implementations, adapters, DTOs, and service integrations
- `core` contains shared infrastructure
- `shared` contains reusable UI building blocks

## Key Technical Integrations

### Firebase
- `firebase_core`
- `firebase_auth`
- `firebase_database`
- `firebase_analytics`
- `firebase_crashlytics`

Used for:
- anonymous auth
- remote history sync
- global trending aggregation input
- analytics events
- crash reporting

### Ads
- `google_mobile_ads`

Banner ads are configured per screen for:
- Home
- History
- Trending
- Metrics
- Settings

### Local Persistence
- Hive stores app preferences and local prompt history
- `flutter_secure_storage` stores provider API keys

## Local Development

### Requirements
- Flutter 3.41.4 stable or newer in the same major line
- Dart 3.11.1 compatible SDK
- Android Studio / Android SDK
- Firebase project configured for Android

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Quality Checks

```bash
flutter analyze
flutter test
```

## Runtime Configuration

The app supports `--dart-define` overrides, but stored Settings values take precedence for the active provider.

Common runtime defines:
- `PROMPT_PROVIDER`
- `PROMPT_MODEL`
- `PROMPT_API_KEY`
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`
- `CLAUDE_API_KEY`
- `HUGGING_FACE_API_KEY`
- `PERPLEXITY_API_KEY`
- `ADMOB_TEST_DEVICE_IDS`

## Android Release Setup

This repository is now prepared for a proper Google Play upload flow.

### What Was Added
- `android/app/build.gradle.kts` now reads release signing from `android/key.properties` or environment variables
- `android/key.properties.example` documents the expected keys
- `android/key.properties` is ignored from source control
- `android/upload-keystore.jks` is ignored from source control

### Local Signing Files

The local workspace contains a generated upload key setup:
- `android/upload-keystore.jks`
- `android/key.properties`

Back these up securely before publishing or changing machines.

### Release Build Commands

Build Play Store bundle:

```bash
flutter build appbundle --release
```

Optional signed APK for device QA:

```bash
flutter build apk --release
```

### Output Paths
- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/flutter-apk/app-release.apk`

### Automatic Android Version Codes

Android `versionCode` now upgrades automatically for release builds so Google Play does not reject uploads with a reused code.

How it works:
- `versionName` still comes from `pubspec.yaml`
- `versionCode` is generated from seconds elapsed since `2024-01-01T00:00:00Z`
- if `pubspec.yaml` already contains a higher build number, that higher value is used
- you can override the generated code with `ANDROID_VERSION_CODE`

Example override:

```bash
ANDROID_VERSION_CODE=900000001 flutter build appbundle --release
```

## Google Play Submission Checklist

### Required Accounts and Console Setup
- Google Play Console developer account
- package name `com.buddingintents.promptenhancer`
- Play App Signing enabled
- production app created in Play Console

### Signing and Versioning
- keep `android/upload-keystore.jks` backed up
- keep `android/key.properties` private
- update `versionName` in `pubspec.yaml` when you want a new visible release version
- Android `versionCode` now auto-increments during release builds
- upload AAB, not APK, to Play production

### Firebase and AdMob
- Firebase Android app must match `com.buddingintents.promptenhancer`
- Realtime Database must be enabled
- Anonymous Auth must be enabled
- Analytics and Crashlytics should remain enabled for release monitoring
- AdMob app ID and banner unit IDs are already wired into Android

### Play Console Forms
- App access
- Ads declaration
- Data safety
- Content rating
- Privacy policy URL
- Store listing

### Store Assets Still Needed
- app icon
- feature graphic
- phone screenshots
- optional tablet screenshots
- privacy policy URL
- support email / website

## Data and Privacy Notes

The app currently uses:
- provider API keys stored only in secure storage on device
- prompt history stored locally
- prompt history mirrored to Firebase Realtime Database
- anonymous Firebase authentication
- device identifiers and device model for synced records
- Firebase Analytics
- Firebase Crashlytics
- AdMob banners

Before publishing, verify your Play Data safety answers against your live backend behavior and privacy policy.

## Suggested Release Workflow

1. Verify Firebase production config
2. verify AdMob units in release mode
3. update `pubspec.yaml` version
4. run `flutter analyze`
5. run `flutter test`
6. build `appbundle`
7. upload AAB to Play internal testing
8. validate crashes, ads, analytics, auth, and database writes
9. complete Play Store listing and policy forms
10. promote to production

## Testing Status

Core checks used during development:
- `flutter analyze`
- `flutter test`
- targeted integration checks for Firebase history sync and navigation

## Repository Notes

Sensitive local release files are intentionally not committed:
- `android/key.properties`
- `android/upload-keystore.jks`

If you clone this project onto another machine, copy those files securely or recreate the upload key and update Play Console accordingly.
