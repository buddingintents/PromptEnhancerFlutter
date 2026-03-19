class TopicResult {
  const TopicResult({
    required this.category,
    required this.reasoningDepth,
    required this.confidence,
    required this.provider,
    required this.latencyMs,
  });

  final String category;
  final String reasoningDepth;
  final double confidence;
  final String provider;
  final int latencyMs;
}
