import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/presentation/pages/my_parcels_page.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _buildMyParcelsHarness({
  InMemoryParcelDataSource? parcelDataSource,
  InMemoryTripDataSource? tripDataSource,
  AuthUser? user,
}) {
  final router = GoRouter(
    initialLocation: '/my-parcels',
    routes: <RouteBase>[
      GoRoute(
        path: '/my-parcels',
        builder: (_, __) => const MyParcelsPage(),
      ),
      GoRoute(
        path: '/trips/new',
        builder: (_, __) => const Scaffold(body: Text('New Trip Screen')),
      ),
      GoRoute(
        path: '/parcels/new',
        builder: (_, __) => const Scaffold(body: Text('New Parcel Screen')),
      ),
      GoRoute(
        path: '/match',
        builder: (_, __) => const Scaffold(body: Text('Match Screen')),
      ),
      GoRoute(
        path: '/offers',
        builder: (_, __) => const Scaffold(body: Text('Offers Screen')),
      ),
      GoRoute(
        path: '/deliveries/:id',
        builder: (_, __) => const Scaffold(body: Text('Delivery Detail Screen')),
      ),
      GoRoute(
        path: '/deals',
        builder: (_, __) => const Scaffold(body: Text('Deals Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: <Override>[
      if (parcelDataSource != null)
        parcelDataSourceProvider.overrideWithValue(parcelDataSource),
      if (tripDataSource != null)
        tripDataSourceProvider.overrideWithValue(tripDataSource),
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
        return MaterialApp.router(
          routerConfig: router,
          locale: locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    ),
  );
}

void main() {
  testWidgets('renders empty state when no parcels are sent (no dummy data)',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final emptyDataSource = InMemoryParcelDataSource();

    await tester.pumpWidget(_buildMyParcelsHarness(parcelDataSource: emptyDataSource));
    await tester.pumpAndSettle();

    // Header
    expect(find.text('My parcels'), findsOneWidget);
    expect(find.byKey(const Key('langBnButton')), findsOneWidget);
    expect(find.byKey(const Key('langEnButton')), findsOneWidget);

    // Segmented Tabs
    expect(find.byKey(const Key('tabSending')), findsOneWidget);
    expect(find.byKey(const Key('tabCarrying')), findsOneWidget);

    // Empty state - verify NO dummy parcels
    expect(find.text('No parcels sent yet'), findsOneWidget);
    expect(find.byKey(const Key('postParcelEmptyButton')), findsOneWidget);
    expect(find.text('Documents · 1.2 kg'), findsNothing);
    expect(find.text('Gift box · 2 kg'), findsNothing);

    // Tap Post a parcel
    await tester.tap(find.byKey(const Key('postParcelEmptyButton')));
    await tester.pumpAndSettle();

    expect(find.text('New Parcel Screen'), findsOneWidget);
  });

  testWidgets('renders real parcel cards when user has posted parcels',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final realDataSource = InMemoryParcelDataSource(
      initialParcels: [
        ParcelDto(
          id: 'real-parcel-1',
          senderId: 'user-1',
          senderName: 'Tanvir Ahmed',
          title: 'Jamdani Saree',
          fromDistrict: 'Dhaka',
          fromArea: 'Dhanmondi',
          toDistrict: 'Chattogram',
          toArea: 'Agrabad',
          weightKg: 1.5,
          size: 'medium',
          deadline: now.add(const Duration(days: 2)).toIso8601String(),
          offeredPrice: 500.0,
          status: 'open',
          createdAt: now.toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(_buildMyParcelsHarness(parcelDataSource: realDataSource));
    await tester.pumpAndSettle();

    expect(find.text('Jamdani Saree · 1.5 kg'), findsOneWidget);
    expect(find.textContaining('Dhaka → Chattogram'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('৳500'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('View offers'), findsOneWidget);
  });

  testWidgets('switching to Carrying tab displays empty state and Post a trip button',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildMyParcelsHarness());
    await tester.pumpAndSettle();

    // Tap Carrying segment
    await tester.tap(find.byKey(const Key('tabCarrying')));
    await tester.pumpAndSettle();

    // Empty state assertions matching Image 1
    expect(find.text('No trips carried yet'), findsOneWidget);
    expect(
      find.text('Post a trip you already plan to make and\ncarry parcels to earn.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('postTripEmptyButton')), findsOneWidget);

    // Tap Post a trip
    await tester.tap(find.byKey(const Key('postTripEmptyButton')));
    await tester.pumpAndSettle();

    expect(find.text('New Trip Screen'), findsOneWidget);
  });

  testWidgets('tapping Open deal on matched parcel navigates to Deals screen',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final matchedDataSource = InMemoryParcelDataSource(
      initialParcels: <ParcelDto>[
        ParcelDto(
          id: 'parcel-matched-1',
          senderId: 'user-1',
          senderName: 'Tanvir Ahmed',
          title: 'Books and Documents',
          fromDistrict: 'Dhaka',
          fromArea: 'Uttara',
          toDistrict: 'Chattogram',
          toArea: 'Agrabad',
          categoryTags: const <String>['documents'],
          weightKg: 1.5,
          size: 'small',
          deadline: DateTime(2026, 10, 24, 18, 0).toIso8601String(),
          offeredPrice: 500.0,
          status: 'matched',
          hasProhibitedItemsDeclaration: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(_buildMyParcelsHarness(parcelDataSource: matchedDataSource));
    await tester.pumpAndSettle();

    expect(find.text('Books and Documents · 1.5 kg'), findsOneWidget);
    expect(find.text('Open deal'), findsOneWidget);

    // Tap Open deal
    await tester.tap(find.text('Open deal'));
    await tester.pumpAndSettle();

    // Verify it navigated to Deals Screen
    expect(find.text('Deals Screen'), findsOneWidget);
  });
}

