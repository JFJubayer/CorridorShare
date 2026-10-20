import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/matching/presentation/pages/match_screen.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({String? tripId, String? parcelId}) {
  return ProviderScope(
    overrides: <Override>[
      tripDataSourceProvider.overrideWithValue(InMemoryTripDataSource(seed: true)),
      parcelDataSourceProvider.overrideWithValue(InMemoryParcelDataSource(seed: true)),
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
      home: MatchScreen(
        tripId: tripId,
        parcelId: parcelId,
      ),
    ),
  );
}

void main() {
  testWidgets('renders Parcels on your trip screen matching Figma Screenshot 2',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(tripId: 'trip-mymensingh'));
    await tester.pumpAndSettle();

    // Verify page header
    expect(find.text('Parcels on your trip'), findsOneWidget);

    // Verify trip card header
    expect(find.text('Dhaka → Mymensingh'), findsOneWidget);
    expect(find.text('Edit trip'), findsOneWidget);
    expect(find.textContaining('2.8 kg free'), findsOneWidget);
    expect(find.text("YOU WON'T CARRY"), findsOneWidget);
    expect(find.text('Liquids'), findsOneWidget);
    expect(find.text('Fragile'), findsOneWidget);

    // Verify filter chips
    expect(find.text('Best match'), findsWidgets);
    expect(find.text('Highest pay'), findsOneWidget);
    expect(find.text('Lightest'), findsOneWidget);

    // Verify matching parcels
    expect(find.text('Documents · 1.2 kg'), findsOneWidget);
    expect(find.text('৳350'), findsOneWidget);
    expect(find.text('Uttara → Mymensingh Sadar'), findsOneWidget);
    expect(find.textContaining('Nila Akter'), findsOneWidget);
    expect(find.text('On your route'), findsWidgets);
    expect(find.text('Fits 2.8 kg'), findsWidgets);

    expect(find.text('Books · 2.5 kg'), findsOneWidget);
    expect(find.text('৳380'), findsOneWidget);
    expect(find.text('Banani → Mymensingh Sadar'), findsOneWidget);
    expect(find.textContaining('Imran Khan'), findsOneWidget);

    expect(find.text('Clothes · 1.5 kg'), findsOneWidget);
    expect(find.text('৳300'), findsOneWidget);
    expect(find.text('Gulshan → Muktagacha'), findsOneWidget);
    expect(find.textContaining('Mitu Sultana'), findsOneWidget);
    expect(find.text('Detour 20 km'), findsOneWidget);

    // Verify buttons
    expect(find.text('Make offer'), findsNWidgets(3));

    // Verify hidden banner
    expect(
      find.text('2 parcels hidden: they contain items you won\'t carry.'),
      findsOneWidget,
    );
    expect(find.text('Show'), findsOneWidget);
  });

  testWidgets('tapping Show toggles visibility of restricted hidden parcels',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(tripId: 'trip-mymensingh'));
    await tester.pumpAndSettle();

    // Tap Show button
    await tester.tap(find.byKey(const Key('toggleHiddenParcelsButton')));
    await tester.pumpAndSettle();

    // Verify hidden items are revealed
    expect(find.text('HIDDEN DUE TO RESTRICTIONS'), findsOneWidget);
    expect(find.text('Mustard Oil & Ghee Jar · 2.0 kg'), findsOneWidget);
    expect(find.text('Clay Handicrafts & Crockery · 1.8 kg'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);

    // Tap Hide
    await tester.tap(find.byKey(const Key('toggleHiddenParcelsButton')));
    await tester.pumpAndSettle();

    expect(find.text('Show'), findsOneWidget);
  });

  testWidgets('tapping Make offer opens MakeOfferSheet with no-carry alert',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(tripId: 'trip-mymensingh'));
    await tester.pumpAndSettle();

    // Tap Make offer on Nila's parcel
    final makeOfferBtn = find.byKey(const Key('makeOfferButton_parcel-match-nila'));
    expect(makeOfferBtn, findsOneWidget);
    await tester.tap(makeOfferBtn);
    await tester.pumpAndSettle();

    // MakeOfferSheet is visible
    expect(find.byType(MakeOfferSheet), findsOneWidget);

    // Verify traveller's no-carry restrictions are explicitly shown
    expect(find.textContaining('Traveller will NOT carry:'), findsOneWidget);
    expect(find.textContaining('liquids'), findsOneWidget);
  });

  testWidgets('renders matching travellers for a selected parcel',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(parcelId: 'parcel-1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Matching Travellers'), findsOneWidget);
    expect(find.textContaining('Make an Offer'), findsWidgets);
  });

  testWidgets('auto matches parcels along travel route given fromDistrict and toDistrict',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        tripDataSourceProvider.overrideWithValue(InMemoryTripDataSource(seed: true)),
        parcelDataSourceProvider.overrideWithValue(InMemoryParcelDataSource(seed: true)),
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
        home: MatchScreen(
          fromDistrict: 'Dhaka',
          toDistrict: 'Mymensingh',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Dhaka → Mymensingh'), findsOneWidget);
    expect(find.text('Best match'), findsWidgets);
    expect(find.text('Documents · 1.2 kg'), findsOneWidget);
    expect(find.text('Clothes · 1.5 kg'), findsOneWidget);
    expect(find.text('Detour 20 km'), findsOneWidget);
  });

  testWidgets('displays Access Restricted screen when non-owner accesses trip match screen',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Current user is "other-user" who does NOT own trip "trip-other"
    final foreignTrip = InMemoryTripDataSource(
      initialTrips: [
        TripDto(
          id: 'trip-other',
          travellerId: 'traveller-owner-123',
          travellerName: 'Other Traveller',
          fromDistrict: 'Dhaka',
          fromArea: 'Uttara',
          toDistrict: 'Sylhet',
          toArea: 'Zindabazar',
          departureDate: DateTime(2026, 10, 25, 7, 30).toIso8601String(),
          capacityKg: 5.0,
          bookedKg: 0.0,
          matchingParcelsCount: 2,
          noCarryTags: const <String>[],
          status: 'open',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        tripDataSourceProvider.overrideWithValue(foreignTrip),
        currentUserProvider.overrideWithValue(
          const AuthUser(
            id: 'unauthorized-intruder-999',
            email: 'intruder@example.com',
            phone: '+8801700000999',
            name: 'Intruder User',
            verified: true,
            ratingAvg: 5.0,
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
        home: MatchScreen(tripId: 'trip-other'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('Unauthorized Trip Matching'), findsOneWidget);
    expect(find.textContaining('Only the traveller who posted this trip is authorized'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets('displays Access Restricted screen when non-owner accesses parcel match screen',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final foreignParcel = InMemoryParcelDataSource(
      initialParcels: [
        ParcelDto(
          id: 'parcel-other',
          senderId: 'sender-owner-123',
          senderName: 'Other Sender',
          title: 'Special Documents',
          fromDistrict: 'Dhaka',
          fromArea: 'Uttara',
          toDistrict: 'Sylhet',
          toArea: 'Zindabazar',
          categoryTags: const <String>['documents'],
          weightKg: 1.0,
          size: 'small',
          deadline: DateTime(2026, 10, 26, 18, 0).toIso8601String(),
          offeredPrice: 400.0,
          status: 'open',
          hasProhibitedItemsDeclaration: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        parcelDataSourceProvider.overrideWithValue(foreignParcel),
        currentUserProvider.overrideWithValue(
          const AuthUser(
            id: 'unauthorized-intruder-999',
            email: 'intruder@example.com',
            phone: '+8801700000999',
            name: 'Intruder User',
            verified: true,
            ratingAvg: 5.0,
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
        home: MatchScreen(parcelId: 'parcel-other'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('Unauthorized Parcel Matching'), findsOneWidget);
    expect(find.textContaining('Only the sender who posted this parcel is authorized'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets(
      'making an offer updates matched parcel state to show Open chat button only and Offer sent badge',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(tripId: 'trip-mymensingh'));
    await tester.pumpAndSettle();

    // Initially, parcel-match-nila has Make offer button and chat button
    expect(find.byKey(const Key('makeOfferButton_parcel-match-nila')), findsOneWidget);
    expect(find.byKey(const Key('chatParcelButton_parcel-match-nila')), findsOneWidget);
    expect(find.byKey(const Key('openChatButton_parcel-match-nila')), findsNothing);

    // Tap Make offer
    await tester.tap(find.byKey(const Key('makeOfferButton_parcel-match-nila')));
    await tester.pumpAndSettle();

    // Verify sheet is visible
    expect(find.byType(MakeOfferSheet), findsOneWidget);

    // Submit the offer
    await tester.tap(find.byKey(const Key('submitOfferButton')));
    await tester.pumpAndSettle();

    // MakeOfferSheet should be closed
    expect(find.byType(MakeOfferSheet), findsNothing);

    // Now, parcel-match-nila card state should be updated:
    // It should have open chat button ONLY
    expect(find.byKey(const Key('openChatButton_parcel-match-nila')), findsOneWidget);
    expect(find.text('Open chat'), findsOneWidget);
    expect(find.text('Offer sent'), findsOneWidget);

    // Make offer and separate icon button for this parcel should no longer exist
    expect(find.byKey(const Key('makeOfferButton_parcel-match-nila')), findsNothing);
    expect(find.byKey(const Key('chatParcelButton_parcel-match-nila')), findsNothing);

    // Remaining other 2 parcels still have Make offer buttons
    expect(find.text('Make offer'), findsNWidgets(2));
  });
}

