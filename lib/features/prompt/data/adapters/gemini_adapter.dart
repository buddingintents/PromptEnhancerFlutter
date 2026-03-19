import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/prompt/data/adapters/llm_provider_adapter.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';

class GeminiAdapter extends LLMProviderAdapter {
  const GeminiAdapter();

  @override
  String get providerName => 'Gemini';

  @override
  String get defaultBaseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/';

  @override
  String get defaultRefinePath => 'models/{model}:generateContent';

  @override
  String get defaultDetectTopicPath => 'models/{model}:generateContent';

  @override
  String? get defaultApiKeyHeader => 'x-goog-api-key';

  @override
  String? get defaultApiKeyPrefix => null;

  @override
  Map<String, dynamic> buildRefinePayload(
    String input,
    LLMProviderConfig config,
  ) {
    return {
      'systemInstruction': {
        'parts': [
          {
            'text':
                'You are a prompt refinement assistant. Rewrite the user input '
                'into a clear, structured, production-ready prompt. Return only '
                'the improved prompt text.',
          },
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': input},
          ],
        },
      ],
      'generationConfig': {
        'temperature': config.temperature,
        'maxOutputTokens': config.maxTokens,
      },
    };
  }

  @override
  Map<String, dynamic> buildDetectTopicPayload(
    String input,
    LLMProviderConfig config,
  ) {
    return {
      'systemInstruction': {
        'parts': [
          {
            'text':
                'Classify the user input and return only valid JSON with this '
                'shape: {"category":"string","reasoningDepth":"basic|standard|deep","confidence":0.0}.',
          },
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': input},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0,
        'maxOutputTokens': config.maxTokens,
      },
    };
  }

  @override
  String extractPrimaryText(Object? data) {
    final map = asMap(data);
    final candidates = map['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw AppException.unknown(
        message: 'No candidates were returned by Gemini.',
        identifier: providerName,
        error: data,
      );
    }

    final firstCandidate = candidates.first;
    if (firstCandidate is! Map) {
      throw AppException.unknown(
        message: 'Unexpected Gemini candidate format.',
        identifier: providerName,
        error: data,
      );
    }

    final content = firstCandidate['content'];
    if (content is Map) {
      final parts = content['parts'];
      final text = extractTextFromMessageContent(parts);
      if (text.isNotEmpty) {
        return text;
      }
    }

    throw AppException.unknown(
      message: 'Unable to extract text content from Gemini response.',
      identifier: providerName,
      error: data,
    );
  }

  @override
  int extractTokenCount(Object? data) {
    final map = asMap(data);
    final usageMetadata = map['usageMetadata'];
    if (usageMetadata is Map) {
      final totalTokenCount = usageMetadata['totalTokenCount'];
      if (totalTokenCount is num) {
        return totalTokenCount.toInt();
      }
    }

    final candidates = map['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final firstCandidate = candidates.first;
      if (firstCandidate is Map) {
        final tokenCount = firstCandidate['tokenCount'];
        if (tokenCount is num) {
          return tokenCount.toInt();
        }
      }
    }

    return 0;
  }
}
