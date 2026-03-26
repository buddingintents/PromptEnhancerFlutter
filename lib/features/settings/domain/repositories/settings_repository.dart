import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/settings_snapshot.dart';

abstract class SettingsRepository {
  Future<SettingsSnapshot> getSettingsSnapshot();

  Future<void> saveProviderApiKey(ProviderApiKey entry);

  Future<void> deleteProviderApiKey(LLMProviderType provider);

  Future<void> updateProviderModel(LLMProviderType provider, String model);

  Future<void> updateThemePreference(AppThemePreference preference);

  Future<void> updateLanguagePreference(AppLanguage language);

  Future<void> updatePreferredProvider(LLMProviderType provider);
}
