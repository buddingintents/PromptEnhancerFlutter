import 'package:flutter/foundation.dart';
import 'package:prompt_enhancer/core/firebase/firebase_telemetry_service.dart';
import 'package:prompt_enhancer/core/storage/base_local_storage_service.dart';
import 'package:prompt_enhancer/features/history/data/models/history_item.dart';
import 'package:prompt_enhancer/features/history/data/services/firebase_history_service.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(
    this._localStorageService, {
    FirebaseHistoryService? firebaseHistoryService,
    FirebaseTelemetryService? telemetryService,
  }) : _firebaseHistoryService = firebaseHistoryService,
       _telemetryService = telemetryService;

  final BaseLocalStorageService _localStorageService;
  final FirebaseHistoryService? _firebaseHistoryService;
  final FirebaseTelemetryService? _telemetryService;

  @override
  Future<void> saveHistory(HistoryEntry entry) async {
    final item = HistoryItem.fromDomain(entry);
    await _localStorageService.write<HistoryItem>(
      boxName: HistoryStorageKeys.boxName,
      key: item.storageKey,
      value: item,
    );

    await _telemetryService?.logPromptRefined(entry);

    if (_firebaseHistoryService == null) {
      debugPrint(
        'Firebase history sync skipped because the Firebase history service is unavailable.',
      );
      return;
    }

    try {
      await _firebaseHistoryService.saveHistoryItem(entry);
      await _telemetryService?.logHistorySynced(entry);
    } catch (error, stackTrace) {
      debugPrint('Firebase history sync failed: $error');
      await _telemetryService?.recordError(
        error,
        stackTrace,
        reason: 'history_sync_save_failed',
      );
    }
  }

  @override
  Future<List<HistoryEntry>> getHistory() async {
    final items = await _localStorageService.readAll<HistoryItem>(
      boxName: HistoryStorageKeys.boxName,
    );

    final entries = items.map((item) => item.toDomain()).toList(growable: false)
      ..sort((left, right) => right.timestamp.compareTo(left.timestamp));

    return entries;
  }

  @override
  Future<void> deleteHistory(DateTime timestamp) async {
    await _localStorageService.delete(
      boxName: HistoryStorageKeys.boxName,
      key: timestamp.microsecondsSinceEpoch.toString(),
    );

    if (_firebaseHistoryService == null) {
      debugPrint(
        'Firebase history delete sync skipped because the Firebase history service is unavailable.',
      );
      return;
    }

    try {
      await _firebaseHistoryService.deleteHistoryItem(timestamp);
    } catch (error, stackTrace) {
      debugPrint('Firebase history delete sync failed: $error');
      await _telemetryService?.recordError(
        error,
        stackTrace,
        reason: 'history_sync_delete_failed',
      );
    }
  }
}
