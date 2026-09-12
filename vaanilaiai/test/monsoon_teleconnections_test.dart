import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/monsoon_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/monsoon_teleconnections_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Monsoon Intelligence Model Unit Tests', () {
    test('SubDivisionalMonsoonModel parses JSON and serializes correctly', () {
      final json = {
        'sub_division_code': 'sd_23',
        'name': 'Konkan & Goa',
        'state': 'Maharashtra & Goa',
        'actual_rainfall_mm': 3150.0,
        'normal_rainfall_mm': 2910.0,
        'departure_percentage': 8.2,
        'departure_category': 'Normal',
        'departure_color': 'Green',
        'soil_moisture_index': 0.92,
        'drought_risk_level': 'Normal',
        'is_user_sub_division': true,
      };

      final model = SubDivisionalMonsoonModel.fromJson(json);
      expect(model.subDivisionCode, 'sd_23');
      expect(model.name, 'Konkan & Goa');
      expect(model.actualRainfallMm, 3150.0);
      expect(model.normalRainfallMm, 2910.0);
      expect(model.departurePercentage, 8.2);
      expect(model.departureCategory, 'Normal');
      expect(model.departureColor, 'Green');
      expect(model.soilMoistureIndex, 0.92);
      expect(model.isUserSubDivision, isTrue);

      final exported = model.toJson();
      expect(exported['sub_division_code'], 'sd_23');
      expect(exported['departure_percentage'], 8.2);
      expect(exported['is_user_sub_division'], isTrue);
    });

    test('OceanicTeleconnectionModel and SeasonalForecastOutlookModel serialization', () {
      final teleJson = {
        'index_code': 'enso_nino34',
        'name': 'ENSO (Niño 3.4 SST Anomaly)',
        'current_value': -0.65,
        'unit': '°C Anomaly',
        'phase': 'La Niña (Cool Phase)',
        'impact_on_monsoon': 'Favorable',
        'mechanism_summary': 'Cool equatorial Pacific SST strengthens cross-equatorial monsoon flow.',
      };

      final tele = OceanicTeleconnectionModel.fromJson(teleJson);
      expect(tele.indexCode, 'enso_nino34');
      expect(tele.currentValue, -0.65);
      expect(tele.impactOnMonsoon, 'Favorable');

      final exportedTele = tele.toJson();
      expect(exportedTele['current_value'], -0.65);
      expect(exportedTele['impact_on_monsoon'], 'Favorable');

      final outlookJson = {
        'season_name': 'Southwest Monsoon Season (June - September)',
        'onset_status': 'Active Pan-India Monsoon',
        'prob_below_normal_pct': 14,
        'prob_normal_pct': 48,
        'prob_above_normal_pct': 38,
        'official_lrf_verdict': 'Normal to Above-Normal Monsoon likely nationwide (106% LPA).',
      };

      final outlook = SeasonalForecastOutlookModel.fromJson(outlookJson);
      expect(outlook.probBelowNormalPct, 14);
      expect(outlook.probNormalPct, 48);
      expect(outlook.probAboveNormalPct, 38);
      expect(outlook.probBelowNormalPct + outlook.probNormalPct + outlook.probAboveNormalPct, 100);

      final exportedOutlook = outlook.toJson();
      expect(exportedOutlook['prob_normal_pct'], 48);
    });

    test('MonsoonIntelligenceModel.defaultFallback provides valid baseline', () {
      final fallback = MonsoonIntelligenceModel.defaultFallback(
        latitude: 13.0827,
        longitude: 80.2707,
        locationName: 'Chennai',
      );

      expect(fallback.locationName, 'Chennai');
      expect(fallback.userSubDivision, isNotNull);
      expect(fallback.teleconnections.length, 3);
      expect(fallback.seasonalOutlook.probNormalPct, greaterThan(0));
      expect(fallback.allSubDivisions, isNotEmpty);
      expect(fallback.adaptationDirectives, isNotEmpty);
      expect(fallback.vernacularAdvisories, contains('ta'));
      expect(fallback.vernacularAdvisories, contains('hi'));
      expect(fallback.vernacularAdvisories, contains('mr'));
      expect(fallback.vernacularAdvisories, contains('bn'));
    });
  });

  group('Monsoon Teleconnections Screen Widget Tests', () {
    testWidgets('Renders all cards and toggles vernacular agronomic guidance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: MonsoonTeleconnectionsScreen(
              initialLat: 13.0827,
              initialLon: 80.2707,
              initialLocationName: 'Chennai',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Monsoon Teleconnections & LRF'), findsOneWidget);

      // Verify User Met Sub-Division Hero Card
      expect(find.text('YOUR MET SUB-DIVISION'), findsOneWidget);
      expect(find.textContaining('Tamil Nadu'), findsWidgets);
      expect(find.text('Cumulative Actual'), findsOneWidget);
      expect(find.text('Climatological Normal'), findsOneWidget);
      expect(find.text('Soil Moisture'), findsOneWidget);

      // Verify Macro-Oceanic Teleconnections Dashboard
      expect(find.text('Macro-Oceanic Teleconnections'), findsOneWidget);
      expect(find.textContaining('Niño 3.4'), findsOneWidget);
      expect(find.textContaining('Indian Ocean Dipole'), findsOneWidget);
      expect(find.textContaining('Madden-Julian Oscillation'), findsOneWidget);

      // Verify Seasonal LRF Tercile Distribution
      expect(find.text('Seasonal Long-Range Forecast (LRF)'), findsOneWidget);
      expect(find.text('Tercile Probability Distribution'), findsOneWidget);

      // Verify Agrarian Directives and Vernacular Switching
      expect(find.text('Agrarian Directives & Sowing'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('मराठी'), findsOneWidget);
      expect(find.text('বাংলা'), findsOneWidget);

      // Tap Tamil language toggle
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();
      expect(find.textContaining('பருவமழை'), findsOneWidget);

      // Tap Hindi language toggle
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();
      expect(find.textContaining('मानसून'), findsOneWidget);

      // Verify 36 Sub-Divisions Explorer Section
      expect(find.text('36 Meteorological Sub-Divisions'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Large Excess'), findsOneWidget);
      expect(find.text('Normal'), findsWidgets);
    });

    testWidgets('Searches and filters sub-divisions in explorer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: MonsoonTeleconnectionsScreen(
              initialLat: 13.0827,
              initialLon: 80.2707,
              initialLocationName: 'Chennai',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Enter search text for Rajasthan
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Rajasthan');
      await tester.pumpAndSettle();

      // Verify filtered search result displays West Rajasthan
      expect(find.text('West Rajasthan'), findsOneWidget);
    });
  });
}
