import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/urban_heat_island_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/urban_heat_island_screen.dart';

void main() {
  group('IMD & NDMA Urban Heat Island Model Unit Tests', () {
    test('UrbanHeatIslandResponseModel parses valid JSON correctly', () {
      final json = {
        'corridor_id': 'ahmedabad_amc',
        'city_name': 'Ahmedabad AMC',
        'state': 'Gujarat',
        'current_corridor': {
          'corridor_id': 'ahmedabad_amc',
          'city_name': 'Ahmedabad AMC',
          'state': 'Gujarat',
          'latitude': 23.0225,
          'longitude': 72.5714,
          'climate_zone': 'Hot-Dry',
          'dominant_morphology': 'INDUSTRIAL_ASPHALT_ZONE',
          'threat_level': 'HIGH_SEVERE',
          'surface_telemetry': {
            'lst_urban_celsius': 47.2,
            'lst_rural_baseline_celsius': 41.3,
            'uhi_thermal_anomaly_delta_c': 5.9,
            'canopy_air_temp_celsius': 42.5,
            'tropical_night_min_temp_celsius': 28.5,
            'tropical_night_flag': true,
            'severe_tropical_night_flag': true,
          },
          'biophysical_metrics': {
            'impervious_surface_fraction_pct': 84.0,
            'ndvi_urban_core': 0.12,
            'ndvi_rural_baseline': 0.44,
            'vegetation_cooling_deficit_delta_c': 2.4,
            'sky_view_factor_svf': 0.42,
            'anthropogenic_heat_flux_w_m2': 78.0,
          },
          'cool_roof_simulation': {
            'roof_material': 'HIGH_ALBEDO_ELASTOMERIC_WHITE',
            'solar_reflectance_index_sri': 104,
            'solar_reflectance_alpha': 0.85,
            'thermal_emittance_epsilon': 0.90,
            'surface_temperature_celsius': 36.5,
            'surface_temp_reduction_delta_c': 22.5,
            'indoor_cooling_benefit_delta_c': -3.5,
            'ac_energy_load_reduction_pct': 24.5,
            'ndma_cool_roof_compliant': true,
          },
          'hotspots': [
            {
              'hotspot_id': 'ah_naroda',
              'hotspot_name': 'Naroda GIDC Industrial Estate',
              'morphology': 'INDUSTRIAL_ASPHALT_ZONE',
              'lst_celsius': 48.4,
              'thermal_anomaly_delta_c': 7.1,
              'vulnerability_rank': 'VERY_HIGH',
              'cooling_shelter_distance_m': 400,
            },
          ],
          'directives': {
            'cool_roof_policy_status': 'ACTIVE_MANDATORY_MUNICIPAL',
            'cool_roof_target_sq_meters': 850000,
            'urban_forestry_corridor_km': 32.0,
            'transit_misting_stations_count': 48,
            'construction_heat_shift_enforced': true,
            'public_pyaus_drinking_water_points': 640,
            'emergency_cooling_shelters_active': 95,
          },
          'vernacular_bulletins': {
            'en': 'AHMEDABAD AMC UHI ADVISORY in English',
            'gu': 'અમદાવાદ મ્યુનિસિપલ કોર્પોરેશન હીટ આઇલેન્ડ ચેતવણી',
          },
        },
        'all_corridors': [
          {
            'corridor_id': 'ahmedabad_amc',
            'city_name': 'Ahmedabad AMC',
            'state': 'Gujarat',
            'threat_level': 'HIGH_SEVERE',
            'uhi_thermal_anomaly_delta_c': 5.9,
            'lst_urban_celsius': 47.2,
            'tropical_night_flag': true,
          },
        ],
        'last_updated_utc': '2026-09-12T12:00:00Z',
        'data_source': 'IMD Urban Meteorology Mesonet & NDMA Mission Cool Roofs Telemetry',
      };

      final model = UrbanHeatIslandResponseModel.fromJson(json);
      expect(model.corridorId, 'ahmedabad_amc');
      expect(model.cityName, 'Ahmedabad AMC');
      expect(model.currentCorridor.threatLevel, 'HIGH_SEVERE');
      expect(model.currentCorridor.surfaceTelemetry.uhiThermalAnomalyDeltaC, 5.9);
      expect(model.currentCorridor.surfaceTelemetry.tropicalNightFlag, true);
      expect(model.currentCorridor.biophysicalMetrics.imperviousSurfaceFractionPct, 84.0);
      expect(model.currentCorridor.coolRoofSimulation.solarReflectanceIndexSri, 104);
      expect(model.currentCorridor.coolRoofSimulation.ndmaCoolRoofCompliant, true);
      expect(model.currentCorridor.hotspots.length, 1);
      expect(model.currentCorridor.hotspots.first.hotspotName, 'Naroda GIDC Industrial Estate');
      expect(model.currentCorridor.directives.publicPyausDrinkingWaterPoints, 640);
      expect(model.currentCorridor.vernacularBulletins['gu'], contains('અમદાવાદ'));
    });

    test('UrbanHeatIslandResponseModel defaultFallback provides safe calibrated baseline', () {
      final fallback = UrbanHeatIslandResponseModel.defaultFallback();
      expect(fallback.corridorId, 'delhi_ncr');
      expect(fallback.cityName, 'Delhi-NCR');
      expect(fallback.currentCorridor.threatLevel, 'CRITICAL_EXTREME');
      expect(fallback.currentCorridor.surfaceTelemetry.uhiThermalAnomalyDeltaC, 6.8);
      expect(fallback.currentCorridor.surfaceTelemetry.tropicalNightFlag, true);
      expect(fallback.currentCorridor.surfaceTelemetry.severeTropicalNightFlag, true);
      expect(fallback.currentCorridor.coolRoofSimulation.solarReflectanceIndexSri, 104);
      expect(fallback.allCorridors.length, 7);
      expect(fallback.currentCorridor.vernacularBulletins.containsKey('hi'), true);
      expect(fallback.currentCorridor.vernacularBulletins.containsKey('ta'), true);
    });
  });

  group('UrbanHeatIslandScreen Widget Tests', () {
    testWidgets('Renders UrbanHeatIslandScreen with hero cards, tropical night banner, canopy HUD, and simulator',
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
            home: UrbanHeatIslandScreen(
              initialData: UrbanHeatIslandResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Urban Heat Island & Cool Roofs'), findsOneWidget);
      expect(find.text('IMD Mesonet & NDMA Mission Cool Roofs'), findsOneWidget);

      // Verify Megacity selector chips
      expect(find.text('Delhi-NCR'), findsWidgets);
      expect(find.text('Ahmedabad AMC'), findsOneWidget);
      expect(find.text('Mumbai MMR'), findsOneWidget);

      // Verify Hero Thermal Anomaly card
      expect(find.text('CRITICAL EXTREME UHI'), findsOneWidget);
      expect(find.text('UHI THERMAL ANOMALY'), findsOneWidget);
      expect(find.text('+6.8°C'), findsWidgets);
      expect(find.text('Urban LST Surface'), findsOneWidget);
      expect(find.text('48.5°C'), findsWidgets);
      expect(find.text('Rural Baseline LST'), findsOneWidget);
      expect(find.text('41.7°C'), findsOneWidget);

      // Verify Tropical Night warning banner
      expect(find.text('Severe Tropical Night Warning'), findsOneWidget);
      expect(find.text('T_min: 29.8°C'), findsOneWidget);

      // Verify Biophysical Urban Canopy Dynamics card
      expect(find.text('Biophysical Urban Canopy Dynamics'), findsOneWidget);
      expect(find.text('Impervious Surface Fraction (ISF)'), findsOneWidget);
      expect(find.text('88.5%'), findsOneWidget);
      expect(find.text('Vegetation Loss Deficit'), findsOneWidget);
      expect(find.text('+2.6°C'), findsOneWidget);
      expect(find.text('Anthropogenic Heat Flux (Q_F)'), findsOneWidget);
      expect(find.text('96 W/m²'), findsOneWidget);

      // Verify Interactive Cool Roof Simulator
      expect(find.text('Interactive Cool Roof Simulator'), findsOneWidget);
      expect(find.text('NDMA SRI>=78 PASS'), findsOneWidget);
      expect(find.text('Peak Roof Surface'), findsOneWidget);
      expect(find.text('36.5°C'), findsOneWidget);
      expect(find.text('Indoor Air Relief'), findsOneWidget);
      expect(find.text('-3.5°C'), findsOneWidget);
      expect(find.text('AC Power Savings'), findsOneWidget);
      expect(find.text('24.5%'), findsOneWidget);

      // Verify Microclimate Hotspots card
      expect(find.text('Identified Microclimate Hotspots'), findsOneWidget);
      expect(find.text('Anand Vihar ISBT & Railway Hub'), findsOneWidget);
      expect(find.text('Chandni Chowk Old Walled City'), findsOneWidget);

      // Verify Municipal & NDMA Directives card
      expect(find.text('Municipal & NDMA Urban Heat Directives'), findsOneWidget);
      expect(find.text('Cool Roof Target'), findsOneWidget);
      expect(find.text('12.0 Lakh m²'), findsOneWidget);
      expect(find.text('Afternoon Construction Ban'), findsOneWidget);
      expect(find.text('ENFORCED (12:00-16:00)'), findsOneWidget);

      // Verify Regional Vernacular Bulletin card
      expect(find.text('Regional Vernacular Bulletin'), findsOneWidget);
      expect(find.textContaining('DELHI-NCR UHI ADVISORY'), findsOneWidget);

      // Tap language dropdown and select Hindi
      final langDropdown = find.text('English');
      expect(langDropdown, findsOneWidget);
      await tester.tap(langDropdown);
      await tester.pumpAndSettle();

      final hindiItem = find.text('हिन्दी').last;
      await tester.tap(hindiItem);
      await tester.pumpAndSettle();

      // Verify Hindi bulletin rendered
      expect(find.textContaining('दिल्ली-एनसीआर शहरी ताप द्वीप'), findsOneWidget);
    });
  });
}
