import 'package:corridorshare/core/router/app_shell.dart';
import 'package:corridorshare/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:corridorshare/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:corridorshare/features/auth/presentation/pages/phone_entry_page.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/presentation/pages/chat_conversation_page.dart';
import 'package:corridorshare/features/chats/presentation/pages/chats_page.dart';
import 'package:corridorshare/features/deals/presentation/pages/deals_page.dart';
import 'package:corridorshare/features/delivery/presentation/pages/delivery_tracking_page.dart';
import 'package:corridorshare/features/home/presentation/pages/home_page.dart';
import 'package:corridorshare/features/matching/presentation/pages/match_screen.dart';
import 'package:corridorshare/features/my_posts/presentation/pages/my_posts_page.dart';
import 'package:corridorshare/features/offers/presentation/pages/offers_page.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/presentation/pages/my_parcels_page.dart';
import 'package:corridorshare/features/parcels/presentation/pages/post_parcel_page.dart';
import 'package:corridorshare/features/profile/presentation/pages/profile_page.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/presentation/pages/post_trip_page.dart';
import 'package:corridorshare/features/wallet/presentation/pages/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  const AppRoutes._();

  static const String auth = '/auth';
  static const String otp = '/auth/otp';
  static const String home = '/home';
  static const String myPosts = '/posts';
  static const String chats = '/chats';
  static const String profile = '/profile';
  static const String myParcels = '/my-parcels';
  static const String wallet = '/wallet';
  static const String newTrip = '/trips/new';
  static const String newParcel = '/parcels/new';
  static const String match = '/match';
  static const String offers = '/offers';
  static const String deals = '/deals';
  static const String dealDetail = '/deals/:id';
  static const String chatDetail = '/chats/:id';
  static const String deliveryDetail = '/deliveries/:id';
  static const String admin = '/admin';
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (AuthState? prev, AuthState next) {
        if (prev?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }
  final Ref _ref;
}

/// App router.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final AuthRouterNotifier notifier = AuthRouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.auth,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState authState = ref.read(authControllerProvider);
      final bool isAuthRoute = state.matchedLocation.startsWith(AppRoutes.auth);

      if (!authState.isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.auth;
      }

      if (isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.auth,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const PhoneEntryPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'otp',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (BuildContext context, GoRouterState state) =>
                const OtpVerificationPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.newTrip,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            PostTripPage(
              initialTrip: state.extra as Trip?,
              tripId: state.uri.queryParameters['tripId'],
            ),
      ),
      GoRoute(
        path: AppRoutes.newParcel,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const PostParcelPage(),
      ),
      GoRoute(
        path: AppRoutes.match,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) => MatchScreen(
          tripId: state.uri.queryParameters['tripId'],
          parcelId: state.uri.queryParameters['parcelId'],
          fromDistrict: state.uri.queryParameters['fromDistrict'],
          toDistrict: state.uri.queryParameters['toDistrict'],
        ),
      ),
      GoRoute(
        path: AppRoutes.offers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) => OffersPage(
          parcelId: state.uri.queryParameters['parcelId'],
          parcel: state.extra as Parcel?,
        ),
      ),
      GoRoute(
        path: AppRoutes.deals,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) => DealsPage(
          initialRole: state.uri.queryParameters['role'],
        ),
      ),
      GoRoute(
        path: AppRoutes.dealDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) => DealsPage(
          dealId: state.pathParameters['id'],
          initialRole: state.uri.queryParameters['role'],
        ),
      ),
      GoRoute(
        path: AppRoutes.chatDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            ChatConversationPage(
          offerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.deliveryDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            DeliveryTrackingPage(
          deliveryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.admin,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const AdminDashboardPage(),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state,
                StatefulNavigationShell shell) =>
            AppShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.myPosts,
                builder: (BuildContext context, GoRouterState state) =>
                    const MyPostsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.chats,
                builder: (BuildContext context, GoRouterState state) =>
                    const ChatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfilePage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'wallet',
                    builder: (BuildContext context, GoRouterState state) =>
                        const WalletPage(),
                  ),
                  GoRoute(
                    path: 'parcels',
                    builder: (BuildContext context, GoRouterState state) =>
                        const MyParcelsPage(),
                  ),
                ],
              ),
              GoRoute(
                path: AppRoutes.myParcels,
                builder: (BuildContext context, GoRouterState state) =>
                    const MyParcelsPage(),
              ),
              GoRoute(
                path: AppRoutes.wallet,
                builder: (BuildContext context, GoRouterState state) =>
                    const WalletPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});