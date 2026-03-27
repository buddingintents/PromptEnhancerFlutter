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
    bool structuredOutputOnly = false,
  }) async {
    final refinementInput =
        '''
Detected topic: ${topicResult.category}
Reasoning depth: ${topicResult.reasoningDepth}
Confidence: ${(topicResult.confidence * 100).toStringAsFixed(0)}%
${structuredOutputOnly ? _structuredRefinementHint : ''}
Original prompt:
$input
''';

    final response = await _llmService.refinePrompt(refinementInput);
    final refinedOutput = structuredOutputOnly
        ? _appendStructuredOutputExample(response.text, topicResult)
        : response.text;

    return PromptEntity(
      input: input,
      topic: topicResult.category,
      refinedOutput: refinedOutput,
      tokens: response.tokens,
      provider: response.provider,
      latencyMs: topicResult.latencyMs + response.latencyMs,
      reasoningDepth: topicResult.reasoningDepth,
      topicConfidence: topicResult.confidence,
    );
  }
}

const String _structuredRefinementHint = '''
Structured output required:
- Rewrite the prompt so the target model returns valid JSON only.
- The refined prompt must explicitly forbid markdown, prose, and code fences.
- Include one short JSON example that shows the expected structure.
''';

String _appendStructuredOutputExample(
  String refinedPrompt,
  TopicResult topicResult,
) {
  final trimmedPrompt = refinedPrompt.trim();
  final jsonExample =
      '''
Return format:
- Respond with valid JSON only.
- Do not include markdown, explanations, or code fences.

One-shot JSON example:
{
  "category": "${_jsonEscape(topicResult.category)}",
  "reasoning_depth": "${_jsonEscape(topicResult.reasoningDepth)}",
  "output": "your final answer here",
  "confidence": ${topicResult.confidence.toStringAsFixed(2)}
}
''';

  if (trimmedPrompt.isEmpty) {
    return jsonExample.trim();
  }

  return '$trimmedPrompt\n\n$jsonExample'.trim();
}

String _jsonEscape(String value) {
  return value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
}
