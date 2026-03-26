import 'package:prompt_enhancer/features/history/domain/repositories/history_repository.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/daily_prompt_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/provider_latency_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/provider_token_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/usage_metrics_summary.dart';
import 'package:prompt_enhancer/features/metrics/domain/repositories/metrics_repository.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  const MetricsRepositoryImpl({required HistoryRepository historyRepository})
    : _historyRepository = historyRepository;

  final HistoryRepository _historyRepository;

  @override
  Future<UsageMetricsSummary> getUsageMetrics() async {
    final history = await _historyRepository.getHistory();
    if (history.isEmpty) {
      return const UsageMetricsSummary();
    }

    final providerTokenTotals = <String, int>{};
    final promptsPerDayMap = <DateTime, int>{};
    final providerLatencyValues = <String, List<int>>{};
    var totalTokens = 0;
    final validLatencies = <int>[];

    for (final item in history) {
      totalTokens += item.tokens;
      providerTokenTotals.update(
        item.provider,
        (value) => value + item.tokens,
        ifAbsent: () => item.tokens,
      );

      final date = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      promptsPerDayMap.update(date, (value) => value + 1, ifAbsent: () => 1);

      if (item.latencyMs > 0) {
        validLatencies.add(item.latencyMs);
        providerLatencyValues
            .putIfAbsent(item.provider, () => <int>[])
            .add(item.latencyMs);
      }
    }

    final providerTokenMetrics =
        providerTokenTotals.entries
            .map(
              (entry) => ProviderTokenMetric(
                provider: entry.key,
                totalTokens: entry.value,
              ),
            )
            .toList(growable: false)
          ..sort(
            (left, right) => right.totalTokens.compareTo(left.totalTokens),
          );

    final promptsPerDay =
        promptsPerDayMap.entries
            .map(
              (entry) =>
                  DailyPromptMetric(date: entry.key, promptCount: entry.value),
            )
            .toList(growable: false)
          ..sort((left, right) => left.date.compareTo(right.date));

    final providerLatencyMetrics =
        providerLatencyValues.entries
            .map(
              (entry) => ProviderLatencyMetric(
                provider: entry.key,
                averageLatencyMs: _average(entry.value),
              ),
            )
            .toList(growable: false)
          ..sort(
            (left, right) => left.provider.toLowerCase().compareTo(
              right.provider.toLowerCase(),
            ),
          );

    return UsageMetricsSummary(
      providerTokenMetrics: providerTokenMetrics,
      promptsPerDay: promptsPerDay,
      providerLatencyMetrics: providerLatencyMetrics,
      averageResponseTimeMs: _average(validLatencies),
      totalPrompts: history.length,
      totalTokens: totalTokens,
    );
  }

  double _average(List<int> values) {
    if (values.isEmpty) {
      return 0;
    }

    final total = values.fold<int>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
