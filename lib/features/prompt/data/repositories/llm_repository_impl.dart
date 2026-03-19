import 'package:dio/dio.dart';
import 'package:prompt_enhancer/core/network/api_error_mapper.dart';
import 'package:prompt_enhancer/features/prompt/data/services/claude_service.dart';
import 'package:prompt_enhancer/features/prompt/data/services/gemini_service.dart';
import 'package:prompt_enhancer/features/prompt/data/services/hugging_face_service.dart';
import 'package:prompt_enhancer/features/prompt/data/services/openai_service.dart';
import 'package:prompt_enhancer/features/prompt/data/services/perplexity_service.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_response.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/llm_repository.dart';
import 'package:prompt_enhancer/features/prompt/domain/services/llm_service.dart';

class LLMRepositoryImpl implements LLMRepository {
  const LLMRepositoryImpl({
    required Dio dio,
    required ApiErrorMapper apiErrorMapper,
  }) : _dio = dio,
       _apiErrorMapper = apiErrorMapper;

  final Dio _dio;
  final ApiErrorMapper _apiErrorMapper;

  @override
  LLMService createService(LLMProviderConfig config) {
    switch (config.type) {
      case LLMProviderType.openAI:
        return OpenAIService(
          dio: _dio,
          apiErrorMapper: _apiErrorMapper,
          config: config,
        );
      case LLMProviderType.gemini:
        return GeminiService(
          dio: _dio,
          apiErrorMapper: _apiErrorMapper,
          config: config,
        );
      case LLMProviderType.claude:
        return ClaudeService(
          dio: _dio,
          apiErrorMapper: _apiErrorMapper,
          config: config,
        );
      case LLMProviderType.huggingFace:
        return HuggingFaceService(
          dio: _dio,
          apiErrorMapper: _apiErrorMapper,
          config: config,
        );
      case LLMProviderType.perplexity:
        return PerplexityService(
          dio: _dio,
          apiErrorMapper: _apiErrorMapper,
          config: config,
        );
    }
  }

  @override
  Future<LLMResponse> refinePrompt({
    required LLMProviderConfig config,
    required String input,
  }) {
    return createService(config).refinePrompt(input);
  }

  @override
  Future<TopicResult> detectTopic({
    required LLMProviderConfig config,
    required String input,
  }) {
    return createService(config).detectTopic(input);
  }
}
