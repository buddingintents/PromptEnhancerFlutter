import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/history/data/services/device_identity_service.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';

class FirebaseHistoryService {
  const FirebaseHistoryService({
    required FirebaseDatabase? database,
    required DeviceIdentityService deviceIdentityService,
  }) : _database = database,
       _deviceIdentityService = deviceIdentityService;

  static const String historyNode = 'prompt_history';

  final FirebaseDatabase? _database;
  final DeviceIdentityService _deviceIdentityService;

  Future<void> saveHistoryItem(HistoryEntry entry) async {
    try {
      final deviceIdentity = await _deviceIdentityService.getSnapshot();
      final countryCode = PlatformDispatcher.instance.locale.countryCode
          ?.trim()
          .toUpperCase();

      await _historyRef.child(entry.storageKey).set({
        'id': entry.storageKey,
        'category': entry.topic,
        'provider': entry.provider,
        'tokens': entry.tokens,
        'latencyMs': entry.latencyMs,
        'timestampEpochMs': entry.timestamp.millisecondsSinceEpoch,
        'timestampIso': entry.timestamp.toUtc().toIso8601String(),
        'serverTimestamp': ServerValue.timestamp,
        'reasoningDepth': entry.reasoningDepth,
        'confidenceLevel': entry.topicConfidence,
        'originalPrompt': entry.prompt,
        'refinedPrompt': entry.refinedPrompt,
        'countryCode': countryCode ?? entry.countryCode ?? 'Unknown',
        'deviceId': entry.deviceId ?? deviceIdentity.deviceId,
        'deviceModel': entry.deviceModel ?? deviceIdentity.deviceModel,
      });
    } catch (error, stackTrace) {
      throw _mapError(
        error,
        stackTrace,
        identifier: '$historyNode/${entry.storageKey}',
      );
    }
  }

  Future<void> deleteHistoryItem(DateTime timestamp) async {
    try {
      await _historyRef
          .child(timestamp.microsecondsSinceEpoch.toString())
          .remove();
    } catch (error, stackTrace) {
      throw _mapError(
        error,
        stackTrace,
        identifier: '$historyNode/${timestamp.microsecondsSinceEpoch}',
      );
    }
  }

  Stream<List<HistoryEntry>> watchHistoryItems() {
    final query = _historyRef.orderByChild('timestampEpochMs');

    return query.onValue.map((event) {
      final entries =
          event.snapshot.children
              .map(_historyEntryFromSnapshot)
              .whereType<HistoryEntry>()
              .toList(growable: false)
            ..sort((left, right) => right.timestamp.compareTo(left.timestamp));

      return entries;
    });
  }

  DatabaseReference get _historyRef {
    final database = _database;
    if (database == null) {
      throw AppException.server(
        message:
            'Firebase is not configured yet. Run flutterfire configure and add the generated Firebase platform files.',
        identifier: historyNode,
      );
    }

    return database.ref(historyNode);
  }

  HistoryEntry? _historyEntryFromSnapshot(DataSnapshot snapshot) {
    final rawValue = snapshot.value;
    if (rawValue is! Map) {
      return null;
    }

    final map = Map<Object?, Object?>.from(rawValue);
    final timestampEpochMs = _asInt(map['timestampEpochMs']);
    final timestamp = timestampEpochMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(timestampEpochMs)
        : DateTime.tryParse((map['timestampIso'] ?? '').toString()) ??
              DateTime.fromMillisecondsSinceEpoch(0);

    return HistoryEntry(
      prompt: (map['originalPrompt'] ?? '').toString(),
      refinedPrompt: (map['refinedPrompt'] ?? '').toString(),
      topic: (map['category'] ?? '').toString(),
      tokens: _asInt(map['tokens']),
      timestamp: timestamp,
      provider: (map['provider'] ?? 'Unknown').toString(),
      latencyMs: _asInt(map['latencyMs']),
      reasoningDepth: (map['reasoningDepth'] ?? '').toString(),
      topicConfidence: _asDouble(map['confidenceLevel']),
      countryCode: (map['countryCode'] ?? '').toString(),
      deviceId: (map['deviceId'] ?? '').toString(),
      deviceModel: (map['deviceModel'] ?? '').toString(),
    );
  }

  AppException _mapError(
    Object error,
    StackTrace stackTrace, {
    required String identifier,
  }) {
    if (error is AppException) {
      return error;
    }

    if (_isPermissionDenied(error)) {
      return AppException.forbidden(
        message:
            'Firebase Realtime Database denied access to history sync. Update the Realtime Database rules for /$historyNode or add Firebase Authentication and allow authenticated writes.',
        identifier: identifier,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return AppException.server(
      message: 'Unable to sync history with Firebase Realtime Database.',
      identifier: identifier,
      error: error,
      stackTrace: stackTrace,
    );
  }

  bool _isPermissionDenied(Object error) {
    if (error is FirebaseException) {
      final code = error.code.toLowerCase();
      if (code.contains('permission-denied') ||
          code.contains('permission_denied')) {
        return true;
      }
    }

    final message = error.toString().toLowerCase();
    return message.contains('permission denied') ||
        message.contains('permission_denied');
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
