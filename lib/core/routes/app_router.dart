import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The app router. A single placeholder route for now; the routing skeleton
/// (I.5) grows this into the shell + typed routes to the real screens.
///
/// Riverpod owns the router so features can read/refresh it without a global
/// singleton (`ref.watch(routerProvider)` from [MemoxApp]).
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _BootstrapHome(),
      ),
    ],
  );
}

/// Temporary landing surface — proof the router + [ProviderScope] + the guarded
/// error zone are wired end-to-end. Replaced by real screens once I.5 lands, so
/// it carries only the brand name (a constant, not localizable copy).
class _BootstrapHome extends StatelessWidget {
  const _BootstrapHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
