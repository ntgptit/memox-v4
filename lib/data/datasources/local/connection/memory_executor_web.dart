import 'package:drift/drift.dart';

/// Web: there is no synchronous in-memory executor and the web app never needs
/// one — this exists only so `app_database.dart` compiles for web without
/// dragging `dart:ffi` in via the native path.
QueryExecutor memoryExecutor() => throw UnsupportedError(
      'AppDatabase.memory() is native/test only; the web app uses openConnection().',
    );
