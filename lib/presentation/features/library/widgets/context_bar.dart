import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Library-local context row (kit `library/context`): a search button, the active
/// language-pair selector, and a sort button. Reads the selected pair via
/// providers; taps are handled by the screen. Copy is from ARB.
class ContextBar extends ConsumerWidget {
  const ContextBar({this.onSearch, this.onPair, this.onSort, super.key});

  final VoidCallback? onSearch;
  final VoidCallback? onPair;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pairs = ref.watch(languagePairsProvider).asData?.value ?? const [];
    final selectedId = ref.watch(selectedLanguagePairIdProvider).asData?.value;

    LanguagePair? selected;
    for (final pair in pairs) {
      if (pair.id.value == selectedId?.value) {
        selected = pair;
        break;
      }
    }

    return Row(
      children: [
        MxIconButton(
          icon: Icons.search,
          semanticLabel: l10n.librarySearch,
          onPressed: onSearch,
        ),
        const SizedBox(width: MxSpacing.space2),
        Expanded(child: _PairButton(pair: selected, onPressed: onPair)),
        const SizedBox(width: MxSpacing.space2),
        MxIconButton(
          icon: Icons.swap_vert,
          semanticLabel: l10n.librarySort,
          onPressed: onSort,
        ),
      ],
    );
  }
}

/// The language-pair pill: "learning ⇄ native ▾", or a placeholder when no pair
/// is selected. A real accessible button.
class _PairButton extends StatelessWidget {
  const _PairButton({required this.pair, this.onPressed});

  final LanguagePair? pair;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final labelStyle = TextStyle(
      fontFamily: MxTypography.fontFamily,
      fontSize: MxTypography.sizeBase,
      fontWeight: MxTypography.bold,
      color: scheme.onSurface,
    );

    final children = pair == null
        ? [Text(l10n.libraryPairNone, style: labelStyle)]
        : [
            Text(pair!.learningLanguage, style: labelStyle),
            const SizedBox(width: MxSpacing.space2),
            Icon(Icons.swap_horiz, size: MxIconSize.sm, color: mx.textTertiary),
            const SizedBox(width: MxSpacing.space2),
            Text(pair!.nativeLanguage, style: labelStyle),
          ];

    return Semantics(
      button: true,
      label: l10n.librarySheetPairTitle,
      child: Material(
        color: mx.surface,
        shape: RoundedRectangleBorder(
          borderRadius: MxRadius.pillRadius,
          side: BorderSide(color: mx.divider, width: MxStroke.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: MxSpacing.space3,
              horizontal: MxSpacing.space4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...children,
                const SizedBox(width: MxSpacing.space2),
                Icon(Icons.expand_more, size: MxIconSize.sm, color: mx.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
