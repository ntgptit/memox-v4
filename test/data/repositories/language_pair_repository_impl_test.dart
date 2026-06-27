import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/language_pair_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/data/repositories/language_pair_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';

void main() {
  late AppDatabase db;
  late LanguagePairRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = LanguagePairRepositoryImpl(LanguagePairDao(db));
  });
  tearDown(() => db.close());

  test('create then list returns pairs ordered by insertion', () async {
    await repository.create(sourceLang: 'ko', targetLang: 'vi');
    await repository.create(sourceLang: 'ja', targetLang: 'vi');

    final pairs = (await repository.list()).valueOrNull!;
    expect(pairs, hasLength(2));
    expect(pairs.first.sourceLang, 'ko');
    expect(pairs.first.orderIndex, 0);
    expect(pairs[1].sourceLang, 'ja');
    expect(pairs[1].orderIndex, 1);
  });

  test('active pair id survives a repository restart', () async {
    final created = await repository.create(sourceLang: 'ko', targetLang: 'vi');
    final id = created.valueOrNull!.id;
    await repository.setActivePairId(id);

    // A fresh repository over the same on-disk data == a process restart.
    final reopened = LanguagePairRepositoryImpl(LanguagePairDao(db));
    expect((await reopened.activePairId()).valueOrNull, id);
  });

  test('display direction persists', () async {
    expect((await repository.displaySwapped()).valueOrNull, isFalse);
    await repository.setDisplaySwapped(true);
    expect((await repository.displaySwapped()).valueOrNull, isTrue);
  });

  test('remove deletes the pair', () async {
    final created = await repository.create(sourceLang: 'ko', targetLang: 'vi');
    await repository.remove(created.valueOrNull!.id);
    expect((await repository.list()).valueOrNull, isEmpty);
  });
}
