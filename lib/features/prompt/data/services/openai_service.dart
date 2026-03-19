import 'package:prompt_enhancer/features/prompt/data/adapters/openai_adapter.dart';
import 'package:prompt_enhancer/features/prompt/data/services/adapter_backed_llm_service.dart';

class OpenAIService extends AdapterBackedLLMService {
  OpenAIService({
    required super.dio,
    required super.apiErrorMapper,
    required super.config,
  }) : super(adapter: const OpenAIAdapter());
}
