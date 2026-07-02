import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/services/language_pair_service.dart';
import 'package:memox_v4/domain/usecases/language_pair/create_language_pair.dart';

class _FakeLanguagePairService implements LanguagePairService {
  LanguagePair? added;

  @override
  Future<Result<LanguagePair>> add(LanguagePair pair) async {
    added = pair;
    return Ok(pair);
  }

  @override
  Future<Result<void>> remove(LanguagePairId id) async => const Ok<void>(null);
  @override
  Future<Result<void>> select(LanguagePairId id) async => const Ok<void>(null);
  @override
  Stream<List<LanguagePair>> watchAll() => Stream.value(const []);
  @override
  Stream<LanguagePairId?> watchSelected() => Stream.value(null);
}

void main() {
  const id = LanguagePairId('lp1');

  group('CreateLanguagePair (D-030)', () {
    test('rejects an empty language code, without persisting', () async {
      final service = _FakeLanguagePairService();
      final result = await (CreateLanguagePair(service)).call(
        id: id,
        learningLanguage: '  ',
        nativeLanguage: 'vi',
      );
      expect(result, isA<Err<LanguagePair>>());
      expect((result as Err<LanguagePair>).failure, isA<ValidationFailure>());
      expect(service.added, isNull);
    });

    test('rejects source == target (case-insensitive), without persisting', () async {
      final service = _FakeLanguagePairService();
      final result = await (CreateLanguagePair(service)).call(
        id: id,
        learningLanguage: 'EN',
        nativeLanguage: 'en',
      );
      expect(result, isA<Err<LanguagePair>>());
      expect(service.added, isNull);
    });

    test('creates + persists a valid distinct pair', () async {
      final service = _FakeLanguagePairService();
      final result = await (CreateLanguagePair(service)).call(
        id: id,
        learningLanguage: 'ko',
        nativeLanguage: 'vi',
      );
      expect(result, isA<Ok<LanguagePair>>());
      expect(service.added!.learningLanguage, 'ko');
      expect(service.added!.nativeLanguage, 'vi');
    });
  });

  test('LanguagePair.create trims and rejects self-pairs directly', () {
    expect(
      LanguagePair.create(id: id, learningLanguage: ' fr ', nativeLanguage: 'FR'),
      isA<Err<LanguagePair>>(),
    );
    final ok = LanguagePair.create(id: id, learningLanguage: ' ja ', nativeLanguage: 'vi');
    expect((ok as Ok<LanguagePair>).value.learningLanguage, 'ja'); // trimmed
  });
}
