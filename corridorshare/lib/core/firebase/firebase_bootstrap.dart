import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';

/// Lazy wrapper around [Firebase.initializeApp] that only fires when the
/// build is invoked with `--dart-define=FIREBASE_ENABLED=true`.
///
/// During the foundation increment we ship UI and domain code without a live
/// Firebase project. The default off-switch avoids `Firebase not initialized`
/// crashes in `flutter run` and CI, while a real build can opt in to the
/// real Firebase backend.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool get isEnabled {
    const String flag = String.fromEnvironment('FIREBASE_ENABLED');
    return flag == 'true';
  }

  /// Initialize Firebase when [isEnabled] is true. Returns a sentinel
  /// [Future<void>] that completes immediately otherwise.
  static Future<void> ensureInitialized() async {
    if (!isEnabled) {
      return;
    }
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    try {
      await Firebase.initializeApp();
    } on Exception catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Firebase init failed: $error\n$stack');
      }
    }
  }
}