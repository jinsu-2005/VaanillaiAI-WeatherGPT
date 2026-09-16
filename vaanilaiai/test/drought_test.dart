import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/drought_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/drought_monitor_screen.dart';

void main() {
  group('IMD & CGWB Agricultural Drought Model Unit Tests', () {
    test('AgriculturalDroughtResponseModel parses valid JSON correctly', () {
      final json = {
        'timestamp': '2026-09-12T06:00:00Z',
        'selected_hotspot': {
          'hotspot_id': 'marathwada_latur',
          'district_name': 'Latur & Marathwada Rain-Shadow Zone',
          'state': 'Maharashtra',
          'latitude': 18.4088,
          'longitude': 76.5604,
          'agro_climatic_subzone': 'Central Maharashtra Plateau Zone (Zone 8)',
          'primary_crops': ['Soybean', 'Pigeonpea (Tur)', 'Sorghum', 'Cotton'],
          'severity': 'WARNING_SEVERE_DROUGHT',
          'meteorological': {
            'spi_1': -1.45,
            'spi_3': -1.82,
            'spi_6': -1.68,
            'rainfall_departure_lpa_pct': -48.0,
            'consecutive_dry_days': 24,
            'drought_stage_verdict': 'Severe Meteorological Drought (Orange Category)',
          },
          'soil_moisture': {
            'root_zone_soil_moisture_pct': 14.5,
            'field_capacity_pct': 34.0,
            'permanent_wilting_point_pct': 12.0,
            'available_water_capacity_mm': 18.2,
            'smdi': -2.85,
            'crop_water_stress_index': 0.82,
            'stress_level': 'Severe Root-Zone Desiccation — Wilting Imminent',
          },
          'groundwater': {
            'depth_to_water_table_m_bgl': 24.8,
            'stage_of_extraction_pct': 108.5,
            'aquifer_category': 'OVER_EXPLOITED',
            'annual_recharge_potential_mcm': 142.5,
            'borewell_yield_trend': 'DECLINING',
            'irrigation_rationing_status': 'Over-Exploited Aquifer: Restrict borewell pumping to critical intervals.',
          },
          'agronomic_directives': {
            'crop_stage_advisory': 'Soybean is at flowering to early pod fill; high flower drop risk.',
            'irrigation_scheduling': 'Apply protective life-saving irrigation via micro-sprinklers.',
            'moisture_conservation': 'Spray 1% KNO3 foliar spray to alleviate thermal stress.',
            'contingency_crop_switch': 'Prepare field for contingency horse gram or moth bean.',
            'livestock_fodder_advisory': 'Store green fodder silage; procure dry sorghum stover.',
          },
        },
        'all_hotspots': [],
        'vernacular_bulletins': {
          'en': 'IMD & CGWB AGRICULTURAL DROUGHT ADVISORY: Latur is under WARNING SEVERE DROUGHT.',
          'mr': 'आयएमडी आणि सीजीडब्ल्यूबी दुष्काळ व भूजल सल्ला: लातूर आणि मराठवाड्यात तीव्र दुष्काळ इशारा.',
        },
        'bulletin_number': 'IMD-CGWB/DROUGHT/202609-ASLAT',
        'provenance': 'IMD Agricultural Meteorology & CGWB',
      };

      final model = AgriculturalDroughtResponseModel.fromJson(json);
      expect(model.selectedHotspot.hotspotId, 'marathwada_latur');
      expect(model.selectedHotspot.severity, 'WARNING_SEVERE_DROUGHT');
      expect(model.selectedHotspot.meteorological.spi3, -1.82);
      expect(model.selectedHotspot.soilMoisture.rootZoneSoilMoisturePct, 14.5);
      expect(model.selectedHotspot.groundwater.stageOfExtractionPct, 108.5);
      expect(model.vernacularBulletins['mr'], contains('आयएमडी आणि सीजीडब्ल्यूबी'));
    });

    test('AgriculturalDroughtResponseModel defaultFallback provides calibrated dryland baseline', () {
      final fallback = AgriculturalDroughtResponseModel.defaultFallback();
      expect(fallback.selectedHotspot.hotspotId, 'marathwada_latur');
      expect(fallback.allHotspots.length, greaterThanOrEqualTo(2));
      expect(fallback.selectedHotspot.meteorological.spi3, lessThan(-1.5));
      expect(fallback.vernacularBulletins.containsKey('en'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('mr'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('te'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('kn'), isTrue);
      expect(fallback.isOfflineCached, isTrue);
    });
  });

  group('DroughtMonitorScreen Widget Tests', () {
    testWidgets('Renders DroughtMonitorScreen with hero severity, SPI grid, soil moisture HUD, and Marathi vernacular toggle',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: MaterialApp(
            home: DroughtMonitorScreen(
              initialData: AgriculturalDroughtResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Drought, Soil Moisture & Groundwater'), findsOneWidget);
      expect(find.text('IMD SPI • Soil Moisture (RZSM) • CGWB Aquifers'), findsOneWidget);

      // Verify Belts selector header
      expect(find.text('Rainfed Drought Monitoring Belts'), findsOneWidget);

      // Verify Hero card
      expect(find.text('Latur & Marathwada Rain-Shadow Zone'), findsAtLeastNWidgets(1));
      expect(find.text('WARNING SEVERE DROUGHT'), findsOneWidget);

      // Verify Meteorological SPI grid
      expect(find.text('Meteorological Drought Indices (IMD Standardized Precipitation Index)'), findsOneWidget);
      expect(find.text('SPI-1 (1 Month)'), findsOneWidget);
      expect(find.text('SPI-3 (Seasonal)'), findsOneWidget);
      expect(find.text('SPI-6 (Hydrological)'), findsOneWidget);

      // Verify Soil Moisture Stress HUD
      expect(find.text('Root-Zone Soil Moisture & Crop Water Stress (SMDI)'), findsOneWidget);
      expect(find.text('Root-Zone Moisture'), findsOneWidget);
      expect(find.text('Plant Available (AWC)'), findsOneWidget);
      expect(find.text('Crop Stress (CWSI)'), findsOneWidget);

      // Verify CGWB Groundwater Card
      expect(find.text('CGWB Hydrogeology & Aquifer Depletion Status'), findsOneWidget);
      expect(find.text('Extraction (SOE %)'), findsOneWidget);
      expect(find.text('Water Table Depth'), findsOneWidget);
      expect(find.text('Aquifer Classification'), findsOneWidget);

      // Verify ICAR-CRIDA Agricultural Directives
      expect(find.text('ICAR-CRIDA Agricultural Drought Directives'), findsOneWidget);
      expect(find.text('Crop Stage Protection'), findsOneWidget);
      expect(find.text('Irrigation Scheduling'), findsOneWidget);
      expect(find.text('Moisture Conservation'), findsOneWidget);

      // Verify Multilingual bulletin switcher
      expect(find.text('Regional Drought Advisory Bulletin'), findsOneWidget);
      final marathiChip = find.text('मराठी');
      expect(marathiChip, findsOneWidget);
      await tester.tap(marathiChip);
      await tester.pumpAndSettle();

      // Verify Marathi bulletin rendered
      expect(find.textContaining('आयएमडी आणि सीजीडब्ल्यूबी'), findsOneWidget);
    });
  });
}
