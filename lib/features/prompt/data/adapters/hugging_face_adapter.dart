import 'package:prompt_enhancer/features/prompt/data/adapters/openai_compatible_adapter.dart';

class HuggingFaceAdapter extends OpenAICompatibleAdapter {
  const HuggingFaceAdapter();

  @override
  String get providerName => 'Hugging Face';

  @override
  String get defaultBaseUrl => 'https://router.huggingface.co/v1/';

  @override
  String get defaultRefinePath => 'chat/completions';

  @override
  String get defaultDetectTopicPath => 'chat/completions';
}
