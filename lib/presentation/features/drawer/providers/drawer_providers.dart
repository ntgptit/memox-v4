import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drawer_providers.g.dart';

/// A selectable language (fixed catalog — v1 has no dynamic language directory;
/// documented gap). [name] is the display value stored on the pair; [subtitle] is
/// the English gloss.
class LanguageOption {
  const LanguageOption(this.name, this.subtitle);

  final String name;
  final String subtitle;
}

/// The fixed set of languages offered when adding a pair.
const List<LanguageOption> drawerLanguages = [
  LanguageOption('한국어', 'Korean'),
  LanguageOption('English', 'English'),
  LanguageOption('日本語', 'Japanese'),
  LanguageOption('Tiếng Việt', 'Vietnamese'),
  LanguageOption('中文', 'Chinese'),
  LanguageOption('Español', 'Spanish'),
  LanguageOption('Français', 'French'),
];

/// Which drawer sub-view is showing (the route hosts all three; no `setState`).
enum DrawerView { menu, addLanguage, removeLanguage }

@riverpod
class DrawerViewState extends _$DrawerViewState {
  @override
  DrawerView build() => DrawerView.menu;

  void show(DrawerView view) => state = view;
}

/// Today's study effort for the drawer header (minutes + words).
@riverpod
Future<({int minutes, int words})> drawerActivity(Ref ref) async {
  final now = ref.watch(clockProvider).now();
  final result = await ref.watch(dailyActivityServiceProvider).activityOn(now);
  return result.fold(
    (value) => value,
    (failure) {
      ref.read(loggerProvider).error('drawer activity read failed', error: failure);
      // Failure is the app's error type → carried to the async error branch.
      // ignore: only_throw_errors
      throw failure;
    },
  );
}

/// The pending learning/native selection on the add-language form.
class LanguageDraft {
  const LanguageDraft({this.learning, this.native});

  final String? learning;
  final String? native;

  /// A valid pair needs both sides chosen and different (D-030).
  bool get canAdd => learning != null && native != null && learning != native;
}

@riverpod
class AddLanguageDraft extends _$AddLanguageDraft {
  @override
  LanguageDraft build() => const LanguageDraft();

  void setLearning(String name) =>
      state = LanguageDraft(learning: name, native: state.native);

  void setNative(String name) =>
      state = LanguageDraft(learning: state.learning, native: name);

  void reset() => state = const LanguageDraft();
}

/// The learner's language pairs (glossary) + add/remove mutations (DM.8, D-030).
/// An async notifier rendered with `AsyncValue.when`. Failed mutations are logged;
/// D-030 validation is prevented at the form (add is gated on [LanguageDraft.canAdd]).
@riverpod
class LanguagePairController extends _$LanguagePairController {
  @override
  Future<List<LanguagePair>> build() =>
      ref.watch(languagePairServiceProvider).watchAll().first;

  Future<void> addPair({required String learning, required String native}) async {
    final created = LanguagePair.create(
      id: LanguagePairId('${learning}_$native'),
      learningLanguage: learning,
      nativeLanguage: native,
    );
    if (created case Err(:final failure)) {
      ref.read(loggerProvider).error('add language pair rejected', error: failure);
      return;
    }
    final saved = await ref
        .read(languagePairServiceProvider)
        .add((created as Ok<LanguagePair>).value);
    _apply(saved);
  }

  Future<void> removePair(LanguagePairId id) async {
    final removed = await ref.read(languagePairServiceProvider).remove(id);
    _apply(removed);
  }

  void _apply(Result<void> result) {
    result.fold(
      (_) => ref.invalidateSelf(), // guard:invalidate-reviewed -- reason: refresh after removing a language pair
      (failure) => ref
          .read(loggerProvider)
          .error('language pair mutation failed', error: failure),
    );
  }
}
