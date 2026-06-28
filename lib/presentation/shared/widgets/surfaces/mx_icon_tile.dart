import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Color tone for [MxIconTile] (omit for soft primary).
enum MxIconTileTone { primary, accent, success, warning, error }

/// A rounded icon chip — the design kit's `MxIconTile`.
///
/// Purpose:
/// A square, tinted container holding a single icon, used as a leading visual
/// for tiles, stats, and menu rows.
///
/// Use when:
/// You need a consistent colored icon badge in front of a label.
///
/// Do not use when:
/// The icon is a tappable action (use MxIconButton).
///
/// Category:
/// display
///
/// Public API:
/// - icon: the icon to show
/// - tone: color tone (default soft primary)
/// - solid: solid fill instead of a soft tint
/// - large: a larger tile
///
/// States:
/// default
///
/// Variants:
/// soft (default), solid
class MxIconTile extends StatelessWidget {
  const MxIconTile({
    super.key,
    required this.icon,
    this.tone = MxIconTileTone.primary,
    this.solid = false,
    this.large = false,
  });

  final IconData icon;
  final MxIconTileTone tone;
  final bool solid;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    final (soft, strong, onStrong) = _palette(colors);
    final dimension = large ? MxSpacing.space10 : MxSpacing.space9;
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: solid ? strong : soft,
        borderRadius: MxRadius.tileRadius,
      ),
      child: Icon(
        icon,
        size: large ? MxSpacing.space6 : MxSpacing.space5,
        color: solid ? onStrong : strong,
      ),
    );
  }

  (Color soft, Color strong, Color onStrong) _palette(MxColors c) =>
      switch (tone) {
        MxIconTileTone.primary => (c.primarySoft, c.primary, c.onPrimary),
        MxIconTileTone.accent => (c.accentSoft, c.accent, c.onAccent),
        MxIconTileTone.success => (c.successSoft, c.success, c.onSuccess),
        MxIconTileTone.warning => (c.warningSoft, c.warning, c.onWarning),
        MxIconTileTone.error => (c.errorSoft, c.error, c.onError),
      };
}
