import 'package:prompt_enhancer/core/constants/llm_provider_models.dart';
import 'package:prompt_enhancer/core/storage/base_local_storage_service.dart';
import 'package:prompt_enhancer/core/storage/secure_storage_service.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/data/settings_storage_keys.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/settings_preferences.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/settings_snapshot.dart';
import 'package:prompt_enhancer/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required BaseLocalStorageService localStorage,
    required SecureStorageService secureStorage,
  }) : _localStorage = localStorage,
       _secureStorage = secureStorage;

  final BaseLocalStorageService _localStorage;
  final SecureStorageService _secureStorage;

  @override
  Future<SettingsSnapshot> getSettingsSnapshot() async {
    final providerEntries = await Future.wait(
      LLMProviderType.values.map(_readProviderApiKey),
    );
    final providerModels = Map<LLMProviderType, String>.fromEntries(
      await Future.wait(LLMProviderType.values.map(_readProviderModelEntry)),
    );

    final themePreference = AppThemePreference.fromStorageValue(
      await _localStorage.read<String>(
        boxName: SettingsStorageKeys.preferencesBoxName,
        key: SettingsStorageKeys.themePreference,
      ),
    );
    final language = AppLanguage.fromCode(
      await _localStorage.read<String>(
        boxName: SettingsStorageKeys.preferencesBoxName,
        key: SettingsStorageKeys.language,
      ),
    );
    final preferredProvider = _readPreferredProvider(
      await _localStorage.read<String>(
        boxName: SettingsStorageKeys.preferencesBoxName,
        key: SettingsStorageKeys.preferredProvider,
      ),
    );

    return SettingsSnapshot(
      providerApiKeys: providerEntries,
      providerModels: providerModels,
      preferences: SettingsPreferences(
        themePreference: themePreference,
        language: language,
        preferredProvider: preferredProvider,
      ),
    );
  }

  @override
  Future<void> saveProviderApiKey(ProviderApiKey entry) {
    return _secureStorage.write(
      key: SettingsStorageKeys.apiKeyFor(entry.provider),
      value: entry.value.trim(),
    );
  }

  @override
  Future<void> deleteProviderApiKey(LLMProviderType provider) {
    return _secureStorage.delete(key: SettingsStorageKeys.apiKeyFor(provider));
  }

  @override
  Future<void> updateProviderModel(LLMProviderType provider, String model) {
    return _localStorage.write<String>(
      boxName: SettingsStorageKeys.preferencesBoxName,
      key: SettingsStorageKeys.modelFor(provider),
      value: model.trim(),
    );
  }

  @override
  Future<void> updateThemePreference(AppThemePreference preference) {
    return _localStorage.write<String>(
      boxName: SettingsStorageKeys.preferencesBoxName,
      key: SettingsStorageKeys.themePreference,
      value: preference.storageValue,
    );
  }

  @override
  Future<void> updateLanguagePreference(AppLanguage language) {
    return _localStorage.write<String>(
      boxName: SettingsStorageKeys.preferencesBoxName,
      key: SettingsStorageKeys.language,
      value: language.code,
    );
  }

  @override
  Future<void> updatePreferredProvider(LLMProviderType provider) {
    return _localStorage.write<String>(
      boxName: SettingsStorageKeys.preferencesBoxName,
      key: SettingsStorageKeys.preferredProvider,
      value: provider.key,
    );
  }

  Future<ProviderApiKey> _readProviderApiKey(LLMProviderType provider) async {
    final value =
        await _secureStorage.read(
          key: SettingsStorageKeys.apiKeyFor(provider),
        ) ??
        '';
    return ProviderApiKey(provider: provider, value: value);
  }

  Future<MapEntry<LLMProviderType, String>> _readProviderModelEntry(
    LLMProviderType provider,
  ) async {
    final key = SettingsStorageKeys.modelFor(provider);
    final rawValue =
        await _localStorage.read<String>(
          boxName: SettingsStorageKeys.preferencesBoxName,
          key: key,
        ) ??
        '';
    final normalizedValue = LlmProviderModels.resolveModel(
      provider,
      preferredModel: rawValue,
    );
    final trimmedRawValue = rawValue.trim();

    if (trimmedRawValue.isNotEmpty && trimmedRawValue != normalizedValue) {
      await _localStorage.write<String>(
        boxName: SettingsStorageKeys.preferencesBoxName,
        key: key,
        value: normalizedValue,
      );
    }

    return MapEntry(provider, trimmedRawValue.isEmpty ? '' : normalizedValue);
  }

  LLMProviderType _readPreferredProvider(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return _fallbackProviderFromEnvironment();
    }

    try {
      return llmProviderTypeFromKey(normalized);
    } catch (_) {
      return _fallbackProviderFromEnvironment();
    }
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
