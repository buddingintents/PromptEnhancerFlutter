enum LLMProviderType { openAI, gemini, claude, huggingFace, perplexity }

extension LLMProviderTypeX on LLMProviderType {
  String get key {
    switch (this) {
      case LLMProviderType.openAI:
        return 'openai';
      case LLMProviderType.gemini:
        return 'gemini';
      case LLMProviderType.claude:
        return 'claude';
      case LLMProviderType.huggingFace:
        return 'hugging_face';
      case LLMProviderType.perplexity:
        return 'perplexity';
    }
  }

  String get displayName {
    switch (this) {
      case LLMProviderType.openAI:
        return 'OpenAI';
      case LLMProviderType.gemini:
        return 'Gemini';
      case LLMProviderType.claude:
        return 'Claude';
      case LLMProviderType.huggingFace:
        return 'Hugging Face';
      case LLMProviderType.perplexity:
        return 'Perplexity';
    }
  }
}

LLMProviderType llmProviderTypeFromKey(String value) {
  switch (value.toLowerCase()) {
    case 'openai':
      return LLMProviderType.openAI;
    case 'gemini':
      return LLMProviderType.gemini;
    case 'claude':
      return LLMProviderType.claude;
    case 'hugging_face':
    case 'huggingface':
      return LLMProviderType.huggingFace;
    case 'perplexity':
      return LLMProviderType.perplexity;
    default:
      throw ArgumentError.value(value, 'value', 'Unknown LLM provider type.');
  }
}
