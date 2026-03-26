import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class UpdatePreferredProviderUseCase {
  const UpdatePreferredProviderUseCase(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<void> call(LLMProviderType provider) {
    return _settingsRepository.updatePreferredProvider(provider);
  }
}
