import 'package:prompt_enhancer/features/prompt/domain/entities/prompt_entity.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';

abstract class PromptRepository {
  Future<TopicResult> detectTopic(String input);

  Future<PromptEntity> refinePrompt({
    required String input,
    required TopicResult topicResult,
  });
}
