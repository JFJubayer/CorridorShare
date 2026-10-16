import 'package:corridorshare/features/matching/presentation/pages/match_screen.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
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
  testWidgets('renders compatible parcels for a selected trip',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(tripId: 'trip-1'));
    await tester.pumpAndSettle();

    // Verify header and matched parcel
    expect(find.textContaining('Compatible Parcels'), findsOneWidget);
    expect(find.text('Original Academic Transcripts'), findsOneWidget);
    expect(find.textContaining('Make an Offer'), findsOneWidget);
  });

  testWidgets('tapping Make an Offer opens MakeOfferSheet with no-carry alert',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(tripId: 'trip-1'));
    await tester.pumpAndSettle();

    // Tap Make an Offer button
    await tester.tap(find.textContaining('Make an Offer'));
    await tester.pumpAndSettle();

    // MakeOfferSheet is visible
    expect(find.byType(MakeOfferSheet), findsOneWidget);

    // Verify traveller's no-carry restrictions are explicitly shown
    expect(find.textContaining('Traveller will NOT carry:'), findsOneWidget);
    expect(find.textContaining('liquid'), findsOneWidget);
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
}
