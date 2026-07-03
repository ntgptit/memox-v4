import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Native/VM: a real in-memory SQLite database for tests.
QueryExecutor memoryExecutor() => NativeDatabase.memory();
