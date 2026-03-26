import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';

abstract class HistoryRepository {
  Future<void> saveHistory(HistoryEntry entry);

  Future<List<HistoryEntry>> getHistory();

  Future<void> deleteHistory(DateTime timestamp);
}
