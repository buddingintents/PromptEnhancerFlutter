class LLMResponse {
  const LLMResponse({
    required this.text,
    required this.tokens,
    required this.provider,
    required this.latencyMs,
  });

  final String text;
  final int tokens;
  final String provider;
  final int latencyMs;
}
