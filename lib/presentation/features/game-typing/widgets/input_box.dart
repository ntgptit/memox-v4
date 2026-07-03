import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Border tone for [InputBox] — mirrors the kit's neutral / correct / wrong tint.
enum InputBoxTone { neutral, correct, wrong }

/// Game-typing local (kit `InputBox`): the bordered answer field. The border
/// tone tints for a correct (success) / wrong (error) grade; [child] is the
/// content — a `TextField` while typing, or the graded answer once checked.
class InputBox extends StatelessWidget {
  const InputBox({
    required this.child,
    this.tone = InputBoxTone.neutral,
    super.key,
  });

  final Widget child;
  final InputBoxTone tone;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final (color, width) = switch (tone) {
      InputBoxTone.neutral => (mx.divider, MxStroke.hairline),
      InputBoxTone.correct => (mx.success, MxStroke.emphasis),
      InputBoxTone.wrong =>
        (Theme.of(context).colorScheme.error, MxStroke.emphasis),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: MxSizes.sizeMd),
      padding: const EdgeInsets.all(MxSpacing.space4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: mx.surface,
        borderRadius: MxRadius.controlRadius,
        border: Border.all(color: color, width: width),
      ),
      child: child,
    );
  }
}
