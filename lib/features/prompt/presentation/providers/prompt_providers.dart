import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/di/core_providers.dart';
import 'package:prompt_enhancer/features/prompt/data/repositories/llm_repository_impl.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_config.dart';
import 'package:prompt_enhancer/features/prompt/domain/repositories/llm_repository.dart';
import 'package:prompt_enhancer/features/prompt/domain/services/llm_service.dart';

final llmRepositoryProvider = Provider<LLMRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final apiErrorMapper = ref.watch(apiErrorMapperProvider);

  return LLMRepositoryImpl(dio: dio, apiErrorMapper: apiErrorMapper);
});

final llmServiceProvider = Provider.family<LLMService, LLMProviderConfig>((
  ref,
  config,
) {
  return ref.watch(llmRepositoryProvider).createService(config);
});
