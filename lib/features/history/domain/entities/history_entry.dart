class HistoryEntry {
  const HistoryEntry({
    required this.prompt,
    required this.refinedPrompt,
    required this.topic,
    required this.tokens,
    required this.timestamp,
    required this.provider,
    this.latencyMs = 0,
    this.reasoningDepth = '',
    this.topicConfidence = 0,
    this.countryCode,
    this.deviceId,
    this.deviceModel,
  });

  final String prompt;
  final String refinedPrompt;
  final String topic;
  final int tokens;
  final DateTime timestamp;
  final String provider;
  final int latencyMs;
  final String reasoningDepth;
  final double topicConfidence;
  final String? countryCode;
  final String? deviceId;
  final String? deviceModel;

  String get storageKey => timestamp.microsecondsSinceEpoch.toString();
}
