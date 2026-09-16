import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/snowmelt_runoff_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/snowmelt_runoff_screen.dart';

void main() {
  group('IMD, CWC & DGRE Himalayan Snowmelt Runoff Model Unit Tests', () {
    test('SnowmeltRunoffResponseModel parses valid JSON correctly', () {
      final json = {
        'basin_id': 'bhagirathi_tehri',
        'basin_name': 'Bhagirathi & Alaknanda Basin (Tehri Dam Catchment)',
        'state': 'Uttarakhand',
        'current_basin': {
          'basin_id': 'bhagirathi_tehri',
          'basin_name': 'Bhagirathi & Alaknanda Basin (Tehri Dam Catchment)',
          'state': 'Uttarakhand',
          'mountain_range': 'Garhwal Himalaya',
          'drainage_area_sq_km': 7511.0,
          'current_regime': 'GLACIAL_ABLATION_PEAK',
          'elevation_bands': [
            {
              'band_id': 'ZONE_A',
              'elevation_range_label': '1,000m - 2,500m AMSL (Tehri Valley)',
              'elevation_min_m': 1000.0,
              'elevation_max_m': 2500.0,
              'zonal_area_sq_km': 1650.0,
              'snow_cover_area_pct': 0.0,
              'mean_temperature_c': 19.2,
              'degree_day_factor_cm_per_deg_c_day': 0.40,
              'daily_melt_volume_mcm': 0.0,
            },
            {
              'band_id': 'ZONE_B',
              'elevation_range_label': '2,500m - 3,800m AMSL (Sub-Alpine)',
              'elevation_min_m': 2500.0,
              'elevation_max_m': 3800.0,
              'zonal_area_sq_km': 2180.0,
              'snow_cover_area_pct': 34.0,
              'mean_temperature_c': 9.5,
              'degree_day_factor_cm_per_deg_c_day': 0.52,
              'daily_melt_volume_mcm': 11.5,
            },
          ],
          'cryosphere_telemetry': {
            'snow_line_altitude_m': 3950.0,
            'equilibrium_line_altitude_m': 5100.0,
            'freezing_level_isotherm_m': 4850.0,
            'basin_snow_water_equivalent_mm': 210.0,
            'fresh_snow_24h_cm': 0.0,
            'satellite_ndsi_coverage_pct': 96.0,
          },
          'runoff_metrics': {
            'daily_discharge_cumecs': 890.0,
            'snowmelt_fraction_pct': 58.0,
            'rainfall_contribution_pct': 24.0,
            'baseflow_contribution_pct': 18.0,
            'peak_diurnal_hour_ist': '17:30 IST',
            'peak_diurnal_discharge_cumecs': 1150.0,
            'diurnal_discharge_amplitude_pct': 38.5,
          },
          'hydropower_inflows': [
            {
              'dam_name': 'Tehri Dam Hydro Complex',
              'river_basin': 'Bhagirathi River',
              'installed_capacity_mw': 2400.0,
              'live_inflow_cumecs': 845.0,
              'generation_capacity_utilized_pct': 88.0,
              'daily_storage_gain_mcm': 52.0,
              'spillway_clearance_margin_m': 12.5,
              'inflow_status': 'NORMAL_STORAGE_FILL',
            },
          ],
          'riparian_safety_advisory': 'Glacial ablation surge in Gangotri.',
          'vernacular_bulletins': {
            'en': 'Active glacial ablation generating 890 cumecs.',
            'hi': 'गंगोत्री ग्लेशियर से बर्फ पिघलने से टिहरी में 890 क्यूमेक प्रवाह।',
          },
        },
        'all_basins': [
          {
            'basin_id': 'bhagirathi_tehri',
            'basin_name': 'Bhagirathi Basin',
            'state': 'Uttarakhand',
            'river_system': 'Garhwal Himalaya',
            'daily_discharge_cumecs': 890.0,
            'snowmelt_fraction_pct': 58.0,
            'inflow_status': 'NORMAL_STORAGE_FILL',
          },
        ],
        'last_updated_utc': '2026-09-12T12:00:00Z',
        'data_source': 'IMD, CWC, DRDO-DGRE & NRSC-ISRO',
      };

      final model = SnowmeltRunoffResponseModel.fromJson(json);
      expect(model.basinId, 'bhagirathi_tehri');
      expect(model.basinName, 'Bhagirathi & Alaknanda Basin (Tehri Dam Catchment)');
      expect(model.state, 'Uttarakhand');
      expect(model.currentBasin.currentRegime, 'GLACIAL_ABLATION_PEAK');
      expect(model.currentBasin.elevationBands.length, 2);
      expect(model.currentBasin.elevationBands[0].bandId, 'ZONE_A');
      expect(model.currentBasin.cryosphereTelemetry.snowLineAltitudeM, 3950.0);
      expect(model.currentBasin.cryosphereTelemetry.freezingLevelIsothermM, 4850.0);
      expect(model.currentBasin.runoffMetrics.dailyDischargeCumecs, 890.0);
      expect(model.currentBasin.runoffMetrics.snowmeltFractionPct, 58.0);
      expect(model.currentBasin.hydropowerInflows.length, 1);
      expect(model.currentBasin.hydropowerInflows[0].damName, 'Tehri Dam Hydro Complex');
      expect(model.currentBasin.hydropowerInflows[0].installedCapacityMw, 2400.0);
      expect(model.currentBasin.vernacularBulletins['hi'], contains('टिहरी'));
      expect(model.allBasins.length, 1);
    });

    test('SnowmeltRunoffResponseModel defaultFallback provides calibrated Satluj & Bhakra baseline', () {
      final fallback = SnowmeltRunoffResponseModel.defaultFallback();
      expect(fallback.basinId, 'satluj_bhakra');
      expect(fallback.basinName, 'Satluj Basin & Bhakra Reservoir Catchment');
      expect(fallback.state, 'Himachal Pradesh');
      expect(fallback.currentBasin.currentRegime, 'SEASONAL_SNOWMELT_SURGE');
      expect(fallback.currentBasin.elevationBands.length, 4);
      expect(fallback.currentBasin.cryosphereTelemetry.freezingLevelIsothermM, 4620.0);
      expect(fallback.currentBasin.runoffMetrics.dailyDischargeCumecs, 1420.0);
      expect(fallback.currentBasin.runoffMetrics.snowmeltFractionPct, 64.5);
      expect(fallback.currentBasin.hydropowerInflows.length, 2);
      expect(fallback.currentBasin.hydropowerInflows[0].damName, 'Bhakra Dam (Gobind Sagar)');
      expect(fallback.allBasins.length, 7);

      // Verify all 7 vernacular languages
      final bulletins = fallback.currentBasin.vernacularBulletins;
      expect(bulletins.containsKey('en'), true);
      expect(bulletins.containsKey('hi'), true);
      expect(bulletins.containsKey('pa'), true);
      expect(bulletins.containsKey('ne'), true);
      expect(bulletins.containsKey('ks'), true);
      expect(bulletins.containsKey('bn'), true);
      expect(bulletins.containsKey('bo'), true);

      expect(bulletins['hi'], contains('सतलुज'));
      expect(bulletins['pa'], contains('ਸਤਲੁਜ'));
    });
  });

  group('SnowmeltRunoffScreen Widget Tests', () {
    testWidgets('Renders SnowmeltRunoffScreen with basin selector, hero discharge card, cryosphere HUD, SRM matrix, hydropower inflows, and language switcher',
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
            home: SnowmeltRunoffScreen(
              initialData: SnowmeltRunoffResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Himalayan Snowmelt Runoff (SRM)'), findsOneWidget);
      expect(find.text('IMD, CWC, DGRE & ISRO Cryospheric Hydrology'), findsOneWidget);

      // Verify Basin selector section
      expect(find.text('HIMALAYAN SNOW & GLACIAL CATCHMENTS'), findsOneWidget);
      expect(find.text('7 Monitored Basins'), findsOneWidget);

      // Verify Hero Catchment Card
      expect(find.text('Satluj Basin & Bhakra Reservoir Catchment'), findsOneWidget);
      expect(find.text('SEASONAL SNOWMELT SURGE'), findsOneWidget);
      expect(find.text('RIVER DISCHARGE'), findsOneWidget);
      expect(find.text('1420'), findsOneWidget);
      expect(find.text('SNOWMELT FRACTION'), findsOneWidget);
      expect(find.text('64.5%'), findsOneWidget);
      expect(find.text('DIURNAL CREST'), findsOneWidget);
      expect(find.text('18:00 IST'), findsOneWidget);

      // Verify Cryospheric Telemetry HUD
      expect(find.text('CRYOSPHERIC SNOWPACK & ISOTHERM TELEMETRY'), findsOneWidget);
      expect(find.text('SNOW LINE ALTITUDE (SLA)'), findsOneWidget);
      expect(find.text('3250 m'), findsOneWidget);
      expect(find.text('FREEZING LEVEL (0°C)'), findsOneWidget);
      expect(find.text('4620 m'), findsOneWidget);
      expect(find.text('EQUILIBRIUM LINE (ELA)'), findsOneWidget);
      expect(find.text('4750 m'), findsOneWidget);
      expect(find.text('SNOW WATER EQUIVALENT'), findsOneWidget);
      expect(find.text('285 mm'), findsOneWidget);

      // Verify Martinec-Rango SRM Hypsometric Zonal Matrix
      expect(find.text('MARTINEC-RANGO SRM HYPSOMETRIC ZONAL MATRIX'), findsOneWidget);
      expect(find.text('1,500m - 2,500m AMSL (Lower Valley)'), findsOneWidget);
      expect(find.text('2,500m - 3,500m AMSL (Mid-Elevation Snowpack)'), findsOneWidget);
      expect(find.text('3,500m - 4,500m AMSL (Sub-Glacial Firn Zone)'), findsOneWidget);
      expect(find.text('> 4,500m AMSL (Perpetual Cryosphere & Glaciers)'), findsOneWidget);
      expect(find.text('Z-A'), findsOneWidget);
      expect(find.text('Z-D'), findsOneWidget);

      // Verify Downstream Hydropower Dam Inflows
      expect(find.text('DOWNSTREAM HYDROPOWER & DAM STORAGE INFLOW'), findsOneWidget);
      expect(find.text('Bhakra Dam (Gobind Sagar)'), findsOneWidget);
      expect(find.text('Nathpa Jhakri Hydroelectric Plant'), findsOneWidget);
      expect(find.text('OPTIMAL GENERATION SURGE'), findsNWidgets(2));

      // Verify Riparian Safety Advisory Card
      expect(find.text('DOWNSTREAM RIPARIAN & RIVERBED SAFETY DIRECTIVE'), findsOneWidget);
      expect(find.textContaining('Rampur Bushahr to Bilaspur'), findsOneWidget);

      // Verify Regional Mountain Bulletin Card
      expect(find.text('MOUNTAIN BASIN HYDRO-MET BULLETIN'), findsOneWidget);

      // Tap Hindi chip
      final hiChip = find.text('हिन्दी (HI)');
      expect(hiChip, findsOneWidget);
      await tester.tap(hiChip);
      await tester.pumpAndSettle();

      // Verify Hindi text is displayed
      expect(find.textContaining('आईएमडी-सीडब्ल्यूसी सतलुज हिमद्रवण बुलेटिन'), findsOneWidget);

      // Tap Punjabi chip
      final paChip = find.text('ਪੰਜਾਬੀ (PA)');
      expect(paChip, findsOneWidget);
      await tester.tap(paChip);
      await tester.pumpAndSettle();

      // Verify Punjabi text is displayed
      expect(find.textContaining('ਸਤਲੁਜ ਬੇਸਿਨ ਬਰਫ਼ ਪਿਘਲਣ ਬੁਲੇਟਿਨ'), findsOneWidget);
    });
  });
}
