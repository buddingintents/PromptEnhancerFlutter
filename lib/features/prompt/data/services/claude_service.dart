import 'package:prompt_enhancer/features/prompt/data/adapters/claude_adapter.dart';
import 'package:prompt_enhancer/features/prompt/data/services/adapter_backed_llm_service.dart';

class ClaudeService extends AdapterBackedLLMService {
  ClaudeService({
    required super.dio,
    required super.apiErrorMapper,
    required super.config,
  }) : super(adapter: const ClaudeAdapter());
}
