import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/delivery/data/datasources/in_memory_delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/models/delivery_dto.dart';
import 'package:corridorshare/features/delivery/presentation/pages/delivery_tracking_page.dart';
import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/pickup_handover_sheet.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/report_dispute_dialog.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/verify_handover_dialog.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({
  required String deliveryId,
  InMemoryDeliveryDataSource? deliveryDataSource,
}) {
  return ProviderScope(
    overrides: <Override>[
      deliveryDataSourceProvider.overrideWithValue(
        deliveryDataSource ?? InMemoryDeliveryDataSource(seed: true),
      ),
      currentUserProvider.overrideWithValue(
        const AuthUser(
          id: 'traveller-1',
          phone: '+8801700000000',
          name: 'Rafiqul Islam',
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
      home: DeliveryTrackingPage(deliveryId: deliveryId),
    ),
  );
}

void main() {
  testWidgets('renders delivery tracking timeline, corridor summary, and actions',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(deliveryId: 'delivery-1'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Delivery Tracking'), findsOneWidget);
    expect(find.text('Original Academic Transcripts'), findsOneWidget);
    expect(find.text('Dhaka → Chattogram'), findsOneWidget);
    expect(find.text('৳ 450'), findsOneWidget);

    // Timeline steps
    expect(find.text('Matched & Agreed'), findsWidgets);
    expect(find.text('In Transit'), findsWidgets);
    expect(find.text('Delivered'), findsWidgets);

    // Confirm Pickup button is visible for traveller on matched delivery
    expect(find.byKey(const Key('openPickupSheetButton')), findsOneWidget);
  });

  testWidgets('traveller confirms pickup handover through modal sheet',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final ds = InMemoryDeliveryDataSource(seed: true);
    await tester.pumpWidget(
      _buildHarness(deliveryId: 'delivery-1', deliveryDataSource: ds),
    );
    await tester.pumpAndSettle();

    // Tap Confirm Pickup
    await tester.tap(find.byKey(const Key('openPickupSheetButton')));
    await tester.pumpAndSettle();

    // PickupHandoverSheet is displayed
    expect(find.byType(PickupHandoverSheet), findsOneWidget);
    expect(find.text('Confirm Parcel Pickup'), findsOneWidget);
    expect(find.byKey(const Key('confirmPickupButton')), findsOneWidget);

    // Enter notes and submit
    await tester.enterText(
      find.byKey(const Key('pickupNotesField')),
      'Package verified clean and sealed.',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('confirmPickupButton')));
    await tester.pumpAndSettle();

    // Sheet dismissed and button changed to Complete Handover
    expect(find.byType(PickupHandoverSheet), findsNothing);
    expect(find.byKey(const Key('openVerifyDialogButton')), findsOneWidget);
  });

  testWidgets('traveller enters 4-digit PIN to complete delivery',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final ds = InMemoryDeliveryDataSource(
      initialDeliveries: [
        DeliveryDto(
          id: 'delivery-transit',
          parcelId: 'parcel-1',
          tripId: 'trip-1',
          senderId: 'sender-demo-1',
          senderName: 'Tanvir Ahmed',
          travellerId: 'traveller-1',
          travellerName: 'Rafiqul Islam',
          parcelTitle: 'Original Academic Transcripts',
          fromDistrict: 'Dhaka',
          toDistrict: 'Chattogram',
          agreedPrice: 450.0,
          status: 'inTransit',
          verificationPin: '4192',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(deliveryId: 'delivery-transit', deliveryDataSource: ds),
    );
    await tester.pumpAndSettle();

    // Tap Complete Handover
    await tester.tap(find.byKey(const Key('openVerifyDialogButton')));
    await tester.pumpAndSettle();

    // VerifyHandoverDialog is displayed
    expect(find.byType(VerifyHandoverDialog), findsOneWidget);
    expect(find.byKey(const Key('handoverPinField')), findsOneWidget);

    // Enter correct 4-digit PIN
    await tester.enterText(find.byKey(const Key('handoverPinField')), '4192');
    await tester.pump();

    // Submit PIN
    await tester.tap(find.byKey(const Key('submitHandoverPinButton')));
    await tester.pumpAndSettle();

    // Dialog is closed
    expect(find.byType(VerifyHandoverDialog), findsNothing);
    // Verification action button disappears as delivery is now completed
    expect(find.byKey(const Key('openVerifyDialogButton')), findsNothing);
  });

  testWidgets('logs dispute through dispute dialog',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final ds = InMemoryDeliveryDataSource(seed: true);
    await tester.pumpWidget(
      _buildHarness(deliveryId: 'delivery-1', deliveryDataSource: ds),
    );
    await tester.pumpAndSettle();

    // Tap Report Dispute
    await tester.tap(find.byKey(const Key('openDisputeDialogButton')));
    await tester.pumpAndSettle();

    expect(find.byType(ReportDisputeDialog), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('disputeReasonField')),
      'Sender gave incorrect phone contact.',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('submitDisputeButton')));
    await tester.pumpAndSettle();

    expect(find.byType(ReportDisputeDialog), findsNothing);
    // Dispute banner is shown in timeline
    expect(find.text('Dispute Raised'), findsOneWidget);
    expect(find.text('Sender gave incorrect phone contact.'), findsOneWidget);
  });
}
