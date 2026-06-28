import 'package:memox_v4/data/services/file_saver/file_saver.dart';
import 'package:memox_v4/domain/services/file_save_service.dart';

/// Writes exported bytes via the platform file saver (native: documents dir;
/// web: not yet supported).
class LocalFileSaveService implements FileSaveService {
  const LocalFileSaveService();

  @override
  Future<String> save(String fileName, List<int> bytes) =>
      saveExportBytes(fileName, bytes);
}
