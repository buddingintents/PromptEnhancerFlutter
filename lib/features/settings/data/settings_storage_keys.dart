import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';

abstract final class SettingsStorageKeys {
  static const String preferencesBoxName = 'settings_preferences';
  static const String themePreference = 'theme_preference';
  static const String language = 'language';
  static const String preferredProvider = 'preferred_provider';

  static String apiKeyFor(LLMProviderType provider) {
    return 'provider_api_key_${provider.key}';
  }

  static String modelFor(LLMProviderType provider) {
    return 'provider_model_${provider.key}';
  }
}
