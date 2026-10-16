import 'package:corridorshare/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Lazy wrapper around [Firebase.initializeApp] that fires when the
/// build is invoked with `--dart-define=FIREBASE_ENABLED=true` or enabled in `main()`.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool _forceEnabled = false;

  /// Programmatically enable Firebase (used in production main()).
  static set forceEnabled(bool value) => _forceEnabled = value;

  static bool get isEnabled {
    if (_forceEnabled) {
      return true;
    }
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
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.web,
        );
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.android,
            );
            break;
          case TargetPlatform.iOS:
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.ios,
            );
            break;
          case TargetPlatform.macOS:
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.macos,
            );
            break;
          case TargetPlatform.windows:
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.windows,
            );
            break;
          case TargetPlatform.linux:
            // Linux has no default Firebase options generated yet.
            break;
          default:
            break;
        }
      }
    } on Exception catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Firebase init failed: $error\n$stack');
      }
    }
  }
}