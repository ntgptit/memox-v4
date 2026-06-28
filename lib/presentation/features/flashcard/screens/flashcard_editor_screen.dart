import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/core/constants/supported_languages.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/models/card_draft.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/flashcard/check_soft_duplicate.dart';
import 'package:memox_v4/domain/usecases/flashcard/create_card.dart';
import 'package:memox_v4/domain/usecases/flashcard/get_card.dart';
import 'package:memox_v4/domain/usecases/flashcard/update_card.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';

/// One editable meaning row: a language + its text controller.
class _MeaningField {
  _MeaningField({
    required this.lang,
    required this.controller,
    required this.removable,
    this.id,
  });

  String lang;
  final TextEditingController controller;
  final bool removable;
  final int? id;
}

/// Create / edit a flashcard (`docs/design/screens/05-flashcard-editor.md`).
/// Save stays disabled until a valid term + native meaning exist; a soft
/// duplicate (D-020) warns but never blocks. Audio generation is deferred (TTS
/// needs a non-stack dependency).
class FlashcardEditorScreen extends ConsumerStatefulWidget {
  const FlashcardEditorScreen({super.key, required this.deckId, this.cardId});

  final int deckId;
  final int? cardId;

  bool get isEditing => cardId != null;

  @override
  ConsumerState<FlashcardEditorScreen> createState() =>
      _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends ConsumerState<FlashcardEditorScreen> {
  final TextEditingController _termController = TextEditingController();
  final List<_MeaningField> _meanings = <_MeaningField>[];
  String? _gender;
  bool _hidden = false;
  bool _showTermError = false;
  bool _showMeaningError = false;
  String? _duplicateTerm;
  bool _forceSave = false;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _termController.addListener(_refresh);
    if (widget.isEditing) {
      unawaited(_loadCard());
    } else {
      _meanings.add(_primaryField(''));
    }
  }

  @override
  void dispose() {
    _termController.dispose();
    for (final field in _meanings) {
      field.controller.dispose();
    }
    super.dispose();
  }

  // ── data ──────────────────────────────────────────────────────────────────
  String _nativeLang() {
    final active = ref.read(languagePairNotifierProvider).value?.active;
    return active?.targetLang ?? kSupportedLanguages.first.code;
  }

  _MeaningField _primaryField(String content) => _MeaningField(
    lang: _nativeLang(),
    controller: _attach(content),
    removable: false,
  );

  TextEditingController _attach(String text) {
    final controller = TextEditingController(text: text);
    controller.addListener(_refresh);
    return controller;
  }

  Future<void> _loadCard() async {
    setState(() => _loading = true);
    final result = await GetCardUseCase(
      ref.read(cardRepositoryProvider),
    ).call(widget.cardId!);
    if (!mounted) return;
    final card = result.valueOrNull;
    if (card != null) {
      _termController.text = card.term;
      _gender = card.gender;
      _hidden = card.hidden;
      for (final meaning in card.meanings) {
        _meanings.add(
          _MeaningField(
            lang: meaning.lang,
            controller: _attach(meaning.content),
            removable: _meanings.isNotEmpty,
            id: meaning.id,
          ),
        );
      }
    }
    if (_meanings.isEmpty) _meanings.add(_primaryField(''));
    setState(() => _loading = false);
  }

  CardDraft _buildDraft() {
    final meanings = _meanings
        .map(
          (f) => CardMeaning(
            id: f.id,
            lang: f.lang,
            content: f.controller.text.trim(),
          ),
        )
        .where((m) => m.content.isNotEmpty)
        .toList(growable: false);
    return CardDraft(
      deckId: widget.deckId,
      term: _termController.text.trim(),
      gender: _gender,
      hidden: _hidden,
      meanings: meanings,
    );
  }

  // ── editing actions ─────────────────────────────────────────────────────────
  void _refresh() {
    if (!mounted) return;
    setState(() {
      final term = _termController.text.trim();
      final primary = _meanings.isEmpty
          ? ''
          : _meanings.first.controller.text.trim();
      _showTermError = term.isEmpty && primary.isNotEmpty;
      _showMeaningError = primary.isEmpty && term.isNotEmpty;
      _duplicateTerm = null;
      _forceSave = false;
    });
  }

  bool get _canSave {
    if (_meanings.isEmpty) return false;
    return _termController.text.trim().isNotEmpty &&
        _meanings.first.controller.text.trim().isNotEmpty;
  }

  void _addSecondaryMeaning() {
    setState(() {
      final used = _meanings.map((f) => f.lang).toSet();
      final lang = kSupportedLanguages
          .firstWhere(
            (l) => !used.contains(l.code),
            orElse: () => kSupportedLanguages.first,
          )
          .code;
      _meanings.add(
        _MeaningField(lang: lang, controller: _attach(''), removable: true),
      );
    });
  }

  void _removeMeaning(_MeaningField field) {
    setState(() {
      field.controller.dispose();
      _meanings.remove(field);
    });
  }

  void _onSave() => unawaited(_save());

  void _addAnyway() {
    setState(() {
      _duplicateTerm = null;
      _forceSave = true;
    });
    unawaited(_save());
  }

