import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/import_export_providers.dart';
import 'package:memox_v4/core/constants/supported_languages.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/types/import_export_format.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/import_export/import_cards.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_switch.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// Import cards into a deck from a CSV/Excel file or the clipboard (D-025): pick
/// source → map columns → preview → import (soft-dup counted, never blocks).
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key, required this.deckId});

  final int deckId;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  Separator _separator = Separator.comma;
  bool _hasHeader = true;
  int _termColumn = 0;
  int _meaningColumn = 1;
  String? _rawText; // set for delimited sources, null for xlsx
  List<List<String>>? _rows;
  ImportResult? _result;
  String? _error;

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: <String>['csv', 'xlsx'],
    );
    final file = picked?.files.firstOrNull;
    final bytes = file?.bytes;
    if (bytes == null) return;
    final codec = ref.read(tableCodecProvider);
    if (file!.extension?.toLowerCase() == 'xlsx') {
      _rawText = null;
      _setRows(codec.fromExcel(bytes));
    } else {
      _rawText = utf8.decode(bytes, allowMalformed: true);
      _setRows(codec.fromDelimited(_rawText!, _separator.char));
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;
    _rawText = text;
    _setRows(ref.read(tableCodecProvider).fromDelimited(text, _separator.char));
  }

  void _setRows(List<List<String>> rows) {
    setState(() {
      _rows = rows;
      _result = null;
      _termColumn = 0;
      _meaningColumn = rows.isNotEmpty && rows.first.length > 1 ? 1 : 0;
    });
  }

  void _changeSeparator(Separator value) {
    setState(() => _separator = value);
    final text = _rawText;
    if (text != null) {
      _setRows(ref.read(tableCodecProvider).fromDelimited(text, value.char));
    }
  }

  Future<void> _import() async {
    final rows = _rows;
    if (rows == null || rows.isEmpty) return;
    final lang =
        ref.read(languagePairProvider).value?.active?.targetLang ??
        kSupportedLanguages.first.code;
    final result = await ref
        .read(importCardsProvider)
        .call(
          rows: rows,
          deckId: widget.deckId,
          termColumn: _termColumn,
          meaningColumn: _meaningColumn,
          meaningLang: lang,
          hasHeader: _hasHeader,
        );
    if (!mounted) return;
    switch (result) {
      case Ok<ImportResult>(:final value):
        setState(() {
          _result = value;
          _error = null;
        });
      case Err<ImportResult>():
        setState(() => _error = AppLocalizations.of(context).transferError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = _rows;
    final columns = (rows != null && rows.isNotEmpty) ? rows.first.length : 0;
    return MxScaffold(
      key: const ValueKey('mx-node:import/screen'),
      appBar: MxAppBar(
        key: const ValueKey('mx-node:import/appbar'),
        title: l10n.importTitle,
      ),
      body: ListView(
        key: const Key('import'),
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space4),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: MxButton(
                  key: const Key('importPickFile'),
                  label: l10n.importPickFile,
                  icon: Icons.upload_file,
                  variant: MxButtonVariant.secondary,
                  block: true,
                  onPressed: () => unawaited(_pickFile()),
                ),
              ),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                child: MxButton(
                  key: const Key('importPaste'),
                  label: l10n.importPaste,
                  icon: Icons.content_paste,
                  variant: MxButtonVariant.outline,
                  block: true,
                  onPressed: () => unawaited(_paste()),
                ),
              ),
            ],
          ),
          if (rows != null && rows.isNotEmpty) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            DropdownButtonFormField<Separator>(
              initialValue: _separator,
              decoration: InputDecoration(labelText: l10n.importSeparator),
              items: <DropdownMenuItem<Separator>>[
                for (final s in Separator.values)
                  DropdownMenuItem<Separator>(value: s, child: Text(s.name)),
              ],
              onChanged: (v) => v == null ? null : _changeSeparator(v),
            ),
            ListTile(
              title: Text(l10n.importHasHeader),
              trailing: MxSwitch(
                value: _hasHeader,
                onChanged: (v) => setState(() => _hasHeader = v),
              ),
            ),
            _columnPicker(
              l10n.importTermColumn,
              columns,
              _termColumn,
              (v) {
                setState(() => _termColumn = v);
              },
              const ValueKey('mx-node:import/map-term-pick'),
            ),
            _columnPicker(
              l10n.importMeaningColumn,
              columns,
              _meaningColumn,
              (v) {
                setState(() => _meaningColumn = v);
              },
              const ValueKey('mx-node:import/map-meaning-pick'),
            ),
            const SizedBox(height: MxSpacing.space3),
            MxText(l10n.importPreview, role: MxTextRole.titleSmall),
            for (final row in rows.take(5))
              MxText(
                row.join('  |  '),
                role: MxTextRole.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: MxSpacing.space4),
            MxButton(
              key: const ValueKey('mx-node:import/do-import'),
              label: l10n.importRun,
              block: true,
              onPressed: () => unawaited(_import()),
            ),
          ],
          if (_result case final r?) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            Text(
              l10n.importDone(r.imported, r.duplicates),
              key: const Key('importResult'),
            ),
            const SizedBox(height: MxSpacing.space3),
            MxButton(
              key: const ValueKey('mx-node:import/go-deck'),
              label: l10n.commonBack,
              block: true,
              onPressed: () => unawaited(Navigator.of(context).maybePop()),
            ),
          ],
          if (_error case final e?) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            MxText(
              e,
              key: const Key('importError'),
              color: MxTheme.of(context).colors.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _columnPicker(
    String label,
    int columns,
    int value,
    ValueChanged<int> onChanged,
    Key key,
  ) => DropdownButtonFormField<int>(
    key: key,
    initialValue: value < columns ? value : 0,
    decoration: InputDecoration(labelText: label),
    items: <DropdownMenuItem<int>>[
      for (var i = 0; i < columns; i++)
        DropdownMenuItem<int>(value: i, child: Text('${i + 1}')),
    ],
    onChanged: (v) => v == null ? null : onChanged(v),
  );
}
