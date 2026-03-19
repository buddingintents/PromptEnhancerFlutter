import 'package:prompt_enhancer/features/prompt/data/adapters/openai_compatible_adapter.dart';

class OpenAIAdapter extends OpenAICompatibleAdapter {
  const OpenAIAdapter();

  @override
  String get providerName => 'OpenAI';

  @override
  String get defaultBaseUrl => 'https://api.openai.com/v1/';

  @override
  String get defaultRefinePath => 'chat/completions';

  @override
  String get defaultDetectTopicPath => 'chat/completions';
}
