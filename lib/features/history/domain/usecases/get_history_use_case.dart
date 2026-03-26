import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';

class GetHistoryUseCase {
  const GetHistoryUseCase(this._historyRepository);

  final HistoryRepository _historyRepository;

  Future<List<HistoryEntry>> call() {
    return _historyRepository.getHistory();
  }
}
