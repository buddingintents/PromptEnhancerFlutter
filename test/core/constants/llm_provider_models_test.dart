import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_enhancer/core/constants/llm_provider_models.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';

void main() {
  group('LlmProviderModels', () {
    test('maps legacy Gemini models to the current supported aliases', () {
      expect(
        LlmProviderModels.resolveModel(
          LLMProviderType.gemini,
          preferredModel: 'gemini-1.5-flash',
        ),
        'gemini-2.5-flash',
      );
      expect(
        LlmProviderModels.resolveModel(
          LLMProviderType.gemini,
          preferredModel: 'gemini-1.5-pro',
        ),
        'gemini-2.5-pro',
      );
    });

    test(
      'keeps custom model ids for providers that support manual entries',
      () {
        expect(
          LlmProviderModels.resolveModel(
            LLMProviderType.openAI,
            preferredModel: 'gpt-4.1-nano',
          ),
          'gpt-4.1-nano',
        );
      },
    );
  });
}
