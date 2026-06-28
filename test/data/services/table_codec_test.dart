import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/services/table_codec.dart';

void main() {
  const codec = TableCodec();
  final rows = <List<String>>[
    <String>['term', 'meaning'],
    <String>['xin', 'please'],
    <String>['hello', 'chào'],
  ];

  test('CSV round-trips rows', () {
    final text = codec.toDelimited(rows, ',');
    expect(codec.fromDelimited(text, ','), rows);
  });

  test('a semicolon separator splits correctly', () {
    final parsed = codec.fromDelimited('a;b;c\nd;e;f', ';');
    expect(parsed, <List<String>>[
      <String>['a', 'b', 'c'],
      <String>['d', 'e', 'f'],
    ]);
  });

  test('XLSX round-trips rows', () {
    final bytes = codec.toExcel(rows);
    expect(bytes, isNotEmpty);
    expect(codec.fromExcel(bytes), rows);
  });
}
