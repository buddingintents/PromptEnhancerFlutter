import 'package:prompt_enhancer/features/prompt/data/adapters/perplexity_adapter.dart';
import 'package:prompt_enhancer/features/prompt/data/services/adapter_backed_llm_service.dart';

class PerplexityService extends AdapterBackedLLMService {
  PerplexityService({
    required super.dio,
    required super.apiErrorMapper,
    required super.config,
  }) : super(adapter: const PerplexityAdapter());
}
