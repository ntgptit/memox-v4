import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's top app bar (`MxAppBar` · base class `.appbar` / `.appbar-lg`):
/// compact by default, or a tall Material-3 hero via [large] (an eyebrow above a
/// large title). A composite implementing [PreferredSizeWidget] so it drops into
/// [MxScaffold] / Material [Scaffold]; token-driven via [MxTheme]. Copy from ARB.
class MxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MxAppBar({
    this.title,
    this.eyebrow,
    this.large = false,
    this.leading,
    this.trailing,
    super.key,
  });

  final String? title;

  /// A small label above the large title (only shown when [large]).
  final String? eyebrow;
  final bool large;
  final Widget? leading;
  final Widget? trailing;

  @override
  Size get preferredSize {
    if (!large) return const Size.fromHeight(MxSpacing.appBarHeight);
    // The hero grows to fit an optional leading/trailing action row above the
    // eyebrow + title (kit `.appbar-lg` is min-height, not fixed).
    final hasRow = leading != null || trailing != null;
    return Size.fromHeight(
      hasRow
          ? MxSpacing.appBarLargeHeight + MxSpacing.minTouchTarget
          : MxSpacing.appBarLargeHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: large ? _buildLarge(context) : _buildCompact(context),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: MxSpacing.appBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MxSpacing.gutter),
        child: Row(
          spacing: MxSpacing.space3,
          children: [
            ?leading,
            Expanded(
              child: Text(
                title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeLg,
                  fontWeight: MxTypography.bold,
                  letterSpacing:
                      MxTypography.sizeLg * MxTypography.trackingTight,
                  color: scheme.onSurface,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLarge(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasRow = leading != null || trailing != null;
    final eyebrow = this.eyebrow;

    return Padding(
      padding: const EdgeInsets.only(
        top: MxSpacing.space5,
        left: MxSpacing.gutter,
        right: MxSpacing.gutter,
        bottom: MxSpacing.space4,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: MxSpacing.space1,
          children: [
            if (hasRow)
              Row(
                spacing: MxSpacing.space3,
                children: [
                  ?leading,
                  const Spacer(),
                  ?trailing,
                ],
              ),
            if (eyebrow != null)
              Text(
                eyebrow,
                style: TextStyle(
                  fontFamily: MxTypography.fontFamily,
                  fontSize: MxTypography.sizeSm,
                  fontWeight: MxTypography.semibold,
                  color: mx.textSecondary,
                ),
              ),
            Text(
              title ?? '',
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.size2xl,
                fontWeight: MxTypography.extrabold,
                letterSpacing:
                    MxTypography.size2xl * MxTypography.trackingTight,
                height: MxTypography.lineHeightTight,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
