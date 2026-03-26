import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/trending/data/repositories/trending_repository_impl.dart';
import 'package:prompt_enhancer/features/trending/domain/repositories/trending_repository.dart';
import 'package:prompt_enhancer/features/trending/domain/usecases/get_trending_topics_use_case.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_controller.dart';
import 'package:prompt_enhancer/features/trending/presentation/providers/trending_state.dart';

final trendingRepositoryProvider = Provider<TrendingRepository>((ref) {
  return TrendingRepositoryImpl(
    historyRepository: ref.watch(historyRepositoryProvider),
  );
});

final getTrendingTopicsUseCaseProvider = Provider<GetTrendingTopicsUseCase>((
  ref,
) {
  return GetTrendingTopicsUseCase(ref.watch(trendingRepositoryProvider));
});

final trendingControllerProvider =
    NotifierProvider<TrendingController, TrendingState>(TrendingController.new);
