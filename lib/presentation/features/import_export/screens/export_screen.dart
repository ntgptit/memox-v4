import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/import_export_providers.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/types/import_export_format.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/inputs/mx_switch.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

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
        final path = await ref
            .read(fileSaveServiceProvider)
            .save(
              'memox_export.csv',
              utf8.encode(codec.toDelimited(rows, Separator.comma.char)),
            );
        if (mounted) setState(() => _message = l10n.exportSavedTo(path));
      case TransferFormat.excel:
        final path = await ref
            .read(fileSaveServiceProvider)
            .save('memox_export.xlsx', codec.toExcel(rows));
        if (mounted) setState(() => _message = l10n.exportSavedTo(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      key: const ValueKey('mx-node:export/screen'),
      appBar: MxAppBar(
        key: const ValueKey('mx-node:export/appbar'),
        title: l10n.exportTitle,
      ),
      body: ListView(
        key: const Key('export'),
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space4),
        children: <Widget>[
          ListTile(
            title: Text(l10n.exportScopeSubtree),
            trailing: MxSwitch(
              key: const Key('exportSubtree'),
              value: _includeSubtree,
              onChanged: (v) => setState(() => _includeSubtree = v),
            ),
          ),
          ListTile(
            title: Text(l10n.exportIncludeSrs),
            trailing: MxSwitch(
              key: const ValueKey('mx-node:export/incl-srs-switch'),
              value: _includeSrs,
              onChanged: (v) => setState(() => _includeSrs = v),
            ),
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
          MxButton(
            key: const ValueKey('mx-node:export/do-export'),
            label: l10n.exportRun,
            block: true,
            onPressed: () => unawaited(_export()),
          ),
          if (_message case final m?) ...<Widget>[
            const SizedBox(height: MxSpacing.space4),
            Text(m, key: const ValueKey('mx-node:export/progress')),
          ],
        ],
      ),
    );
  }
}
