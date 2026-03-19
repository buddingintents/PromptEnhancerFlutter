import 'package:prompt_enhancer/features/prompt/domain/entities/llm_response.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';

abstract class LLMService {
  Future<LLMResponse> refinePrompt(String input);

  Future<TopicResult> detectTopic(String input);
}
