import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web configuration has not been generated yet. Run flutterfire configure to add web support.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase iOS configuration is missing. Add GoogleService-Info.plist and run flutterfire configure.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase macOS configuration is missing. Run flutterfire configure to add macOS support.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase Windows configuration is missing. Run flutterfire configure to add Windows support.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase Linux configuration is missing. Run flutterfire configure to add Linux support.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase is not configured for Fuchsia.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAx9h9zcpDaJtOlozjroidNZnVqNpiASSc',
    appId: '1:223155429200:android:6b48b77bf485273d045655',
    messagingSenderId: '223155429200',
    projectId: 'myblog-d7b57',
    databaseURL: 'https://myblog-d7b57.firebaseio.com',
    storageBucket: 'myblog-d7b57.firebasestorage.app',
  );
}
