import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/di/core_providers.dart';
import 'package:prompt_enhancer/features/history/data/repositories/history_repository_impl.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';
import 'package:prompt_enhancer/features/history/domain/usecases/delete_history_use_case.dart';
import 'package:prompt_enhancer/features/history/domain/usecases/get_history_use_case.dart';
import 'package:prompt_enhancer/features/history/domain/usecases/save_history_use_case.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_controller.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_state.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.watch(baseLocalStorageProvider));
});

final saveHistoryUseCaseProvider = Provider<SaveHistoryUseCase>((ref) {
  return SaveHistoryUseCase(ref.watch(historyRepositoryProvider));
});

final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  return GetHistoryUseCase(ref.watch(historyRepositoryProvider));
});

final deleteHistoryUseCaseProvider = Provider<DeleteHistoryUseCase>((ref) {
  return DeleteHistoryUseCase(ref.watch(historyRepositoryProvider));
});

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryState>(HistoryController.new);
