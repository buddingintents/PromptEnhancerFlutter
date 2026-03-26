import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';

class SaveHistoryUseCase {
  const SaveHistoryUseCase(this._historyRepository);

  final HistoryRepository _historyRepository;

  Future<void> call(HistoryEntry entry) {
    return _historyRepository.saveHistory(entry);
  }
}
