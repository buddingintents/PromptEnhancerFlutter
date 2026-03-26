import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/prompt_entity.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/topic_result.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/prompt_repository.dart';
import 'package:prompt_enhancer/features/prompt/presentation/providers/prompt_providers.dart';

void main() {
  group('PromptController', () {
    test('validates empty input before calling the repository', () async {
      final promptRepository = FakePromptRepository();
      final container = _buildContainer(promptRepository: promptRepository);
      addTearDown(container.dispose);

      await container.read(promptControllerProvider.notifier).refinePrompt();

      final state = container.read(promptControllerProvider);
      expect(state.error, 'Enter a prompt to refine.');
      expect(promptRepository.detectTopicCallCount, 0);
      expect(promptRepository.refinePromptCallCount, 0);
    });

    test('requires an API key for the active provider', () async {
      final promptRepository = FakePromptRepository();
      final container = _buildContainer(
        promptRepository: promptRepository,
        config: LLMProviderConfig.openAI(model: 'gpt-4.1-mini', apiKey: ''),
      );
      addTearDown(container.dispose);

      final controller = container.read(promptControllerProvider.notifier);
      controller.updateInput('Rewrite this marketing prompt.');
      await controller.refinePrompt();

      final state = container.read(promptControllerProvider);
      expect(
        state.error,
        'No API key is configured for OpenAI. Add one in Settings.',
      );
      expect(promptRepository.detectTopicCallCount, 0);
      expect(promptRepository.refinePromptCallCount, 0);
    });

    test(
      'shows Gemini-specific guidance when the selected model is unavailable',
      () async {
        final promptRepository = FakePromptRepository(
          detectTopicError: AppException.notFound(
            message: 'Unable to complete the request.',
          ),
        );
        final container = _buildContainer(
          promptRepository: promptRepository,
          config: LLMProviderConfig.gemini(
            model: 'gemini-1.5-flash',
            apiKey: 'test-key',
          ),
        );
        addTearDown(container.dispose);

        final controller = container.read(promptControllerProvider.notifier);
        controller.updateInput('Surprise me');
        await controller.refinePrompt();

        final state = container.read(promptControllerProvider);
        expect(state.loading, isFalse);
        expect(
          state.error,
          'The selected Gemini model is unavailable. Open Settings and switch to Gemini 2.5 Flash, Gemini 2.5 Flash-Lite, or Gemini 2.5 Pro.',
        );
        expect(state.refinedOutput, isNull);
      },
    );
    test('completes the detect, refine, and save flow', () async {
      final topicResult = TopicResult(
        category: 'Marketing',
        reasoningDepth: 'deep',
        confidence: 0.92,
        provider: 'OpenAI',
        latencyMs: 120,
      );
      final promptEntity = PromptEntity(
        input: 'Rewrite this product brief for a launch email.',
        topic: 'Marketing',
        refinedOutput:
            'Create a launch email prompt with audience, tone, CTA, and constraints.',
        tokens: 256,
        provider: 'OpenAI',
        latencyMs: 480,
        reasoningDepth: 'deep',
        topicConfidence: 0.92,
      );
      final promptRepository = FakePromptRepository(
        topicResult: topicResult,
        promptEntity: promptEntity,
      );
      final historyRepository = FakeHistoryRepository();
      final container = _buildContainer(
        promptRepository: promptRepository,
        historyRepository: historyRepository,
      );
      addTearDown(container.dispose);

      final controller = container.read(promptControllerProvider.notifier);
      controller.updateInput(promptEntity.input);
      await controller.refinePrompt();

      final state = container.read(promptControllerProvider);
      expect(promptRepository.detectTopicCallCount, 1);
      expect(promptRepository.refinePromptCallCount, 1);
      expect(promptRepository.lastDetectInput, promptEntity.input);
      expect(promptRepository.lastRefineCall?.input, promptEntity.input);
      expect(state.loading, isFalse);
      expect(state.error, isNull);
      expect(state.topic, promptEntity.topic);
      expect(state.refinedOutput, promptEntity.refinedOutput);
      expect(state.tokens, promptEntity.tokens);
      expect(state.provider, promptEntity.provider);
      expect(state.latencyMs, promptEntity.latencyMs);
      expect(state.reasoningDepth, promptEntity.reasoningDepth);
      expect(state.topicConfidence, promptEntity.topicConfidence);
      expect(historyRepository.savedEntries, hasLength(1));
      expect(historyRepository.savedEntries.single.prompt, promptEntity.input);
      expect(
        historyRepository.savedEntries.single.refinedPrompt,
        promptEntity.refinedOutput,
      );
    });

    test('maps AppException failures into state', () async {
      final promptRepository = FakePromptRepository(
        detectTopicError: AppException.server(message: 'Provider unavailable.'),
      );
      final container = _buildContainer(promptRepository: promptRepository);
      addTearDown(container.dispose);

      final controller = container.read(promptControllerProvider.notifier);
      controller.updateInput('Draft a support response prompt.');
      await controller.refinePrompt();

      final state = container.read(promptControllerProvider);
      expect(state.loading, isFalse);
      expect(state.error, 'Provider unavailable.');
      expect(state.refinedOutput, isNull);
    });
  });
}

