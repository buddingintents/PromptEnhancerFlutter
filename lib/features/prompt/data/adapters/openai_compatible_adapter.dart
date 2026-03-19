import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/prompt/data/adapters/llm_provider_adapter.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';

abstract class OpenAICompatibleAdapter extends LLMProviderAdapter {
  const OpenAICompatibleAdapter();

  @override
  String? get defaultApiKeyHeader => 'Authorization';

  @override
  String? get defaultApiKeyPrefix => 'Bearer';

  @override
  Map<String, dynamic> buildRefinePayload(
    String input,
    LLMProviderConfig config,
  ) {
    return {
      'model': config.model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a prompt refinement assistant. Rewrite the user input '
              'into a clear, structured, production-ready prompt. Return only '
              'the improved prompt text.',
        },
        {'role': 'user', 'content': input},
      ],
      'temperature': config.temperature,
      'max_tokens': config.maxTokens,
    };
  }

  @override
  Map<String, dynamic> buildDetectTopicPayload(
    String input,
    LLMProviderConfig config,
  ) {
    return {
      'model': config.model,
      'messages': [
        {
          'role': 'system',
          'content':
              'Classify the user input and return only valid JSON with this '
              'shape: {"category":"string","reasoningDepth":"basic|standard|deep","confidence":0.0}.',
        },
        {'role': 'user', 'content': input},
      ],
      'temperature': 0,
      'max_tokens': config.maxTokens,
    };
  }

  @override
  String extractPrimaryText(Object? data) {
    final map = asMap(data);
    final choices = map['choices'];
    if (choices is! List || choices.isEmpty) {
      throw AppException.unknown(
        message: 'No choices were returned by $providerName.',
        identifier: providerName,
        error: data,
      );
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map) {
      throw AppException.unknown(
        message: 'Unexpected choice format returned by $providerName.',
        identifier: providerName,
        error: data,
      );
    }

    final message = firstChoice['message'];
    if (message is Map) {
      final content = message['content'];
      final text = extractTextFromMessageContent(content);
      if (text.isNotEmpty) {
        return text;
      }
    }

    final text = firstChoice['text'];
    if (text is String && text.trim().isNotEmpty) {
      return text.trim();
    }

    throw AppException.unknown(
      message: 'Unable to extract text content from $providerName response.',
      identifier: providerName,
      error: data,
    );
  }

  @override
  int extractTokenCount(Object? data) {
    final map = asMap(data);
    final usage = map['usage'];
    if (usage is Map) {
      final totalTokens = usage['total_tokens'];
      if (totalTokens is num) {
        return totalTokens.toInt();
      }
    }

    return 0;
  }
}
