import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_response.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/services/llm_service.dart';

abstract class LLMRepository {
  LLMService createService(LLMProviderConfig config);

  Future<LLMResponse> refinePrompt({
    required LLMProviderConfig config,
    required String input,
  });

  Future<TopicResult> detectTopic({
    required LLMProviderConfig config,
    required String input,
  });
}
