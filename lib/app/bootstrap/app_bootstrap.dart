import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/app_dependencies.dart';
import 'package:memox_v4/app/memox_app.dart';

/// Wires application startup and runs the root widget.
///
/// Responsible only for startup orchestration: ensure the binding, build the DI
/// container, run the app. No business logic, no placeholder data, no
/// persistent state held here.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(overrides: appOverrides(), child: const MemoXApp()));
}
