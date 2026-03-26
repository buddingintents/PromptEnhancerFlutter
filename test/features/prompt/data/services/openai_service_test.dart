import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_enhancer/core/network/api_error_mapper.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/prompt/data/services/openai_service.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';

void main() {
  group('OpenAIService', () {
    test(
      'refinePrompt normalizes text, tokens, and provider metadata',
      () async {
        final service = OpenAIService(
          dio: _buildDio(
            onRequest: (options, handler) {
              expect(options.headers['Authorization'], 'Bearer test-key');
              expect(
                options.uri.toString(),
                'https://api.openai.com/v1/chat/completions',
              );
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'choices': [
                      {
                        'message': {'content': 'Refined prompt output'},
                      },
                    ],
                    'usage': {'total_tokens': 321},
                  },
                ),
              );
            },
          ),
          apiErrorMapper: const ApiErrorMapper(),
          config: LLMProviderConfig.openAI(
            model: 'gpt-4.1-mini',
            apiKey: 'test-key',
          ),
        );

        final response = await service.refinePrompt('Rewrite this prompt.');

        expect(response.text, 'Refined prompt output');
        expect(response.tokens, 321);
        expect(response.provider, 'OpenAI');
        expect(response.latencyMs, greaterThanOrEqualTo(0));
      },
    );

    test('detectTopic parses structured JSON content', () async {
      final service = OpenAIService(
        dio: _buildDio(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'choices': [
                    {
                      'message': {
                        'content':
                            '{"category":"Marketing","reasoningDepth":"deep","confidence":0.91}',
                      },
                    },
                  ],
                },
              ),
            );
          },
        ),
        apiErrorMapper: const ApiErrorMapper(),
        config: LLMProviderConfig.openAI(
          model: 'gpt-4.1-mini',
          apiKey: 'test-key',
        ),
      );

      final result = await service.detectTopic('Classify this prompt.');

      expect(result.category, 'Marketing');
      expect(result.reasoningDepth, 'deep');
      expect(result.confidence, 0.91);
      expect(result.provider, 'OpenAI');
      expect(result.latencyMs, greaterThanOrEqualTo(0));
    });

    test('maps Dio failures into AppException', () async {
      final service = OpenAIService(
        dio: _buildDio(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Invalid API key.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
        apiErrorMapper: const ApiErrorMapper(),
        config: LLMProviderConfig.openAI(
          model: 'gpt-4.1-mini',
          apiKey: 'test-key',
        ),
      );

      await expectLater(
        service.refinePrompt('Rewrite this prompt.'),
        throwsA(
          isA<AppException>()
              .having(
                (error) => error.type,
                'type',
                AppExceptionType.unauthorized,
              )
              .having((error) => error.message, 'message', 'Invalid API key.'),
        ),
      );
    });
  });
}

Dio _buildDio({
  required void Function(
    RequestOptions options,
    RequestInterceptorHandler handler,
  )
  onRequest,
}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}
