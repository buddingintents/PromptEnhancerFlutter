import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/core/utils/app_exception.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_providers.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_state.dart';

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final preferredProvider = _fallbackProviderFromEnvironment();
    Future.microtask(loadSettings);
    return SettingsState.initial(preferredProvider: preferredProvider);
  }

  Future<void> loadSettings() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final snapshot = await ref.read(getSettingsSnapshotUseCaseProvider)();
      state = SettingsState.fromSnapshot(snapshot);
    } catch (error) {
      state = state.copyWith(loading: false, error: _mapError(error));
    }
  }

  Future<String> saveApiKey({
    required LLMProviderType provider,
    required String value,
  }) async {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) {
      return 'Enter an API key for ${provider.displayName}.';
    }

    try {
      await ref.read(saveProviderApiKeyUseCaseProvider)(
        ProviderApiKey(provider: provider, value: normalizedValue),
      );

      state = state.copyWith(
        providerApiKeys: _upsertProviderApiKey(
          ProviderApiKey(provider: provider, value: normalizedValue),
        ),
        error: null,
      );
      return 'API key saved for ${provider.displayName}.';
    } catch (error) {
      final message = _mapError(error);
      state = state.copyWith(error: message);
      return message;
    }
  }

  Future<String> deleteApiKey(LLMProviderType provider) async {
    try {
      await ref.read(deleteProviderApiKeyUseCaseProvider)(provider);
      state = state.copyWith(
        providerApiKeys: _upsertProviderApiKey(
          ProviderApiKey(provider: provider),
        ),
        error: null,
      );
      return 'API key deleted for ${provider.displayName}.';
    } catch (error) {
      final message = _mapError(error);
      state = state.copyWith(error: message);
      return message;
    }
  }

  Future<String> copyApiKey(LLMProviderType provider) async {
    final entry = state.apiKeyFor(provider);
    if (!entry.isConfigured) {
      return 'No API key is stored for ${provider.displayName} yet.';
    }

    try {
      final approved = await ref
          .read(biometricGuardProvider)
          .authenticate(reason: 'Copy API key for ${provider.displayName}');
      if (!approved) {
        return 'Biometric check was not approved.';
      }

      await Clipboard.setData(ClipboardData(text: entry.value));
      state = state.copyWith(error: null);
      return 'API key copied after the mock biometric check.';
    } catch (error) {
      final message = _mapError(error);
      state = state.copyWith(error: message);
      return message;
    }
  }

  Future<String> updateProviderModel(
    LLMProviderType provider,
    String model,
  ) async {
    final normalizedModel = model.trim();
    if (normalizedModel.isEmpty) {
      return 'Select a model for ${provider.displayName}.';
    }

    final previousState = state;
    state = state.copyWith(
      providerModels: {...state.providerModels, provider: normalizedModel},
      error: null,
    );

    try {
      await ref.read(updateProviderModelUseCaseProvider)(
        provider,
        normalizedModel,
      );
      return 'Model updated for ${provider.displayName}.';
    } catch (error) {
      final message = _mapError(error);
      state = previousState.copyWith(error: message);
      return message;
    }
  }

  Future<void> updateThemePreference(AppThemePreference preference) async {
    final previousState = state;
    state = state.copyWith(themePreference: preference, error: null);

    try {
      await ref.read(updateThemePreferenceUseCaseProvider)(preference);
    } catch (error) {
      state = previousState.copyWith(error: _mapError(error));
    }
  }

  Future<void> updateLanguage(AppLanguage language) async {
    final previousState = state;
    state = state.copyWith(language: language, error: null);

    try {
      await ref.read(updateLanguagePreferenceUseCaseProvider)(language);
    } catch (error) {
      state = previousState.copyWith(error: _mapError(error));
    }
  }

  Future<void> updatePreferredProvider(LLMProviderType provider) async {
    final previousState = state;
    state = state.copyWith(preferredProvider: provider, error: null);

    try {
      await ref.read(updatePreferredProviderUseCaseProvider)(provider);
    } catch (error) {
      state = previousState.copyWith(error: _mapError(error));
    }
  }

  List<ProviderApiKey> _upsertProviderApiKey(ProviderApiKey nextEntry) {
    return [
      for (final provider in LLMProviderType.values)
        if (provider == nextEntry.provider)
          nextEntry
        else
          state.apiKeyFor(provider),
    ];
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Unable to update settings right now.';
  }

  LLMProviderType _fallbackProviderFromEnvironment() {
    const rawProvider = String.fromEnvironment(
      'PROMPT_PROVIDER',
      defaultValue: 'openai',
    );

    try {
      return llmProviderTypeFromKey(rawProvider);
    } catch (_) {
      return LLMProviderType.openAI;
    }
  }
}
