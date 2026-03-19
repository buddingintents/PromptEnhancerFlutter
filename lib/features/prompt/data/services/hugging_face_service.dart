import 'package:prompt_enhancer/features/prompt/data/adapters/hugging_face_adapter.dart';
import 'package:prompt_enhancer/features/prompt/data/services/adapter_backed_llm_service.dart';

class HuggingFaceService extends AdapterBackedLLMService {
  HuggingFaceService({
    required super.dio,
    required super.apiErrorMapper,
    required super.config,
  }) : super(adapter: const HuggingFaceAdapter());
}
