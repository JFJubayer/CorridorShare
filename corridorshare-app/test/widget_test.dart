import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:corridorshare_app/core/config/app_config.dart';
import 'package:corridorshare_app/providers/user_provider.dart';
import 'package:corridorshare_app/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders Stitch components correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(
          config: const AppConfig(dataMode: AppDataMode.demo),
        ),
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Add funds'), findsOneWidget);
    expect(find.text('How a delivery works'), findsOneWidget);
    expect(find.text('Sending'), findsOneWidget);
    expect(find.text('Travelling'), findsOneWidget);
  });
}
