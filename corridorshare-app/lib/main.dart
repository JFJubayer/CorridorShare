import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'screens/admin_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/match_screen.dart';
import 'screens/messages_screen.dart';
import 'widgets/auth_modal.dart';
import 'widgets/ui.dart';

// TEMP: set to false to re-enable the sign-in gate.
const bool kDisableAuth = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final config = AppConfig.fromEnvironment();
    config.validateForStartup();
    if (config.dataMode == AppDataMode.supabase) {
      await Supabase.initialize(
        url: config.supabaseUrl!,
        publishableKey: config.supabaseAnonKey!,
      );
    }
    runApp(CorridorShareApp(config: config));
  } on Object catch (error) {
    runApp(ConfigurationErrorApp(error: error));
  }
}

class CorridorShareApp extends StatelessWidget {
  const CorridorShareApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(config: config),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: 'CorridorShare',
            debugShowCheckedModeBanner: false,
            themeMode: userProvider.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const SessionGate(),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final provider = context.read<UserProvider>();
    try {
      await provider.bootstrapSession();
      if (kDisableAuth &&
          !provider.isAuthenticated &&
          provider.dataMode == AppDataMode.demo) {
        provider.startDemoSession('01700000000');
      }
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (kDisableAuth) return const MainNavigationShell();
    return context.watch<UserProvider>().isAuthenticated
        ? const MainNavigationShell()
        : const SignInScreen();
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.alt_route, color: context.cs.onSurface, size: 32),
                const Spacer(),
                Text('CorridorShare', style: context.tt.headlineMedium),
                Gap.sm,
                Text(
                  'Post trips, agree on deals, and hold payment in escrow until delivery is confirmed.',
                  style: context.tt.bodyLarge?.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                ),
                Gap.xl,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const AuthModal(),
                    ),
                    child: const Text('Sign in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  static const _betaBannerKey = 'cs_friends_beta_banner_dismissed';
  int _currentIndex = 0;
  bool _showPrivateBetaBanner = false;
  bool _bannerReady = false;

  final List<Widget> _pages = const [
    DashboardScreen(),
    MatchScreen(),
    MessagesScreen(),
    AdminScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerPreference();
  }

  Future<void> _loadBannerPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getBool(_betaBannerKey) ?? false;
      if (!mounted) return;
      setState(() {
        _showPrivateBetaBanner = !dismissed;
        _bannerReady = true;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _showPrivateBetaBanner = true;
        _bannerReady = true;
      });
    }
  }

  Future<void> _dismissBanner() async {
    setState(() => _showPrivateBetaBanner = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_betaBannerKey, true);
    } on Object {
      // Session-only dismiss if prefs unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_bannerReady && _showPrivateBetaBanner)
            Material(
              color: context.cs.surfaceContainerLow,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Private beta. Live payments and continuous GPS are off; wallets are funded by an admin.',
                          style: context.tt.bodySmall,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _dismissBanner,
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Dismiss',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route),
            label: 'Matching',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Deals',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Safety',
          ),
        ],
      ),
    );
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CorridorShare could not start',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('$error', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
}
