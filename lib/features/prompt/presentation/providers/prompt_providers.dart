import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/constants/app_constants.dart';
import 'package:prompt_enhancer/core/constants/llm_provider_models.dart';
import 'package:prompt_enhancer/core/di/core_providers.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/metrics/presentation/providers/metrics_providers.dart';
import 'package:prompt_enhancer/features/prompt/data/repositories/llm_repository_impl.dart';
import 'package:prompt_enhancer/features/prompt/data/repositories/prompt_repository_impl.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/prompt_entity.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/llm_repository.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/prompt_repository.dart';
import 'package:prompt_enhancer/features/prompt/domain/services/llm_service.dart';
import 'package:prompt_enhancer/features/prompt/domain/usecases/detect_topic_use_case.dart';
import 'package:prompt_enhancer/features/prompt/domain/usecases/refine_prompt_use_case.dart';
import 'package:prompt_enhancer/features/prompt/presentation/providers/prompt_state.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_providers.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_providers.dart';

final llmRepositoryProvider = Provider<LLMRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final apiErrorMapper = ref.watch(apiErrorMapperProvider);

  return LLMRepositoryImpl(dio: dio, apiErrorMapper: apiErrorMapper);
});

final llmServiceProvider = Provider.family<LLMService, LLMProviderConfig>((
  ref,
  config,
) {
  return ref.watch(llmRepositoryProvider).createService(config);
});

final preferredPromptProviderTypeProvider = Provider<LLMProviderType>((ref) {
  return ref.watch(
    settingsControllerProvider.select((settings) => settings.preferredProvider),
  );
});

final activePromptProviderApiKeyProvider = Provider<String>((ref) {
  final providerType = ref.watch(preferredPromptProviderTypeProvider);

  return ref.watch(
    settingsControllerProvider.select(
      (settings) => settings.apiKeyFor(providerType).value,
    ),
  );
});

final activePromptProviderSelectedModelProvider = Provider<String?>((ref) {
  final providerType = ref.watch(preferredPromptProviderTypeProvider);

  return ref.watch(
    settingsControllerProvider.select(
      (settings) => settings.selectedModelFor(providerType),
    ),
  );
});

