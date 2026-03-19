import 'package:dio/dio.dart';
import 'package:prompt_enhancer/core/network/api_error_mapper.dart';
import 'package:prompt_enhancer/features/prompt/data/adapters/llm_provider_adapter.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_response.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/services/llm_service.dart';

abstract class AdapterBackedLLMService implements LLMService {
  AdapterBackedLLMService({
    required Dio dio,
    required ApiErrorMapper apiErrorMapper,
    required LLMProviderConfig config,
    required LLMProviderAdapter adapter,
  }) : _dio = dio,
       _apiErrorMapper = apiErrorMapper,
       _config = config,
       _adapter = adapter;

  final Dio _dio;
  final ApiErrorMapper _apiErrorMapper;
  final LLMProviderConfig _config;
  final LLMProviderAdapter _adapter;

  @override
  Future<LLMResponse> refinePrompt(String input) async {
    return _execute(
      uri: _adapter.resolveRefineUri(_config),
      payload: _adapter.buildRefinePayload(input, _config),
      parser: (data, latencyMs) => _adapter.parseRefineResponse(
        data,
        config: _config,
        latencyMs: latencyMs,
      ),
    );
  }

  @override
  Future<TopicResult> detectTopic(String input) async {
    return _execute(
      uri: _adapter.resolveDetectTopicUri(_config),
      payload: _adapter.buildDetectTopicPayload(input, _config),
      parser: (data, latencyMs) => _adapter.parseDetectTopicResponse(
        data,
        config: _config,
        latencyMs: latencyMs,
      ),
    );
  }

  Future<T> _execute<T>({
    required Uri uri,
    required Map<String, dynamic> payload,
    required T Function(Object? data, int latencyMs) parser,
  }) async {
    final stopwatch = Stopwatch()..start();
    final resolvedUri = _mergeQueryParameters(
      uri,
      _adapter.buildQueryParameters(_config),
    );

    try {
      final response = await _dio.postUri(
        resolvedUri,
        data: payload,
        options: Options(
          headers: _adapter.buildHeaders(_config),
          responseType: ResponseType.json,
        ),
      );

      return parser(response.data, stopwatch.elapsedMilliseconds);
    } catch (error, stackTrace) {
      throw _apiErrorMapper.map(error, stackTrace);
    } finally {
      stopwatch.stop();
    }
  }

  Uri _mergeQueryParameters(Uri uri, Map<String, dynamic> queryParameters) {
    if (queryParameters.isEmpty) {
      return uri;
    }

    final mergedQueryParameters = <String, String>{
      ...uri.queryParameters,
      ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
    };

    return uri.replace(queryParameters: mergedQueryParameters);
  }
}
