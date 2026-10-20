import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/deals/presentation/pages/deals_page.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({
  String? dealId,
  String? initialRole,
}) {
  return ProviderScope(
    overrides: <Override>[
      currentUserProvider.overrideWithValue(
        const AuthUser(
          id: 'traveller-1',
          phone: '+8801700000000',
          name: 'Rafi Mahmud',
          verified: true,
          ratingAvg: 4.8,
        ),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DealsPage(
        dealId: dealId,
        initialRole: initialRole,
      ),
    ),
  );
}

void main() {
  testWidgets('renders Deals page with Deal status title, no language toggle, and carrier view cards',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    // App Bar checks
    expect(find.text('Deal status'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Verify NO language toggle is present in top right
    expect(find.text('বাংলা'), findsNothing);
    expect(find.text('EN'), findsNothing);

    // Card 1: Carrier view info
    expect(find.text('NA'), findsOneWidget);
    expect(find.text('Nila Akter'), findsOneWidget);
    expect(find.text('Sender · Documents'), findsOneWidget);
    expect(find.text('Dhaka → Mymensingh · Sat 24 Oct'), findsOneWidget);
    expect(find.text('ESCROW'), findsOneWidget);
    expect(find.text('You earn ৳300 on delivery'), findsOneWidget);

    // Card 2: 5 Timeline steps
    expect(find.text('Agreed'), findsOneWidget);
    expect(find.text('Paid (escrow)'), findsOneWidget);
    expect(find.text('Picked up'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Money released'), findsOneWidget);
    expect(find.text('Waiting for handover code'), findsOneWidget);

    // Card 3: Enter Handover Code
    expect(find.text('ENTER HANDOVER CODE'), findsOneWidget);
    expect(find.byKey(const Key('confirmPickupActionBtn')), findsOneWidget);
    expect(find.text('Confirm pickup'), findsOneWidget);

    // Bottom action buttons
    expect(find.byKey(const Key('dealChatBtn')), findsOneWidget);
    expect(find.byKey(const Key('dealReportProblemBtn')), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Report a problem'), findsOneWidget);
  });

  testWidgets('switches to Sender view and displays dark handover code card with 4 digits',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    // Tap Sender toggle
    await tester.tap(find.text('Sender'));
    await tester.pumpAndSettle();

    // Card 1: Sender view info
    expect(find.text('RM'), findsOneWidget);
    expect(find.text('Rafi Mahmud'), findsOneWidget);
    expect(find.text('Carrying your Documents'), findsOneWidget);
    expect(find.text('৳300 held until delivery'), findsOneWidget);

    // Card 3: Dark Handover Code display card
    expect(find.text('HANDOVER CODE'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(
      find.text("Show this to Rafi at pickup. Don't share it earlier."),
      findsOneWidget,
    );
  });

  testWidgets('carrier enters handover code and confirms pickup successfully',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    // Initially says "Waiting for handover code"
    expect(find.text('Waiting for handover code'), findsOneWidget);

    // Find TextField inputs for the 4 digits
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(4));

    await tester.enterText(textFields.at(0), '4');
    await tester.enterText(textFields.at(1), '8');
    await tester.enterText(textFields.at(2), '2');
    await tester.enterText(textFields.at(3), '7');
    await tester.pumpAndSettle();

    // Tap Confirm pickup
    await tester.tap(find.byKey(const Key('confirmPickupActionBtn')));
    await tester.pumpAndSettle();

    // Status advances: Pickup Confirmed
    expect(find.text('Pickup Confirmed'), findsOneWidget);
    expect(find.text('Handover verified'), findsOneWidget);
    expect(find.text('Receiver confirms'), findsOneWidget);
  });

  testWidgets('tapping Report a problem opens report modal sheet',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dealReportProblemBtn')));
    await tester.pumpAndSettle();

    expect(find.text('Select the issue you are experiencing with this deal.'), findsOneWidget);
    expect(find.text('Submit report'), findsOneWidget);
  });
}
