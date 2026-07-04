import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// The words-per-round options offered by the game-settings picker (D-008).
const List<int> gameWordsPerRoundOptions = [5, 10, 20];

/// The settings view-model — the live values surfaced on the hub.
class SettingsData {
  const SettingsData({required this.gameWordsPerRound, this.languageLabel});

  /// Words shown per game round (settings BR-2 / D-008).
  final int gameWordsPerRound;

  /// "learning → native" for the selected pair, or null when none is chosen.
  final String? languageLabel;
}

/// Assembles the settings hub state from the DM.8 services and owns the
/// game-settings mutation. An async notifier rendered with `AsyncValue.when`.
/// The setting streams do not fail (no `Result`), so there is no read-error state
/// (the kit has none either); a failed *save* is logged, not swallowed.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<SettingsData> build() async {
    final settings = ref.watch(settingsServiceProvider);
    final pairs = ref.watch(languagePairServiceProvider);

    final words = await settings.watchGameWordsPerRound().first;
    final selectedId = await pairs.watchSelected().first;
    final all = await pairs.watchAll().first;

    String? label;
    if (selectedId != null) {
      for (final pair in all) {
        if (pair.id.value == selectedId.value) {
          label = _label(pair);
          break;
        }
      }
    }

    return SettingsData(gameWordsPerRound: words, languageLabel: label);
  }

  Future<void> setGameWordsPerRound(int count) async {
    final result =
        await ref.read(settingsServiceProvider).saveGameWordsPerRound(count);
    result.fold(
      (_) => ref.invalidateSelf(), // guard:invalidate-reviewed -- reason: re-fetch settings after saving game words-per-round
      (failure) => ref
          .read(loggerProvider)
          .error('save game words per round failed', error: failure),
    );
  }

  String _label(LanguagePair pair) =>
      '${pair.learningLanguage} → ${pair.nativeLanguage}';
}

/// The SRS detail sub-page's only mutable value: the "cards due" notifications
/// opt-in. The box count + intervals shown there are fixed domain constants
/// (`BoxLevel.max`, `SrsScheduler.intervalDays`), so they need no provider.
/// Delivery of the notifications is a later feature; this persists the preference.
@riverpod
class SrsSettingsController extends _$SrsSettingsController {
  @override
  Future<bool> build() async {
    final settings = ref.watch(settingsServiceProvider);
    return settings.watchSrsDueNotifications().first;
  }

  Future<void> setDueNotifications({required bool enabled}) async {
    final result =
        await ref.read(settingsServiceProvider).saveSrsDueNotifications(enabled);
    result.fold(
      (_) => ref.invalidateSelf(), // guard:invalidate-reviewed -- reason: re-fetch settings after saving SRS due-notifications
      (failure) => ref
          .read(loggerProvider)
          .error('save SRS due notifications failed', error: failure),
    );
  }
}
