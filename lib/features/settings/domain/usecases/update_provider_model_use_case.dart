import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class UpdateProviderModelUseCase {
  const UpdateProviderModelUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(LLMProviderType provider, String model) {
    return _repository.updateProviderModel(provider, model);
  }
}
