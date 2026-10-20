import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testTrip = Trip(
    id: 'trip-101',
    travellerId: 'traveller-1',
    travellerName: 'Karim',
    fromDistrict: 'Dhaka',
    fromArea: 'Uttara',
    toDistrict: 'Sylhet',
    toArea: 'Zindabazar',
    departureDate: DateTime.now().add(const Duration(days: 1)),
    capacityKg: 5.0,
    noCarryTags: const <String>['liquids', 'fragile'],
    createdAt: DateTime.now(),
  );

  final testParcel = Parcel(
    id: 'parcel-101',
    senderId: 'sender-1',
    senderName: 'Nila Rahman',
    fromDistrict: 'Dhaka',
    fromArea: 'Dhanmondi',
    toDistrict: 'Sylhet',
    toArea: 'Ambarkhana',
    deadline: DateTime.now().add(const Duration(days: 2)),
    weightKg: 2.0,
    offeredPrice: 300,
    title: 'Books and Notes',
    categoryTags: const <String>['documents'],
    createdAt: DateTime.now(),
  );

  Widget buildSheet() {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MakeOfferSheet(
            trip: testTrip,
            parcel: testParcel,
            currentUserId: 'traveller-1',
          ),
        ),
      ),
    );
  }

  testWidgets('MakeOfferSheet renders synchronized premium design elements',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSheet());
    await tester.pumpAndSettle();

    // Header & category label
    expect(find.text('OFFER TO CARRY'), findsOneWidget);
    expect(find.text('Make an Offer'), findsNWidgets(2));

    // Parcel & corridor summary card
    expect(find.text('Books and Notes · 2.0 kg'), findsOneWidget);
    expect(find.text('Sender: Nila Rahman'), findsOneWidget);
    expect(find.text('Dhaka → Sylhet'), findsOneWidget);
    expect(find.text('LISTED'), findsOneWidget);
    expect(find.text('৳300'), findsWidgets);

    // No-carry warning banner
    expect(find.textContaining('Traveller will NOT carry:'), findsOneWidget);
    expect(find.textContaining('liquids'), findsOneWidget);

    // Price section and suggestions
    expect(find.text('YOUR PROPOSED PRICE (BDT)'), findsOneWidget);
    expect(find.byKey(const Key('offerPriceField')), findsOneWidget);
    expect(find.byKey(const Key('priceChip_250')), findsOneWidget);
    expect(find.byKey(const Key('priceChip_300')), findsOneWidget);
    expect(find.byKey(const Key('priceChip_350')), findsOneWidget);

    // Tapping a price chip updates input
    await tester.tap(find.byKey(const Key('priceChip_350')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '350'), findsOneWidget);

    // Submit button
    expect(find.byKey(const Key('submitOfferButton')), findsOneWidget);
  });
}
