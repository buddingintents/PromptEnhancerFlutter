import 'package:prompt_enhancer/features/metrics/domain/entities/usage_metrics_summary.dart';

class MetricsState {
  const MetricsState({
    this.summary = const UsageMetricsSummary(),
    this.loading = false,
    this.error,
  });

  final UsageMetricsSummary summary;
  final bool loading;
  final String? error;

  MetricsState copyWith({
    UsageMetricsSummary? summary,
    bool? loading,
    Object? error = _sentinel,
  }) {
    return MetricsState(
      summary: summary ?? this.summary,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();
