import 'package:drift/drift.dart';

/// Fallback when neither dart:io nor js_interop is available.
QueryExecutor openLocalDatabase() =>
    throw UnsupportedError('No database backend for this platform.');

QueryExecutor openInMemoryDatabase() =>
    throw UnsupportedError('No database backend for this platform.');
