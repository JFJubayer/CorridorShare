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
}
