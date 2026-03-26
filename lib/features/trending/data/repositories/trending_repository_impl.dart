import 'package:prompt_enhancer/features/history/domain/entities/history_entry.dart';
import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';
import 'package:prompt_enhancer/features/trending/domain/entities/trending_topic.dart';
import 'package:prompt_enhancer/features/trending/domain/repositories/trending_repository.dart';

class TrendingRepositoryImpl implements TrendingRepository {
  const TrendingRepositoryImpl({required HistoryRepository historyRepository})
    : _historyRepository = historyRepository;

  final HistoryRepository _historyRepository;

  @override
  Future<List<TrendingTopic>> getTrendingTopics({int days = 7}) async {
    final history = await _historyRepository.getHistory();
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final recentItems = history.where((entry) {
      final normalizedTopic = entry.topic.trim();
      return normalizedTopic.isNotEmpty && !entry.timestamp.isBefore(cutoff);
    });

    final groupedItems = <String, List<HistoryEntry>>{};
    for (final entry in recentItems) {
      groupedItems
          .putIfAbsent(entry.topic.trim(), () => <HistoryEntry>[])
          .add(entry);
    }

    final topics =
        groupedItems.entries
            .map((group) {
              final entries = [...group.value]
                ..sort(
                  (left, right) => right.timestamp.compareTo(left.timestamp),
                );
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

            return right.lastUsedAt.compareTo(left.lastUsedAt);
          });

    return topics;
  }
}
