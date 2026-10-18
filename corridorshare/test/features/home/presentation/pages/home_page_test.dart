import 'package:corridorshare/features/home/presentation/pages/home_page.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/parcels/presentation/widgets/parcel_card.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/trip_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHomeHarness() {
  return ProviderScope(
    overrides: <Override>[
      tripDataSourceProvider.overrideWithValue(InMemoryTripDataSource(seed: true)),
      parcelDataSourceProvider.overrideWithValue(InMemoryParcelDataSource(seed: true)),
    ],
    child: const MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    ),
  );
}

void main() {
  testWidgets('renders home page with brand, route banner, and trips feed by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    expect(find.text('CorridorShare'), findsOneWidget);
    expect(find.byKey(const Key('homeFabPlus')), findsOneWidget);

    // Initial feed shows seeded trips
    expect(find.byType(TripCard), findsWidgets);
    expect(find.byType(ParcelCard), findsNothing);
  });

  testWidgets('switches to parcels feed when toggled via sort & filter sheet',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    // Tap on sort & filter button
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    // Verify feedSegmentedButton is inside sort & filter
    expect(find.byKey(const Key('feedSegmentedButton')), findsOneWidget);

    // Tap on "Parcels to Carry" segment
    await tester.tap(find.text('Parcels to Carry'));
    await tester.pumpAndSettle();

    // Now parcels feed is active
    expect(find.byType(ParcelCard), findsWidgets);
    expect(find.byType(TripCard), findsNothing);
  });

  testWidgets('tapping floating action button (+ icon) opens speed dial capsule with post options',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    // Find and tap the FAB (+ icon)
    final fabFinder = find.byKey(const Key('homeFabPlus'));
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Verify speed dial options display and align horizontally with FAB
    final postTripFinder = find.byKey(const Key('postTripQuickAction'));
    final postParcelFinder = find.byKey(const Key('postParcelQuickAction'));
    expect(postTripFinder, findsOneWidget);
    expect(postParcelFinder, findsOneWidget);
    final fabRect = tester.getRect(fabFinder);
    final postTripRect = tester.getRect(postTripFinder);
    final postParcelRect = tester.getRect(postParcelFinder);
    // Both speed dial options should be right-aligned with the FAB
    expect(postTripRect.right, equals(fabRect.right));
    expect(postParcelRect.right, equals(fabRect.right));
  });

  testWidgets('tapping sort button opens sort sheet with date sorting options',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    // Tap the sort icon button
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    // Verify sort sheet options
    expect(find.text('Sort & Filter'), findsOneWidget);
    expect(find.text('Date: Earliest First'), findsOneWidget);
    expect(find.text('Date: Latest First'), findsOneWidget);

    // Select earliest first
    await tester.tap(find.text('Date: Earliest First'));
    await tester.pumpAndSettle();

    // Sort sheet closes and items are still visible
    expect(find.byType(TripCard), findsWidgets);
  });

  testWidgets('tapping Change button in corridor banner opens corridor selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    // Tap the Change button
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    // Verify corridor options
    expect(find.text('Select Travel Corridor'), findsOneWidget);
    expect(find.text('All Corridors (Show Everything)'), findsOneWidget);
  });
}
