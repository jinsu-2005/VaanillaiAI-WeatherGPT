import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/satellite_radar_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/providers/alert_provider.dart';
import 'package:vaanilaiai/providers/citizen_provider.dart';
import 'package:vaanilaiai/screens/weather_map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Satellite and Radar Model Unit Tests', () {
    test('DwrRadarStationModel parses JSON and serializes back correctly', () {
      final json = {
        'station_id': 'dwr_chennai_meenambakkam',
        'name': 'Chennai (Meenambakkam DWR)',
        'state': 'Tamil Nadu',
        'latitude': 12.99,
        'longitude': 80.18,
        'band': 'C-band (5cm - Severe Storm Nowcasting)',
        'frequency_ghz': 5.62,
        'max_range_km': 250,
        'status': 'Operational',
        'last_sweep_utc': '2026-09-12T00:00:00.000Z',
        'peak_reflectivity_dbz': 38.5,
        'convective_cells_detected': 3,
        'storm_motion_heading_deg': 80.0,
        'storm_motion_speed_kmh': 18.0,
      };

      final station = DwrRadarStationModel.fromJson(json);
      expect(station.stationId, 'dwr_chennai_meenambakkam');
      expect(station.name, contains('Meenambakkam'));
      expect(station.band, contains('C-band'));
      expect(station.peakReflectivityDbz, 38.5);
      expect(station.convectiveCellsDetected, 3);

      final backToJson = station.toJson();
      expect(backToJson['station_id'], 'dwr_chennai_meenambakkam');
      expect(backToJson['peak_reflectivity_dbz'], 38.5);
    });

    test('MosdacSatelliteProductModel parses and handles color gradients', () {
      final json = {
        'product_id': 'insat3dr_tir1_ctt',
        'name': 'INSAT-3DR Thermal IR (Cloud Top Temperature)',
        'satellite': 'INSAT-3DR Geostationary (74°E)',
        'sensor': 'Multispectral Imager (TIR-1 Channel)',
        'resolution_km': 4.0,
        'channel_wavelength': '10.8 µm',
        'latest_scan_time_utc': '2026-09-12T00:00:00.000Z',
        'refresh_interval_min': 15,
        'color_scale_unit': '°C',
        'color_scale_labels': ['-80°C', '-40°C', '+20°C'],
        'palette_gradient': ['#311B92', '#00ACC1', '#E53935'],
        'synoptic_interpretation': 'Identifies deep convective thunderstorm towers.',
        'tile_or_image_url': 'https://mosdac.gov.in/insat3dr/tir1_ctt.png',
        'bounds': [-10.0, 45.0, 45.0, 110.0],
      };

      final product = MosdacSatelliteProductModel.fromJson(json);
      expect(product.productId, 'insat3dr_tir1_ctt');
      expect(product.channelWavelength, '10.8 µm');
      expect(product.paletteGradient.length, 3);
      expect(product.colorScaleUnit, '°C');

      final backToJson = product.toJson();
      expect(backToJson['product_id'], 'insat3dr_tir1_ctt');
      expect(backToJson['palette_gradient'], hasLength(3));
    });

    test('SatelliteRadarOverviewModel.defaultFallback provides 100% offline baseline', () {
      final fallback = SatelliteRadarOverviewModel.defaultFallback(
        latitude: 13.0827,
        longitude: 80.2707,
        locationName: 'Chennai',
      );

      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.dwrStations, isNotEmpty);
      expect(fallback.satelliteProducts, isNotEmpty);
      expect(fallback.nearestDwrStation, isNotNull);
      expect(fallback.dataProvenance, contains('ISRO MOSDAC'));
      expect(fallback.dataProvenance, contains('IMD'));
    });
  });

  group('WeatherMapScreen Widget Tests', () {
    testWidgets('Renders WeatherMapScreen, layer switcher pills, and HUD elements cleanly', (tester) async {
      final weatherProvider = WeatherProvider();
      final alertProvider = AlertProvider();
      final citizenProvider = CitizenProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
            ChangeNotifierProvider.value(value: alertProvider),
            ChangeNotifierProvider.value(value: citizenProvider),
          ],
          child: const MaterialApp(
            home: WeatherMapScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Verify AppBar title
      expect(find.text('Live Satellite & Radar GIS'), findsOneWidget);

      // Verify layer switcher pills exist
      expect(find.text('Live Radar'), findsOneWidget);
      expect(find.text('IMD Doppler Radar'), findsOneWidget);
      expect(find.text('INSAT-3DR CTT'), findsOneWidget);
      expect(find.text('INSAT-3DR WV'), findsOneWidget);
      expect(find.text('INSAT-3DR VIS'), findsOneWidget);
      expect(find.text('Citizen Hazards'), findsOneWidget);
      expect(find.text('Disaster Zones'), findsOneWidget);

      // Verify default precipitation legend is visible
      expect(find.text('Precipitation Rate (mm/h)'), findsOneWidget);

      // Tap on IMD Doppler Radar layer
      await tester.tap(find.text('IMD Doppler Radar'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify legend switches to IMD Radar Reflectivity
      expect(find.text('IMD Radar Reflectivity (dBZ)'), findsOneWidget);

      // Tap on INSAT-3DR CTT layer
      await tester.tap(find.text('INSAT-3DR CTT'));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify legend switches to Cloud Top Temp
      expect(find.text('Cloud Top Temp (°C)'), findsOneWidget);
    });
  });
}
