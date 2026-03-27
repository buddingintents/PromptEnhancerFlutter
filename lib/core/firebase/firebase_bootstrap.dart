import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';
import 'package:prompt_enhancer/firebase_options.dart';

const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
const String _adMobTestDeviceIds = String.fromEnvironment(
  'ADMOB_TEST_DEVICE_IDS',
);

Future<void> initializeFirebaseServices() async {
  try {
    await _initializeMobileAdsIfSupported();
  } catch (error, stackTrace) {
    debugPrint(
      'Mobile Ads initialization skipped. Banner ads will remain unavailable until the AdMob SDK starts correctly. Error: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await _initializeFirebaseApp();

    if (Firebase.apps.isEmpty) {
      return;
    }

    await _ensureAnonymousFirebaseSession();

    final analytics = FirebaseAnalytics.instance;
    final crashlytics = FirebaseCrashlytics.instance;
    final previousOnError = FlutterError.onError;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    FirebaseTelemetryService.configure(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    await FirebaseTelemetryService.setUserIdentifier(userId);
    await crashlytics.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (details) {
      unawaited(
        FirebaseTelemetryService.reportError(
          details.exception,
          details.stack ?? StackTrace.current,
          reason: 'flutter_error',
          fatal: true,
          customKeys: {
            'library': details.library ?? 'unknown',
            'context': details.context?.toDescription() ?? 'unknown',
          },
        ),
      );
      previousOnError?.call(details);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(
        FirebaseTelemetryService.reportError(
          error,
          stackTrace,
          reason: 'platform_dispatcher_error',
          fatal: true,
        ),
      );
      return true;
    };
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase initialization skipped. Realtime sync, analytics, and crash reporting are disabled until Firebase is configured. Error: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> _initializeFirebaseApp() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError {
    await Firebase.initializeApp();
  }
}

Future<void> _ensureAnonymousFirebaseSession() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser != null) {
    return;
  }

  try {
    await auth.signInAnonymously();
  } on FirebaseAuthException catch (error) {
    final code = error.code.toLowerCase();
    if (code == 'operation-not-allowed' ||
        code == 'admin-restricted-operation') {
      throw StateError(
        'Firebase Anonymous Authentication is not fully enabled for this project. Enable Anonymous sign-in in Firebase Authentication and try again.',
      );
    }

    rethrow;
  }
}

Future<void> _initializeMobileAdsIfSupported() async {
  if (_isFlutterTest || kIsWeb) {
    return;
  }

  final platform = defaultTargetPlatform;
  if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
    return;
  }

  final testDeviceIds = _adMobTestDeviceIds
      .split(',')
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList(growable: false);
  if (testDeviceIds.isNotEmpty) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );
  }

  await MobileAds.instance.initialize();
}
