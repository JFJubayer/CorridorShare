import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/profile/presentation/pages/profile_page.dart';
import 'package:corridorshare/features/wallet/data/datasources/in_memory_wallet_datasource.dart';
import 'package:corridorshare/features/wallet/presentation/pages/wallet_page.dart';
import 'package:corridorshare/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/top_up_dialog.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/transaction_history_sheet.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _buildHarness({
  InMemoryWalletDataSource? walletDataSource,
  AuthUser? user,
}) {
  final router = GoRouter(
    initialLocation: '/profile',
    routes: <RouteBase>[
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (_, __) => const WalletPage(),
      ),
      GoRoute(
        path: '/my-parcels',
        builder: (_, __) => const Scaffold(body: Text('My Parcels Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: <Override>[
      if (walletDataSource != null)
        walletDataSourceProvider.overrideWithValue(walletDataSource),
      currentUserProvider.overrideWithValue(
        user ??
            const AuthUser(
              id: 'user-1',
              phone: '+880 1711 000000',
              name: 'Tanvir Ahmed',
              verified: true,
              ratingAvg: 4.8,
            ),
      ),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(localeControllerProvider);
        return MaterialApp.router(
          routerConfig: router,
          locale: locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    ),
  );
}

void main() {
  testWidgets('renders redesigned profile with user card, stats row, and menu items',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    // App Bar & Language toggle
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byKey(const Key('langBnButton')), findsOneWidget);
    expect(find.byKey(const Key('langEnButton')), findsOneWidget);

    // User Card
    expect(find.text('Tanvir Ahmed'), findsOneWidget);
    expect(find.text('TA'), findsOneWidget);
    expect(find.text('+880 1711-••••00'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    // Stats Row
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('RATING'), findsOneWidget);
    expect(find.text('SENT'), findsOneWidget);
    expect(find.text('CARRIED'), findsOneWidget);

    // Menu Card
    expect(find.byKey(const Key('myParcelsTile')), findsOneWidget);
    expect(find.byKey(const Key('walletTile')), findsOneWidget);
    expect(find.byKey(const Key('walletBalanceDisplay')), findsOneWidget);
    expect(find.byKey(const Key('languagePickerTile')), findsOneWidget);
    expect(find.byKey(const Key('helpTile')), findsOneWidget);
    expect(find.byKey(const Key('signOutTile')), findsOneWidget);
  });

  testWidgets('tapping wallet tile navigates to WalletPage with top-up and adds funds',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final walletDs = InMemoryWalletDataSource(
      initialBalances: {'user-1': 3500.0},
    );

    await tester.pumpWidget(_buildHarness(walletDataSource: walletDs));
    await tester.pumpAndSettle();

    expect(find.text('৳3,500'), findsOneWidget);

    // Tap Wallet tile to navigate to WalletPage
    await tester.tap(find.byKey(const Key('walletTile')));
    await tester.pumpAndSettle();

    // Verify Wallet page is opened
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Demo wallet'), findsOneWidget);
    expect(find.byKey(const Key('openTopUpDialogButton')), findsOneWidget);

    // Tap Top Up
    await tester.tap(find.byKey(const Key('openTopUpDialogButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TopUpDialog), findsOneWidget);

    // Enter top up amount: 1500
    await tester.enterText(find.byKey(const Key('topUpAmountField')), '1500');
    await tester.pump();

    await tester.tap(find.byKey(const Key('submitTopUpButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TopUpDialog), findsNothing);
    // Balance updated to 3500 + 1500 = 5000 (formatted as ৳5,000 on WalletPage)
    expect(find.text('৳5,000'), findsOneWidget);
  });

  testWidgets('tapping Ledger opens TransactionHistorySheet from wallet page',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    // Open wallet page
    await tester.tap(find.byKey(const Key('walletTile')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('walletLedgerButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionHistorySheet), findsOneWidget);
    expect(find.text('Wallet Transaction History'), findsOneWidget);
  });

  testWidgets('tapping language toggle switches locale to Bangla and back',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);

    // Tap 'বাংলা'
    await tester.tap(find.byKey(const Key('langBnButton')));
    await tester.pumpAndSettle();

    // Should switch to Bangla translation for Profile (প্রোফাইল)
    expect(find.text('প্রোফাইল'), findsOneWidget);

    // Tap 'EN'
    await tester.tap(find.byKey(const Key('langEnButton')));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping Help tile opens Help sheet with admin dashboard link',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    // Tap Help tile
    await tester.tap(find.byKey(const Key('helpTile')));
    await tester.pumpAndSettle();

    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.byKey(const Key('adminDashboardTile')), findsOneWidget);
  });

  testWidgets('tapping My parcels tile navigates to My Parcels page (not My posts)',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('myParcelsTile')));
    await tester.pumpAndSettle();

    expect(find.text('My Parcels Screen'), findsOneWidget);
  });
}
