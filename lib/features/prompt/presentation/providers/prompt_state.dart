class PromptState {
  const PromptState({
    this.input = '',
    this.topic,
    this.refinedOutput,
    this.loading = false,
    this.error,
    this.tokens,
    this.provider,
    this.latencyMs,
    this.reasoningDepth,
    this.topicConfidence,
  });

  final String input;
  final String? topic;
  final String? refinedOutput;
  final bool loading;
  final String? error;
  final int? tokens;
  final String? provider;
  final int? latencyMs;
  final String? reasoningDepth;
  final double? topicConfidence;

  bool get hasTopic => topic != null && topic!.trim().isNotEmpty;

  bool get hasOutput =>
      refinedOutput != null && refinedOutput!.trim().isNotEmpty;

  PromptState copyWith({
    String? input,
    Object? topic = _sentinel,
    Object? refinedOutput = _sentinel,
    bool? loading,
    Object? error = _sentinel,
    Object? tokens = _sentinel,
    Object? provider = _sentinel,
    Object? latencyMs = _sentinel,
    Object? reasoningDepth = _sentinel,
    Object? topicConfidence = _sentinel,
  }) {
    return PromptState(
      input: input ?? this.input,
      topic: identical(topic, _sentinel) ? this.topic : topic as String?,
      refinedOutput: identical(refinedOutput, _sentinel)
          ? this.refinedOutput
          : refinedOutput as String?,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
      tokens: identical(tokens, _sentinel) ? this.tokens : tokens as int?,
      provider: identical(provider, _sentinel)
          ? this.provider
          : provider as String?,
      latencyMs: identical(latencyMs, _sentinel)
          ? this.latencyMs
          : latencyMs as int?,
      reasoningDepth: identical(reasoningDepth, _sentinel)
          ? this.reasoningDepth
          : reasoningDepth as String?,
      topicConfidence: identical(topicConfidence, _sentinel)
          ? this.topicConfidence
          : topicConfidence as double?,
    );
  }
}

const Object _sentinel = Object();
