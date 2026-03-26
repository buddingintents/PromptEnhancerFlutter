enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'Hindi');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  static AppLanguage fromCode(String? value) {
    return AppLanguage.values.firstWhere(
      (candidate) => candidate.code == value,
      orElse: () => AppLanguage.english,
    );
  }
}