  Future<void> _save() async {
    final repository = ref.read(cardRepositoryProvider);
    final term = _termController.text.trim();
    if (!_forceSave) {
      final dup = await CheckSoftDuplicateUseCase(
        repository,
      ).call(widget.deckId, term, excludingCardId: widget.cardId);
      if (!mounted) return;
      if (dup.valueOrNull ?? false) {
        setState(() => _duplicateTerm = term);
        return;
      }
    }
    setState(() => _saving = true);
    final draft = _buildDraft();
    final result = widget.cardId == null
        ? await CreateCardUseCase(repository).call(draft)
        : await UpdateCardUseCase(repository).call(widget.cardId!, draft);
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case Ok():
        unawaited(Navigator.of(context).maybePop());
      case Err():
        _showSaveError();
    }
  }

  void _showSaveError() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.editorSaveError)));
  }

  void _comingSoon() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editorTitleEdit)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('editorClose'),
          icon: const Icon(Icons.close),
          tooltip: l10n.commonCancel,
          onPressed: () => unawaited(Navigator.of(context).maybePop()),
        ),
        title: Text(
          widget.isEditing ? l10n.editorTitleEdit : l10n.editorTitleNew,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: MxSpacing.space3),
            child: FilledButton(
              key: const Key('editorSave'),
              onPressed: (_canSave && !_saving) ? _onSave : null,
              child: Text(l10n.editorSave),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(MxSpacing.space5),
        children: <Widget>[
          if (_duplicateTerm != null) ...<Widget>[
            _buildDuplicateBanner(l10n),
            const SizedBox(height: MxSpacing.space4),
          ],
          TextField(
            key: const Key('editorTermField'),
            controller: _termController,
            decoration: InputDecoration(
              labelText: l10n.editorTermLabel,
              hintText: l10n.editorTermHint,
              errorText: _showTermError ? l10n.editorErrorTermRequired : null,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: MxSpacing.space4),
          ..._buildMeaningFields(l10n, theme),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('editorAddMeaning'),
              onPressed: _addSecondaryMeaning,
              icon: const Icon(Icons.add),
              label: Text(l10n.editorAddMeaning),
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          Text(l10n.editorGenderLabel, style: theme.textTheme.labelMedium),
          const SizedBox(height: MxSpacing.space2),
          _buildGenderChips(l10n),
          const SizedBox(height: MxSpacing.space4),
          _buildAudioRow(l10n, theme),
          const SizedBox(height: MxSpacing.space2),
          SwitchListTile(
            key: const Key('editorHiddenSwitch'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.editorHiddenLabel),
            subtitle: Text(l10n.editorHiddenSubtitle),
            value: _hidden,
            onChanged: (value) => setState(() => _hidden = value),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMeaningFields(AppLocalizations l10n, ThemeData theme) {
    final widgets = <Widget>[];
    for (var i = 0; i < _meanings.length; i++) {
      final field = _meanings[i];
      final isPrimary = i == 0;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: MxSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (isPrimary)
                    Text(
                      endonymOf(field.lang),
                      style: theme.textTheme.labelMedium,
                    )
                  else
                    _buildLanguageDropdown(l10n, field),
                  const Spacer(),
                  if (field.removable)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: l10n.commonDelete,
                      onPressed: () => _removeMeaning(field),
                    ),
                ],
              ),
              TextField(
                key: isPrimary ? const Key('editorMeaningField') : null,
                controller: field.controller,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.editorMeaningHint,
                  errorText: isPrimary && _showMeaningError
                      ? l10n.editorErrorMeaningRequired
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildLanguageDropdown(AppLocalizations l10n, _MeaningField field) =>
      DropdownButton<String>(
        value: field.lang,
        items: kSupportedLanguages
            .map(
              (l) => DropdownMenuItem<String>(
                value: l.code,
                child: Text(l.endonym),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => field.lang = value);
        },
      );

  Widget _buildGenderChips(AppLocalizations l10n) {
    final options = <(String, String)>[
      ('masculine', l10n.genderMasculine),
      ('feminine', l10n.genderFeminine),
      ('neuter', l10n.genderNeuter),
    ];
    return Wrap(
      spacing: MxSpacing.space2,
      children: options
          .map(
            (o) => ChoiceChip(
              label: Text(o.$2),
              selected: _gender == o.$1,
              onSelected: (selected) =>
                  setState(() => _gender = selected ? o.$1 : null),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAudioRow(AppLocalizations l10n, ThemeData theme) => Row(
    children: <Widget>[
      Text(l10n.editorAudioLabel, style: theme.textTheme.labelMedium),
      const Spacer(),
      OutlinedButton.icon(
        onPressed: _comingSoon,
        icon: const Icon(Icons.volume_up_outlined),
        label: Text(l10n.editorAudioAuto),
      ),
    ],
  );

  Widget _buildDuplicateBanner(AppLocalizations l10n) {
    final colors = MxTheme.of(context).colors;
    return DecoratedBox(
      key: const Key('editorDuplicateBanner'),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        borderRadius: const BorderRadius.all(Radius.circular(MxRadius.md)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.editorDuplicateMessage(_duplicateTerm!),
              style: TextStyle(color: colors.onWarningSoft),
            ),
            const SizedBox(height: MxSpacing.space2),
            Row(
              children: <Widget>[
                TextButton(
                  key: const Key('editorDuplicateAddAnyway'),
                  onPressed: _addAnyway,
                  child: Text(l10n.editorDuplicateAddAnyway),
                ),
                TextButton(
                  onPressed: _comingSoon,
                  child: Text(l10n.editorDuplicateViewExisting),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
