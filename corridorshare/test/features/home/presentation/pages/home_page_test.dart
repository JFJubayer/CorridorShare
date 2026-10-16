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
  testWidgets('renders home page with banner, quick actions, and trips feed by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    expect(find.text('CorridorShare'), findsOneWidget);
    expect(find.byKey(const Key('postTripQuickAction')), findsOneWidget);
    expect(find.byKey(const Key('postParcelQuickAction')), findsOneWidget);
    expect(find.byKey(const Key('feedSegmentedButton')), findsOneWidget);

    // Initial feed shows seeded trips
    expect(find.byType(TripCard), findsWidgets);
    expect(find.byType(ParcelCard), findsNothing);
  });

  testWidgets('switches to parcels feed when segmented button is toggled',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildHomeHarness());
    await tester.pumpAndSettle();

    // Tap on "Parcels to Carry" segment
    await tester.tap(find.text('Parcels to Carry'));
    await tester.pumpAndSettle();

    // Now parcels feed is active
    expect(find.byType(ParcelCard), findsWidgets);
    expect(find.byType(TripCard), findsNothing);
  });
}
