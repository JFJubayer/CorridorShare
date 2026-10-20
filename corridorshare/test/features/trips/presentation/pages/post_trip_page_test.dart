import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:corridorshare/features/trips/presentation/pages/post_trip_page.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({InMemoryTripDataSource? dataSource}) {
  return ProviderScope(
    overrides: <Override>[
      if (dataSource != null)
        tripDataSourceProvider.overrideWithValue(dataSource),
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
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PostTripPage(),
    ),
  );
}

void main() {
  testWidgets('renders post trip form elements', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Post a Trip'), findsOneWidget);
    expect(find.byKey(const Key('fromDistrictDropdown')), findsOneWidget);
    expect(find.byKey(const Key('toDistrictDropdown')), findsOneWidget);
    expect(find.byKey(const Key('capacityField')), findsOneWidget);
    expect(find.byKey(const Key('submitTripButton')), findsOneWidget);
  });

  testWidgets('validates capacity input', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('capacityField')), '');
    await tester.tap(find.byKey(const Key('submitTripButton')));
    await tester.pumpAndSettle();

    expect(find.text('Enter capacity in kg'), findsOneWidget);
  });

  testWidgets('submits trip successfully on valid inputs', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final ds = InMemoryTripDataSource(initialTrips: <TripDto>[]);
    await tester.pumpWidget(_buildHarness(dataSource: ds));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('capacityField')), '7.5');
    await tester.enterText(find.byKey(const Key('fromAreaField')), 'Dhanmondi');
    await tester.enterText(find.byKey(const Key('toAreaField')), 'Agrabad');

    await tester.tap(find.byKey(const Key('submitTripButton')));
    await tester.pumpAndSettle();

    final trips = await ds.getTrips();
    expect(trips.length, 1);
    expect(trips.first.capacityKg, 7.5);
    expect(trips.first.fromArea, 'Dhanmondi');
  });

  testWidgets('preloads trip data when initialTrip is provided and saves update to database',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final initialTripDto = TripDto(
      id: 'trip-existing-1',
      travellerId: 'traveller-1',
      travellerName: 'Rafiqul Islam',
      fromDistrict: 'Dhaka',
      fromArea: 'Gulshan',
      toDistrict: 'Chattogram',
      toArea: 'GEC Circle',
      departureDate: now.add(const Duration(days: 2)).toIso8601String(),
      capacityKg: 6.0,
      bookedKg: 0.0,
      matchingParcelsCount: 1,
      noCarryTags: const <String>['liquids'],
      note: 'AC bus travelling',
      status: 'open',
      createdAt: now.toIso8601String(),
    );

    final ds = InMemoryTripDataSource(initialTrips: <TripDto>[initialTripDto]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          tripDataSourceProvider.overrideWithValue(ds),
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
          home: PostTripPage(initialTrip: initialTripDto.toDomain()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify preloaded values
    expect(find.text('Edit trip'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Gulshan'), findsOneWidget);
    expect(find.text('GEC Circle'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    // Edit capacity and notes
    await tester.enterText(find.byKey(const Key('capacityField')), '9.5');
    await tester.enterText(find.byKey(const Key('fromAreaField')), 'Banani');

    // Submit / Save
    await tester.tap(find.byKey(const Key('submitTripButton')));
    await tester.pumpAndSettle();

    // Verify updated data synced to database
    final updated = await ds.getTripById('trip-existing-1');
    expect(updated.capacityKg, 9.5);
    expect(updated.fromArea, 'Banani');
  });
}
