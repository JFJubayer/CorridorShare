import 'package:corridorshare/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdminDashboardPage(),
    ),
  );
}

void main() {
  testWidgets('renders admin dashboard with KPI metric cards and dispute queue',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Platform Metrics & Health'), findsOneWidget);

    // Verify KPI metric tiles
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('Active Trips'), findsOneWidget);
    expect(find.text('Active In-Transit'), findsOneWidget);
    expect(find.text('Total Handover Volume'), findsOneWidget);

    // Verify dispute queue section
    expect(find.text('Dispute Escalations'), findsOneWidget);
  });
}
