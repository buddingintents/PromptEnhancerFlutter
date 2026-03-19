import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/prompt/data/adapters/llm_provider_adapter.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';

class ClaudeAdapter extends LLMProviderAdapter {
  const ClaudeAdapter();

  @override
  String get providerName => 'Claude';

  @override
  String get defaultBaseUrl => 'https://api.anthropic.com/';

  @override
  String get defaultRefinePath => 'v1/messages';

  @override
  String get defaultDetectTopicPath => 'v1/messages';

  @override
  String? get defaultApiKeyHeader => 'x-api-key';

  @override
  String? get defaultApiKeyPrefix => null;

  @override
  Map<String, String> get defaultHeaders => const {
    'anthropic-version': '2023-06-01',
  };

  @override
  Map<String, dynamic> buildRefinePayload(
    String input,
    LLMProviderConfig config,
  ) {
    return {
      'model': config.model,
      'max_tokens': config.maxTokens,
      'temperature': config.temperature,
      'system':
          'You are a prompt refinement assistant. Rewrite the user input into '
          'a clear, structured, production-ready prompt. Return only the '
          'improved prompt text.',
      'messages': [
        {'role': 'user', 'content': input},
      ],
    };
  }

  @override
  Map<String, dynamic> buildDetectTopicPayload(
    String input,
    LLMProviderConfig config,
  ) {
    return {
      'model': config.model,
      'max_tokens': config.maxTokens,
      'temperature': 0,
      'system':
          'Classify the user input and return only valid JSON with this shape: '
          '{"category":"string","reasoningDepth":"basic|standard|deep","confidence":0.0}.',
      'messages': [
        {'role': 'user', 'content': input},
      ],
    };
  }

  @override
  String extractPrimaryText(Object? data) {
    final map = asMap(data);
    final content = map['content'];
    if (content is! List || content.isEmpty) {
      throw AppException.unknown(
        message: 'Claude returned no content blocks.',
        identifier: providerName,
        error: data,
      );
    }

    final text = extractTextFromMessageContent(content);
    if (text.isNotEmpty) {
      return text;
    }

    throw AppException.unknown(
      message: 'Unable to extract text content from Claude response.',
      identifier: providerName,
      error: data,
    );
  }

  @override
  int extractTokenCount(Object? data) {
    final map = asMap(data);
    final usage = map['usage'];
    if (usage is Map) {
      final inputTokens = usage['input_tokens'];
      final outputTokens = usage['output_tokens'];
      if (inputTokens is num || outputTokens is num) {
        return (inputTokens is num ? inputTokens.toInt() : 0) +
            (outputTokens is num ? outputTokens.toInt() : 0);
      }
    }

    return 0;
  }
}
