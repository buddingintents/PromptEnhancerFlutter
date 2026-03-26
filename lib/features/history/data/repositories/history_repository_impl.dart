import 'package:prompt_enhancer/core/storage/base_local_storage_service.dart';
import 'package:prompt_enhancer/features/history/data/models/history_item.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._localStorageService);

  final BaseLocalStorageService _localStorageService;

  @override
  Future<void> saveHistory(HistoryEntry entry) async {
    final item = HistoryItem.fromDomain(entry);
    await _localStorageService.write<HistoryItem>(
      boxName: HistoryStorageKeys.boxName,
      key: item.storageKey,
      value: item,
    );
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
  Future<void> deleteHistory(DateTime timestamp) {
    return _localStorageService.delete(
      boxName: HistoryStorageKeys.boxName,
      key: timestamp.microsecondsSinceEpoch.toString(),
    );
  }
}
