import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/presentation/features/settings/viewmodels/settings_notifier.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    container = ProviderContainer(
      overrides: <Override>[databaseProvider.overrideWithValue(db)],
    );
    container.listen(settingsNotifierProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('setGameWordsPerRound persists and updates state', () async {
    await container.read(settingsNotifierProvider.future);
    await container
        .read(settingsNotifierProvider.notifier)
        .setGameWordsPerRound(9);

    final settings = await container.read(settingsNotifierProvider.future);
    expect(settings.gameWordsPerRound, 9);
  });

  test('D-008: gamePlayLocation carries the configured words per round', () {
    final location = RoutePaths.gamePlayLocation(
      1,
      GameType.matching,
      GameScope.spaced,
      wordsPerRound: 8,
    );
    expect(location, contains('words=8'));
  });
}
