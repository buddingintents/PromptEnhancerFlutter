import 'package:prompt_enhancer/features/prompt/data/adapters/gemini_adapter.dart';
import 'package:prompt_enhancer/features/prompt/data/services/adapter_backed_llm_service.dart';

class GeminiService extends AdapterBackedLLMService {
  GeminiService({
    required super.dio,
    required super.apiErrorMapper,
    required super.config,
  }) : super(adapter: const GeminiAdapter());
}
