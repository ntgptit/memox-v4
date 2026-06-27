import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/language_pair/create_language_pair.dart';

/// Minimal in-memory fake — records created pairs, leaves the rest unused.
class _FakeRepository implements LanguagePairRepository {
  final List<LanguagePair> created = <LanguagePair>[];

  @override
  Future<Result<LanguagePair>> create({
    required String sourceLang,
    required String targetLang,
  }) async {
    final pair = LanguagePair(
      id: created.length + 1,
      sourceLang: sourceLang,
      targetLang: targetLang,
      orderIndex: created.length,
    );
    created.add(pair);
    return Ok(pair);
  }

  @override
  Future<Result<List<LanguagePair>>> list() async => Ok(created);

  @override
  Future<Result<int?>> activePairId() => throw UnimplementedError();

  @override
  Future<Result<bool>> displaySwapped() => throw UnimplementedError();

  @override
  Future<Result<void>> remove(int id) => throw UnimplementedError();

  @override
  Future<Result<void>> setActivePairId(int id) => throw UnimplementedError();

  @override
  Future<Result<void>> setDisplaySwapped(bool swapped) =>
      throw UnimplementedError();
}

void main() {
  test('D-030: source equal to target yields a ValidationFailure', () async {
    final repository = _FakeRepository();
    final result = await CreateLanguagePairUseCase(
      repository,
    ).call(sourceLang: 'ko', targetLang: 'ko');

    expect(result, isA<Err<LanguagePair>>());
    expect((result as Err).failure, isA<ValidationFailure>());
    expect(repository.created, isEmpty);
  });

  test('empty code yields a ValidationFailure', () async {
    final repository = _FakeRepository();
    final result = await CreateLanguagePairUseCase(
      repository,
    ).call(sourceLang: '', targetLang: 'vi');

    expect((result as Err).failure, isA<ValidationFailure>());
    expect(repository.created, isEmpty);
  });

  test('valid distinct codes create a normalized pair', () async {
    final repository = _FakeRepository();
    final result = await CreateLanguagePairUseCase(
      repository,
    ).call(sourceLang: 'KO', targetLang: 'vi');

    final pair = result.valueOrNull!;
    expect(pair.sourceLang, 'ko');
    expect(pair.targetLang, 'vi');
    expect(repository.created, hasLength(1));
  });
}
