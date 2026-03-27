import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';

final firebaseReadyProvider = Provider<bool>((ref) {
  return Firebase.apps.isNotEmpty;
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase?>((ref) {
  if (Firebase.apps.isEmpty) {
    return null;
  }

  return FirebaseDatabase.instance;
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics?>((ref) {
  if (Firebase.apps.isEmpty) {
    return null;
  }

  return FirebaseAnalytics.instance;
});

final firebaseCrashlyticsProvider = Provider<FirebaseCrashlytics?>((ref) {
  if (Firebase.apps.isEmpty) {
    return null;
  }

  return FirebaseCrashlytics.instance;
});

final firebaseAnalyticsObserverProvider = Provider<NavigatorObserver?>((ref) {
  final analytics = ref.watch(firebaseAnalyticsProvider);
  if (analytics == null) {
    return null;
  }

  return FirebaseAnalyticsObserver(analytics: analytics);
});

final firebaseTelemetryServiceProvider = Provider<FirebaseTelemetryService>((
  ref,
) {
  return FirebaseTelemetryService(
    analytics: ref.watch(firebaseAnalyticsProvider),
    crashlytics: ref.watch(firebaseCrashlyticsProvider),
  );
});
