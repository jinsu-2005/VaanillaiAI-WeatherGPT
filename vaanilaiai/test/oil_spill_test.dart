import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/oil_spill_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/oil_spill_screen.dart';

void main() {
  group('INCOIS & ICG Marine Oil Spill Trajectory Model Unit Tests', () {
    test('OilSpillResponseModel parses valid JSON correctly', () {
      final json = {
        'selected_corridor': {
          'corridor_id': 'gulf_of_kutch_vadinar',
          'corridor_name': 'Gulf of Kutch & Vadinar SBM Offshore Corridor',
          'state_or_ut': 'Gujarat',
          'latitude': 22.48,
          'longitude': 69.72,
          'spill_volume_tonnes': 3500.0,
          'oil_type': 'MEDIUM_CRUDE_ARABIAN_LIGHT',
          'severity_tier': 'TIER_2_REGIONAL_COAST_GUARD',
          'drift_vector': {
            'surface_current_speed_knots': 2.8,
            'surface_current_direction_deg': 115.0,
            'wind_speed_10m_knots': 18.5,
            'wind_direction_deg': 290.0,
            'net_drift_speed_knots': 3.2,
            'net_drift_direction_deg': 108.0,
            'stokes_drift_knots': 0.35,
          },
          'trajectory_waypoints': [
            {
              'time_horizon_hours': 6,
              'latitude': 22.44,
              'longitude': 69.88,
              'distance_traveled_km': 17.8,
              'slick_area_km2': 14.2,
              'slick_thickness_microns': 125.0,
              'appearance_code': 'CODE_4_DISCONTINUOUS_TRUE',
              'shoreline_hit_risk': 'MODERATE_OFFSHORE',
            },
          ],
          'fay_spreading': {
            'current_regime': 'GRAVITY_VISCOUS_REGIME_II',
            'slick_radius_meters': 3200.0,
            'slick_area_km2': 32.17,
            'average_thickness_microns': 82.5,
            'bonn_code': 'CODE_4_DISCONTINUOUS_TRUE',
            'thick_core_area_pct': 15.0,
          },
          'weathering': {
            'evaporated_fraction_pct': 34.2,
            'emulsified_water_fraction_pct': 62.0,
            'emulsion_viscosity_cst': 18500.0,
            'viscosity_increase_factor': 37.0,
            'natural_dispersion_fraction_pct': 8.4,
            'sedimentation_sinking_risk': 'MODERATE_NEARSHORE_SUSPENDED_SEDIMENT',
            'flash_point_celsius': 68.0,
          },
          'sensitive_habitats': [
            {
              'habitat_id': 'marine_national_park_jamnagar',
              'habitat_name': 'Marine National Park & Coral Sanctuaries (Pirotan & Narara)',
              'ecosystem_type': 'Fringing Coral Reefs & Scleractinian Corals',
              'esi_rating': 10,
              'distance_from_slick_km': 14.5,
              'estimated_impact_eta_hours': 9,
              'priority_protection_rank': 'PRIORITY_1_IMMEDIATE_DEFENSE',
              'boom_defense_plan':
                  'Deploy 2,400m Offshore Curtain Boom at Pirotan Channel mouth with deflection angle 45°.',
            },
          ],
          'icg_directives': {
            'nosdcp_activation_level': 'TIER_2_REGIONAL_COAST_GUARD',
            'lead_response_authority':
                'Indian Coast Guard District HQ No. 1 (Porbandar / Vadinar)',
            'containment_boom_type':
                'Offshore High-Buoyancy Inflatable Curtain Boom (1200mm skirt)',
            'recommended_boom_length_meters': 3500.0,
            'maximum_towing_speed_knots': 0.75,
            'skimmer_selection':
                'Oleophilic Multi-Disc & Brush Skimmer (Recovery capacity: 120 m³/h)',
            'chemical_dispersant_clearance':
                'CONDITIONAL: Permitted outside 5km Marine National Park buffer where depth >20m.',
            'dispersant_restrictions':
                'PROHIBITED in coral lagoons, intertidal mudflats, and oyster beds of Pirotan.',
            'coast_guard_emergency_no': '1554',
          },
        },
        'all_corridors': [
          {
            'corridor_id': 'gulf_of_kutch_vadinar',
            'corridor_name': 'Gulf of Kutch & Vadinar SBM Offshore Corridor',
            'state_or_ut': 'Gujarat',
            'severity_tier': 'TIER_2_REGIONAL_COAST_GUARD',
            'oil_type': 'MEDIUM_CRUDE_ARABIAN_LIGHT',
            'spill_volume_tonnes': 3500.0,
            'slick_area_km2': 32.17,
            'nearest_habitat_eta_hours': 4,
          }
        ],
        'bulletins': {
          'en':
              'INCOIS-ICG MARINE OIL SPILL ADVISORY for Gulf of Kutch & Vadinar: TIER 2 REGIONAL WARNING declared.',
          'ta':
              'இன்கோயிஸ் - இந்திய கடலோர காவல்படை (ICG) எச்சரிக்கை: கட்ச் வளைகுடாவில் எண்ணெய் கசிவு.',
          'gu':
              'ઇનકોઇસ અને ભારતીય કોસ્ટ ગાર્ડ ચેતવણી: કચ્છના અખાતમાં ક્રૂડ ઓઇલ ગળતર માટે ટાયર ૨ કટોકટી.',
        },
        'offline_cached': false,
        'generated_at': '2026-09-12T06:00:00Z',
      };

      final model = OilSpillResponseModel.fromJson(json);
      expect(model.selectedCorridor.corridorId, 'gulf_of_kutch_vadinar');
      expect(model.selectedCorridor.severityTier, 'TIER_2_REGIONAL_COAST_GUARD');
      expect(model.selectedCorridor.spillVolumeTonnes, 3500.0);
      expect(model.selectedCorridor.driftVector.netDriftSpeedKnots, 3.2);
      expect(model.selectedCorridor.faySpreading.slickAreaKm2, 32.17);
      expect(model.selectedCorridor.sensitiveHabitats.length, 1);
      expect(model.selectedCorridor.sensitiveHabitats.first.esiRating, 10);
      expect(model.selectedCorridor.icgDirectives.coastGuardEmergencyNo, '1554');
      expect(model.bulletins['gu'], contains('કચ્છના અખાતમાં'));
    });

    test('OilSpillResponseModel defaultFallback provides safe calibrated defaults', () {
      final fallback = OilSpillResponseModel.defaultFallback();
      expect(fallback.selectedCorridor.corridorId, 'gulf_of_kutch_vadinar');
      expect(fallback.selectedCorridor.severityTier, 'TIER_2_REGIONAL_COAST_GUARD');
      expect(fallback.allCorridors.length, 7);
      expect(fallback.selectedCorridor.sensitiveHabitats.length, greaterThanOrEqualTo(2));
      expect(fallback.selectedCorridor.trajectoryWaypoints.length, 5);
      expect(fallback.bulletins.containsKey('en'), isTrue);
      expect(fallback.bulletins.containsKey('ta'), isTrue);
      expect(fallback.bulletins.containsKey('bn'), isTrue);
      expect(fallback.bulletins.containsKey('ml'), isTrue);
      expect(fallback.bulletins.containsKey('gu'), isTrue);
      expect(fallback.bulletins.containsKey('mr'), isTrue);
      expect(fallback.bulletins.containsKey('od'), isTrue);
      expect(fallback.offlineCached, isTrue);
    });
  });

  group('OilSpillScreen Widget Tests', () {
    testWidgets('Renders OilSpillScreen with hero cards, trajectory HUD, ESI habitats, and multilingual toggle',
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
            home: OilSpillScreen(
              initialData: OilSpillResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      // Allow async initState and postFrameCallback to complete
      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Marine Oil Spill & Habitat Radar'), findsOneWidget);
      expect(find.text('INCOIS · Indian Coast Guard (NOS-DCP)'), findsOneWidget);

      // Verify corridor selector chips
      expect(find.text('Gulf of Kutch (GJ)'), findsOneWidget);
      expect(find.text('Mumbai & JNPT (MH)'), findsOneWidget);

      // Verify hero spill severity banner
      expect(find.text('TIER 2 · REGIONAL COAST GUARD'), findsOneWidget);
      expect(find.text('Tonnes Spilled'), findsOneWidget);
      expect(find.text('3500'), findsOneWidget);

      // Verify Hydrodynamic Drift & 72h Trajectory card
      expect(find.text('Hydrodynamic Drift & 72h Trajectory'), findsOneWidget);
      expect(find.text('Tidal Current'), findsOneWidget);
      expect(find.text('Surface Wind'), findsOneWidget);
      expect(find.text('Stokes Wave Drift'), findsOneWidget);

      // Verify Fay Spreading & Chemical Weathering HUD
      expect(find.text('Fay Spreading & Chemical Weathering HUD'), findsOneWidget);
      expect(find.text('Slick Area'), findsOneWidget);
      expect(find.text('Avg Thickness'), findsOneWidget);
      expect(find.text('Evaporation'), findsOneWidget);

      // Verify Sensitive Coastal Habitats & ESI Priority card
      expect(find.text('Sensitive Coastal Habitats & ESI Priority'), findsOneWidget);
      expect(find.text('ESI 10/10'), findsWidgets);

      // Verify Indian Coast Guard (NOS-DCP) Directives card
      expect(find.text('Indian Coast Guard (NOS-DCP) Directives'), findsOneWidget);
      expect(find.text('HOTLINE: 1554'), findsOneWidget);

      // Verify Coastal Multi-Lingual Emergency Bulletin & Tap Tamil
      expect(find.text('Coastal Multi-Lingual Emergency Bulletin'), findsOneWidget);
      final tamilChip = find.text('தமிழ்');
      expect(tamilChip, findsOneWidget);
      await tester.tap(tamilChip);
      await tester.pumpAndSettle();

      // Verify Tamil bulletin text rendered
      expect(find.textContaining('கடலோர காவல்படை'), findsOneWidget);

      // Tap Bengali chip
      final bengaliChip = find.text('বাংলা');
      expect(bengaliChip, findsOneWidget);
      await tester.tap(bengaliChip);
      await tester.pumpAndSettle();

      // Verify Bengali bulletin text rendered
      expect(find.textContaining('উপকূলরক্ষী বাহিনী'), findsOneWidget);

      // Tap Gujarati chip
      final gujaratiChip = find.text('ગુજરાતી');
      expect(gujaratiChip, findsOneWidget);
      await tester.tap(gujaratiChip);
      await tester.pumpAndSettle();

      // Verify Gujarati bulletin text rendered
      expect(find.textContaining('કચ્છના અખાતમાં'), findsOneWidget);
    });
  });
}
