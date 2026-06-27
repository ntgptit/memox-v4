/// A learning context pairing the language being studied with the learner's own
/// language; all content belongs to one pair (`docs/business/glossary.md` —
/// `LanguagePair`). Display direction is reversible, tracked as app context
/// (see `LanguagePairRepository`), not on the entity itself.
///
/// Immutable: const constructor + final fields, no framework dependency.
class LanguagePair {
  const LanguagePair({
    required this.id,
    required this.sourceLang,
    required this.targetLang,
    this.orderIndex = 0,
  });

  /// Stable identity (`language_pair.id`).
  final int id;

  /// Language code being studied (the question side), e.g. `ko`.
  final String sourceLang;

  /// The learner's language, e.g. `vi`.
  final String targetLang;

  /// Display order among pairs.
  final int orderIndex;

  @override
  bool operator ==(Object other) =>
      other is LanguagePair &&
      other.id == id &&
      other.sourceLang == sourceLang &&
      other.targetLang == targetLang &&
      other.orderIndex == orderIndex;

  @override
  int get hashCode => Object.hash(id, sourceLang, targetLang, orderIndex);
}
