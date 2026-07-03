import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';

/// The kit's root phone-screen frame (`MxScaffold` · base class `.app`): an app
/// bar, a scrollable padded body, an optional bottom nav, and an optional FAB
/// parked above the nav. A composite wrapping Material's [Scaffold] (which owns
/// the safe-area insets + slot layout), token-driven for the body padding + gaps.
///
/// [children] are the body sections, laid out in a scrolling column with the
/// kit's `space5` gap. [flush] drops the horizontal gutter for full-bleed content.
class MxScaffold extends StatelessWidget {
  const MxScaffold({
    required this.children,
    this.appBar,
    this.bottomNav,
    this.fab,
    this.flush = false,
    super.key,
  });

  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNav;
  final Widget? fab;
  final bool flush;

  @override
  Widget build(BuildContext context) {
    final horizontal = flush ? 0.0 : MxSpacing.gutter;

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontal,
          MxSpacing.space4,
          horizontal,
          MxSpacing.space6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: MxSpacing.space5,
          children: children,
        ),
      ),
    );
  }
}
