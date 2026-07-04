/// A tabular codec — decodes text into rows of string cells and encodes rows back
/// to text. Import/export use cases depend on this interface, never on a file
/// plugin, so they stay pure and testable (import-export note: parse/encode via a
/// `TableCodec`). The Excel codec is a data-layer implementation of the same
/// interface; [CsvCodec] below is the pure-Dart CSV/TSV one.
abstract interface class TableCodec {
  List<List<String>> decode(String input);
  String encode(List<List<String>> rows);
}

/// A pure RFC-4180 CSV codec with a configurable single-character [delimiter]
/// (comma / tab / semicolon / …, D-025). Cells containing the delimiter, a quote,
/// or a newline are wrapped in double quotes with embedded quotes doubled (BR-4);
/// UTF-8 is inherent to Dart strings.
class CsvCodec implements TableCodec {
  const CsvCodec({this.delimiter = ','});

  final String delimiter;

  @override
  List<List<String>> decode(String input) {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var inQuotes = false;
    var sawContent = false;

    void endField() {
      row.add(field.toString());
      field = StringBuffer();
    }

    void endRow() {
      endField();
      rows.add(row);
      row = <String>[];
      sawContent = false;
    }

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (inQuotes) {
        if (ch != '"') {
          field.write(ch);
          continue;
        }
        final isEscapedQuote = i + 1 < input.length && input[i + 1] == '"';
        if (isEscapedQuote) {
          field.write('"');
          i++;
          continue;
        }
        inQuotes = false;
        continue;
      }
      if (ch == '"') {
        inQuotes = true;
        sawContent = true;
        continue;
      }
      if (ch == delimiter) {
        endField();
        sawContent = true;
        continue;
      }
      if (ch == '\r') continue;
      if (ch == '\n') {
        endRow();
        continue;
      }
      field.write(ch);
      sawContent = true;
    }

    if (sawContent || field.isNotEmpty || row.isNotEmpty) endRow();
    return rows;
  }

  @override
  String encode(List<List<String>> rows) =>
      rows.map((row) => row.map(_escape).join(delimiter)).join('\r\n');

  String _escape(String field) {
    final needsQuoting = field.contains(delimiter) ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r');
    if (!needsQuoting) return field;
    return '"${field.replaceAll('"', '""')}"';
  }
}
