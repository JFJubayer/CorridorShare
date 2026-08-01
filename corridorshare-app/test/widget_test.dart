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
    expect(find.text('NID Verified'), findsOneWidget);
    expect(find.text('Earnings Estimator'), findsOneWidget);
    expect(find.text('ESCROW BALANCE'), findsOneWidget);
    expect(find.text('Top Up via bKash'), findsOneWidget);
    expect(find.text('Top Up via Nagad'), findsOneWidget);
    expect(find.text('How It Works'), findsOneWidget);
    expect(find.text('Safety & Verification Matrix'), findsOneWidget);
  });
}
