import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class SaveProviderApiKeyUseCase {
  const SaveProviderApiKeyUseCase(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<void> call(ProviderApiKey entry) {
    return _settingsRepository.saveProviderApiKey(entry);
  }
}
