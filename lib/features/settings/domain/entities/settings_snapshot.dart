import 'package:prompt_enhancer/core/constants/llm_provider_models.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/settings_preferences.dart';

class SettingsSnapshot {
  const SettingsSnapshot({
    required this.providerApiKeys,
    required this.providerModels,
    required this.preferences,
  });

  final List<ProviderApiKey> providerApiKeys;
  final Map<LLMProviderType, String> providerModels;
  final SettingsPreferences preferences;

  ProviderApiKey apiKeyFor(LLMProviderType provider) {
    return providerApiKeys.firstWhere(
      (entry) => entry.provider == provider,
      orElse: () => ProviderApiKey(provider: provider),
    );
  }

  String? selectedModelFor(LLMProviderType provider) {
    return LlmProviderModels.normalizeModelAlias(
      provider,
      providerModels[provider],
    );
  }
}