ProviderContainer _buildContainer({
  required PromptRepository promptRepository,
  HistoryRepository? historyRepository,
  LLMProviderConfig? config,
}) {
  return ProviderContainer(
    overrides: [
      promptRepositoryProvider.overrideWith((ref) => promptRepository),
      historyRepositoryProvider.overrideWith(
        (ref) => historyRepository ?? FakeHistoryRepository(),
      ),
      activePromptProviderConfigProvider.overrideWith(
        (ref) =>
            config ??
            LLMProviderConfig.openAI(model: 'gpt-4.1-mini', apiKey: 'test-key'),
      ),
    ],
  );
}

class FakePromptRepository implements PromptRepository {
  FakePromptRepository({
    this.topicResult,
    this.promptEntity,
    this.detectTopicError,
    this.refinePromptError,
  });

  final TopicResult? topicResult;
  final PromptEntity? promptEntity;
  final Object? detectTopicError;
  final Object? refinePromptError;

  int detectTopicCallCount = 0;
  int refinePromptCallCount = 0;
  String? lastDetectInput;
  ({String input, TopicResult topicResult})? lastRefineCall;

  @override
  Future<TopicResult> detectTopic(String input) async {
    detectTopicCallCount += 1;
    lastDetectInput = input;

    if (detectTopicError != null) {
      throw detectTopicError!;
    }

    return topicResult ??
        const TopicResult(
          category: 'General',
          reasoningDepth: 'standard',
          confidence: 0.5,
          provider: 'OpenAI',
          latencyMs: 100,
        );
  }

  @override
  Future<PromptEntity> refinePrompt({
    required String input,
    required TopicResult topicResult,
  }) async {
    refinePromptCallCount += 1;
    lastRefineCall = (input: input, topicResult: topicResult);

    if (refinePromptError != null) {
      throw refinePromptError!;
    }

    return promptEntity ??
        PromptEntity(
          input: input,
          topic: topicResult.category,
          refinedOutput: 'Refined prompt output',
          tokens: 120,
          provider: 'OpenAI',
          latencyMs: 320,
          reasoningDepth: topicResult.reasoningDepth,
          topicConfidence: topicResult.confidence,
        );
  }
}

class FakeHistoryRepository implements HistoryRepository {
  final List<HistoryEntry> savedEntries = <HistoryEntry>[];

  @override
  Future<void> deleteHistory(DateTime timestamp) async {
    savedEntries.removeWhere((entry) => entry.timestamp == timestamp);
  }

  @override
  Future<List<HistoryEntry>> getHistory() async {
    return List<HistoryEntry>.unmodifiable(savedEntries);
  }

  @override
  Future<void> saveHistory(HistoryEntry entry) async {
    savedEntries.add(entry);
  }
}
