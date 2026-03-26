import 'package:prompt_enhancer/features/metrics/domain/entities/daily_prompt_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/provider_latency_metric.dart';
import 'package:prompt_enhancer/features/metrics/domain/entities/provider_token_metric.dart';

class UsageMetricsSummary {
  const UsageMetricsSummary({
    this.providerTokenMetrics = const [],
    this.promptsPerDay = const [],
    this.providerLatencyMetrics = const [],
    this.averageResponseTimeMs = 0,
    this.totalPrompts = 0,
    this.totalTokens = 0,
  });

  final List<ProviderTokenMetric> providerTokenMetrics;
  final List<DailyPromptMetric> promptsPerDay;
  final List<ProviderLatencyMetric> providerLatencyMetrics;
  final double averageResponseTimeMs;
  final int totalPrompts;
  final int totalTokens;

  bool get hasData => totalPrompts > 0;
}
