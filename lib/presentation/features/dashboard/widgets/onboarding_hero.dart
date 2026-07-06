import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Dashboard-local first-run hero card (kit `dashboard/onboarding`): replaces
/// the today card while the library has no decks yet — an invitation to create
/// the first deck. [child] carries the CTA stack (create / import). Foreground
/// colours come from the primary [MxCard]; this widget owns only sizes/weights.
/// Copy is from ARB.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    required this.icon,
    required this.title,
    required this.text,
    this.child,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final Widget? child;

  // Kit body copy renders at 90% opacity on the primary card.
  static const double _bodyOpacity = MxOpacity.label;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final child = this.child;

    return MxCard(
      variant: MxCardVariant.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative glyph chip (kit: primary-strong circle on the hero).
          Container(
            width: MxSizes.sizeSm,
            height: MxSizes.sizeSm,
            decoration: BoxDecoration(
              color: mx.primaryStrong,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: MxIconSize.md),
          ),
          const SizedBox(height: MxSpacing.space3),
          Text(
            title,
            style: const TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeLg,
              fontWeight: MxTypography.extrabold,
              letterSpacing: MxTypography.sizeLg * MxTypography.trackingTight,
            ),
          ),
          const SizedBox(height: MxSpacing.space1),
          Opacity(
            opacity: _bodyOpacity,
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeSm,
                height: MxTypography.lineHeightNormal,
              ),
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: MxSpacing.space4),
            child,
          ],
        ],
      ),
    );
  }
}
