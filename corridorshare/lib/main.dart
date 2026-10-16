import 'package:corridorshare/app.dart';
import 'package:corridorshare/core/firebase/firebase_bootstrap.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    if (kDebugMode) {
      debugPrint('No .env file found or failed to load: $error');
    }
  }
  const String envFlag = String.fromEnvironment('FIREBASE_ENABLED');
  if (envFlag != 'false') {
    FirebaseBootstrap.forceEnabled = true;
  }
  await FirebaseBootstrap.ensureInitialized();

  runApp(
    const ProviderScope(
      child: CorridorShareApp(),
    ),
  );
}

/// Re-exported so test files can reach the data source override without
/// importing this file directly.
typedef AppAuthDataSource = AuthDataSource;