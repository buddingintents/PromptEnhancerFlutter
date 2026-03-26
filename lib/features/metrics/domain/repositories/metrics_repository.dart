import 'package:prompt_enhancer/features/metrics/domain/entities/usage_metrics_summary.dart';

abstract class MetricsRepository {
  Future<UsageMetricsSummary> getUsageMetrics();
}
