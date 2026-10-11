import 'package:corridorshare/core/router/app_shell.dart';
import 'package:corridorshare/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:corridorshare/features/auth/presentation/pages/phone_entry_page.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/presentation/pages/chats_page.dart';
import 'package:corridorshare/features/home/presentation/pages/home_page.dart';
import 'package:corridorshare/features/my_posts/presentation/pages/my_posts_page.dart';
import 'package:corridorshare/features/profile/presentation/pages/profile_page.dart';
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
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final AuthListenable listenable = AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.auth,
    refreshListenable: listenable,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String location = state.matchedLocation;
      final bool atAuth = location == AppRoutes.auth ||
          location == AppRoutes.otp;

      if (auth is AuthInitial) {
        return null;
      }
      if (!auth.isAuthenticated && !atAuth) {
        return AppRoutes.auth;
      }
      if (auth is AuthOtpRequested && location != AppRoutes.otp) {
        return AppRoutes.otp;
      }
      if (auth is AuthAuthenticated &&
          (location == AppRoutes.auth || location == AppRoutes.otp)) {
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod's [authControllerProvider] to [GoRouter]'s
/// [Listenable] contract so redirects re-run when the user signs in or out.
class AuthListenable extends ChangeNotifier {
  AuthListenable(this._ref) {
    _sub = _ref.listen<AuthState>(authControllerProvider, (AuthState? _, AuthState _) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}