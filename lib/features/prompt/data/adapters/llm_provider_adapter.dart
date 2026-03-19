import 'dart:convert';

import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_response.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';

abstract class LLMProviderAdapter {
  const LLMProviderAdapter();

  String get providerName;

  String get defaultBaseUrl;

  String get defaultRefinePath;

  String get defaultDetectTopicPath;

  String? get defaultApiKeyHeader;

  String? get defaultApiKeyPrefix;

  String? get defaultApiKeyQueryParameter => null;

  Map<String, String> get defaultHeaders => const {};

  Uri resolveRefineUri(LLMProviderConfig config) {
    return config.buildUri(
      defaultBaseUrl: defaultBaseUrl,
      pathTemplate: config.refinePath ?? defaultRefinePath,
    );
  }

  Uri resolveDetectTopicUri(LLMProviderConfig config) {
    return config.buildUri(
      defaultBaseUrl: defaultBaseUrl,
      pathTemplate: config.detectTopicPath ?? defaultDetectTopicPath,
    );
  }

  Map<String, String> buildHeaders(LLMProviderConfig config) {
    return config.buildHeaders(
      defaultHeaders: defaultHeaders,
      defaultApiKeyHeader: defaultApiKeyHeader,
      defaultApiKeyPrefix: defaultApiKeyPrefix,
    );
  }

  Map<String, dynamic> buildQueryParameters(LLMProviderConfig config) {
    return config.buildQueryParameters(
      defaultApiKeyQueryParameter: defaultApiKeyQueryParameter,
    );
  }

  Map<String, dynamic> buildRefinePayload(
    String input,
    LLMProviderConfig config,
  );

  Map<String, dynamic> buildDetectTopicPayload(
    String input,
    LLMProviderConfig config,
  );

  LLMResponse parseRefineResponse(
    Object? data, {
    required LLMProviderConfig config,
    required int latencyMs,
  }) {
    return LLMResponse(
      text: extractPrimaryText(data),
      tokens: extractTokenCount(data),
      provider: config.providerName,
      latencyMs: latencyMs,
    );
  }

  TopicResult parseDetectTopicResponse(
    Object? data, {
    required LLMProviderConfig config,
    required int latencyMs,
  }) {
    final rawText = extractPrimaryText(data);
    final normalizedResult = extractTopicResult(rawText);

    return TopicResult(
      category: normalizedResult.category,
      reasoningDepth: normalizedResult.reasoningDepth,
      confidence: normalizedResult.confidence,
      provider: config.providerName,
      latencyMs: latencyMs,
    );
  }

  String extractPrimaryText(Object? data);

  int extractTokenCount(Object? data);

  TopicResult extractTopicResult(String rawText) {
    final parsed = _tryExtractStructuredTopicResult(rawText);
    if (parsed != null) {
      return parsed;
    }

    final trimmedText = rawText.trim();
    if (trimmedText.isEmpty) {
      throw AppException.unknown(
        message:
            'The provider returned an empty topic classification response.',
        identifier: providerName,
      );
    }

    final lines = trimmedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final category =
        _extractLineValue(lines, ['category', 'topic']) ??
        trimmedText.split(RegExp(r'[\n\.,]')).first.trim();
    final reasoningDepth =
        _extractLineValue(lines, ['reasoningDepth', 'reasoning_depth']) ??
        _extractLineValue(lines, ['reasoning']) ??
        'standard';
    final confidence = _extractConfidence(lines) ?? 0.0;

    return TopicResult(
      category: category,
      reasoningDepth: reasoningDepth,
      confidence: confidence,
      provider: providerName,
      latencyMs: 0,
    );
  }

  Map<String, dynamic> asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }

    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    throw AppException.unknown(
      message: 'Unexpected response shape from $providerName.',
      identifier: providerName,
      error: data,
    );
  }

  String extractTextFromMessageContent(Object? content) {
    if (content is String) {
      return content.trim();
    }

    if (content is List) {
      final parts = <String>[];

      for (final item in content) {
        if (item is String && item.trim().isNotEmpty) {
          parts.add(item.trim());
          continue;
        }

        if (item is Map) {
          final map = item.map((key, value) => MapEntry(key.toString(), value));
          final text = map['text'];
          if (text is String && text.trim().isNotEmpty) {
            parts.add(text.trim());
          }
        }
      }

      return parts.join('\n').trim();
    }

    return '';
  }

  TopicResult? _tryExtractStructuredTopicResult(String rawText) {
    final jsonObject = _extractJsonObject(rawText);
    if (jsonObject == null) {
      return null;
    }

    final category =
        _extractString(
          jsonObject,
          keys: const ['category', 'topic', 'label'],
        ) ??
        'general';
    final reasoningDepth =
        _extractString(
          jsonObject,
          keys: const ['reasoningDepth', 'reasoning_depth', 'reasoning'],
        ) ??
        'standard';
    final confidence =
        _extractDouble(
          jsonObject,
          keys: const ['confidence', 'score', 'probability'],
        ) ??
        0.0;

    return TopicResult(
      category: category,
      reasoningDepth: reasoningDepth,
      confidence: confidence.clamp(0.0, 1.0),
      provider: providerName,
      latencyMs: 0,
    );
  }

  Map<String, dynamic>? _extractJsonObject(String rawText) {
    final sanitized = rawText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final decoded = jsonDecode(sanitized);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(sanitized);
      if (match == null) {
        return null;
      }

      final candidate = match.group(0);
      if (candidate == null) {
        return null;
      }

      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  String? _extractString(
    Map<String, dynamic> source, {
    required List<String> keys,
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  double? _extractDouble(
    Map<String, dynamic> source, {
    required List<String> keys,
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value.trim().replaceAll('%', ''));
        if (parsed != null) {
          return value.contains('%') ? parsed / 100 : parsed;
        }
      }
    }

    return null;
  }

  String? _extractLineValue(List<String> lines, List<String> candidateKeys) {
    for (final line in lines) {
      for (final key in candidateKeys) {
        final prefix = '$key:';
        if (line.toLowerCase().startsWith(prefix.toLowerCase())) {
          return line.substring(prefix.length).trim();
        }
      }
    }

    return null;
  }

  double? _extractConfidence(List<String> lines) {
    final rawValue = _extractLineValue(lines, const ['confidence', 'score']);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(rawValue.replaceAll('%', '').trim());
    if (parsed == null) {
      return null;
    }

    return rawValue.contains('%') ? parsed / 100 : parsed;
  }
}
