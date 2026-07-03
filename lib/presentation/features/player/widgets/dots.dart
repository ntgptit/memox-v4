import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/presentation/features/player/providers/player_providers.dart';

/// Player-local (kit `player/progress`): an [playerDotCount]-dot deck-progress
/// indicator. Dots up to [active] are primary (the active one elongated); the
/// rest are sunken.
class Dots extends StatelessWidget {
  const Dots({required this.active, super.key});

  final int active;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < playerDotCount; i++) ...[
          if (i > 0) const SizedBox(width: MxSpacing.space2),
          Container(
            width: i == active ? MxSizes.sizeXs : MxSizes.size2xs,
            height: MxSizes.size2xs,
            decoration: BoxDecoration(
              color: i <= active ? scheme.primary : mx.surfaceSunken,
              borderRadius: const BorderRadius.all(Radius.circular(MxRadius.pill)),
            ),
          ),
        ],
      ],
    );
  }
}
