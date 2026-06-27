import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/flashcard/create_card.dart';

/// Records the drafts handed to create; other methods are unused here.
class _FakeRepository implements CardRepository {
  CardDraft? created;

  @override
  Future<Result<Card>> create(CardDraft draft) async {
    created = draft;
    return Ok(
      Card(
        id: 1,
        deckId: draft.deckId,
        term: draft.term,
        hidden: draft.hidden,
        orderIndex: 0,
        createdAt: 0,
        meanings: draft.meanings,
      ),
    );
  }

  @override
  Future<Result<void>> delete(int id) => throw UnimplementedError();
  @override
  Future<Result<Card?>> getById(int id) => throw UnimplementedError();
  @override
  Future<Result<List<Card>>> listByDeck(
    int deckId, {
    bool includeHidden = true,
  }) => throw UnimplementedError();
  @override
  Future<Result<void>> setHidden(int id, {required bool hidden}) =>
      throw UnimplementedError();
  @override
  Future<Result<bool>> termExists(
    int deckId,
    String term, {
    int? excludingCardId,
  }) => throw UnimplementedError();
  @override
  Future<Result<Card>> update(int id, CardDraft draft) =>
      throw UnimplementedError();
  @override
  Future<Result<int>> visibleCount(int deckId) => throw UnimplementedError();
}

CardDraft draftWith({
  String term = 'term',
  List<CardMeaning> meanings = const <CardMeaning>[
    CardMeaning(lang: 'vi', content: 'nghĩa'),
  ],
}) => CardDraft(deckId: 1, term: term, meanings: meanings);

void main() {
  test('BR-2: an empty term is rejected with a ValidationFailure', () async {
    final repository = _FakeRepository();
    final result = await CreateCardUseCase(
      repository,
    ).call(draftWith(term: '  '));
    expect((result as Err).failure, isA<ValidationFailure>());
    expect(repository.created, isNull);
  });

  test('BR-2: zero meanings is rejected', () async {
    final repository = _FakeRepository();
    final result = await CreateCardUseCase(
      repository,
    ).call(draftWith(meanings: const <CardMeaning>[]));
    expect((result as Err).failure, isA<ValidationFailure>());
  });

  test('BR-2: an empty meaning content is rejected', () async {
    final repository = _FakeRepository();
    final result = await CreateCardUseCase(repository).call(
      draftWith(
        meanings: const <CardMeaning>[CardMeaning(lang: 'vi', content: '  ')],
      ),
    );
    expect((result as Err).failure, isA<ValidationFailure>());
  });

  test('a valid draft is trimmed and forwarded to the repository', () async {
    final repository = _FakeRepository();
    final result = await CreateCardUseCase(repository).call(
      draftWith(
        term: '  안녕  ',
        meanings: const <CardMeaning>[
          CardMeaning(lang: 'vi', content: '  xin chào  '),
        ],
      ),
    );
    expect(result.valueOrNull, isNotNull);
    expect(repository.created!.term, '안녕');
    expect(repository.created!.meanings.first.content, 'xin chào');
  });
}
