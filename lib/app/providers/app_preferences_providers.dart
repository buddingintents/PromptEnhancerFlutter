import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_enhancer/features/settings/presentation/providers/settings_providers.dart';

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(
    settingsControllerProvider.select((settings) => settings.themeMode),
  );
});

final appLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(
    settingsControllerProvider.select((settings) => settings.locale),
  );
});
