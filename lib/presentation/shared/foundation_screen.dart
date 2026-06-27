import 'package:flutter/material.dart';
import 'package:memox_v4/core/constants/app_constants.dart';

/// Temporary foundation placeholder mounted at the app root.
///
/// W1 ships no business UI; this screen exists only so routing, theming, and
/// boot can be exercised end to end. The navigation contract replaces the root
/// with the library tree at W6. It shows the brand name only — no localizable
/// copy is introduced here.
class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

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
