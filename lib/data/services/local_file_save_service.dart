import 'dart:io';

import 'package:memox_v4/domain/services/file_save_service.dart';
import 'package:path_provider/path_provider.dart';

/// Writes to the app documents directory.
class LocalFileSaveService implements FileSaveService {
  const LocalFileSaveService();

  @override
  Future<String> save(String fileName, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
