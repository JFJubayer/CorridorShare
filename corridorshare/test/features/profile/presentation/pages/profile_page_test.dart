import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/profile/presentation/pages/profile_page.dart';
import 'package:corridorshare/features/wallet/data/datasources/in_memory_wallet_datasource.dart';
import 'package:corridorshare/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/top_up_dialog.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/transaction_history_sheet.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({
  InMemoryWalletDataSource? walletDataSource,
  AuthUser? user,
}) {
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
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProfilePage(),
    ),
  );
}

void main() {
  testWidgets('renders profile with user info, wallet card, reviews, and admin tile',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Demo Wallet'), findsOneWidget);
    expect(find.byKey(const Key('walletBalanceDisplay')), findsOneWidget);
    expect(find.text('Ratings & Reviews'), findsOneWidget);
    expect(find.byKey(const Key('adminDashboardTile')), findsOneWidget);
    expect(find.byKey(const Key('openTopUpDialogButton')), findsOneWidget);
  });

  testWidgets('top-up dialog adds funds to demo wallet balance',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final walletDs = InMemoryWalletDataSource(
      initialBalances: {'user-1': 3500.0},
    );

    await tester.pumpWidget(_buildHarness(walletDataSource: walletDs));
    await tester.pumpAndSettle();

    expect(find.text('৳ 3500'), findsOneWidget);

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
    // Balance updated to 3500 + 1500 = 5000
    expect(find.text('৳ 5000'), findsOneWidget);
  });

  testWidgets('tapping Ledger opens TransactionHistorySheet',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('walletLedgerButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionHistorySheet), findsOneWidget);
    expect(find.text('Wallet Transaction History'), findsOneWidget);
  });
}
