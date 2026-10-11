import 'package:corridorshare/app.dart';
import 'package:corridorshare/core/firebase/firebase_bootstrap.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/data/datasources/fake_auth_datasource.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: <Override>[
        // The foundation ships with a fake data source. The Increment 1,
        // part 2 commit will swap this for `FirebaseAuthDataSource` when
        // the build is invoked with `--dart-define=FIREBASE_ENABLED=true`.
        authDataSourceProvider.overrideWithValue(FakeAuthDataSource()),
      ],
      child: const CorridorShareApp(),
    ),
  );
}

/// Re-exported so test files can reach the data source override without
/// importing this file directly.
typedef AppAuthDataSource = AuthDataSource;