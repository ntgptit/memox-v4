import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Reminder-local scrollable hour/minute column (kit `TimeCol`): each value is a
/// tappable row; the selected value is bold + primary. [semanticLabel] names the
/// column for screen readers. Values are 2-digit zero-padded.
class TimeCol extends StatelessWidget {
  const TimeCol({
    required this.values,
    required this.selected,
    required this.onSelect,
    required this.semanticLabel,
    super.key,
  });

  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelect;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel,
      container: true,
      child: SizedBox(
        height: MxSizes.size2xl,
        // The SizedBox bounds the height, so the list scrolls lazily via .builder
        // (no shrinkWrap needed) — hours/minutes are up to 60 rows.
        child: ListView.builder(
          itemCount: values.length,
          itemBuilder: (context, index) {
            final value = values[index];
            return Semantics(
              button: true,
              selected: value == selected,
              child: InkWell(
                onTap: () => onSelect(value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
                  child: Center(
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: MxTypography.fontFamily,
                        fontSize: MxTypography.sizeMd,
                        fontWeight: value == selected
                            ? MxTypography.extrabold
                            : MxTypography.medium,
                        color: value == selected ? scheme.primary : mx.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
