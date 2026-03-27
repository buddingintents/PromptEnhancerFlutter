import 'package:prompt_enhancer/features/prompt/domain/entities/prompt_entity.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/prompt_repository.dart';

class RefinePromptUseCase {
  const RefinePromptUseCase(this._promptRepository);

  final PromptRepository _promptRepository;

  Future<PromptEntity> call({
    required String input,
    required TopicResult topicResult,
    bool structuredOutputOnly = false,
  }) {
    return _promptRepository.refinePrompt(
      input: input,
      topicResult: topicResult,
      structuredOutputOnly: structuredOutputOnly,
    );
  }
}
