class HistoryEntry {
  const HistoryEntry({
    required this.prompt,
    required this.refinedPrompt,
    required this.topic,
    required this.tokens,
    required this.timestamp,
    required this.provider,
    this.latencyMs = 0,
  });

  final String prompt;
  final String refinedPrompt;
  final String topic;
  final int tokens;
  final DateTime timestamp;
  final String provider;
  final int latencyMs;

  String get storageKey => timestamp.microsecondsSinceEpoch.toString();
}
