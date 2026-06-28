import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// Encodes/decodes table rows to CSV text and XLSX bytes (W8). Kept thin and at
/// the data edge; the import/export use cases stay plugin-free.
class TableCodec {
  const TableCodec();

  /// Parses delimited [text] into rows of string cells.
  List<List<String>> fromDelimited(String text, String delimiter) {
    final raw = CsvDecoder(fieldDelimiter: delimiter).convert(text);
    return <List<String>>[
      for (final row in raw) <String>[for (final cell in row) '${cell ?? ''}'],
    ];
  }

  /// Serialises [rows] to delimited text.
  String toDelimited(List<List<String>> rows, String delimiter) =>
      CsvEncoder(fieldDelimiter: delimiter, lineDelimiter: '\n').convert(rows);

  /// Reads the first sheet of an XLSX file into rows of string cells.
  List<List<String>> fromExcel(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return const <List<String>>[];
    final sheet = excel.tables.values.first;
    return <List<String>>[
      for (final row in sheet.rows)
        <String>[for (final cell in row) cell?.value?.toString() ?? ''],
    ];
  }

  /// Builds an XLSX file (single sheet) from [rows].
  List<int> toExcel(List<List<String>> rows) {
    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    for (final row in rows) {
      excel.appendRow(sheetName, <CellValue?>[
        for (final cell in row) TextCellValue(cell),
      ]);
    }
    return excel.encode() ?? <int>[];
  }
}
