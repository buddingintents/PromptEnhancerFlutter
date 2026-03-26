import 'package:prompt_enhancer/features/metrics/domain/entities/usage_metrics_summary.dart';
import 'package:prompt_enhancer/features/metrics/domain/repositories/metrics_repository.dart';

class GetUsageMetricsUseCase {
  const GetUsageMetricsUseCase(this._metricsRepository);

  final MetricsRepository _metricsRepository;

  Future<UsageMetricsSummary> call() {
    return _metricsRepository.getUsageMetrics();
  }
}
