class ProviderLatencyMetric {
  const ProviderLatencyMetric({
    required this.provider,
    required this.averageLatencyMs,
  });

  final String provider;
  final double averageLatencyMs;
}
