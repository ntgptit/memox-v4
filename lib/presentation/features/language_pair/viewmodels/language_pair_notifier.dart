import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/language_pair_providers.dart';
import 'package:memox_v4/domain/models/language_pair_context.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/language_pair/create_language_pair.dart';
import 'package:memox_v4/domain/usecases/language_pair/get_pair_context.dart';
import 'package:memox_v4/domain/usecases/language_pair/remove_language_pair.dart';
import 'package:memox_v4/domain/usecases/language_pair/set_active_pair.dart';
import 'package:memox_v4/domain/usecases/language_pair/swap_display_direction.dart';

/// App-wide language-pair context (active pair + display direction), kept alive
/// for the app's lifetime. Orchestrates the language-pair use cases only; holds
/// no business logic and no sole copy of data (`state-management-contract`).
///
/// Hand-written `AsyncNotifier` rather than `@riverpod` codegen: the generator's
/// `source_gen`/`analyzer` pins conflict with `drift_dev` (see
/// `docs/stack/stack.md`). The provider is keepAlive (not `autoDispose`).
final languagePairNotifierProvider =
    AsyncNotifierProvider<LanguagePairNotifier, LanguagePairContext>(
      LanguagePairNotifier.new,
    );

class LanguagePairNotifier extends AsyncNotifier<LanguagePairContext> {
  LanguagePairRepository get _repository =>
      ref.read(languagePairRepositoryProvider);

  @override
  Future<LanguagePairContext> build() => _load();

  /// Creates a pair; the first pair becomes the active context.
  Future<void> addPair({
    required String sourceLang,
    required String targetLang,
  }) async {
    final result = await CreateLanguagePairUseCase(
      _repository,
    ).call(sourceLang: sourceLang, targetLang: targetLang);
    if (result case Ok(value: final pair)) {
      final hadNone = state.value?.isEmpty ?? true;
      if (hadNone) {
        await SetActivePairUseCase(_repository).call(pair.id);
      }
    }
    await _refresh();
  }

  Future<void> removePair(int id) async {
    await RemoveLanguagePairUseCase(_repository).call(id);
    await _refresh();
  }

  Future<void> setActive(int id) async {
    await SetActivePairUseCase(_repository).call(id);
    await _refresh();
  }

  Future<void> swapDirection() async {
    await SwapDisplayDirectionUseCase(_repository).call();
    await _refresh();
  }

  Future<LanguagePairContext> _load() async {
    final result = await GetPairContextUseCase(_repository).call();
    return switch (result) {
      Ok(:final value) => value,
      Err() => const LanguagePairContext(),
    };
  }

  Future<void> _refresh() async {
    state = await AsyncValue.guard(_load);
  }
}
