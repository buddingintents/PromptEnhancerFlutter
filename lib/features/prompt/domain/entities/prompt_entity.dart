class PromptEntity {
  const PromptEntity({
    required this.input,
    required this.topic,
    required this.refinedOutput,
    required this.tokens,
    required this.provider,
    required this.latencyMs,
    required this.reasoningDepth,
    required this.topicConfidence,
  });

  final String input;
  final String topic;
  final String refinedOutput;
  final int tokens;
  final String provider;
  final int latencyMs;
  final String reasoningDepth;
  final double topicConfidence;
}
