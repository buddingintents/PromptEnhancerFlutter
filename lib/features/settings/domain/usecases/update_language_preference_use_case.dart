import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class UpdateLanguagePreferenceUseCase {
  const UpdateLanguagePreferenceUseCase(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<void> call(AppLanguage language) {
    return _settingsRepository.updateLanguagePreference(language);
  }
}
