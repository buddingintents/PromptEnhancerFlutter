import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';

class FirebaseTelemetryService {
  const FirebaseTelemetryService({this.analytics, this.crashlytics});

  static FirebaseAnalytics? _configuredAnalytics;
  static FirebaseCrashlytics? _configuredCrashlytics;

  final FirebaseAnalytics? analytics;
  final FirebaseCrashlytics? crashlytics;

  static void configure({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) {
    _configuredAnalytics = analytics ?? _configuredAnalytics;
    _configuredCrashlytics = crashlytics ?? _configuredCrashlytics;
  }

  static Future<void> setUserIdentifier(String userId) async {
    final crashlytics = _configuredCrashlytics;
    if (crashlytics == null || userId.trim().isEmpty) {
      return;
    }

    try {
      await crashlytics.setUserIdentifier(userId.trim());
    } catch (_) {}
  }

  Future<void> logPromptRefined(HistoryEntry entry) async {
    final analytics = this.analytics ?? _configuredAnalytics;
    if (analytics == null) {
      return;
    }

    try {
      await analytics.logEvent(
        name: 'prompt_refined',
        parameters: {
          'provider': _sanitize(entry.provider),
          'category': _sanitize(entry.topic),
          'reasoning_depth': _sanitize(entry.reasoningDepth),
          'tokens': entry.tokens,
          'latency_ms': entry.latencyMs,
          'confidence_level': entry.topicConfidence,
        },
      );
    } catch (_) {}
  }

  Future<void> logHistorySynced(HistoryEntry entry) async {
    final analytics = this.analytics ?? _configuredAnalytics;
    if (analytics == null) {
      return;
    }

    try {
      await analytics.logEvent(
        name: 'history_synced',
        parameters: {
          'provider': _sanitize(entry.provider),
          'category': _sanitize(entry.topic),
          'country_code': _sanitize(entry.countryCode),
        },
      );
    } catch (_) {}
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String reason = 'non_fatal_error',
    bool fatal = false,
    Map<String, Object?> customKeys = const {},
  }) {
    return reportError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
      customKeys: customKeys,
    );
  }

  static Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    String reason = 'non_fatal_error',
    bool fatal = false,
    Map<String, Object?> customKeys = const {},
  }) async {
    final crashlytics = _configuredCrashlytics;
    if (crashlytics == null) {
      return;
    }

    try {
      for (final entry in customKeys.entries) {
        await crashlytics.setCustomKey(entry.key, '${entry.value}');
      }

      await crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {}
  }

  String _sanitize(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? 'unknown' : normalized;
  }
}
