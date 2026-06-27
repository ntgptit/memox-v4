/// A meaning block for a card in one language — a single free-text field
/// (`docs/business/glossary.md` — `CardMeaning`; `docs/contracts/types-catalog.md`).
/// The invariant (non-empty content) is enforced by the card use cases at the
/// boundary, not in this holder.
class CardMeaning {
  const CardMeaning({required this.lang, required this.content, this.id});

  /// Row id once persisted; null for an unsaved meaning.
  final int? id;

  /// Language code of this meaning, e.g. `vi`.
  final String lang;

  /// Free-text meaning (translation + notes + examples in one field).
  final String content;

  CardMeaning copyWith({int? id, String? lang, String? content}) => CardMeaning(
    id: id ?? this.id,
    lang: lang ?? this.lang,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      other is CardMeaning &&
      other.id == id &&
      other.lang == lang &&
      other.content == content;

  @override
  int get hashCode => Object.hash(id, lang, content);
}