final activePromptProviderConfigProvider = Provider<LLMProviderConfig>((ref) {
  final providerType = ref.watch(preferredPromptProviderTypeProvider);
  final storedApiKey = ref.watch(activePromptProviderApiKeyProvider).trim();
  final selectedModel = ref.watch(activePromptProviderSelectedModelProvider);
  final apiKey = storedApiKey.isNotEmpty
      ? storedApiKey
      : _resolveApiKey(providerType);
  final model = _resolveModel(providerType, selectedModel: selectedModel);
  final baseUrl = _optionalDefine(
    const String.fromEnvironment('PROMPT_BASE_URL', defaultValue: ''),
  );
  final refinePath = _optionalDefine(
    const String.fromEnvironment('PROMPT_REFINE_PATH', defaultValue: ''),
  );
  final detectTopicPath = _optionalDefine(
    const String.fromEnvironment('PROMPT_DETECT_TOPIC_PATH', defaultValue: ''),
  );
  final temperature = _resolveTemperature();
  final maxTokens = _resolveMaxTokens();

  switch (providerType) {
    case LLMProviderType.openAI:
      return LLMProviderConfig.openAI(
        model: model,
        apiKey: apiKey,
        baseUrl: baseUrl,
        refinePath: refinePath,
        detectTopicPath: detectTopicPath,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    case LLMProviderType.gemini:
      return LLMProviderConfig.gemini(
        model: model,
        apiKey: apiKey,
        baseUrl: baseUrl,
        refinePath: refinePath,
        detectTopicPath: detectTopicPath,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    case LLMProviderType.claude:
      return LLMProviderConfig.claude(
        model: model,
        apiKey: apiKey,
        baseUrl: baseUrl,
        refinePath: refinePath,
        detectTopicPath: detectTopicPath,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    case LLMProviderType.huggingFace:
      return LLMProviderConfig.huggingFace(
        model: model,
        apiKey: apiKey,
        baseUrl: baseUrl,
        refinePath: refinePath,
        detectTopicPath: detectTopicPath,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    case LLMProviderType.perplexity:
      return LLMProviderConfig.perplexity(
        model: model,
        apiKey: apiKey,
        baseUrl: baseUrl,
        refinePath: refinePath,
        detectTopicPath: detectTopicPath,
        temperature: temperature,
        maxTokens: maxTokens,
      );
  }
});

final activeLlmServiceProvider = Provider<LLMService>((ref) {
  final config = ref.watch(activePromptProviderConfigProvider);
  return ref.watch(llmServiceProvider(config));
});

final promptRepositoryProvider = Provider<PromptRepository>((ref) {
  final llmService = ref.watch(activeLlmServiceProvider);
  return PromptRepositoryImpl(llmService: llmService);
});

final detectTopicUseCaseProvider = Provider<DetectTopicUseCase>((ref) {
  return DetectTopicUseCase(ref.watch(promptRepositoryProvider));
});

final refinePromptUseCaseProvider = Provider<RefinePromptUseCase>((ref) {
  return RefinePromptUseCase(ref.watch(promptRepositoryProvider));
});

final promptControllerProvider =
    NotifierProvider<PromptController, PromptState>(PromptController.new);

class PromptController extends Notifier<PromptState> {
  @override
  PromptState build() {
    return const PromptState();
  }

  void updateInput(String value) {
    state = state.copyWith(input: value, error: null);
  }

  void loadDraft(String value) {
    state = PromptState(input: value);
  }

  Future<void> refinePrompt() async {
    final rawInput = state.input;
    final input = rawInput.trim();

    if (input.isEmpty) {
      state = state.copyWith(error: 'Enter a prompt to refine.');
      return;
    }

    if (input.length > AppConstants.maxPromptCharacters) {
      state = state.copyWith(
        error:
            'Keep the prompt under ${AppConstants.maxPromptCharacters} characters.',
      );
      return;
    }

    final providerConfig = ref.read(activePromptProviderConfigProvider);
    if (providerConfig.apiKey.trim().isEmpty) {
      state = state.copyWith(
        error:
            'No API key is configured for ${providerConfig.providerName}. Add one in Settings.',
      );
      return;
    }

    if (providerConfig.model.trim().isEmpty) {
      state = state.copyWith(
        error: 'No model is configured for the active LLM provider.',
      );
      return;
    }

    state = state.copyWith(
      loading: true,
      error: null,
      topic: null,
      refinedOutput: null,
      tokens: null,
      provider: null,
      latencyMs: null,
      reasoningDepth: null,
      topicConfidence: null,
    );

    try {
      final topicResult = await ref.read(detectTopicUseCaseProvider)(input);
      state = state.copyWith(
        topic: topicResult.category,
        reasoningDepth: topicResult.reasoningDepth,
        topicConfidence: topicResult.confidence,
      );

      final prompt = await ref.read(refinePromptUseCaseProvider)(
        input: input,
        topicResult: topicResult,
      );

      state = state.copyWith(
        input: rawInput,
        loading: false,
        topic: prompt.topic,
        refinedOutput: prompt.refinedOutput,
        tokens: prompt.tokens,
        provider: prompt.provider,
        latencyMs: prompt.latencyMs,
        reasoningDepth: prompt.reasoningDepth,
        topicConfidence: prompt.topicConfidence,
      );

      await _savePromptRun(prompt);
    } catch (error) {
      state = state.copyWith(loading: false, error: _mapErrorMessage(error));
    }
  }

  Future<void> _savePromptRun(PromptEntity prompt) async {
    try {
      await ref.read(saveHistoryUseCaseProvider)(
        HistoryEntry(
          prompt: prompt.input,
          refinedPrompt: prompt.refinedOutput,
          topic: prompt.topic,
          tokens: prompt.tokens,
          timestamp: DateTime.now(),
          provider: prompt.provider,
          latencyMs: prompt.latencyMs,
        ),
      );
      _refreshConnectedFeatures();
    } catch (error) {
      state = state.copyWith(error: _mapHistorySaveError(error));
    }
  }

  void _refreshConnectedFeatures() {
    ref.invalidate(historyControllerProvider);
    ref.invalidate(trendingControllerProvider);
    ref.invalidate(metricsControllerProvider);
  }

  String _mapHistorySaveError(Object error) {
    if (error is AppException) {
      return 'Prompt refined, but history could not be saved: ${error.message}';
    }

    return 'Prompt refined, but history could not be saved.';
  }

  String _mapErrorMessage(Object error) {
    final providerConfig = ref.read(activePromptProviderConfigProvider);
    final providerName = providerConfig.providerName;

    if (error is AppException) {
      switch (error.type) {
        case AppExceptionType.timeout:
          return '$providerName took too long to respond. Try again, shorten the prompt, or switch to a faster model in Settings.';
        case AppExceptionType.unauthorized:
          return 'Authentication failed for $providerName. Open Settings to verify the API key and selected model.';
        case AppExceptionType.network:
          return 'We could not reach $providerName. Check your internet connection and provider configuration, then try again.';
        case AppExceptionType.validation:
          return '$providerName rejected this request. Shorten the prompt or choose a different model in Settings.';
        case AppExceptionType.forbidden:
        case AppExceptionType.conflict:
          return _isGenericProviderMessage(error.message)
              ? '$providerName rejected this request. Review provider access, API key, and model selection in Settings.'
              : error.message;
        case AppExceptionType.notFound:
          if (providerConfig.type == LLMProviderType.gemini) {
            return 'The selected Gemini model is unavailable. Open Settings and switch to Gemini 2.5 Flash, Gemini 2.5 Flash-Lite, or Gemini 2.5 Pro.';
          }

          return _isGenericProviderMessage(error.message)
              ? '$providerName rejected this request. Review provider access, API key, and model selection in Settings.'
              : error.message;
        case AppExceptionType.server:
        case AppExceptionType.unknown:
          return _isGenericProviderMessage(error.message)
              ? '$providerName could not complete the request right now. Try again in a moment or switch model/provider in Settings.'
              : error.message;
        case AppExceptionType.storage:
        case AppExceptionType.secureStorage:
          return 'The app could not access local settings correctly. Restart the app and try again.';
      }
    }

    return 'The request could not be completed. Check your connection, provider settings, and try again.';
  }
}

String _resolveApiKey(LLMProviderType providerType) {
  const sharedApiKey = String.fromEnvironment(
    'PROMPT_API_KEY',
    defaultValue: '',
  );
  if (sharedApiKey.trim().isNotEmpty) {
    return sharedApiKey;
  }

  switch (providerType) {
    case LLMProviderType.openAI:
      return const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    case LLMProviderType.gemini:
      return const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    case LLMProviderType.claude:
      return const String.fromEnvironment('CLAUDE_API_KEY', defaultValue: '');
    case LLMProviderType.huggingFace:
      return const String.fromEnvironment(
        'HUGGING_FACE_API_KEY',
        defaultValue: '',
      );
    case LLMProviderType.perplexity:
      return const String.fromEnvironment(
        'PERPLEXITY_API_KEY',
        defaultValue: '',
      );
  }
}

String _resolveModel(LLMProviderType providerType, {String? selectedModel}) {
  const configuredModel = String.fromEnvironment(
    'PROMPT_MODEL',
    defaultValue: '',
  );

  return LlmProviderModels.resolveModel(
    providerType,
    preferredModel: selectedModel,
    fallbackModel: configuredModel,
  );
}

String? _optionalDefine(String value) {
  final trimmedValue = value.trim();
  return trimmedValue.isEmpty ? null : trimmedValue;
}

double _resolveTemperature() {
  const rawTemperature = String.fromEnvironment(
    'PROMPT_TEMPERATURE',
    defaultValue: '0.2',
  );
  return double.tryParse(rawTemperature) ?? 0.2;
}

int _resolveMaxTokens() {
  const rawMaxTokens = String.fromEnvironment(
    'PROMPT_MAX_TOKENS',
    defaultValue: '1200',
  );
  return int.tryParse(rawMaxTokens) ?? 1200;
}

bool _isGenericProviderMessage(String message) {
  final normalized = message.trim().toLowerCase();
  return normalized.isEmpty ||
      normalized == 'unable to complete the request.' ||
      normalized == 'something went wrong. please try again.';
}
