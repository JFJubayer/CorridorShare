import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_colors.dart';
import 'providers/user_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/match_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/admin_screen.dart';
import 'widgets/auth_modal.dart';

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
            title: 'CorridorShare Mobile App',
            debugShowCheckedModeBanner: false,
            themeMode: userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.brand,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.canvasDark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.brand,
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            ),
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
    try {
      await context.read<UserProvider>().bootstrapSession();
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const Scaffold(
        backgroundColor: AppColors.canvasDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }
    return context.watch<UserProvider>().isAuthenticated
        ? const MainNavigationShell()
        : const SignInScreen();
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.canvasDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.alt_route, color: AppColors.brand, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to CorridorShare',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to post trips, discuss deals, and view your wallet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AuthModal(),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
                  child: const Text('SIGN IN', style: TextStyle(color: Colors.white)),
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
              color: const Color(0xFF7C2D12),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Friends private beta — OTP sign-in, matching, deal chat, meetup pins, and escrow OTP work. Live payments and continuous GPS are not included; use admin wallet credit for staging.',
                          style: TextStyle(color: Colors.white, fontSize: 11, height: 1.3),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _dismissBanner,
                        icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                        tooltip: 'Dismiss friends beta banner',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.brand.withValues(alpha: 0.2),
        elevation: 10,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.brand),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.alt_route, color: AppColors.brand),
            label: 'Matching',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.chat_bubble, color: AppColors.brand),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.shield, color: AppColors.brand),
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
        home: Scaffold(
          backgroundColor: AppColors.canvasDark,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'CorridorShare could not start.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
}
