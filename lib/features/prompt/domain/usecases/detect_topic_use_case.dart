import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/prompt_repository.dart';

class DetectTopicUseCase {
  const DetectTopicUseCase(this._promptRepository);

  final PromptRepository _promptRepository;

  Future<TopicResult> call(String input) {
    return _promptRepository.detectTopic(input);
  }
}
