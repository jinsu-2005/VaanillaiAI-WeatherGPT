import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/hydro_rating_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/hydro_rating_screen.dart';

void main() {
  group('IMD & CWC National Flood Forecasting & Rating Curve Model Tests', () {
    test('HydroRatingResponseModel parses valid JSON correctly', () {
      final json = {
        'timestamp': '2026-09-12T06:00:00Z',
        'active_station': {
          'station_id': 'brahmaputra_pandu',
          'station_name': 'Pandu Gauge Station',
          'river_name': 'Brahmaputra River',
          'state_name': 'Assam',
          'latitude': 26.17,
          'longitude': 91.68,
          'cwc_division': 'Brahmaputra & Barak Basin Organization, Guwahati',
          'flood_stage_tier': 'DANGER_STAGE',
          'benchmarks': {
            'zero_flow_datum_m': 40.00,
            'warning_level_m': 48.68,
            'danger_level_m': 49.68,
            'highest_flood_level_hfl_m': 51.46,
            'hfl_record_year': 2004,
            'embankment_crest_m': 52.80,
          },
          'rating_curve': {
            'stage_height_m': 50.12,
            'zero_flow_datum_h0_m': 40.00,
            'effective_head_m': 10.12,
            'rating_coefficient_a': 112.50,
            'hydraulic_exponent_b': 1.98,
            'computed_discharge_cumecs': 11180.5,
            'wetted_cross_section_area_m2': 2750.0,
            'hydraulic_radius_m': 4.20,
            'manning_roughness_n': 0.038,
            'channel_energy_slope': 0.00018,
            'mean_flow_velocity_mps': 4.07,
          },
          'embankment_safety': {
            'embankment_crest_level_m': 52.80,
            'countryside_toe_level_m': 44.50,
            'freeboard_margin_m': 2.68,
            'freeboard_tier': 'OPTIMAL_FREEBOARD',
            'seepage_path_length_m': 45.0,
            'exit_hydraulic_gradient': 0.125,
            'critical_hydraulic_gradient': 1.0,
            'piping_factor_of_safety': 8.0,
            'piping_risk_tier': 'HIGH_SANDBOIL_RISK',
            'sand_boil_detected': true,
          },
          'gumbel_frequency': {
            'discharge_10yr_cumecs': 48000.0,
            'discharge_25yr_cumecs': 56000.0,
            'discharge_50yr_cumecs': 62500.0,
            'discharge_100yr_cumecs': 71000.0,
            'current_return_period': 'LESS_THAN_10_YEAR',
            'annual_exceedance_probability_pct': 25.0,
          },
          'directives': {
            'flood_warning_color': '#DC2626',
            'evacuation_urgency_level': 'IMMEDIATE_RIPARIAN_EVACUATION',
            'embankment_patrol_frequency': 'Continuous 24x7',
            'piping_countermeasure_directive': 'Construct sandbag ring bunds around boils.',
            'riparian_safety_protocol': 'Evacuate char inhabitants to high ground.',
            'drinking_water_sanitation_advisory': 'Chlorinate borewells.',
          },
        },
        'all_stations': [
          {
            'station_id': 'brahmaputra_pandu',
            'station_name': 'Pandu Gauge Station',
            'river_name': 'Brahmaputra River',
            'state_name': 'Assam',
            'stage_height_m': 50.12,
            'danger_level_m': 49.68,
            'flood_stage_tier': 'DANGER_STAGE',
            'freeboard_margin_m': 2.68,
            'piping_risk_tier': 'HIGH_SANDBOIL_RISK',
          }
        ],
        'vernacular_bulletins': {
          'EN': 'CWC & IMD FLOOD BULLETIN: Brahmaputra River at Pandu is flowing at 50.12m MSL.',
          'AS': 'কেন্দ্ৰীয় জল আয়োগ আৰু IMD বান সতৰ্কবাৰ্তা: ব্ৰহ্মপুত্ৰ নদীৰ জলস্তৰ বিপদসীমাৰ ওপৰত।',
        },
        'dataSource': 'Central Water Commission (CWC) & IMD Hydromet',
      };

      final model = HydroRatingResponseModel.fromJson(json);

      expect(model.activeStation.stationId, equals('brahmaputra_pandu'));
      expect(model.activeStation.riverName, equals('Brahmaputra River'));
      expect(model.activeStation.floodStageTier, equals('DANGER_STAGE'));
      expect(model.activeStation.benchmarks.warningLevelM, equals(48.68));
      expect(model.activeStation.benchmarks.dangerLevelM, equals(49.68));
      expect(model.activeStation.benchmarks.highestFloodLevelHflM, equals(51.46));
      expect(model.activeStation.ratingCurve.computedDischargeCumecs, equals(11180.5));
      expect(model.activeStation.embankmentSafety.sandBoilDetected, isTrue);
      expect(model.activeStation.embankmentSafety.pipingRiskTier, equals('HIGH_SANDBOIL_RISK'));
      expect(model.vernacularBulletins['AS'], contains('ব্ৰহ্মপুত্ৰ'));
    });

    test('defaultFallback provides comprehensive offline Kosi River telemetry', () {
      final fallback = HydroRatingResponseModel.defaultFallback();

      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.activeStation.stationId, equals('kosi_baltara'));
      expect(fallback.activeStation.riverName, equals('Kosi River'));
      expect(fallback.activeStation.stateName, equals('Bihar'));
      expect(fallback.activeStation.benchmarks.dangerLevelM, equals(34.75));
      expect(fallback.activeStation.ratingCurve.stageHeightM, equals(35.15));
      expect(fallback.activeStation.embankmentSafety.freeboardMarginM, equals(2.65));
      expect(fallback.allStations.length, equals(7));
      expect(fallback.vernacularBulletins.containsKey('EN'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('HI'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('AS'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('BN'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('OD'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('TE'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('GU'), isTrue);
    });
  });

  group('HydroRatingScreen Widget Tests', () {
    testWidgets('renders hero flood card, benchmarks HUD, rating curve, and directives', (tester) async {
      final fallbackData = HydroRatingResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<WeatherProvider>(
                create: (_) => WeatherProvider(),
              ),
            ],
            child: HydroRatingScreen(initialData: fallbackData),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('CWC Flood & Rating Curve Telemetry'), findsOneWidget);

      // Verify Active Station & River
      expect(find.text('Baltara Gauge Station – Kosi River'), findsOneWidget);
      expect(find.text('Bihar • Lat: 25.68°N, Lon: 86.68°E'), findsOneWidget);

      // Verify CWC Benchmarks HUD
      expect(find.text('CWC Flood Benchmark Elevations (m MSL)'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
      expect(find.text('34.75m'), findsOneWidget);

      // Verify Rating Curve & Manning Conveyance
      expect(find.text('Hydrological Rating Curve & Manning Conveyance'), findsOneWidget);
      expect(find.text('2478.4 cumecs'), findsOneWidget);

      // Verify Embankment & Piping Safety
      expect(find.text('Embankment Structural Safety & Piping Stability'), findsOneWidget);
      expect(find.text('2.65 meters'), findsOneWidget);

      // Verify NDMA Directives
      expect(find.text('NDMA & CWC Riparian Protection Directives'), findsOneWidget);
      expect(find.text('Evacuation Protocol'), findsOneWidget);

      // Verify Riparian Vernacular Bulletins
      expect(find.text('Riparian Emergency Vernacular Bulletin'), findsOneWidget);
    });
  });
}
