import 'package:memox_v4/domain/entities/card.dart';

/// The authoritative card-search rule (global-search D-019). The query is split
/// into whitespace tokens; a card matches when **every** token is a substring of
/// its term or of one of its meanings (case-insensitive AND across tokens). A
/// single token therefore behaves as a plain substring match.
///
/// Hidden cards are NOT excluded — search must still surface them (D-028 / AC-2).
/// The SQL-backed [CardRepository.search] implements these same semantics; this is
/// the canonical, unit-testable definition it must mirror.
abstract final class CardSearch {
  static final RegExp _whitespace = RegExp(r'\s+');

  static List<String> tokenize(String query) => query
      .toLowerCase()
      .split(_whitespace)
      .where((token) => token.isNotEmpty)
      .toList(growable: false);

  static bool matches(Card card, String query) {
    final tokens = tokenize(query);
    if (tokens.isEmpty) return false;
    final haystacks = <String>[
      card.term.toLowerCase(),
      for (final meaning in card.meanings) meaning.text.toLowerCase(),
    ];
    return tokens
        .every((token) => haystacks.any((field) => field.contains(token)));
  }

  static List<Card> filter(Iterable<Card> cards, String query) =>
      cards.where((card) => matches(card, query)).toList(growable: false);
}
