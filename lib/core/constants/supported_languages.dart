/// A selectable language: its code plus its endonym (the language's own name).
/// Endonyms are proper nouns shown identically in every UI locale, so they are
/// reference data — not localizable copy.
class SupportedLanguage {
  const SupportedLanguage(this.code, this.endonym);

  /// Language code stored on a pair, e.g. `ko`.
  final String code;

  /// The language's own name, e.g. `한국어`.
  final String endonym;
}

/// The languages offered by the add-language picker. Curated reference data;
/// extend as the product grows.
const List<SupportedLanguage> kSupportedLanguages = <SupportedLanguage>[
  SupportedLanguage('vi', 'Tiếng Việt'),
  SupportedLanguage('en', 'English'),
  SupportedLanguage('ko', '한국어'),
  SupportedLanguage('ja', '日本語'),
  SupportedLanguage('zh', '中文'),
  SupportedLanguage('fr', 'Français'),
  SupportedLanguage('de', 'Deutsch'),
  SupportedLanguage('es', 'Español'),
  SupportedLanguage('ru', 'Русский'),
  SupportedLanguage('it', 'Italiano'),
];

/// The endonym for a code, falling back to the raw code when unknown.
String endonymOf(String code) {
  for (final language in kSupportedLanguages) {
    if (language.code == code) return language.endonym;
  }
  return code;
}
