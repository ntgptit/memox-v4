import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_text_field.dart';

/// A deliberately hostile ambient theme (the app theme with outline borders +
/// fill forced on every slot). The kit `.field` contract says the input is
/// BARE — the visible box belongs to the caller's container — so none of this
/// may leak into MxTextField.
final _hostileTheme = AppTheme.light.copyWith(
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.red,
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 4)),
  ),
);

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

void main() {
  Future<void> pump(WidgetTester tester, {ThemeData? theme}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        home: const Scaffold(body: MxTextField(hintText: 'Type here')),
      ),
    );
  }

  testWidgets('is bare: every border slot none, no fill', (tester) async {
    await pump(tester);
    final deco = _decoration(tester);
    expect(deco.isCollapsed, isTrue);
    expect(deco.filled, isFalse);
    expect(deco.border, InputBorder.none);
    expect(deco.enabledBorder, InputBorder.none);
    expect(deco.focusedBorder, InputBorder.none);
    expect(deco.errorBorder, InputBorder.none);
    expect(deco.focusedErrorBorder, InputBorder.none);
    expect(deco.disabledBorder, InputBorder.none);
  });

  testWidgets('stays bare under a hostile InputDecorationTheme',
      (tester) async {
    await pump(tester, theme: _hostileTheme);
    // applyDefaults only fills NULL slots — ours are all explicit, so the
    // ambient theme cannot paint a second box inside a MemoX container.
    final effective = _decoration(tester)
        .applyDefaults(_hostileTheme.inputDecorationTheme);
    expect(effective.enabledBorder, InputBorder.none);
    expect(effective.focusedBorder, InputBorder.none);
    expect(effective.filled, isFalse);
  });

  testWidgets('app theme itself declares the bare-input contract',
      (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final t = theme.inputDecorationTheme;
      expect(t.filled, isFalse);
      expect(t.border, InputBorder.none);
      expect(t.enabledBorder, InputBorder.none);
      expect(t.focusedBorder, InputBorder.none);
    }
  });
}
