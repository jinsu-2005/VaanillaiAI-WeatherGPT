import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/glof_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/glof_screen.dart';

void main() {
  group('Himalayan GLOF & Moraine Dam Breach Model Unit Tests', () {
    test('GlofResponseModel parses valid JSON correctly', () {
      final json = {
        'selected_lake': {
          'lake_id': 'south_lhonak_sikkim',
          'lake_name': 'South Lhonak Lake (Chungthang / Teesta Basin)',
          'river_basin': 'Teesta River Basin',
          'state': 'Sikkim',
          'latitude': 27.915,
          'longitude': 88.205,
          'elevation_m': 5200.0,
          'threat_tier': 'CRITICAL_RED_BREACH_IMMINENT',
          'morphometry': {
            'surface_area_ha': 168.0,
            'surface_area_km2': 1.68,
            'mean_depth_m': 38.0,
            'max_depth_m': 131.0,
            'water_volume_million_m3': 63.84,
            'expansion_rate_10yr_pct': 28.5,
            'satellite_sensor_provenance': 'Sentinel-1 SAR Multi-temporal Interferometry',
          },
          'moraine_geotechnics': {
            'crest_elevation_m': 5240.0,
            'dam_height_m': 55.0,
            'crest_width_to_height_ratio': 1.65,
            'freeboard_height_m': 4.5,
            'permafrost_degradation_pct': 68.0,
            'hydraulic_piping_index': 1.25,
            'stability_status': 'CRITICAL PIPING & OVERTOPPING SUSCEPTIBILITY',
          },
          'breach_hydrodynamics': {
            'peak_outflow_discharge_m3_s': 15420.0,
            'breach_formation_time_hours': 0.8,
            'total_breach_volume_million_m3': 45.0,
            'wave_propagation_speed_kmh': 45.0,
            'trigger_mechanism': 'OVERTOPPING_ICE_AVALANCHE_SURGE',
          },
          'downstream_impact_timeline': [
            {
              'node_name': 'Chungthang / Teesta-III Hydro Dam',
              'distance_km': 65.0,
              'wave_arrival_eta_min': 87,
              'peak_surge_depth_m': 18.5,
              'infrastructure_alert': 'RADIAL GATES EMERGENCY FLUSH',
              'evacuation_zone_elevation_m': 35.0,
            },
          ],
          'ndma_safety_directives': [
            'MANDATORY VERTICAL EVACUATION: Climb at least 35m above valley floor immediately.',
            'DO NOT rely on bridge crossings or follow the riverbank road.',
          ],
        },
        'all_lakes': [
          {
            'lake_id': 'south_lhonak_sikkim',
            'lake_name': 'South Lhonak Lake (Chungthang / Teesta Basin)',
            'river_basin': 'Teesta River Basin',
            'state': 'Sikkim',
            'elevation_m': 5200.0,
            'threat_tier': 'CRITICAL_RED_BREACH_IMMINENT',
            'surface_area_ha': 168.0,
            'volume_million_m3': 63.84,
            'peak_discharge_m3_s': 15420.0,
            'earliest_eta_min': 87,
          }
        ],
        'bulletins': {
          'en': 'CRITICAL RED GLOF ALERT: Immediate moraine breach risk detected at South Lhonak Lake.',
          'hi': 'अत्यंत गंभीर लाल चेतावनी: दक्षिण ल्होनक झील में हिमनद झील विस्फोट (GLOF) की तात्कालिक संभावना।',
          'ne': 'अति गम्भीर रातो चेतावनी: दक्षिण ल्होनक तालमा बाँध फुट्ने (GLOF) को तत्काल जोखिम।',
        },
        'offline_cached': false,
        'generated_at': '2026-09-12T06:00:00Z',
      };

      final model = GlofResponseModel.fromJson(json);
      expect(model.selectedLake.lakeId, 'south_lhonak_sikkim');
      expect(model.selectedLake.threatTier, 'CRITICAL_RED_BREACH_IMMINENT');
      expect(model.selectedLake.breachHydrodynamics.triggerMechanism, 'OVERTOPPING_ICE_AVALANCHE_SURGE');
      expect(model.selectedLake.morphometry.surfaceAreaHa, 168.0);
      expect(model.selectedLake.moraineGeotechnics.damHeightM, 55.0);
      expect(model.selectedLake.breachHydrodynamics.peakOutflowDischargeM3S, 15420.0);
      expect(model.selectedLake.downstreamImpactTimeline.length, 1);
      expect(model.selectedLake.downstreamImpactTimeline.first.nodeName, contains('Chungthang'));
      expect(model.selectedLake.ndmaSafetyDirectives.length, 2);
      expect(model.bulletins['ne'], contains('दक्षिण ल्होनक'));
    });

    test('GlofResponseModel defaultFallback provides safe calibrated defaults', () {
      final fallback = GlofResponseModel.defaultFallback();
      expect(fallback.selectedLake.lakeId, 'south_lhonak_sikkim');
      expect(fallback.selectedLake.threatTier, 'CRITICAL_RED_BREACH_IMMINENT');
      expect(fallback.allLakes.length, greaterThanOrEqualTo(3));
      expect(fallback.selectedLake.downstreamImpactTimeline.length, greaterThanOrEqualTo(3));
      expect(fallback.selectedLake.breachHydrodynamics.peakOutflowDischargeM3S, greaterThan(5000.0));
      expect(fallback.bulletins.containsKey('en'), isTrue);
      expect(fallback.bulletins.containsKey('hi'), isTrue);
      expect(fallback.bulletins.containsKey('ne'), isTrue);
      expect(fallback.bulletins.containsKey('bo'), isTrue);
      expect(fallback.bulletins.containsKey('pa'), isTrue);
      expect(fallback.bulletins.containsKey('bn'), isTrue);
      expect(fallback.bulletins.containsKey('as'), isTrue);
      expect(fallback.offlineCached, isTrue);
    });
  });

  group('GlofScreen Widget Tests', () {
    testWidgets('Renders GlofScreen with hero cards, morphometry HUD, wave propagation, and multilingual toggle',
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
            home: GlofScreen(
              initialData: GlofResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      // Allow async initState and postFrameCallback to complete
      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text('Himalayan GLOF Early Warning'), findsOneWidget);
      expect(find.text('NRSC-ISRO · CWC · NDMA Glacial Lake Radar'), findsOneWidget);

      // Verify lake selector chips
      expect(find.text('South Lhonak (SK)'), findsOneWidget);
      expect(find.text('Chorabari (UK)'), findsOneWidget);

      // Verify hero threat banner
      expect(find.text('CRITICAL RED · BREACH IMMINENT'), findsOneWidget);
      expect(find.textContaining('South Lhonak Lake'), findsWidgets);

      // Verify Glacial Lake Morphometry & Satellite SAR card
      expect(find.text('Glacial Lake Morphometry & Satellite SAR'), findsOneWidget);
      expect(find.text('Surface Area'), findsOneWidget);
      expect(find.text('Storage Volume'), findsOneWidget);

      // Verify Moraine Dam Geotechnical Stability HUD
      expect(find.text('Moraine Dam Geotechnical Stability'), findsOneWidget);
      expect(find.text('Dam Geometry'), findsOneWidget);
      expect(find.text('Freeboard & Thaw'), findsOneWidget);

      // Verify Breach Hydrodynamics & Peak Outflow card
      expect(find.text('Breach Hydrodynamics & Peak Outflow'), findsOneWidget);
      expect(find.text('Peak Discharge (Qp)'), findsOneWidget);

      // Verify Downstream Flood Wave Timeline & Infrastructure ETA Cascade
      expect(find.text('Downstream Flood Wave Timeline (ETA)'), findsOneWidget);
      expect(find.textContaining('Chungthang'), findsWidgets);

      // Verify NDMA Directives
      expect(find.text('NDMA Mountain Community & Hydropower Directives'), findsOneWidget);

      // Verify Multilingual Glacial Flood Emergency Bulletins & Tap Nepali
      expect(find.text('Himalayan Regional Early Warning Bulletin'), findsOneWidget);
      final nepaliChip = find.text('नेपाली');
      expect(nepaliChip, findsOneWidget);
      await tester.tap(nepaliChip);
      await tester.pumpAndSettle();

      // Verify Nepali bulletin text rendered
      expect(find.textContaining('साउथ ल्होनाक'), findsOneWidget);

      // Tap Hindi chip
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();

      // Verify Hindi bulletin text rendered
      expect(find.textContaining('साउथ ल्होनाक'), findsOneWidget);

      // Tap Bhutia chip
      final bhutiaChip = find.text('བོད་སྐད (Bhutia)');
      expect(bhutiaChip, findsOneWidget);
      await tester.tap(bhutiaChip);
      await tester.pumpAndSettle();

      // Verify Bhutia bulletin text rendered
      expect(find.textContaining('ཉེན་བརྡ'), findsOneWidget);
    });
  });
}
