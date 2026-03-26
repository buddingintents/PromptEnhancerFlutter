import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';

class DeleteHistoryUseCase {
  const DeleteHistoryUseCase(this._historyRepository);

  final HistoryRepository _historyRepository;

  Future<void> call(DateTime timestamp) {
    return _historyRepository.deleteHistory(timestamp);
  }
}
