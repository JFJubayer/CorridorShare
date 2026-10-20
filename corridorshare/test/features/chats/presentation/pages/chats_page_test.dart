import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/data/datasources/in_memory_chat_datasource.dart';
import 'package:corridorshare/features/chats/presentation/pages/chats_page.dart';
import 'package:corridorshare/features/chats/presentation/providers/chat_providers.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildChatsHarness() {
  final offerDs = InMemoryOfferDataSource(seed: true);
  final chatDs = InMemoryChatDataSource(offerDataSource: offerDs, seed: true);

  return ProviderScope(
    overrides: <Override>[
      offerDataSourceProvider.overrideWithValue(offerDs),
      chatDataSourceProvider.overrideWithValue(chatDs),
      currentUserProvider.overrideWithValue(
        const AuthUser(
          id: 'sender-1',
          phone: '+8801700000000',
          name: 'Tania',
          verified: true,
          ratingAvg: 5.0,
        ),
      ),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatsPage(),
    ),
  );
}

void main() {
  testWidgets('renders Chats page with search, filters, and design mockup conversations',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildChatsHarness());
    await tester.pumpAndSettle();

    // Verify Title & Language Toggle
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);

    // Verify Search Bar
    expect(find.text('Search name or parcel'), findsOneWidget);

    // Verify Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Unread · 3'), findsOneWidget);
    expect(find.text('Deals'), findsOneWidget);

    // Verify Seed Conversations from Mockup
    expect(find.text('Rafi Mahmud'), findsOneWidget);
    expect(find.text('Agreed'), findsWidgets);
    expect(find.text("Okay, I'll be at Kamalapur at 8:30."), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // unread count for Rafi

    expect(find.text('Nila Akter'), findsOneWidget);
    expect(find.text('Counter-offer'), findsOneWidget);
    expect(find.text('Could you do ৳550 instead?'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // unread count for Nila

    expect(find.text('Sabbir Hasan'), findsOneWidget);
    expect(find.text('Disputed'), findsOneWidget);
    expect(find.text("You: I've reported the problem."), findsOneWidget);

    expect(find.text('Imran Khan'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Delivered. Thank you!'), findsOneWidget);

    expect(find.text('CorridorShare'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Your Demo wallet is ready.'), findsOneWidget);
  });

  testWidgets('filters conversations by search query',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildChatsHarness());
    await tester.pumpAndSettle();

    // Type "Nila" into the search field
    await tester.enterText(find.byType(TextField), 'Nila');
    await tester.pumpAndSettle();

    expect(find.text('Nila Akter'), findsOneWidget);
    expect(find.text('Rafi Mahmud'), findsNothing);
    expect(find.text('Sabbir Hasan'), findsNothing);
  });

  testWidgets('filters conversations by Unread tab',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildChatsHarness());
    await tester.pumpAndSettle();

    // Tap "Unread · 3" chip
    await tester.tap(find.text('Unread · 3'));
    await tester.pumpAndSettle();

    // Only Rafi (2 unread) and Nila (1 unread) should appear
    expect(find.text('Rafi Mahmud'), findsOneWidget);
    expect(find.text('Nila Akter'), findsOneWidget);
    expect(find.text('Sabbir Hasan'), findsNothing);
    expect(find.text('CorridorShare'), findsNothing);
  });
}
