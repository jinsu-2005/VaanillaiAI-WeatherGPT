import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/storm_surge_model.dart';
import 'package:vaanilaiai/screens/storm_surge_screen.dart';

void main() {
  group('INCOIS-IMD Storm Surge & Tidal Inundation Models', () {
    test('defaultFallback creates valid storm surge model with offline flag', () {
      final fallback = StormSurgeResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedSector.sectorId, 'sundarbans_wb');
      expect(fallback.selectedSector.state, 'West Bengal');
      expect(fallback.selectedSector.threatTier, 'EMERGENCY_RED');
      expect(fallback.selectedSector.hydrodynamics.totalWaterLevelM, 7.60);
      expect(fallback.selectedSector.hydrodynamics.overtoppingDepthM, 1.40);
      expect(fallback.selectedSector.hydrodynamics.coastalEmbankmentCrestM, 6.20);
      expect(fallback.selectedSector.tidalBore.borePhenomenonActive, isTrue);
      expect(fallback.selectedSector.tidalBore.boreHeightM, 2.20);
      expect(fallback.selectedSector.inundation.maxInlandIntrusionKm, 4.80);
      expect(fallback.selectedSector.inundation.embankmentBreachesReported, 5);
      expect(fallback.vernacularBulletins.containsKey('bn'), isTrue);
      expect(fallback.vernacularBulletins['bn'], contains('সুন্দরবন'));
    });

    test('fromJson and toJson parse storm surge telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'INCOIS-IMD/SS-TIDE/2026-TEST',
        'provenance': 'INCOIS-IMD Joint Storm Surge Warning Centre Test Provenance',
        'national_coastal_threat_summary': 'CRITICAL: Coastal Embankment Overtopping Active',
        'selected_sector': {
          'sector_id': 'paradeep_mahanadi_or',
          'sector_name': 'Paradeep Port & Mahanadi Estuary',
          'state': 'Odisha',
          'water_body': 'Bay of Bengal - Mahanadi River Mouth',
          'latitude': 20.3167,
          'longitude': 86.6111,
          'threat_tier': 'EMERGENCY_RED',
          'tidal_phase': 'SPRING_HIGH_TIDE',
          'cyclonic_forcing': {
            'cyclone_name': "Severe Cyclonic Storm 'Dana'",
            'imd_classification': 'Very Severe Cyclonic Storm (VSCS)',
            'sustained_wind_speed_kmh': 130.0,
            'central_pressure_hpa': 970.0,
            'forward_speed_kmh': 17.5,
            'landfall_point': 'Bhadrak Coast',
            'distance_to_landfall_km': 35.0,
          },
          'hydrodynamics': {
            'astronomical_tide_m': 3.10,
            'storm_surge_peak_m': 2.85,
            'wave_setup_m': 0.85,
            'total_water_level_m': 6.80,
            'coastal_embankment_crest_m': 5.90,
            'overtopping_depth_m': 0.90,
            'freeboard_margin_m': -0.90,
            'peak_surge_window_utc': '14:00 to 19:00 UTC',
          },
          'tidal_bore': {
            'bore_phenomenon_active': false,
            'bore_height_m': 0.40,
            'bore_propagation_speed_kmh': 12.0,
            'upstream_penetration_km': 14.0,
            'river_basin_name': 'Mahanadi - Devi River Delta',
            'bore_safety_advisory': 'Moderate surge wave propagating up river mouth.',
          },
          'inundation': {
            'max_inland_intrusion_km': 5.20,
            'estimated_inundated_area_sq_km': 142.0,
            'surge_water_salinity_ppt': 29.2,
            'embankment_breaches_reported': 4,
            'paddy_aquaculture_contamination_risk': 'CRITICAL',
          },
          'directives': {
            'sluice_gate_action': 'LOCKED_SHUT_BACKFLOW_PREVENTION',
            'storm_surge_barrier_status': 'Overwashed breakwaters',
            'cyclone_shelter_mobilization': 'Evacuation in progress',
            'marine_craft_harbor_directive': 'Boats tied down',
            'drinking_water_well_sealing_order': 'Seal tubewells',
            'designated_shelters': ['Paradeep Port MPCS Block A'],
          },
          'vernacular_bulletins': {
            'en': 'CRITICAL STORM SURGE BULLETIN: Paradeep experiencing 6.80m TWL.',
            'or': 'ଜରୁରୀକାଳୀନ ବାତ୍ୟା ଜୁଆର ଚେତାବନୀ: ପାରାଦ୍ୱୀପରେ ସମୁଦ୍ର ଜଳସ୍ତର ବୃଦ୍ଧି।',
          },
        },
        'all_sectors': [],
        'numerical_model_coupling': 'Coupled ADCIRC + SWAN',
        'vernacular_bulletins': {
          'en': 'CRITICAL STORM SURGE BULLETIN: Paradeep experiencing 6.80m TWL.',
          'or': 'ଜରୁରୀକାଳୀନ ବାତ୍ୟା ଜୁଆର ଚେତାବନୀ: ପାରାଦ୍ୱୀପରେ ସମୁଦ୍ର ଜଳସ୍ତର ବୃଦ୍ଧି।',
        },
        'is_offline_cached': false,
      };

      final parsed = StormSurgeResponseModel.fromJson(sampleJson);
      expect(parsed.selectedSector.sectorId, 'paradeep_mahanadi_or');
      expect(parsed.selectedSector.state, 'Odisha');
      expect(parsed.selectedSector.threatTier, 'EMERGENCY_RED');
      expect(parsed.selectedSector.hydrodynamics.totalWaterLevelM, 6.80);
      expect(parsed.vernacularBulletins['or'], contains('ପାରାଦ୍ୱୀପ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_sector']['sector_id'], 'paradeep_mahanadi_or');
      expect(serialized['selected_sector']['hydrodynamics']['total_water_level_m'], 6.80);
    });
  });

  group('StormSurgeScreen Widget Tests', () {
    testWidgets('renders hero TWL, ADCIRC components, tidal bore HUD, and switches language',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = StormSurgeResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: StormSurgeScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('INCOIS-IMD Storm Surge'), findsOneWidget);
      expect(find.text('ADCIRC-SWAN Hydrodynamics & Tidal Inundation'), findsOneWidget);
      expect(find.text('Sundarbans Delta & Hooghly Estuary'), findsOneWidget);
      expect(find.text('7.60'), findsOneWidget);
      expect(find.text('RED EMERGENCY'), findsOneWidget);
      expect(find.text('OVERTOPPING CRITICAL: +1.40 m'), findsOneWidget);

      // Verify ADCIRC hydrodynamic metrics
      expect(find.text('4.20 m'), findsOneWidget); // Astronomical tide
      expect(find.text('2.65 m'), findsOneWidget); // Storm surge peak
      expect(find.text('0.75 m'), findsOneWidget); // Wave setup

      // Verify Tidal Bore card
      expect(find.text('Estuarine Tidal Bore Phenomenon'), findsOneWidget);
      expect(find.text('2.20 m'), findsOneWidget); // Bore wave height
      expect(find.text('26.5 km/h'), findsOneWidget); // Bore speed

      // Verify Saline Inundation card
      expect(find.text('Saline Inundation & Soil Salinization'), findsOneWidget);
      expect(find.text('4.8 km'), findsOneWidget); // Max intrusion
      expect(find.text('28.5 PPT'), findsOneWidget); // Salinity

      // Verify English bulletin is shown by default
      expect(
        find.textContaining('EMERGENCY STORM SURGE WARNING: Sundarbans & Hooghly Estuary'),
        findsOneWidget,
      );

      // Switch to Bengali bulletin
      final bengaliChip = find.text('বাংলা');
      expect(bengaliChip, findsOneWidget);
      await tester.tap(bengaliChip);
      await tester.pumpAndSettle();

      // Verify Bengali vernacular text appears
      expect(find.textContaining('জরুরি ঘূর্ণিঝড় জলোচ্ছ্বাস সতর্কবার্তা'), findsOneWidget);
    });
  });
}
