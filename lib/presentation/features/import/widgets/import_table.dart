import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Import-local preview table (kit `Table`): a header row (bold) over data rows,
/// with hairline dividers. Cells are supplied by the caller; the first row is the
/// header.
class ImportTable extends StatelessWidget {
  const ImportTable({required this.rows, super.key});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: MxRadius.controlRadius,
        border: Border.all(color: mx.divider, width: MxStroke.hairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, row) in rows.indexed)
            DecoratedBox(
              decoration: BoxDecoration(
                border: index == rows.length - 1
                    ? null
                    : Border(
                        bottom:
                            BorderSide(color: mx.divider, width: MxStroke.hairline),
                      ),
              ),
              child: _Row(cells: row, header: index == 0),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.cells, required this.header});

  final List<String> cells;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: MxSpacing.space3,
        horizontal: MxSpacing.space4,
      ),
      child: Row(
        children: [
          for (final cell in cells)
            Expanded(
              child: Text(
                cell,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  fontWeight: header ? MxTypography.bold : MxTypography.regular,
                  color: header ? scheme.onSurface : mx.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
