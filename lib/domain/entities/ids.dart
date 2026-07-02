/// Typed identifiers for the domain aggregates. Extension types give each ID its
/// own static type at zero runtime cost — a [CardId] can't be passed where a
/// [DeckId] is expected — while still comparing/serializing as the underlying
/// string. See `docs/business/glossary.md` for the concepts.
library;

/// Identifies a [Card] (`Thẻ học`).
extension type const CardId(String value) {}

/// Identifies a [Deck] (`Bộ thẻ`) — a self-nesting library node.
extension type const DeckId(String value) {}

/// Identifies a [LanguagePair] (`Cặp ngôn ngữ`) — the learning context every
/// piece of content belongs to.
extension type const LanguagePairId(String value) {}

/// Identifies a single [CardMeaning] (`Nghĩa`) block of a card.
extension type const CardMeaningId(String value) {}
