class TrendingTopic {
  const TrendingTopic({
    required this.topic,
    required this.usageCount,
    required this.samplePrompt,
    required this.lastUsedAt,
  });

  final String topic;
  final int usageCount;
  final String samplePrompt;
  final DateTime lastUsedAt;
}
