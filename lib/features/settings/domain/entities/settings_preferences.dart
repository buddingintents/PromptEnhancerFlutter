import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';

class SettingsPreferences {
  const SettingsPreferences({
    this.themePreference = AppThemePreference.system,
    this.language = AppLanguage.english,
    this.preferredProvider = LLMProviderType.openAI,
  });

  final AppThemePreference themePreference;
  final AppLanguage language;
  final LLMProviderType preferredProvider;

  SettingsPreferences copyWith({
    AppThemePreference? themePreference,
    AppLanguage? language,
    LLMProviderType? preferredProvider,
  }) {
    return SettingsPreferences(
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      preferredProvider: preferredProvider ?? this.preferredProvider,
    );
  }
}
