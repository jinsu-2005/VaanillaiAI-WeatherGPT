import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/avalanche_snow_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/avalanche_snow_screen.dart';

void main() {
  group('Himalayan Avalanche & Snow Model Unit Tests', () {
    test('AvalancheSnowResponseModel parses valid JSON correctly', () {
      final json = {
        'timestamp': '2026-09-12T06:00:00Z',
        'selected_sector': {
          'sector_id': 'zojila_dras',
          'sector_name': 'Zoji La Pass & Dras Sector',
          'mountain_range': 'Great Himalaya',
          'state_or_ut': 'Ladakh / J&K',
          'latitude': 34.281,
          'longitude': 75.498,
          'base_elevation_m': 2800.0,
          'peak_elevation_m': 4200.0,
          'danger_level': 'LEVEL_4_RED_HIGH_DANGER',
          'danger_rating_text': 'Red Alert (Extreme Danger): Depth hoar collapse.',
          'snowpack': {
            'total_snowpack_depth_cm': 210.0,
            'fresh_snow_24h_cm': 54.0,
            'snow_water_equivalent_mm': 250.0,
            'average_density_kg_m3': 260.0,
            'critical_slope_angle_deg': 41.0,
            'primary_weak_layer': 'DEPTH_HOAR_FACETS',
            'weak_layer_depth_cm': 65.0,
            'aspect_hazard': 'East and South-East chutes',
          },
          'pass_status': {
            'pass_name': 'Zoji La Pass',
            'altitude_m': 3528.0,
            'altitude_ft': 11575,
            'highway_code': 'NH-1',
            'status': 'CLOSED_SNOW_CLEARING',
            'bro_operational_status': 'Closed due to recurring slides.',
            'bro_equipment_deployed': ['Rolba Snow Cutter', 'Bulldozer D85'],
            'chains_required': true,
          },
          'safety': {
            'elevation_m': 3528.0,
            'ams_risk': 'High',
            'hypothermia_risk': 'Extreme',
            'bps_gear_mandatory': true,
            'travel_advisory': 'Halt all civilian transit.',
            'emergency_helpline': '112',
          },
        },
        'all_sectors': [],
        'western_disturbance': {
          'intensity': 'INTENSE',
          'subtropical_jet_speed_kt': 135.0,
          'trough_500hpa_depth_dam': 546.0,
          'induced_cyclonic_circulation': 'Over Central Pakistan',
          'moisture_source': 'North Arabian Sea',
          'freezing_level_m': 2150.0,
          'synoptic_summary': 'Deep trough causing intense snowfall.',
        },
        'vernacular_bulletins': {
          'en': 'DGRE / IMD AVALANCHE WARNING: Zoji La is under LEVEL 4 RED HIGH DANGER.',
          'hi': 'डीजीआरई / आईएमडी चेतावनी: ज़ੋਜੀ ਲਾ में रेड अलर्ट लागू है।',
        },
        'dgre_advisory_bulletin_no': 'DGRE-IMD/HIM/2026-WD-TEST',
        'provenance': 'IMD Mountain Weather & DRDO DGRE',
      };

      final model = AvalancheSnowResponseModel.fromJson(json);
      expect(model.selectedSector.sectorId, 'zojila_dras');
      expect(model.selectedSector.dangerLevel, 'LEVEL_4_RED_HIGH_DANGER');
      expect(model.selectedSector.snowpack.totalSnowpackDepthCm, 210.0);
      expect(model.selectedSector.passStatus.status, 'CLOSED_SNOW_CLEARING');
      expect(model.westernDisturbance.intensity, 'INTENSE');
      expect(model.vernacularBulletins['en'], contains('LEVEL 4 RED'));
    });

    test('AvalancheSnowResponseModel defaultFallback provides safe calibrated defaults', () {
      final fallback = AvalancheSnowResponseModel.defaultFallback();
      expect(fallback.selectedSector.sectorId, 'gulmarg_pir_panjal');
      expect(fallback.allSectors.length, greaterThanOrEqualTo(2));
      expect(fallback.westernDisturbance.intensity, 'INTENSE');
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('ur'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('pa'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('bn'), isTrue);
      expect(fallback.isOfflineCached, isTrue);
    });
  });

  group('AvalancheSnowScreen Widget Tests', () {
    testWidgets('Renders AvalancheSnowScreen with overview, telemetry HUD, pass status, and multilingual toggle',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2200));

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: MaterialApp(
            home: AvalancheSnowScreen(
              initialData: AvalancheSnowResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      // Allow async initState and postFrameCallback to complete
      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text('Himalayan Snowpack & Avalanche'), findsOneWidget);

      // Verify sector chips
      expect(find.text('Himalayan Monitoring Sectors'), findsOneWidget);

      // Verify hero danger classification card
      expect(find.text('Gulmarg & Apharwat Sector'), findsOneWidget);
      expect(find.text('LEVEL 3 ORANGE DANGER'), findsOneWidget);

      // Verify Cryospheric Snowpack Physics HUD
      expect(find.text('Cryospheric Snowpack Physics'), findsOneWidget);
      expect(find.text('24h Fresh Snow'), findsOneWidget);
      expect(find.text('Snow Water Eq. (SWE)'), findsOneWidget);

      // Verify BRO Pass status
      expect(find.text('BRO Mountain Pass Transit Corridor'), findsOneWidget);
      expect(find.text('CHAINS MANDATORY'), findsOneWidget);

      // Verify multilingual switcher: tap Hindi chip
      expect(find.text('Emergency Avalanche Bulletin'), findsOneWidget);
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();

      // Verify Hindi text rendered
      expect(find.textContaining('डीजीआरई / आईएमडी'), findsOneWidget);
    });
  });
}
