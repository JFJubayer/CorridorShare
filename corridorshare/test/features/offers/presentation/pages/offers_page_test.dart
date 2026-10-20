import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/data/models/offer_dto.dart';
import 'package:corridorshare/features/offers/presentation/pages/offers_page.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildOffersHarness({
  Parcel? parcel,
  String? parcelId,
  InMemoryOfferDataSource? offerDataSource,
  InMemoryParcelDataSource? parcelDataSource,
}) {
  final offerDs = offerDataSource ?? InMemoryOfferDataSource(seed: true);
  final parcelDs = parcelDataSource ?? InMemoryParcelDataSource(seed: true);

  return ProviderScope(
    overrides: <Override>[
      offerDataSourceProvider.overrideWithValue(offerDs),
      parcelDataSourceProvider.overrideWithValue(parcelDs),
      currentUserProvider.overrideWithValue(
        const AuthUser(
          id: 'sender-1',
          phone: '+8801700000000',
          name: 'Tanvir Ahmed',
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
      home: OffersPage(
        parcel: parcel,
        parcelId: parcelId,
      ),
    ),
  );
}

void main() {
  final sampleParcel = Parcel(
    id: 'parcel-documents',
    senderId: 'sender-1',
    senderName: 'Tanvir Ahmed',
    title: 'Documents',
    fromDistrict: 'Dhaka',
    fromArea: 'Uttara',
    toDistrict: 'Mymensingh',
    toArea: 'Town Hall',
    weightKg: 1.2,
    size: ParcelSize.small,
    deadline: DateTime(2026, 10, 24, 9, 0),
    offeredPrice: 350,
    status: ParcelStatus.open,
    createdAt: DateTime(2026, 10, 18),
  );

  testWidgets('renders parcel summary header card and 3 offers from seed data',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildOffersHarness(parcel: sampleParcel));
    await tester.pumpAndSettle();

    // Verify parcel summary card
    expect(find.text('Documents · 1.2 kg'), findsOneWidget);
    expect(find.text('Dhaka → Mymensingh'), findsOneWidget);
    expect(find.text('Budget ৳350'), findsOneWidget);

    // Verify section header: 3 OFFERS
    expect(find.text('3 OFFERS'), findsOneWidget);

    // Verify Offer 1: Rafi Mahmud
    expect(find.text('Rafi Mahmud'), findsOneWidget);
    expect(find.text('RM'), findsOneWidget);
    expect(find.text('★ 4.9 · 48 trips'), findsOneWidget);
    expect(find.text('৳300'), findsOneWidget);
    expect(find.text('No liquids'), findsNWidgets(2)); // Card 1 and Card 3
    expect(find.text('No fragile'), findsOneWidget);

    // Verify Offer 2: Nila Akter
    expect(find.text('Nila Akter'), findsOneWidget);
    expect(find.text('NA'), findsOneWidget);
    expect(find.text('★ 4.7 · 31 trips'), findsOneWidget);
    expect(find.text('৳320'), findsOneWidget);
    expect(find.text('No electronics'), findsOneWidget);

    // Verify Offer 3: Sabbir Hasan
    expect(find.text('Sabbir Hasan'), findsOneWidget);
    expect(find.text('SH'), findsOneWidget);
    expect(find.text('★ 4.2 · 6 trips · Unverified'), findsOneWidget);
    expect(find.text('৳280'), findsOneWidget);

    // Verify action buttons exist for cards
    expect(find.text('Accept'), findsNWidgets(3));
    expect(find.text('Counter-offer'), findsNWidgets(3));
  });

  testWidgets('tapping Counter-offer opens bottom sheet matching Screenshot 2',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildOffersHarness(parcel: sampleParcel));
    await tester.pumpAndSettle();

    // Tap Counter-offer on first offer (Rafi Mahmud)
    final counterBtn = find.byKey(const Key('counterOfferButton_offer-rafi'));
    expect(counterBtn, findsOneWidget);
    await tester.tap(counterBtn);
    await tester.pumpAndSettle();

    // Verify bottom sheet title and subtitle
    expect(find.text('Counter-offer to Rafi'), findsOneWidget);
    expect(find.text('Rafi asked ৳300 · your budget ৳350'), findsOneWidget);
    expect(find.text('YOUR PRICE (BDT)'), findsOneWidget);
    expect(find.text('Fair prices get accepted faster.'), findsOneWidget);

    // Verify default price in input is 280
    expect(find.byKey(const Key('counterPriceField')), findsOneWidget);
    expect(find.text('280'), findsWidgets);

    // Verify suggested chips: ৳250, ৳280, ৳300
    expect(find.text('৳250'), findsOneWidget);
    expect(find.text('৳280'), findsWidgets);
    expect(find.text('৳300'), findsWidgets);

    // Tap ৳250 chip
    await tester.tap(find.byKey(const Key('priceChip_250')));
    await tester.pumpAndSettle();

    // Verify Send counter-offer button
    expect(find.byKey(const Key('sendCounterOfferButton')), findsOneWidget);
    await tester.tap(find.byKey(const Key('sendCounterOfferButton')));
    await tester.pumpAndSettle();

    // Sheet dismissed and snackbar shown
    expect(find.text('Counter-offer sent successfully!'), findsOneWidget);
  });

  testWidgets('renders empty state matching Screenshot 1 when no offers exist',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Empty offer datasource with no offers
    final emptyOfferDs = InMemoryOfferDataSource(initialOffers: <OfferDto>[]);
    final emptyParcel = sampleParcel.copyWith(id: 'parcel-empty');

    await tester.pumpWidget(
      _buildOffersHarness(
        parcel: emptyParcel,
        offerDataSource: emptyOfferDs,
      ),
    );
    await tester.pumpAndSettle();

    // Verify parcel summary card still visible
    expect(find.text('Documents · 1.2 kg'), findsOneWidget);
    expect(find.text('Dhaka → Mymensingh'), findsOneWidget);
    expect(find.text('Budget ৳350'), findsOneWidget);

    // Verify empty state text matching Screenshot 1
    expect(find.text('No offers yet'), findsOneWidget);
    expect(
      find.text(
        "Travellers on this route can see your parcel. We'll notify you when someone makes an offer.",
      ),
      findsOneWidget,
    );

    // Verify buttons
    expect(find.byKey(const Key('editParcelButton')), findsOneWidget);
    expect(find.byKey(const Key('raiseBudgetButton')), findsOneWidget);

    // Tap Raise budget
    await tester.tap(find.byKey(const Key('raiseBudgetButton')));
    await tester.pumpAndSettle();

    // Verify Raise budget sheet opened
    expect(find.text('Raise parcel budget'), findsOneWidget);
    expect(find.byKey(const Key('confirmRaiseBudgetButton')), findsOneWidget);

    // Tap Update budget
    await tester.tap(find.byKey(const Key('confirmRaiseBudgetButton')));
    await tester.pumpAndSettle();

    // Budget updated to ৳400
    expect(find.text('Budget ৳400'), findsOneWidget);
  });

  testWidgets('semantics tree builds without assertion error in empty state',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();

    final emptyOfferDs = InMemoryOfferDataSource(initialOffers: <OfferDto>[]);
    final emptyParcel = sampleParcel.copyWith(id: 'parcel-empty');

    await tester.pumpWidget(
      _buildOffersHarness(
        parcel: emptyParcel,
        offerDataSource: emptyOfferDs,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No offers yet'), findsOneWidget);
    expect(find.byKey(const Key('editParcelButton')), findsOneWidget);
    expect(find.byKey(const Key('raiseBudgetButton')), findsOneWidget);

    handle.dispose();
  });
}
