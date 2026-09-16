import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/potential_fishing_zone_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/potential_fishing_zone_screen.dart';

void main() {
  group('INCOIS & CMFRI Potential Fishing Zone Model Unit Tests', () {
    test('PfzResponseModel parses valid JSON correctly', () {
      final json = {
        'sector_id': 'veraval_saurashtra',
        'sector_name': 'Veraval & Porbandar (Saurashtra Coast)',
        'state': 'Gujarat',
        'current_sector': {
          'sector_id': 'veraval_saurashtra',
          'sector_name': 'Veraval & Porbandar (Saurashtra Coast)',
          'state': 'Gujarat',
          'coastal_sea': 'Northeastern Arabian Sea',
          'primary_species': 'RIBBON_FISH_CROAKER',
          'ocean_color': {
            'chlorophyll_a_mg_m3': 2.45,
            'productivity_tier': 'OPTIMAL_HIGH_YIELD',
            'diffuse_attenuation_k490': 0.16,
            'phytoplankton_bloom_active': true,
            'harmful_algal_bloom_risk': false,
          },
          'thermal_front': {
            'sea_surface_temp_celsius': 27.2,
            'sst_gradient_deg_c_per_km': 0.82,
            'thermal_front_type': 'COASTAL_UPWELLING_FRONT',
            'mesoscale_eddy_type': 'CYCLONIC_COLD_CORE_UPWELLING',
            'sea_surface_height_anomaly_cm': -8.5,
          },
          'navigational_vector': {
            'landing_harbourName': 'Veraval Modern Fishing Harbour',
            'true_bearing_degrees': 215,
            'compass_direction': 'SW',
            'distance_nautical_miles': 32.0,
            'distance_kilometers': 59.3,
            'centroid_latitude': 20.45,
            'centroid_longitude': 69.80,
            'target_depth_fathoms': 35,
            'target_depth_meters': 64.0,
          },
          'fuel_savings': {
            'craft_type': 'MECHANIZED_TRAWLER_SINGLE_DAY',
            'scouting_time_reduction_pct': 52.0,
            'diesel_saved_liters': 180.0,
            'rupee_fuel_cost_savings_inr': 16200.0,
            'carbon_emission_reduction_kg_co2': 482.4,
          },
          'conservation': {
            'nearest_mpa_name': 'Marine National Park Gulf of Kutch',
            'distance_to_mpa_boundary_km': 48.0,
            'mpa_buffer_violation_risk': 'SAFE_OUTSIDE_BUFFER',
            'minimum_legal_size_advisory': 'Ribbonfish MLS >= 44 cm',
            'artisanal_exclusive_zone_status': '0-10 km Coastal Zone Enforced',
          },
          'vernacular_bulletins': {
            'en': 'VERAVAL PFZ ADVISORY in English',
            'gu': 'વેરાવળ અને પોરબંદર મત્સ્ય પાલન ક્ષેત્ર સલાહ',
          },
        },
        'all_sectors': [
          {
            'sector_id': 'veraval_saurashtra',
            'sector_name': 'Veraval & Porbandar',
            'state': 'Gujarat',
            'productivity_tier': 'OPTIMAL_HIGH_YIELD',
            'primary_species': 'RIBBON_FISH_CROAKER',
            'compass_direction': 'SW',
            'distance_nm': 32.0,
          },
        ],
        'last_updated_utc': '2026-09-12T12:00:00Z',
        'data_source': 'INCOIS Oceansat-3 OCM & CMFRI Marine Telemetry',
      };

      final model = PfzResponseModel.fromJson(json);
      expect(model.sectorId, 'veraval_saurashtra');
      expect(model.sectorName, 'Veraval & Porbandar (Saurashtra Coast)');
      expect(model.state, 'Gujarat');
      expect(model.currentSector.primarySpecies, 'RIBBON_FISH_CROAKER');
      expect(model.currentSector.oceanColor.chlorophyllAMgM3, 2.45);
      expect(model.currentSector.oceanColor.productivityTier, 'OPTIMAL_HIGH_YIELD');
      expect(model.currentSector.thermalFront.sstGradientDegCPerKm, 0.82);
      expect(model.currentSector.navigationalVector.trueBearingDegrees, 215);
      expect(model.currentSector.fuelSavings.dieselSavedLiters, 180.0);
      expect(model.currentSector.fuelSavings.rupeeFuelCostSavingsInr, 16200.0);
      expect(model.currentSector.conservation.distanceToMpaBoundaryKm, 48.0);
      expect(model.currentSector.vernacularBulletins['gu'], contains('વેરાવળ'));
    });

    test('PfzResponseModel defaultFallback provides safe calibrated baseline', () {
      final fallback = PfzResponseModel.defaultFallback();
      expect(fallback.sectorId, 'kochi_malabar');
      expect(fallback.sectorName, 'Kochi & Munambam FLC (Malabar Coast)');
      expect(fallback.state, 'Kerala');
      expect(fallback.currentSector.oceanColor.productivityTier, 'OPTIMAL_HIGH_YIELD');
      expect(fallback.currentSector.navigationalVector.trueBearingDegrees, 235);
      expect(fallback.currentSector.navigationalVector.compassDirection, 'SW');
      expect(fallback.currentSector.navigationalVector.distanceNauticalMiles, 25.0);
      expect(fallback.currentSector.fuelSavings.dieselSavedLiters, 35.0);
      expect(fallback.currentSector.conservation.nearestMpaName, 'Vembanad Estuarine Wetland Buffer');
      expect(fallback.allSectors.length, 7);
      expect(fallback.currentSector.vernacularBulletins.containsKey('ml'), true);
      expect(fallback.currentSector.vernacularBulletins.containsKey('ta'), true);
      expect(fallback.currentSector.vernacularBulletins.containsKey('gu'), true);
    });
  });

  group('PotentialFishingZoneScreen Widget Tests', () {
    testWidgets('Renders PotentialFishingZoneScreen with hero vector HUD, ocean telemetry, fuel savings, and CMFRI safeguards',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: MaterialApp(
            home: PotentialFishingZoneScreen(
              initialData: PfzResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Potential Fishing Zone (PFZ)'), findsOneWidget);
      expect(find.text('INCOIS Ocean Color & CMFRI Conservation Radar'), findsOneWidget);

      // Verify Coastal fishing hubs section
      expect(find.text('COASTAL FISHING HUBS'), findsOneWidget);
      expect(find.text('7 Operational Sectors'), findsOneWidget);

      // Verify Hero Navigational Vector
      expect(find.text('Kochi & Munambam FLC (Malabar Coast)'), findsOneWidget);
      expect(find.text('TRUE BEARING'), findsOneWidget);
      expect(find.text('235°'), findsOneWidget);
      expect(find.text('SW'), findsOneWidget);
      expect(find.text('DISTANCE'), findsOneWidget);
      expect(find.text('25.0 nm'), findsOneWidget);
      expect(find.text('TARGET DEPTH'), findsOneWidget);
      expect(find.text('28 fathoms'), findsOneWidget);

      // Verify Ocean Telemetry HUD
      expect(find.text('OCEAN COLOR & SST THERMAL FRONT HUD'), findsOneWidget);
      expect(find.text('CHLOROPHYLL-A'), findsOneWidget);
      expect(find.text('1.85 mg/m³'), findsOneWidget);
      expect(find.text('SEA SURFACE TEMP (SST)'), findsOneWidget);
      expect(find.text('28.4 °C'), findsOneWidget);

      // Verify Fuel Economics
      expect(find.text('ARTISANAL FUEL CONSERVATION & SAVINGS'), findsOneWidget);
      expect(find.text('DIESEL SAVED'), findsOneWidget);
      expect(find.text('35 L'), findsOneWidget);
      expect(find.text('RUPEE SAVINGS'), findsOneWidget);
      expect(find.text('₹3150'), findsOneWidget);

      // Verify CMFRI Conservation
      expect(find.text('CMFRI ECOLOGICAL SAFEGUARDS & MLS'), findsOneWidget);
      expect(find.text('Protected Marine Area: Vembanad Estuarine Wetland Buffer'), findsOneWidget);

      // Verify Vernacular Bulletin Card
      expect(find.text('COASTAL FISHERMAN BULLETIN'), findsOneWidget);

      // Tap Malayalam language chip
      final mlChip = find.text('മലയാളം (ML)');
      expect(mlChip, findsOneWidget);
      await tester.tap(mlChip);
      await tester.pumpAndSettle();

      // Verify Malayalam bulletin content is displayed
      expect(
        find.textContaining('കൊച്ചി/മലബാർ തീരദേശ മത്സ്യബന്ധന മേഖല'),
        findsOneWidget,
      );
    });
  });
}
