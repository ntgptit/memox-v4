import 'dart:async';

import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';

/// A single in-memory data holder shared by all fake repositories — the fake
/// analogue of one Drift database with several DAOs. Any mutation calls [notify]
/// so every `watch*` stream re-emits (coarse but correct for tests).
class FakeStore {
  final Map<String, Deck> decks = {};
  final Map<String, Card> cards = {};
  final Map<String, SrsState> srsByCard = {};
  final List<ReviewLog> reviewLogs = [];

  DailyGoal dailyGoal = const DailyGoal(minutesTarget: 15, wordsTarget: 20);
  int newCardsPerDay = AppConstants.newCardsPerDayDefault;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  Stream<void> get onChange => _changes.stream;
  void notify() => _changes.add(null);
  Future<void> dispose() => _changes.close();
}

/// A settable, deterministic [Clock] for tests.
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;
  void advance(Duration delta) => _now = _now.add(delta);
}

/// Deterministic sequential id generator (`prefix-1`, `prefix-2`, …).
class FakeIdGenerator {
  int _counter = 0;

  String next([String prefix = 'id']) => '$prefix-${++_counter}';
}

Deck _deck(String id, String name, String? parent) => (Deck.create(
      id: DeckId(id),
      name: name,
      parentId: parent == null ? null : DeckId(parent),
    ) as Ok<Deck>)
    .value;

Card _card(String id, String deckId, String term, String meaning) => (Card.create(
      id: CardId(id),
      deckId: DeckId(deckId),
      term: term,
      meanings: [
        (CardMeaning.create(id: CardMeaningId('m-$id'), language: 'vi', text: meaning)
                as Ok<CardMeaning>)
            .value,
      ],
    ) as Ok<Card>)
    .value;

/// A populated store so screens render a realistic "loaded" state: one root deck
/// with a child, a few cards, and a mix of SRS positions (one due, one new).
FakeStore seedFakeStore({DateTime? now}) {
  final today = now ?? DateTime.utc(2026, 7, 3, 9);
  final store = FakeStore();

  for (final deck in [
    _deck('deck-root', 'Korean Basics', null),
    _deck('deck-food', 'Food', 'deck-root'),
  ]) {
    store.decks[deck.id.value] = deck;
  }

  for (final card in [
    _card('card-1', 'deck-food', '사과', 'quả táo'),
    _card('card-2', 'deck-food', '고양이', 'con mèo'),
    _card('card-3', 'deck-food', '개', 'con chó'),
  ]) {
    store.cards[card.id.value] = card;
  }

  // card-1 is due now; card-2 is scheduled ahead; card-3 is brand new.
  store.srsByCard['card-1'] =
      SrsState(box: BoxLevel.firstBox, dueAt: today.subtract(const Duration(hours: 1)));
  store.srsByCard['card-2'] =
      SrsState(box: (BoxLevel.of(3) as Ok<BoxLevel>).value, dueAt: today.add(const Duration(days: 5)));
  store.srsByCard['card-3'] = SrsState.newborn;

  return store;
}
