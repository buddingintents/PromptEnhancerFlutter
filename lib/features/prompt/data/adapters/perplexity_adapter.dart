import 'package:prompt_enhancer/features/prompt/data/adapters/openai_compatible_adapter.dart';

class PerplexityAdapter extends OpenAICompatibleAdapter {
  const PerplexityAdapter();

  @override
  String get providerName => 'Perplexity';

  @override
  String get defaultBaseUrl => 'https://api.perplexity.ai/';

  @override
  String get defaultRefinePath => 'v1/sonar';

  @override
  String get defaultDetectTopicPath => 'v1/sonar';
}
