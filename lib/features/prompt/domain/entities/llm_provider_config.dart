import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';

class LLMProviderConfig {
  const LLMProviderConfig({
    required this.type,
    required this.model,
    required this.apiKey,
    this.baseUrl,
    this.refinePath,
    this.detectTopicPath,
    this.headers = const {},
    this.queryParameters = const {},
    this.temperature = 0.2,
    this.maxTokens = 1200,
    this.apiKeyHeader,
    this.apiKeyPrefix,
    this.apiKeyQueryParameter,
  });

  factory LLMProviderConfig.openAI({
    required String model,
    required String apiKey,
    String? baseUrl,
    String? refinePath,
    String? detectTopicPath,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    double temperature = 0.2,
    int maxTokens = 1200,
  }) {
    return LLMProviderConfig(
      type: LLMProviderType.openAI,
      model: model,
      apiKey: apiKey,
      baseUrl: baseUrl,
      refinePath: refinePath,
      detectTopicPath: detectTopicPath,
      headers: headers,
      queryParameters: queryParameters,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  factory LLMProviderConfig.gemini({
    required String model,
    required String apiKey,
    String? baseUrl,
    String? refinePath,
    String? detectTopicPath,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    double temperature = 0.2,
    int maxTokens = 1200,
  }) {
    return LLMProviderConfig(
      type: LLMProviderType.gemini,
      model: model,
      apiKey: apiKey,
      baseUrl: baseUrl,
      refinePath: refinePath,
      detectTopicPath: detectTopicPath,
      headers: headers,
      queryParameters: queryParameters,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  factory LLMProviderConfig.claude({
    required String model,
    required String apiKey,
    String? baseUrl,
    String? refinePath,
    String? detectTopicPath,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    double temperature = 0.2,
    int maxTokens = 1200,
  }) {
    return LLMProviderConfig(
      type: LLMProviderType.claude,
      model: model,
      apiKey: apiKey,
      baseUrl: baseUrl,
      refinePath: refinePath,
      detectTopicPath: detectTopicPath,
      headers: headers,
      queryParameters: queryParameters,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  factory LLMProviderConfig.huggingFace({
    required String model,
    required String apiKey,
    String? baseUrl,
    String? refinePath,
    String? detectTopicPath,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    double temperature = 0.2,
    int maxTokens = 1200,
  }) {
    return LLMProviderConfig(
      type: LLMProviderType.huggingFace,
      model: model,
      apiKey: apiKey,
      baseUrl: baseUrl,
      refinePath: refinePath,
      detectTopicPath: detectTopicPath,
      headers: headers,
      queryParameters: queryParameters,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  factory LLMProviderConfig.perplexity({
    required String model,
    required String apiKey,
    String? baseUrl,
    String? refinePath,
    String? detectTopicPath,
    Map<String, String> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    double temperature = 0.2,
    int maxTokens = 1200,
  }) {
    return LLMProviderConfig(
      type: LLMProviderType.perplexity,
      model: model,
      apiKey: apiKey,
      baseUrl: baseUrl,
      refinePath: refinePath,
      detectTopicPath: detectTopicPath,
      headers: headers,
      queryParameters: queryParameters,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  final LLMProviderType type;
  final String model;
  final String apiKey;
  final String? baseUrl;
  final String? refinePath;
  final String? detectTopicPath;
  final Map<String, String> headers;
  final Map<String, dynamic> queryParameters;
  final double temperature;
  final int maxTokens;
  final String? apiKeyHeader;
  final String? apiKeyPrefix;
  final String? apiKeyQueryParameter;

  String get providerName => type.displayName;

  LLMProviderConfig copyWith({
    LLMProviderType? type,
    String? model,
    String? apiKey,
    String? baseUrl,
    String? refinePath,
    String? detectTopicPath,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    double? temperature,
    int? maxTokens,
    String? apiKeyHeader,
    String? apiKeyPrefix,
    String? apiKeyQueryParameter,
  }) {
    return LLMProviderConfig(
      type: type ?? this.type,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      refinePath: refinePath ?? this.refinePath,
      detectTopicPath: detectTopicPath ?? this.detectTopicPath,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      apiKeyHeader: apiKeyHeader ?? this.apiKeyHeader,
      apiKeyPrefix: apiKeyPrefix ?? this.apiKeyPrefix,
      apiKeyQueryParameter: apiKeyQueryParameter ?? this.apiKeyQueryParameter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.key,
      'model': model,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'refinePath': refinePath,
      'detectTopicPath': detectTopicPath,
      'headers': headers,
      'queryParameters': queryParameters,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'apiKeyHeader': apiKeyHeader,
      'apiKeyPrefix': apiKeyPrefix,
      'apiKeyQueryParameter': apiKeyQueryParameter,
    };
  }

  factory LLMProviderConfig.fromJson(Map<String, dynamic> json) {
    return LLMProviderConfig(
      type: llmProviderTypeFromKey(json['type'] as String),
      model: json['model'] as String,
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String?,
      refinePath: json['refinePath'] as String?,
      detectTopicPath: json['detectTopicPath'] as String?,
      headers:
          (json['headers'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      queryParameters:
          (json['queryParameters'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const {},
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.2,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 1200,
      apiKeyHeader: json['apiKeyHeader'] as String?,
      apiKeyPrefix: json['apiKeyPrefix'] as String?,
      apiKeyQueryParameter: json['apiKeyQueryParameter'] as String?,
    );
  }

  Uri buildUri({required String defaultBaseUrl, required String pathTemplate}) {
    final effectiveBaseUrl = _ensureTrailingSlash(baseUrl ?? defaultBaseUrl);
    final effectivePath = _resolvePathTemplate(pathTemplate);

    if (_isAbsoluteUrl(effectivePath)) {
      return Uri.parse(effectivePath);
    }

    final normalizedPath = effectivePath.startsWith('/')
        ? effectivePath.substring(1)
        : effectivePath;

    return Uri.parse(effectiveBaseUrl).resolve(normalizedPath);
  }

  Map<String, String> buildHeaders({
    required Map<String, String> defaultHeaders,
    String? defaultApiKeyHeader,
    String? defaultApiKeyPrefix,
    Map<String, String> additionalHeaders = const {},
  }) {
    final resolvedHeaders = <String, String>{
      ...defaultHeaders,
      ...headers,
      ...additionalHeaders,
    };

    final effectiveApiKeyHeader = apiKeyHeader ?? defaultApiKeyHeader;
    if (effectiveApiKeyHeader != null &&
        apiKey.trim().isNotEmpty &&
        (apiKeyQueryParameter ?? '').trim().isEmpty) {
      final prefix = apiKeyPrefix ?? defaultApiKeyPrefix;
      resolvedHeaders[effectiveApiKeyHeader] = prefix == null || prefix.isEmpty
          ? apiKey
          : '$prefix $apiKey';
    }

    return resolvedHeaders;
  }

  Map<String, dynamic> buildQueryParameters({
    String? defaultApiKeyQueryParameter,
    Map<String, dynamic> additionalQueryParameters = const {},
  }) {
    final resolvedQueryParameters = <String, dynamic>{
      ...queryParameters,
      ...additionalQueryParameters,
    };

    final effectiveApiKeyQueryParameter =
        apiKeyQueryParameter ?? defaultApiKeyQueryParameter;
    if (effectiveApiKeyQueryParameter != null && apiKey.trim().isNotEmpty) {
      resolvedQueryParameters[effectiveApiKeyQueryParameter] = apiKey;
    }

    return resolvedQueryParameters;
  }

  String _resolvePathTemplate(String pathTemplate) {
    return pathTemplate.replaceAll('{model}', model);
  }

  bool _isAbsoluteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _ensureTrailingSlash(String value) {
    return value.endsWith('/') ? value : '$value/';
  }
}
