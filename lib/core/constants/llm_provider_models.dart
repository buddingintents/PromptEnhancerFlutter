import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';

abstract final class LlmProviderModels {
  static const Map<LLMProviderType, List<String>> _modelsByProvider = {
    LLMProviderType.openAI: ['gpt-4.1-mini', 'gpt-4.1', 'gpt-4o-mini'],
    LLMProviderType.gemini: [
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite',
      'gemini-2.5-pro',
    ],
    LLMProviderType.claude: [
      'claude-3-5-sonnet-latest',
      'claude-3-5-haiku-latest',
      'claude-3-opus-latest',
    ],
    LLMProviderType.huggingFace: [
      'meta-llama/Llama-3.1-70B-Instruct',
      'mistralai/Mixtral-8x7B-Instruct-v0.1',
      'Qwen/Qwen2.5-72B-Instruct',
    ],
    LLMProviderType.perplexity: ['sonar', 'sonar-pro', 'sonar-reasoning'],
  };

  static const Map<LLMProviderType, Map<String, String>> _legacyAliases = {
    LLMProviderType.gemini: {
      'gemini-1.5-flash': 'gemini-2.5-flash',
      'gemini-1.5-flash-latest': 'gemini-2.5-flash',
      'gemini-1.5-pro': 'gemini-2.5-pro',
      'gemini-1.5-pro-latest': 'gemini-2.5-pro',
      'gemini-2.0-flash': 'gemini-2.5-flash',
      'gemini-2.0-flash-001': 'gemini-2.5-flash',
      'gemini-2.0-flash-lite': 'gemini-2.5-flash-lite',
      'gemini-2.0-flash-lite-001': 'gemini-2.5-flash-lite',
      'gemini-pro': 'gemini-2.5-flash',
    },
  };

  static List<String> supportedModelsFor(LLMProviderType provider) {
    return List<String>.unmodifiable(_modelsByProvider[provider] ?? const []);
  }

  static String defaultModelFor(LLMProviderType provider) {
    final models = _modelsByProvider[provider];
    if (models == null || models.isEmpty) {
      return 'default';
    }

    return models.first;
  }

  static bool isSupportedModel(LLMProviderType provider, String model) {
    return _modelsByProvider[provider]?.contains(model) ?? false;
  }

  static String? normalizeModelAlias(LLMProviderType provider, String? model) {
    final normalized = model?.trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }

    return _legacyAliases[provider]?[normalized] ?? normalized;
  }

  static String resolveModel(
    LLMProviderType provider, {
    String? preferredModel,
    String? fallbackModel,
  }) {
    final normalizedPreferred = normalizeModelAlias(provider, preferredModel);
    if (normalizedPreferred != null && normalizedPreferred.isNotEmpty) {
      return normalizedPreferred;
    }

    final normalizedFallback = normalizeModelAlias(provider, fallbackModel);
    if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
      return normalizedFallback;
    }

    return defaultModelFor(provider);
  }
}
