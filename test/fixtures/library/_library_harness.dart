import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

import '../../harness/provider_harness.dart';

/// empty — no decks.
List<Override> libraryEmptyOverrides() =>
    FakeHarness(store: FakeStore()).overrides;

/// loading — the deck tree never resolves.
List<Override> libraryLoadingOverrides() =>
    FakeHarness(deckRepository: _StuckDeckRepository()).overrides;

/// error — the deck tree read fails.
List<Override> libraryErrorOverrides() =>
    FakeHarness(deckRepository: _ErroringDeckRepository()).overrides;

class _StuckDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.fromFuture(Completer<List<Deck>>().future);
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}

class _ErroringDeckRepository implements DeckRepository {
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) =>
      Stream.error(const PersistenceFailure('deck read failed'));
  @override
  Future<Result<Deck>> getById(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}
