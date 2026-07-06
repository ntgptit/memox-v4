import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_services.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';

import '../../harness/provider_harness.dart';

/// empty — no decks.
List<Override> libraryEmptyOverrides() =>
    FakeHarness(store: FakeStore()).overrides;

/// The seeded library plus two language pairs (one selected), so tapping the
/// context-bar pair button opens a populated PairPickerSheet.
List<Override> libraryPairPickerOverrides() {
  final pairs = FakeLanguagePairService();
  unawaited(
    pairs.add(
      (LanguagePair.create(
                id: const LanguagePairId('p1'),
                learningLanguage: 'Korean',
                nativeLanguage: 'English',
              )
              as Ok<LanguagePair>)
          .value,
    ),
  );
  unawaited(
    pairs.add(
      (LanguagePair.create(
                id: const LanguagePairId('p2'),
                learningLanguage: 'Japanese',
                nativeLanguage: 'English',
              )
              as Ok<LanguagePair>)
          .value,
    ),
  );
  unawaited(pairs.select(const LanguagePairId('p1')));
  return FakeHarness(languagePairService: pairs).overrides;
}

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
