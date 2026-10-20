import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/my_posts/presentation/pages/my_posts_page.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _buildMyPostsHarness({
  InMemoryParcelDataSource? parcelDataSource,
  InMemoryTripDataSource? tripDataSource,
  AuthUser? user,
}) {
  final router = GoRouter(
    initialLocation: '/posts',
    routes: <RouteBase>[
      GoRoute(
        path: '/posts',
        builder: (_, __) => const MyPostsPage(),
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

    await tester.pumpWidget(_buildMyPostsHarness(parcelDataSource: emptyDataSource));
    await tester.pumpAndSettle();

    // Header
    expect(find.text('My parcels'), findsOneWidget);
    expect(find.byKey(const Key('langBnButton')), findsOneWidget);
    expect(find.byKey(const Key('langEnButton')), findsOneWidget);

    // Segmented Tabs
    expect(find.byKey(const Key('tabSending')), findsOneWidget);
    expect(find.byKey(const Key('tabCarrying')), findsOneWidget);

    // Verify empty state is displayed and no dummy parcels appear
    expect(find.text('No parcels sent yet'), findsOneWidget);
    expect(find.text('Documents · 1.2 kg'), findsNothing);
  });

  testWidgets('renders parcel cards and actions when user has parcels',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final parcelDs = InMemoryParcelDataSource(
      initialParcels: [
        ParcelDto(
          id: 'parcel-test-1',
          senderId: 'user-1',
          senderName: 'Tanvir Ahmed',
          title: 'Documents',
          fromDistrict: 'Dhaka',
          fromArea: 'Farmgate',
          toDistrict: 'Mymensingh',
          toArea: 'Town',
          weightKg: 1.2,
          size: 'small',
          deadline: now.add(const Duration(days: 3)).toIso8601String(),
          offeredPrice: 350.0,
          status: 'open',
          createdAt: now.toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(_buildMyPostsHarness(parcelDataSource: parcelDs));
    await tester.pumpAndSettle();

    expect(find.text('Documents · 1.2 kg'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('৳350'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('View offers'), findsOneWidget);
  });

  testWidgets('switching to Carrying tab displays empty state and Post a trip button',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildMyPostsHarness());
    await tester.pumpAndSettle();

    // Tap Carrying segment
    await tester.tap(find.byKey(const Key('tabCarrying')));
    await tester.pumpAndSettle();

    // Empty state assertions
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
}
