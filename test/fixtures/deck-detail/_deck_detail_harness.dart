import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

import '../../harness/provider_harness.dart';

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

/// empty — the deck-food deck exists but holds no cards or sub-decks.
List<Override> deckDetailEmptyOverrides() {
  final store = FakeStore();
  store.decks['deck-food'] = _deck('deck-food', 'Food');
  return FakeHarness(store: store).overrides;
}

/// error — the deck-food id is not in the store → unknown-deck error.
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
