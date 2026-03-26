enum AppThemePreference {
  system('system', 'System'),
  light('light', 'Light'),
  dark('dark', 'Dark');

  const AppThemePreference(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static AppThemePreference fromStorageValue(String? value) {
    return AppThemePreference.values.firstWhere(
      (candidate) => candidate.storageValue == value,
      orElse: () => AppThemePreference.system,
    );
  }
}
