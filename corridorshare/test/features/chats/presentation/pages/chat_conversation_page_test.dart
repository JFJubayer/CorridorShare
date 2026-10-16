import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/data/datasources/in_memory_chat_datasource.dart';
import 'package:corridorshare/features/chats/presentation/pages/chat_conversation_page.dart';
import 'package:corridorshare/features/chats/presentation/providers/chat_providers.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({required String offerId}) {
  final offerDs = InMemoryOfferDataSource(seed: true);
  final chatDs = InMemoryChatDataSource(offerDataSource: offerDs, seed: true);
  return ProviderScope(
    overrides: <Override>[
      offerDataSourceProvider.overrideWithValue(offerDs),
      chatDataSourceProvider.overrideWithValue(chatDs),
      currentUserProvider.overrideWithValue(
        const AuthUser(
          id: 'traveller-1',
          phone: '+8801700000000',
          name: 'Rafiqul Islam',
          verified: true,
          ratingAvg: 4.9,
        ),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatConversationPage(offerId: offerId),
    ),
  );
}

void main() {
  testWidgets('renders conversation header, offer banner, and message stream',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(offerId: 'offer-1'));
    await tester.pumpAndSettle();

    // Verify counterpart name and corridor
    expect(find.text('Tanvir Ahmed'), findsOneWidget);
    expect(find.text('Dhaka → Chattogram'), findsOneWidget);

    // Verify offer banner
    expect(find.text('Original Academic Transcripts'), findsOneWidget);
    expect(find.text('৳ 450'), findsOneWidget);
    expect(find.byKey(const Key('acceptOfferButton')), findsOneWidget);
    expect(find.byKey(const Key('counterOfferButton')), findsOneWidget);
    expect(find.byKey(const Key('rejectOfferButton')), findsOneWidget);

    // Verify seed messages rendered
    expect(
      find.text('Hello! I saw you are travelling from Dhaka to Chattogram by train.'),
      findsOneWidget,
    );
  });

  testWidgets('sends new chat message and updates stream view',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(offerId: 'offer-1'));
    await tester.pumpAndSettle();

    // Type a message
    await tester.enterText(
      find.byKey(const Key('chatInputField')),
      'I can meet you right outside Dhaka airport station.',
    );
    await tester.pump();

    // Send
    await tester.tap(find.byKey(const Key('chatSendButton')));
    await tester.pumpAndSettle();

    // Verify new message bubble is rendered
    expect(
      find.text('I can meet you right outside Dhaka airport station.'),
      findsOneWidget,
    );
  });

  testWidgets('accepting offer updates status banner to accepted',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(offerId: 'offer-1'));
    await tester.pumpAndSettle();

    // Tap Accept button
    await tester.tap(find.byKey(const Key('acceptOfferButton')));
    await tester.pumpAndSettle();

    // Verify accepted status
    expect(find.text('Deal Agreed!'), findsOneWidget);
    // Action buttons should now disappear since offer is terminal
    expect(find.byKey(const Key('acceptOfferButton')), findsNothing);
  });
}
