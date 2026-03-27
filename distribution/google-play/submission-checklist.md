# Google Play Submission Checklist

## Release Package
- Upload `build/app/outputs/bundle/release/app-release.aab`
- Confirm package name is `com.buddingintents.promptenhancer`
- Confirm version in `pubspec.yaml` is correct

## Secrets and Keys
- Keep `android/upload-keystore.jks` backed up securely
- Keep `android/key.properties` private
- Enroll in Play App Signing

## Play Console Setup
- App category: `Productivity` recommended
- Ads declaration: `Yes`
- Content rating questionnaire completed
- Data safety form completed
- Privacy policy URL added
- Support email added

## Store Listing Copy
- Title: use `title.txt`
- Short description: use `short-description.txt`
- Full description: use `full-description.txt`
- What's new: use `whats-new.txt`

## Visual Assets
- App icon: 512 x 512 PNG
- Feature graphic: 1024 x 500 JPG or 24-bit PNG
- Phone screenshots: at least 2
- Optional tablet screenshots if targeting larger devices

## Release Validation
- Verify Firebase anonymous auth works
- Verify history sync writes to Realtime Database
- Verify world trending data loads
- Verify Crashlytics receives non-fatal and fatal reports
- Verify Analytics events are visible
- Verify AdMob banners load in release/internal testing
