import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/usecases/library/card_search_usecase.dart';
import 'package:memox_v4/domain/usecases/library/card_usecases.dart';
import 'package:memox_v4/domain/usecases/library/deck_usecases.dart';

Deck _deck(String id, {String? parent}) => (Deck.create(
      id: DeckId(id),
      name: 'deck-$id',
      parentId: parent == null ? null : DeckId(parent),
    ) as Ok<Deck>)
    .value;

Card _card(String id, String deckId, String term, {String meaning = 'nghĩa', bool hidden = false}) =>
    (Card.create(
      id: CardId(id),
      deckId: DeckId(deckId),
      term: term,
      meanings: [
        (CardMeaning.create(id: const CardMeaningId('m'), language: 'vi', text: meaning) as Ok<CardMeaning>).value,
      ],
      hidden: hidden,
    ) as Ok<Card>)
        .value;

class _FakeDeckRepository implements DeckRepository {
  _FakeDeckRepository(this._decks);
  final Map<String, Deck> _decks;
  Deck? savedDeck;
  DeckId? deletedId;

  @override
  Future<Result<Deck>> getById(DeckId id) async {
    final deck = _decks[id.value];
    if (deck == null) return const Err(NotFoundFailure('missing'));
    return Ok(deck);
  }

  @override
  Future<Result<Deck>> save(Deck deck) async {
    savedDeck = deck;
    _decks[deck.id.value] = deck;
    return Ok(deck);
  }

  @override
  Future<Result<void>> delete(DeckId id) async {
    deletedId = id;
    return const Ok<void>(null);
  }

  @override
  Future<Result<DeckStats>> statsFor(DeckId id) async => const Ok(DeckStats.empty);
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) => const Stream.empty();
}

class _FakeCardRepository implements CardRepository {
  _FakeCardRepository(this._cards);
  final List<Card> _cards;

  @override
  Stream<List<Card>> watchByDeck(DeckId deckId) =>
      Stream.value(_cards.where((c) => c.deckId == deckId).toList());

  @override
  Future<Result<List<Card>>> search(String query, {DeckId? within}) async =>
      Ok(CardSearchUseCase.filter(_cards, query));

  @override
  Future<Result<Card>> getById(CardId id) async => const Err(NotFoundFailure('x'));
  @override
  Future<Result<Card>> save(Card card) async => Ok(card);
  @override
  Future<Result<void>> delete(CardId id) async => const Ok<void>(null);
  @override
  Future<Result<void>> setHidden(CardId id, {required bool hidden}) async => const Ok<void>(null);
}

void main() {
  group('MoveDeckUseCase cycle prevention (BR-3 / AC-3)', () {
    // Tree: a → b → c
    Map<String, Deck> tree() => {
          'a': _deck('a'),
          'b': _deck('b', parent: 'a'),
          'c': _deck('c', parent: 'b'),
          'x': _deck('x'), // unrelated root
        };

    test('rejects moving a deck into its own subtree', () async {
      final repo = _FakeDeckRepository(tree());
      final result = await MoveDeckUseCase(repo).call(deckId: const DeckId('a'), newParentId: const DeckId('c'));
      expect(result, isA<Err<Deck>>());
      expect(repo.savedDeck, isNull);
    });

    test('rejects making a deck its own parent', () async {
      final repo = _FakeDeckRepository(tree());
      expect(
        await MoveDeckUseCase(repo).call(deckId: const DeckId('b'), newParentId: const DeckId('b')),
        isA<Err<Deck>>(),
      );
    });

    test('allows a valid move to an unrelated node', () async {
      final repo = _FakeDeckRepository(tree());
      final result = await MoveDeckUseCase(repo).call(deckId: const DeckId('c'), newParentId: const DeckId('x'));
      expect(result, isA<Ok<Deck>>());
      expect(repo.savedDeck!.parentId, const DeckId('x'));
    });

    test('allows a move to root (null parent)', () async {
      final repo = _FakeDeckRepository(tree());
      final result = await MoveDeckUseCase(repo).call(deckId: const DeckId('c'), newParentId: null);
      expect(result, isA<Ok<Deck>>());
      expect(repo.savedDeck!.parentId, isNull);
    });
  });

  test('DeleteDeckUseCase delegates the cascade to the repository (D-024)', () async {
    final repo = _FakeDeckRepository({'a': _deck('a')});
    await DeleteDeckUseCase(repo).call(const DeckId('a'));
    expect(repo.deletedId, const DeckId('a'));
  });

  group('DetectDuplicateTermUseCase (soft-dup, D-020)', () {
    test('flags a case-insensitive term already in the deck', () async {
      final repo = _FakeCardRepository([_card('c1', 'd1', 'Neko')]);
      final dup = await DetectDuplicateTermUseCase(repo).call(deckId: const DeckId('d1'), term: 'neko');
      expect((dup as Ok<bool>).value, isTrue);
    });

    test('does not flag a distinct term, nor the card being edited', () async {
      final repo = _FakeCardRepository([_card('c1', 'd1', 'neko')]);
      expect(
        (await DetectDuplicateTermUseCase(repo).call(deckId: const DeckId('d1'), term: 'inu') as Ok<bool>).value,
        isFalse,
      );
      expect(
        (await DetectDuplicateTermUseCase(repo)
                .call(deckId: const DeckId('d1'), term: 'neko', excluding: const CardId('c1')) as Ok<bool>)
            .value,
        isFalse,
      );
    });
  });

  group('CardSearchUseCase — D-019 token AND over term + meaning', () {
    final cat = _card('c1', 'd1', 'neko', meaning: 'con mèo');
    final dog = _card('c2', 'd1', 'inu', meaning: 'con chó', hidden: true);

    test('single token is a substring match on term or meaning (AC-1)', () {
      expect(CardSearchUseCase.matches(cat, 'neko'), isTrue);
      expect(CardSearchUseCase.matches(cat, 'mèo'), isTrue);
      expect(CardSearchUseCase.matches(cat, 'chó'), isFalse);
    });

    test('multi-token requires every token to match somewhere on the card (AC-4)', () {
      expect(CardSearchUseCase.matches(cat, 'neko mèo'), isTrue); // term + meaning
      expect(CardSearchUseCase.matches(cat, 'neko chó'), isFalse); // one token misses
    });

    test('hidden cards are still matched (D-028 / AC-2)', () {
      expect(CardSearchUseCase.matches(dog, 'inu'), isTrue);
      expect(CardSearchUseCase.filter([cat, dog], 'con'), hasLength(2));
    });

    test('empty query matches nothing', () {
      expect(CardSearchUseCase.matches(cat, '   '), isFalse);
    });
  });

  group('SearchCardsUseCase use case', () {
    test('empty query short-circuits to no results', () async {
      final repo = _FakeCardRepository([_card('c1', 'd1', 'neko')]);
      expect((await SearchCardsUseCase(repo).call('  ') as Ok<List<Card>>).value, isEmpty);
    });

    test('delegates matching to the repository', () async {
      final repo = _FakeCardRepository([_card('c1', 'd1', 'neko', meaning: 'con mèo')]);
      final result = await SearchCardsUseCase(repo).call('mèo');
      expect((result as Ok<List<Card>>).value, hasLength(1));
    });
  });
}
