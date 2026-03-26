import 'package:flutter/material.dart';
import 'package:prompt_enhancer/core/constants/llm_provider_models.dart';
import 'package:prompt_enhancer/features/prompt/domain/entities/llm_provider_type.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_language.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/app_theme_preference.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/provider_api_key.dart';
import 'package:prompt_enhancer/features/settings/domain/entities/settings_snapshot.dart';

class SettingsState {
  const SettingsState({
    this.providerApiKeys = const [],
    this.providerModels = const {},
    this.themePreference = AppThemePreference.system,
    this.language = AppLanguage.english,
    this.preferredProvider = LLMProviderType.openAI,
    this.loading = false,
    this.error,
  });

  factory SettingsState.initial({
    LLMProviderType preferredProvider = LLMProviderType.openAI,
  }) {
    return SettingsState(
      providerApiKeys: LLMProviderType.values
          .map((provider) => ProviderApiKey(provider: provider))
          .toList(growable: false),
      preferredProvider: preferredProvider,
      loading: true,
    );
  }

  factory SettingsState.fromSnapshot(
    SettingsSnapshot snapshot, {
    bool loading = false,
    String? error,
  }) {
    return SettingsState(
      providerApiKeys: snapshot.providerApiKeys,
      providerModels: snapshot.providerModels,
      themePreference: snapshot.preferences.themePreference,
      language: snapshot.preferences.language,
      preferredProvider: snapshot.preferences.preferredProvider,
      loading: loading,
      error: error,
    );
  }

  final List<ProviderApiKey> providerApiKeys;
  final Map<LLMProviderType, String> providerModels;
  final AppThemePreference themePreference;
  final AppLanguage language;
  final LLMProviderType preferredProvider;
  final bool loading;
  final String? error;

  ThemeMode get themeMode {
    switch (themePreference) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  Locale get locale => Locale(language.code);

  ProviderApiKey apiKeyFor(LLMProviderType provider) {
    return providerApiKeys.firstWhere(
      (entry) => entry.provider == provider,
      orElse: () => ProviderApiKey(provider: provider),
    );
  }

  String? selectedModelFor(LLMProviderType provider) {
    return LlmProviderModels.normalizeModelAlias(
      provider,
      providerModels[provider],
    );
  }

  String resolvedModelFor(LLMProviderType provider) {
    return LlmProviderModels.resolveModel(
      provider,
      preferredModel: providerModels[provider],
    );
  }

  SettingsState copyWith({
    List<ProviderApiKey>? providerApiKeys,
    Map<LLMProviderType, String>? providerModels,
    AppThemePreference? themePreference,
    AppLanguage? language,
    LLMProviderType? preferredProvider,
    bool? loading,
    Object? error = _sentinel,
  }) {
    return SettingsState(
      providerApiKeys: providerApiKeys ?? this.providerApiKeys,
      providerModels: providerModels ?? this.providerModels,
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      preferredProvider: preferredProvider ?? this.preferredProvider,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();
