import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/match_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CorridorShareApp());
}

class CorridorShareApp extends StatelessWidget {
  const CorridorShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
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
                seedColor: const Color(0xFFF97316),
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF051424),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFF97316),
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            ),
            home: const MainNavigationShell(),
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

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    MatchScreen(),
    MessagesScreen(),
    AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFFF97316).withValues(alpha: 0.2),
        elevation: 10,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFFF97316)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.alt_route, color: Color(0xFFF97316)),
            label: 'Matching',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFFF97316)),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.shield, color: Color(0xFFF97316)),
            label: 'Safety',
          ),
        ],
      ),
    );
  }
}
