import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/import_export_providers.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/types/import_export_format.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

/// Export a deck's cards to CSV/Excel/clipboard, optionally its subtree and SRS
/// state (D-026).
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, required this.deckId});

  final int deckId;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _includeSubtree = false;
  bool _includeSrs = false;
  TransferFormat _format = TransferFormat.csv;
  String? _message;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final codec = ref.read(tableCodecProvider);
    final result = await ref
        .read(exportCardsProvider)
        .call(
          deckId: widget.deckId,
          includeSubtree: _includeSubtree,
          includeSrs: _includeSrs,
        );
    final rows = result.valueOrNull;
    if (rows == null) {
      if (mounted) setState(() => _message = l10n.transferError);
      return;
    }
    switch (_format) {
      case TransferFormat.clipboard:
        await Clipboard.setData(
          ClipboardData(text: codec.toDelimited(rows, Separator.comma.char)),
        );
        if (mounted) setState(() => _message = l10n.exportCopied);
      case TransferFormat.csv:
        final path = await _writeFile(
          'memox_export.csv',
          utf8.encode(codec.toDelimited(rows, Separator.comma.char)),
        );
        if (mounted) setState(() => _message = l10n.exportSavedTo(path));
      case TransferFormat.excel:
        final path = await _writeFile('memox_export.xlsx', codec.toExcel(rows));
        if (mounted) setState(() => _message = l10n.exportSavedTo(path));
    }
  }

  Future<String> _writeFile(String name, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportTitle)),
      body: ListView(
        key: const Key('export'),
        padding: const EdgeInsets.all(MxSpacing.space4),
        children: <Widget>[
          SwitchListTile(
            key: const Key('exportSubtree'),
            title: Text(l10n.exportScopeSubtree),
            value: _includeSubtree,
            onChanged: (v) => setState(() => _includeSubtree = v),
          ),
          SwitchListTile(
            key: const Key('exportIncludeSrs'),
            title: Text(l10n.exportIncludeSrs),
            value: _includeSrs,
            onChanged: (v) => setState(() => _includeSrs = v),
          ),
          const SizedBox(height: MxSpacing.space3),
          DropdownButtonFormField<TransferFormat>(
            initialValue: _format,
            decoration: InputDecoration(labelText: l10n.exportFormat),
            items: <DropdownMenuItem<TransferFormat>>[
              for (final f in TransferFormat.values)
                DropdownMenuItem<TransferFormat>(value: f, child: Text(f.name)),
            ],
            onChanged: (v) => v == null ? null : setState(() => _format = v),
          ),
          const SizedBox(height: MxSpacing.space4),
          FilledButton(
            key: const Key('exportRun'),
            onPressed: () => unawaited(_export()),
            child: Text(l10n.exportRun),
          ),
          if (_message case final m?) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            Text(m, key: const Key('exportResult')),
          ],
        ],
      ),
    );
  }
}
