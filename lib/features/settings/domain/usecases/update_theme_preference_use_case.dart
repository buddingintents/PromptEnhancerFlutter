import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class UpdateThemePreferenceUseCase {
  const UpdateThemePreferenceUseCase(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<void> call(AppThemePreference preference) {
    return _settingsRepository.updateThemePreference(preference);
  }
}
