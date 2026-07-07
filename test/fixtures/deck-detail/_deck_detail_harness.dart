import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

import '../../harness/provider_harness.dart';

// The deck-detail goldens render `deckId: 'deck-kb'` — a store seeded to MIRROR
// the kit's DeckDetail sample (Korean Basics · 2 sub-decks · 6 cards), so the
// diff measures visual parity rather than seed-content noise (the scrimmed
// background behind every overlay state matches the kit shot).

final DateTime _now = DateTime.utc(2026, 7, 3, 9);

Deck _deck(String id, String name, {String? parent}) =>
    (Deck.create(
              id: DeckId(id),
              name: name,
              parentId: parent == null ? null : DeckId(parent),
            )
            as Ok<Deck>)
        .value;

Card _card(
  String id,
  String deckId,
  String term,
  String meaning, {
  bool hidden = false,
}) =>
    (Card.create(
              id: CardId(id),
              deckId: DeckId(deckId),
              term: term,
              hidden: hidden,
              meanings: [
                (CardMeaning.create(
                          id: CardMeaningId('m-$id'),
                          language: 'en',
                          text: meaning,
                        )
                        as Ok<CardMeaning>)
                    .value,
              ],
            )
            as Ok<Card>)
        .value;

/// due (box 1–7) / mastered (box 8) / new (box 0) — matches `_statusOf`.
SrsState _due() =>
    SrsState(box: BoxLevel.firstBox, dueAt: _now.subtract(const Duration(hours: 1)));
SrsState _mastered() => const SrsState(box: BoxLevel.mastered);

/// Korean Basics — the kit's DeckDetail sample: 2 sub-decks + 6 cards, statuses
/// matching the kit (due · mastered · new · due · mastered · new+hidden).
FakeStore deckDetailKitStore() {
  final store = FakeStore();
  store.decks['deck-kb'] = _deck('deck-kb', 'Korean Basics');
  store.decks['deck-bg'] = _deck('deck-bg', 'Beginner Grammar', parent: 'deck-kb');
  store.decks['deck-tf'] = _deck('deck-tf', 'Topic: Family', parent: 'deck-kb');

  // Sub-deck cards exist only so the sub-deck rows show non-zero, ~kit progress
  // (exact 412 words / 64% isn't seedable — stats are computed from real cards).
  for (var i = 0; i < 8; i++) {
    final id = 'bg-$i';
    store.cards[id] = _card(id, 'deck-bg', 'g$i', 'grammar $i');
    store.srsByCard[id] = i < 5 ? _mastered() : _due(); // ~62% mastered
  }
  for (var i = 0; i < 6; i++) {
    final id = 'tf-$i';
    store.cards[id] = _card(id, 'deck-tf', 'f$i', 'family $i');
    store.srsByCard[id] = _mastered(); // 100% mastered
  }

  // The viewed deck's own cards (kit CARDS list).
  const rows = [
    ('kb-1', '안녕하세요', 'Hello (formal)', 'due', false),
    ('kb-2', '감사합니다', 'Thank you', 'mastered', false),
    ('kb-3', '사랑', 'love; affection', 'new', false),
    ('kb-4', '공부하다', 'to study', 'due', false),
    ('kb-5', '맛있다', 'delicious (food)', 'mastered', false),
    ('kb-6', '어렵다', 'difficult, hard', 'new', true),
  ];
  for (final (id, term, meaning, status, hidden) in rows) {
    store.cards[id] = _card(id, 'deck-kb', term, meaning, hidden: hidden);
    store.srsByCard[id] = switch (status) {
      'due' => _due(),
      'mastered' => _mastered(),
      _ => SrsState.newborn,
    };
  }
  return store;
}

/// loaded / overlays — the full Korean Basics deck.
List<Override> deckDetailKitOverrides() =>
    FakeHarness(store: deckDetailKitStore()).overrides;

/// empty — the deck-kb deck exists but holds no cards or sub-decks.
List<Override> deckDetailEmptyOverrides() {
  final store = FakeStore();
  store.decks['deck-kb'] = _deck('deck-kb', 'Korean Basics');
  return FakeHarness(store: store).overrides;
}

/// error — deck-kb is not in the store → unknown-deck error.
List<Override> deckDetailErrorOverrides() =>
    FakeHarness(store: FakeStore()).overrides;

/// loading — the deck tree never resolves.
List<Override> deckDetailLoadingOverrides() =>
    FakeHarness(deckRepository: _StuckDeckRepository()).overrides;

class _StuckDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.fromFuture(Completer<List<Deck>>().future);
  @override
  Future<Result<Deck>> getById(DeckId id) => Completer<Result<Deck>>().future;
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) =>
      Completer<Result<DeckStats>>().future;
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}
