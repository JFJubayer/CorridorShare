import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
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

Widget _buildWalletHarness({
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
    child: Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(localeControllerProvider);
        return MaterialApp(
          locale: locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WalletPage(),
        );
      },
    ),
  );
}

void main() {
  testWidgets('renders Wallet page with dark card, balance, escrow, and action buttons',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final walletDs = InMemoryWalletDataSource(
      initialBalances: {'user-1': 1250.0},
      initialEscrows: {'user-1': 300.0},
    );

    await tester.pumpWidget(_buildWalletHarness(walletDataSource: walletDs));
    await tester.pumpAndSettle();

    // Top Bar
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.byKey(const Key('langBnButton')), findsOneWidget);
    expect(find.byKey(const Key('langEnButton')), findsOneWidget);

    // Dark Card
    expect(find.text('Demo wallet'), findsOneWidget);
    expect(find.text('No real money'), findsOneWidget);
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('৳1,250'), findsOneWidget);
    expect(find.text('In escrow'), findsOneWidget);
    expect(find.text('৳300'), findsOneWidget);
    expect(find.byKey(const Key('openTopUpDialogButton')), findsOneWidget);
    expect(find.byKey(const Key('withdrawSimulatedButton')), findsOneWidget);

    // Filter pills
    expect(find.text('All'), findsOneWidget);
    expect(find.text('In'), findsOneWidget);
    expect(find.text('Out'), findsOneWidget);

    // Default Transactions
    expect(find.text('Earning'), findsOneWidget);
    expect(find.text('Escrow hold'), findsOneWidget);
    expect(find.text('Top-up'), findsOneWidget);
    expect(find.text('Refund'), findsOneWidget);
    expect(find.text('Release'), findsOneWidget);
  });

  testWidgets('filter pills correctly filter transactions by In and Out',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildWalletHarness());
    await tester.pumpAndSettle();

    // Tap "In" filter: should show incoming credits (Earning, Top-up, Refund) and hide Out (Escrow hold, Release)
    await tester.tap(find.text('In'));
    await tester.pumpAndSettle();

    expect(find.text('Earning'), findsOneWidget);
    expect(find.text('Top-up'), findsOneWidget);
    expect(find.text('Refund'), findsOneWidget);
    expect(find.text('Escrow hold'), findsNothing);
    expect(find.text('Release'), findsNothing);

    // Tap "Out" filter: should show outgoing debits (Escrow hold, Release) and hide In
    await tester.tap(find.text('Out'));
    await tester.pumpAndSettle();

    expect(find.text('Escrow hold'), findsOneWidget);
    expect(find.text('Release'), findsOneWidget);
    expect(find.text('Earning'), findsNothing);
    expect(find.text('Top-up'), findsNothing);
    expect(find.text('Refund'), findsNothing);

    // Tap "All" filter: shows all 5
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('Earning'), findsOneWidget);
    expect(find.text('Escrow hold'), findsOneWidget);
    expect(find.text('Top-up'), findsOneWidget);
    expect(find.text('Refund'), findsOneWidget);
    expect(find.text('Release'), findsOneWidget);
  });

  testWidgets('tapping Add demo funds opens TopUpDialog and updates balance',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final walletDs = InMemoryWalletDataSource(
      initialBalances: {'user-1': 1250.0},
    );

    await tester.pumpWidget(_buildWalletHarness(walletDataSource: walletDs));
    await tester.pumpAndSettle();

    expect(find.text('৳1,250'), findsOneWidget);

    await tester.tap(find.byKey(const Key('openTopUpDialogButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TopUpDialog), findsOneWidget);

    await tester.enterText(find.byKey(const Key('topUpAmountField')), '750');
    await tester.pump();

    await tester.tap(find.byKey(const Key('submitTopUpButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TopUpDialog), findsNothing);
    // 1250 + 750 = 2000
    expect(find.text('৳2,000'), findsOneWidget);
  });

  testWidgets('tapping Withdraw simulated opens simulation modal',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildWalletHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('withdrawSimulatedButton')));
    await tester.pumpAndSettle();

    expect(find.text('Withdrawal (Simulation)'), findsOneWidget);
    expect(find.text('Confirm Simulated Payout'), findsOneWidget);

    await tester.tap(find.text('Confirm Simulated Payout'));
    await tester.pumpAndSettle();

    expect(find.text('Withdrawal (Simulation)'), findsNothing);
  });

  testWidgets('tapping Ledger history icon in AppBar opens TransactionHistorySheet',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildWalletHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('walletLedgerButton')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionHistorySheet), findsOneWidget);
  });
}
