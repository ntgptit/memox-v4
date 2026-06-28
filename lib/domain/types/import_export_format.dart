/// Where import data comes from / export data goes (`import-export.md`, D-025/D-026).
enum TransferFormat { csv, excel, clipboard }

/// Column separator for delimited (CSV / clipboard) text.
enum Separator { comma, tab, semicolon }

extension SeparatorX on Separator {
  String get char => switch (this) {
    Separator.comma => ',',
    Separator.tab => '\t',
    Separator.semicolon => ';',
  };
}
