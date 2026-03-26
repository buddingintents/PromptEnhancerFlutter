import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';

class ProviderApiKey {
  const ProviderApiKey({required this.provider, this.value = ''});

  final LLMProviderType provider;
  final String value;

  bool get isConfigured => value.trim().isNotEmpty;

  String get maskedValue {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Not configured';
    }

    final visibleCharacters = normalized.length >= 4
        ? normalized.substring(normalized.length - 4)
        : normalized;
    return '********$visibleCharacters';
  }

  ProviderApiKey copyWith({LLMProviderType? provider, String? value}) {
    return ProviderApiKey(
      provider: provider ?? this.provider,
      value: value ?? this.value,
    );
  }
}
