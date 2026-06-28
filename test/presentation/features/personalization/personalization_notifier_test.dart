import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/theme_prefs.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/presentation/features/personalization/viewmodels/personalization_notifier.dart';

void main() {
  late AppDatabase db;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    container.listen(personalizationNotifierProvider, (_, _) {});
    return container;
  }

  setUp(() => db = AppDatabase.forTesting(openInMemoryDatabase()));
  tearDown(() => db.close());

  test('defaults when nothing is stored', () async {
    final container = makeContainer();
    final prefs = await container.read(personalizationNotifierProvider.future);
    expect(prefs.mode, ThemeMode.system);
    expect(prefs.accent, AccentChoice.brand);
    expect(prefs.fontScale, FontScale.medium);
    container.dispose();
  });

  test('mode/accent/font persist and survive a reload', () async {
    final container = makeContainer();
    await container.read(personalizationNotifierProvider.future);
    final notifier = container.read(personalizationNotifierProvider.notifier);
    await notifier.setMode(ThemeMode.dark);
    await notifier.setAccent(AccentChoice.cool);
    await notifier.setFontScale(FontScale.large);
    container.dispose();

    // A fresh container on the same db == reopening the app.
    final reopened = makeContainer();
    final prefs = await reopened.read(personalizationNotifierProvider.future);
    expect(prefs.mode, ThemeMode.dark);
    expect(prefs.accent, AccentChoice.cool);
    expect(prefs.fontScale, FontScale.large);
    reopened.dispose();
  });

  test('accent choice changes the scheme primary', () {
    expect(
      AppTheme.light(accent: AccentChoice.cool).colorScheme.primary,
      isNot(AppTheme.light().colorScheme.primary),
    );
  });

  test('font scale factors are ordered', () {
    expect(FontScale.small.factor, lessThan(FontScale.medium.factor));
    expect(FontScale.large.factor, greaterThan(FontScale.medium.factor));
  });
}
