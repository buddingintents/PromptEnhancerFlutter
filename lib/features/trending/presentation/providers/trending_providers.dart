import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/presentation/providers/history_providers.dart';
import 'package:prompt_enhancer/features/trending/data/repositories/trending_repository_impl.dart';
import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';
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

final worldTrendingTopicsProvider = StreamProvider<List<TrendingTopic>>((ref) {
  return ref
      .watch(firebaseHistoryServiceProvider)
      .watchHistoryItems()
      .map((items) => _buildWorldTrendingTopics(items));
});

List<TrendingTopic> _buildWorldTrendingTopics(
  List<HistoryEntry> historyItems, {
  int days = 7,
  int limit = 3,
}) {
  final cutoff = DateTime.now().subtract(Duration(days: days));
  final groupedItems = <String, List<HistoryEntry>>{};

  for (final entry in historyItems) {
    final normalizedCategory = entry.topic.trim();
    if (normalizedCategory.isEmpty || entry.timestamp.isBefore(cutoff)) {
      continue;
    }

    groupedItems
        .putIfAbsent(normalizedCategory, () => <HistoryEntry>[])
        .add(entry);
  }

  final topics =
      groupedItems.entries
          .map((group) {
            final entries = [
              ...group.value,
            ]..sort((left, right) => right.timestamp.compareTo(left.timestamp));
            final mostRecentEntry = entries.first;

            return TrendingTopic(
              topic: group.key,
              usageCount: entries.length,
              samplePrompt: mostRecentEntry.prompt,
              lastUsedAt: mostRecentEntry.timestamp,
            );
          })
          .toList(growable: false)
        ..sort((left, right) {
          final usageComparison = right.usageCount.compareTo(left.usageCount);
          if (usageComparison != 0) {
            return usageComparison;
          }

          return left.topic.toLowerCase().compareTo(right.topic.toLowerCase());
        });

  return topics.take(limit).toList(growable: false);
}
