import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/datasources/local/connection/open_connection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// The single app-wide [AppDatabase] (Drift), opened via the platform-appropriate
/// executor ([openConnection] — a file `NativeDatabase` on mobile/desktop, a
/// `WasmDatabase` on web). Kept alive for the whole session and closed on dispose.
/// Tests override this provider with `AppDatabase.memory()`, so the plugin/wasm
/// path never runs under `flutter test`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(openConnection());
  ref.onDispose(db.close);
  return db;
}
