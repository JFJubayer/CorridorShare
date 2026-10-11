import 'package:corridorshare/app.dart';
import 'package:corridorshare/core/firebase/firebase_bootstrap.dart';
import 'package:corridorshare/features/auth/data/datasources/fake_auth_datasource.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({FakeAuthDataSource? dataSource}) {
  return ProviderScope(
    overrides: <Override>[
      authDataSourceProvider
          .overrideWithValue(dataSource ?? FakeAuthDataSource()),
    ],
    child: const CorridorShareApp(),
  );
}

void main() {
  setUpAll(() {
    // Sanity: the foundation boots without Firebase enabled.
    expect(FirebaseBootstrap.isEnabled, isFalse);
  });

  testWidgets('rejects a malformed phone number', (WidgetTester tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('phoneField')), '123');
    await tester.tap(find.byKey(const Key('phoneContinue')));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid Bangladeshi mobile number.'),
      findsOneWidget,
    );
  });

  testWidgets('moves to the OTP page on a valid phone', (WidgetTester tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('phoneField')), '01712345678');
    await tester.tap(find.byKey(const Key('phoneContinue')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the 6-digit code'), findsOneWidget);
    expect(find.text('+880 171 2345678'), findsOneWidget);
  });

  testWidgets('AppLocalizations exposes the foundation keys in English',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(body: _LocalizationProbe()),
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(_LocalizationProbe)),
    );
    expect(l10n.appTitle, isNotEmpty);
    expect(l10n.tabHome, isNotEmpty);
    expect(l10n.tabMyPosts, isNotEmpty);
    expect(l10n.tabChats, isNotEmpty);
    expect(l10n.tabProfile, isNotEmpty);
    expect(l10n.phoneLabel, isNotEmpty);
    expect(l10n.otpVerify, isNotEmpty);
  });

  testWidgets('AppLocalizations exposes the foundation keys in Bangla',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('bn'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(body: _LocalizationProbe()),
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(_LocalizationProbe)),
    );
    expect(l10n.appTitle, isNotEmpty);
    expect(l10n.tabHome, isNotEmpty);
    expect(l10n.tabMyPosts, isNotEmpty);
    expect(l10n.tabChats, isNotEmpty);
    expect(l10n.tabProfile, isNotEmpty);
    expect(l10n.phoneLabel, isNotEmpty);
    expect(l10n.otpVerify, isNotEmpty);
  });
}

class _LocalizationProbe extends StatelessWidget {
  const _LocalizationProbe();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Text(l10n.appTitle),
        Text(l10n.tabHome),
        Text(l10n.tabMyPosts),
        Text(l10n.tabChats),
        Text(l10n.tabProfile),
        Text(l10n.phoneLabel),
        Text(l10n.otpVerify),
      ],
    );
  }
}
