import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/usecases/library/card_use_cases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor_providers.g.dart';

/// The grammatical-gender presets (kit chips). `null` = none.
const List<String> editorGenders = ['masc', 'fem', 'neutral'];

/// Default meaning languages (per-pair language selection is deferred — gap).
const String _primaryLanguage = 'en';
const String _secondaryLanguage = 'vi';

/// Language code the term is spoken in (a fixed default in v1 — the pair language
/// isn't wired here; documented gap).
const String _termSpeakLanguage = 'ko';

/// The editor form model.
class EditorData {
  const EditorData({
    required this.term,
    required this.meaning,
    required this.secondary,
    required this.gender,
    required this.hidden,
    required this.showSecondary,
    required this.duplicate,
    required this.termTouched,
    required this.meaningTouched,
    required this.deckId,
    required this.cardId,
  });

  final String term;
  final String meaning;
  final String? secondary;
  final String? gender;
  final bool hidden;
  final bool showSecondary;
  final bool duplicate;
  final bool termTouched;
  final bool meaningTouched;
  final DeckId? deckId;
  final CardId? cardId;

  bool get isEditing => cardId != null;
  bool get canSave =>
      term.trim().isNotEmpty && meaning.trim().isNotEmpty && deckId != null;

  EditorData copyWith({
    String? term,
    String? meaning,
    String? Function()? secondary,
    String? Function()? gender,
    bool? hidden,
    bool? showSecondary,
    bool? duplicate,
    bool? termTouched,
    bool? meaningTouched,
  }) {
    return EditorData(
      term: term ?? this.term,
      meaning: meaning ?? this.meaning,
      secondary: secondary != null ? secondary() : this.secondary,
      gender: gender != null ? gender() : this.gender,
      hidden: hidden ?? this.hidden,
      showSecondary: showSecondary ?? this.showSecondary,
      duplicate: duplicate ?? this.duplicate,
      termTouched: termTouched ?? this.termTouched,
      meaningTouched: meaningTouched ?? this.meaningTouched,
      deckId: deckId,
      cardId: cardId,
    );
  }
}

/// Drives the flashcard editor (DM.6 card use cases; DM.8 audio). A [cardId] loads
/// an existing card (edit); null starts a blank card in the first library deck
/// (create — a deck picker is deferred). No `setState`; failures are logged.
@riverpod
class EditorController extends _$EditorController {
  @override
  Future<EditorData> build(String? cardId) async {
    if (cardId == null) return _blank();
    final card = _value(await ref.read(cardRepositoryProvider).getById(CardId(cardId)));
    return EditorData(
      term: card.term,
      meaning: card.meanings.isEmpty ? '' : card.meanings.first.text,
      secondary: card.meanings.length > 1 ? card.meanings[1].text : null,
      gender: card.grammaticalGender,
      hidden: card.hidden,
      showSecondary: card.meanings.length > 1,
      duplicate: false,
      termTouched: false,
      meaningTouched: false,
      deckId: card.deckId,
      cardId: card.id,
    );
  }

  Future<EditorData> _blank() async {
    final roots =
        await ref.read(deckRepositoryProvider).watchChildren(null).first;
    return EditorData(
      term: '',
      meaning: '',
      secondary: null,
      gender: null,
      hidden: false,
      showSecondary: false,
      duplicate: false,
      termTouched: false,
      meaningTouched: false,
      deckId: roots.isEmpty ? null : roots.first.id,
      cardId: null,
    );
  }

  EditorData? get _data => state.asData?.value;

  Future<void> setTerm(String term) async {
    final data = _data;
    if (data == null) return;
    state = AsyncData(data.copyWith(term: term, termTouched: true));
    await _checkDuplicate();
  }

  void setMeaning(String meaning) {
    final data = _data;
    if (data == null) return;
    state = AsyncData(data.copyWith(meaning: meaning, meaningTouched: true));
  }

  void setSecondary(String value) {
    final data = _data;
    if (data == null) return;
    state = AsyncData(data.copyWith(secondary: () => value));
  }

  void showSecondary() {
    final data = _data;
    if (data == null) return;
    state = AsyncData(data.copyWith(showSecondary: true, secondary: () => ''));
  }

  void setGender(String? gender) {
    final data = _data;
    if (data == null) return;
    state = AsyncData(data.copyWith(gender: () => gender));
  }

  void setHidden(bool hidden) {
    final data = _data;
    if (data == null) return;
    state = AsyncData(data.copyWith(hidden: hidden));
  }

  Future<void> playAudio() async {
    final data = _data;
    if (data == null || data.term.trim().isEmpty) return;
    final result = await ref
        .read(audioServiceProvider)
        .speak(data.term, languageCode: _termSpeakLanguage);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('editor audio failed', error: failure);
    }
  }

  /// Persist the card. Returns true on success (the screen then pops).
  Future<bool> save() async {
    final data = _data;
    if (data == null || !data.canSave) return false;

    final meanings = <CardMeaning>[];
    final primary = CardMeaning.create(
      id: CardMeaningId('m-${_stamp()}-0'),
      language: _primaryLanguage,
      text: data.meaning,
    );
    if (primary case Ok<CardMeaning>(:final value)) meanings.add(value);
    final secondaryText = data.secondary?.trim() ?? '';
    if (data.showSecondary && secondaryText.isNotEmpty) {
      final secondary = CardMeaning.create(
        id: CardMeaningId('m-${_stamp()}-1'),
        language: _secondaryLanguage,
        text: secondaryText,
      );
      if (secondary case Ok<CardMeaning>(:final value)) meanings.add(value);
    }
    if (meanings.isEmpty) return false;

    final card = Card.create(
      id: data.cardId ?? CardId('card-${_stamp()}'),
      deckId: data.deckId!,
      term: data.term,
      meanings: meanings,
      hidden: data.hidden,
      grammaticalGender: data.gender,
    );
    if (card case Err(:final failure)) {
      ref.read(loggerProvider).error('editor save rejected', error: failure);
      return false;
    }
    final saved = await SaveCard(ref.read(cardRepositoryProvider))
        .call((card as Ok<Card>).value);
    if (saved case Err(:final failure)) {
      ref.read(loggerProvider).error('editor save failed', error: failure);
      return false;
    }
    return true;
  }

  Future<void> _checkDuplicate() async {
    final data = _data;
    if (data == null) return;
    if (data.term.trim().isEmpty || data.deckId == null) {
      state = AsyncData(data.copyWith(duplicate: false));
      return;
    }
    final result = await DetectDuplicateTerm(ref.read(cardRepositoryProvider))
        .call(deckId: data.deckId!, term: data.term, excluding: data.cardId);
    final isDuplicate = switch (result) {
      Ok<bool>(:final value) => value,
      Err<bool>() => false,
    };
    final latest = _data;
    if (latest == null) return;
    state = AsyncData(latest.copyWith(duplicate: isDuplicate));
  }

  int _stamp() => ref.read(clockProvider).now().microsecondsSinceEpoch;

  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors
        Err<T>(:final failure) => throw failure,
      };
}
