import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/di/core_providers.dart';
import 'package:prompt_enhancer/core/firebase/firebase_providers.dart';
import 'package:prompt_enhancer/features/history/data/repositories/history_repository_impl.dart';
import 'package:prompt_enhancer/features/history/data/services/device_identity_service.dart';
import 'package:prompt_enhancer/features/history/data/services/firebase_history_service.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';
import 'package:prompt_enhancer/features/history/domain/usecases/delete_history_use_case.dart';
import 'package:prompt_enhancer/features/history/domain/usecases/get_history_use_case.dart';
import 'package:prompt_enhancer/features/history/domain/usecases/save_history_use_case.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_controller.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_state.dart';

final deviceIdentityServiceProvider = Provider<DeviceIdentityService>((ref) {
  return DeviceIdentityService(secureStorage: ref.watch(secureStorageProvider));
});

final firebaseHistoryServiceProvider = Provider<FirebaseHistoryService>((ref) {
  return FirebaseHistoryService(
    database: ref.watch(firebaseDatabaseProvider),
    deviceIdentityService: ref.watch(deviceIdentityServiceProvider),
  );
});

final remoteHistoryItemsProvider = StreamProvider<List<HistoryEntry>>((ref) {
  return ref.watch(firebaseHistoryServiceProvider).watchHistoryItems();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    ref.watch(baseLocalStorageProvider),
    firebaseHistoryService: ref.watch(firebaseHistoryServiceProvider),
    telemetryService: ref.watch(firebaseTelemetryServiceProvider),
  );
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
