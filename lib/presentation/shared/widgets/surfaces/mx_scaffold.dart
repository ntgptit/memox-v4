import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// The root screen frame — the design kit's `MxScaffold`.
///
/// Purpose:
/// A consistent screen shell: brand background, a gutter-padded body, and slots
/// for the app bar, bottom navigation, and a floating action button.
///
/// Use when:
/// Building any top-level screen.
///
/// Do not use when:
/// Composing a fragment inside another screen (use a plain widget).
///
/// Category:
/// layout
///
/// Public API:
/// - appBar: top app bar (usually MxAppBar)
/// - bottomNav: bottom navigation bar
/// - fab: floating action button
/// - flush: remove the body's horizontal gutter for full-bleed content
/// - body: scrollable screen content
///
/// States:
/// default
class MxScaffold extends StatelessWidget {
  const MxScaffold({
    super.key,
    this.appBar,
    this.bottomNav,
    this.fab,
    this.flush = false,
    required this.body,
  });

  final PreferredSizeWidget? appBar;
  final Widget? bottomNav;
  final Widget? fab;
  final bool flush;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      floatingActionButton: fab,
      body: SafeArea(
        child: flush
            ? body
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MxSpacing.space4,
                ),
                child: body,
              ),
      ),
    );
  }
}
