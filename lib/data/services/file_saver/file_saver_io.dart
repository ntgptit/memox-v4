import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Writes export bytes to the app documents directory and returns the path.
Future<String> saveExportBytes(String fileName, List<int> bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
