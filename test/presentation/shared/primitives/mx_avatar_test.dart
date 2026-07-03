import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_avatar.dart';

/// A valid 1×1 transparent PNG — an [ImageProvider] that loads without error.
final _pngImage = MemoryImage(
  Uint8List.fromList(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]),
);

Future<void> _pump(WidgetTester tester, Widget avatar, {bool dark = false}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: avatar)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(MxAvatar), matching: find.byType(Container)),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('initialsOf', () {
    test('takes the first letter of the first two words, uppercased', () {
      expect(MxAvatar.initialsOf('John Doe'), 'JD');
      expect(MxAvatar.initialsOf('cher'), 'C');
      expect(MxAvatar.initialsOf('  nguyen  van  a '), 'NV');
      expect(MxAvatar.initialsOf(null), '');
      expect(MxAvatar.initialsOf('   '), '');
    });
  });

  group('sizes', () {
    testWidgets('md=44, sm=32, lg=64 diameters', (tester) async {
      for (final (size, dim) in [
        (MxAvatarSize.small, 32.0),
        (MxAvatarSize.medium, 44.0),
        (MxAvatarSize.large, 64.0),
      ]) {
        await _pump(tester, MxAvatar(name: 'Jo', size: size));
        expect(tester.getSize(find.byType(MxAvatar)), Size(dim, dim));
      }
    });
  });

  group('variant → tokens', () {
    testWidgets('neutral = primarySoft; accent = accentSoft', (tester) async {
      await _pump(tester, const MxAvatar(name: 'Jo'));
      expect(_decoration(tester).color, MxColors.light.primarySoft);

      await _pump(tester, const MxAvatar(name: 'Jo', variant: MxAvatarVariant.accent));
      expect(_decoration(tester).color, MxColors.light.accentSoft);
    });

    testWidgets('dark uses dark tokens', (tester) async {
      await _pump(tester, const MxAvatar(name: 'Jo'), dark: true);
      expect(_decoration(tester).color, MxColors.dark.primarySoft);
    });
  });

  group('content', () {
    testWidgets('shows initials when no image', (tester) async {
      await _pump(tester, const MxAvatar(name: 'John Doe'));
      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows a clipped image when provided', (tester) async {
      await _pump(tester, MxAvatar(name: 'John Doe', image: _pngImage));
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.text('JD'), findsNothing);
    });
  });

  testWidgets('ring adds the two-layer shadow', (tester) async {
    await _pump(tester, const MxAvatar(name: 'Jo', ring: true));
    expect(_decoration(tester).boxShadow, hasLength(2));

    await _pump(tester, const MxAvatar(name: 'Jo'));
    expect(_decoration(tester).boxShadow, isNull);
  });
}
