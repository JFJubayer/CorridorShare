import 'package:corridorshare/app.dart';
import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/features/auth/data/datasources/fake_auth_datasource.dart';
import 'package:corridorshare/features/auth/presentation/pages/phone_entry_page.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _authOnlyRouter() {
  return GoRouter(
    initialLocation: AppRoutes.auth,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.auth,
        builder: (BuildContext context, GoRouterState state) =>
            const PhoneEntryPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('Home Screen')),
      ),
    ],
  );
}

Widget _harness({FakeAuthDataSource? dataSource}) {
  return ProviderScope(
    overrides: <Override>[
      authDataSourceProvider
          .overrideWithValue(dataSource ?? FakeAuthDataSource()),
      appRouterProvider.overrideWithValue(_authOnlyRouter()),
    ],
    child: const CorridorShareApp(),
  );
}

void main() {
  testWidgets('renders phone and email tabs and allows switching',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.byKey(const Key('phoneField')), findsOneWidget);

    // Tap Email tab
    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('emailSubmitButton')), findsOneWidget);
  });

  testWidgets('toggles between Sign In and Sign Up modes',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    // Default is Sign In
    expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
    expect(find.byKey(const Key('nameField')), findsNothing);

    // Tap toggle to switch to Sign Up
    await tester.tap(find.byKey(const Key('toggleAuthModeButton')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Create Account'), findsOneWidget);
    expect(find.byKey(const Key('nameField')), findsOneWidget);
  });

  testWidgets('signs in successfully with email and navigates to home',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('emailField')), 'test@example.com');
    await tester.enterText(
        find.byKey(const Key('passwordField')), 'password123');
    await tester.tap(find.byKey(const Key('emailSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });
}
