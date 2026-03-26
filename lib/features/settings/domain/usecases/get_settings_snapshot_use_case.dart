import 'package:prompt_enhancer/features/settings/domain/entities/settings_snapshot.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class GetSettingsSnapshotUseCase {
  const GetSettingsSnapshotUseCase(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<SettingsSnapshot> call() {
    return _settingsRepository.getSettingsSnapshot();
  }
}
