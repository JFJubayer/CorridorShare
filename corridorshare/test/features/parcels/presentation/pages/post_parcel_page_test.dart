import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/presentation/pages/post_parcel_page.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({InMemoryParcelDataSource? dataSource}) {
  return ProviderScope(
    overrides: <Override>[
      if (dataSource != null)
        parcelDataSourceProvider.overrideWithValue(dataSource),
      currentUserProvider.overrideWithValue(
        const AuthUser(
          id: 'sender-1',
          phone: '+8801800000000',
          name: 'Tanvir Ahmed',
          verified: true,
          ratingAvg: 4.9,
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
      home: PostParcelPage(),
    ),
  );
}

void main() {
  testWidgets('renders post parcel form elements', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    expect(find.text('Send a Parcel'), findsOneWidget);
    expect(find.byKey(const Key('parcelTitleField')), findsOneWidget);
    expect(find.byKey(const Key('fromDistrictDropdown')), findsOneWidget);
    expect(find.byKey(const Key('toDistrictDropdown')), findsOneWidget);
    expect(find.byKey(const Key('parcelWeightField')), findsOneWidget);
    expect(find.byKey(const Key('parcelPriceField')), findsOneWidget);
    expect(find.byKey(const Key('prohibitedDeclarationCheckbox')), findsOneWidget);
    expect(find.byKey(const Key('submitParcelButton')), findsOneWidget);
  });

  testWidgets('blocks submission when prohibited items declaration is unchecked',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('parcelTitleField')),
      'Medical Reports',
    );

    // Ensure checkbox is unchecked
    final checkboxFinder = find.byKey(const Key('prohibitedDeclarationCheckbox'));
    expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isFalse);

    await tester.tap(find.byKey(const Key('submitParcelButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('You must acknowledge the prohibited items declaration.'),
      findsOneWidget,
    );
  });

  testWidgets('submits parcel successfully when form is valid and declared',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final ds = InMemoryParcelDataSource(initialParcels: <ParcelDto>[]);
    await tester.pumpWidget(_buildHarness(dataSource: ds));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('parcelTitleField')),
      'Passport & NID Copies',
    );
    await tester.enterText(find.byKey(const Key('parcelWeightField')), '0.5');
    await tester.enterText(find.byKey(const Key('parcelPriceField')), '400');

    // Check the mandatory prohibited items declaration
    await tester.tap(find.byKey(const Key('prohibitedDeclarationCheckbox')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitParcelButton')));
    await tester.pumpAndSettle();

    final parcels = await ds.getParcels();
    expect(parcels.length, 1);
    expect(parcels.first.title, 'Passport & NID Copies');
    expect(parcels.first.hasProhibitedItemsDeclaration, isTrue);
    expect(parcels.first.offeredPrice, 400.0);
  });
}
