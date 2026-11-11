import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/presentation/widgets/map_search_bar.dart';
import 'package:community_safety_app/core/services/app_coordinate.dart';
import 'package:community_safety_app/core/services/location_service_impl.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

void main() {
  group('search results from OpenStreetMap', () {
    test('keep places inside Moonwalk, named first', () {
      final places = LocationServiceImpl.placesFromNominatim([
        {
          'lat': '14.4851',
          'lon': '121.0116',
          'name': 'Moonwalk Elementary School',
          'display_name': 'Moonwalk Elementary School, Parañaque',
          'address': {'road': 'Sampaguita Street', 'neighbourhood': 'Moonwalk Proper', 'city': 'Parañaque'},
        },
        {
          // Makati: outside Moonwalk's box, dropped.
          'lat': '14.5547',
          'lon': '121.0244',
          'name': 'Ayala Triangle',
          'address': {'road': 'Ayala Avenue', 'city': 'Makati'},
        },
        {'lat': 'not a number', 'lon': '121.01'},
      ]);
      expect(places, hasLength(1));
      expect(places.single.address, 'Moonwalk Elementary School, Sampaguita Street, Moonwalk Proper, Parañaque City');
      expect(places.single.latitude, 14.4851);
    });

    test('fall back to the full name when there is no address block', () {
      final places = LocationServiceImpl.placesFromNominatim([
        {'lat': '14.4862', 'lon': '121.0142', 'display_name': 'Somewhere, Parañaque'},
      ]);
      expect(places.single.address, 'Somewhere, Parañaque');
      expect(places.single.sector, isNotEmpty);
    });
  });

  group('MapSearchBar', () {
    late List<AppCoordinate> chosen;
    late List<String> searched;

    Future<void> pumpBar(WidgetTester tester, {List<AppCoordinate> online = const []}) async {
      chosen = [];
      searched = [];
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapSearchBar(
            onSelected: chosen.add,
            search: (q) async {
              searched.add(q);
              return online;
            },
          ),
        ),
      ));
    }

    testWidgets("shows Moonwalk's areas as you type, without going online", (tester) async {
      await pumpBar(tester);
      await tester.enterText(find.byKey(const Key('map-search')), 'san');
      await tester.pump();

      expect(find.textContaining('San Jose'), findsWidgets);
      expect(find.textContaining('San Agustin'), findsWidgets);
      expect(searched, isEmpty);

      await tester.tap(find.text('San Jose (Area 1), Barangay Moonwalk, Parañaque City'));
      await tester.pump();
      expect(chosen.single.sector, 'Area 1 - San Jose');
    });

    testWidgets('searches streets and places when asked, and picks one', (tester) async {
      const school = AppCoordinate(
        latitude: 14.4851,
        longitude: 121.0116,
        address: 'Moonwalk Elementary School, Parañaque City',
        sector: 'Area 5 - Moonwalk Proper',
      );
      await pumpBar(tester, online: [school]);
      await tester.enterText(find.byKey(const Key('map-search')), 'elementary');
      await tester.pump();

      await tester.tap(find.text('Search “elementary”'));
      await tester.pumpAndSettle();
      expect(searched, ['elementary']);

      await tester.tap(find.text('Moonwalk Elementary School, Parañaque City'));
      await tester.pump();
      expect(chosen.single.latitude, 14.4851);
    });

    testWidgets('says so when nothing is found in Moonwalk', (tester) async {
      await pumpBar(tester);
      await tester.enterText(find.byKey(const Key('map-search')), 'zzzz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Nothing found inside Barangay Moonwalk.'), findsOneWidget);
    });
  });
}
