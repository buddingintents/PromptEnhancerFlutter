import 'package:prompt_enhancer/features/prompt/domain/entities/prompt_entity.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/prompt_repository.dart';
import 'package:prompt_enhancer/features/prompt/domain/services/llm_service.dart';

class PromptRepositoryImpl implements PromptRepository {
  const PromptRepositoryImpl({required LLMService llmService})
    : _llmService = llmService;

  final LLMService _llmService;

  @override
  Future<TopicResult> detectTopic(String input) {
    return _llmService.detectTopic(input);
  }

  @override
  Future<PromptEntity> refinePrompt({
    required String input,
    required TopicResult topicResult,
  }) async {
    final refinementInput =
        '''
Detected topic: ${topicResult.category}
Reasoning depth: ${topicResult.reasoningDepth}
Confidence: ${(topicResult.confidence * 100).toStringAsFixed(0)}%

Original prompt:
$input
''';

    final response = await _llmService.refinePrompt(refinementInput);

    return PromptEntity(
      input: input,
      topic: topicResult.category,
      refinedOutput: response.text,
      tokens: response.tokens,
      provider: response.provider,
      latencyMs: topicResult.latencyMs + response.latencyMs,
      reasoningDepth: topicResult.reasoningDepth,
      topicConfidence: topicResult.confidence,
    );
  }
}
