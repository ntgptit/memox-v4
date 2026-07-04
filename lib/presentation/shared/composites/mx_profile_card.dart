import 'package:flutter/material.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_avatar.dart';

/// The kit's `_shared/ProfileCard` as a reusable composite: an avatar + name +
/// subtitle identity card. Shared by settings (settings/profile) and — once built
/// — account-sync (account/profile, deferred WBS S.22).
///
/// v1 divergence (documented, D-027): local-first with no account/sync, so this
/// shows the app's **local** identity — the MemoX wordmark + an on-device subtitle —
/// not the kit's signed-in name/email. The kit's optional `badge` (account-sync's
/// ALPHA tag) has no v1 slot here (deferred-screen props-parity exception). Copy is
/// from ARB; the wordmark is brand, not translatable.
class MxProfileCard extends StatelessWidget {
  const MxProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MxAvatar(
            name: AppConstants.appName,
            size: MxAvatarSize.large,
            variant: MxAvatarVariant.accent,
            ring: true,
          ),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeMd,
                    fontWeight: MxTypography.extrabold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  l10n.settingsProfileSubtitle,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
