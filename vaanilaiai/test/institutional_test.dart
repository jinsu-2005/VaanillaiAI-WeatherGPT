import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/marine_model.dart';
import 'package:vaanilaiai/models/crop_stage_model.dart';
import 'package:vaanilaiai/models/lightning_model.dart';
import 'package:vaanilaiai/models/citizen_report_model.dart';
import 'package:vaanilaiai/models/sky_analysis_model.dart';

void main() {
  group('Institutional Models Tests', () {
    test('MarineAdvisoryModel deserialization test', () {
      final json = {
        'location_name': 'Chennai Coast',
        'coastal_region': 'Bay of Bengal Coastal Sector',
        'date': '2026-09-11',
        'sea_condition': 'Moderate',
        'sea_condition_color': 'Yellow',
        'significant_wave_height_m': 1.8,
        'swell_period_seconds': 10.2,
        'coastal_wind_knots': 18,
        'coastal_wind_kmh': 33.3,
        'wind_gusts_kmh': 42.0,
        'wind_direction_deg': 190,
        'wind_direction_cardinal': 'S',
        'sea_surface_temperature_c': 29.2,
        'chlorophyll_a_mg_m3': 1.6,
        'potential_fishing_zone_status': 'High Density Belt',
        'pfz_bearing_direction': '145° SE',
        'pfz_distance_nautical_miles': 16.5,
        'deep_sea_navigation_safe': true,
        'fishermen_warning_text': 'Safe for mechanized vessels.',
        'port_warning_signal_number': 3,
        'port_warning_signal_name': 'Signal No. III',
        'port_warning_signal_description': 'Local cautionary signal.',
        'tide_high_time': '01:45 PM',
        'tide_high_height_m': 1.6,
        'tide_low_time': '07:20 PM',
        'tide_low_height_m': 0.4,
      };

      final model = MarineAdvisoryModel.fromJson(json);
      expect(model.locationName, 'Chennai Coast');
      expect(model.significantWaveHeightM, 1.8);
      expect(model.portWarningSignalNumber, 3);
      expect(model.potentialFishingZoneStatus, 'High Density Belt');
    });

    test('CropStageAdvisoryModel deserialization test', () {
      final json = {
        'crop_type': 'Paddy/Rice',
        'growth_stage': 'Flowering',
        'location_name': 'Thanjavur',
        'stage_vulnerability': 'Critical',
        'water_requirement_status': 'High Moisture Essential',
        'irrigation_directive': 'Do not let field go dry.',
        'chemical_spraying_directive': 'Avoid anthesis hours.',
        'pest_disease_alert': 'Brown plant hopper scout.',
        'harvest_logistics_advice': 'Clear threshing floors.',
        'action_items': ['Scout base of hills', 'Avoid noon spray'],
      };

      final model = CropStageAdvisoryModel.fromJson(json);
      expect(model.cropType, 'Paddy/Rice');
      expect(model.stageVulnerability, 'Critical');
      expect(model.actionItems.length, 2);
    });

    test('LightningAlertModel deserialization test', () {
      final json = {
        'location_name': 'Vellore',
        'threat_level': 'High Threat',
        'nearest_strike_km': 12.4,
        'strikes_last_30m': 14,
        'strike_trend': 'Approaching Eastward',
        'cape_thunderstorm_index_j_kg': 1650.0,
        'sound_rumble_audible': true,
        'safety_rule_30_30': 'Flash to bang < 30 seconds.',
        'field_safety_guidance': ['Crouch in low spot', 'Avoid open tractors'],
        'last_updated': '17:30 IST',
      };

      final model = LightningAlertModel.fromJson(json);
      expect(model.threatLevel, 'High Threat');
      expect(model.nearestStrikeKm, 12.4);
      expect(model.soundRumbleAudible, true);
      expect(model.capeThunderstormIndexJKg, 1650.0);
    });

    test('CitizenReportModel serialization and deserialization test', () {
      final json = {
        'id': 'rep_101',
        'report_type': 'Waterlogging',
        'severity': 'Moderate',
        'water_depth_inches': 9.0,
        'description': 'Underpass submerged up to knee level.',
        'latitude': 13.0827,
        'longitude': 80.2707,
        'location_name': 'Chennai Central',
        'reporter_role': 'Citizen',
        'upvotes': 15,
        'created_at': '10m ago',
      };

      final model = CitizenReportModel.fromJson(json);
      expect(model.id, 'rep_101');
      expect(model.waterDepthInches, 9.0);
      expect(model.upvotes, 15);

      final exported = model.toJson();
      expect(exported['water_depth_inches'], 9.0);
      expect(exported['report_type'], 'Waterlogging');
    });

    test('SkyAnalysisModel deserialization test', () {
      final json = {
        'cloud_genus': 'Cumulonimbus Calvus',
        'cloud_description': 'Dense towering thundercloud.',
        'cloud_coverage_percentage': 85,
        'rain_onset_estimated_minutes': 25,
        'squall_risk_level': 'High',
        'confidence_score': 0.94,
        'actionable_verdict': 'Seek shelter; secure grain.',
        'vernacularSummary': 'மழை விரைவில் வரும்.',
      };

      final model = SkyAnalysisModel.fromJson(json);
      expect(model.cloudGenus, 'Cumulonimbus Calvus');
      expect(model.rainOnsetEstimatedMinutes, 25);
      expect(model.squallRiskLevel, 'High');
      expect(model.dataUnavailable, false);
    });

    test('MarineAdvisoryModel.unavailable factory test', () {
      final model = MarineAdvisoryModel.unavailable('Rameshwaram Coast');
      expect(model.locationName, 'Rameshwaram Coast');
      expect(model.dataUnavailable, true);
      expect(model.seaCondition, 'Data Unavailable');
      expect(model.deepSeaNavigationSafe, false);
    });

    test('LightningAlertModel.unavailable factory test', () {
      final model = LightningAlertModel.unavailable('Madurai');
      expect(model.locationName, 'Madurai');
      expect(model.dataUnavailable, true);
      expect(model.threatLevel, 'Unknown');
      expect(model.strikesLast30m, 0);
    });

    test('SkyAnalysisModel.unavailable factory test', () {
      final model = SkyAnalysisModel.unavailable('Salem');
      expect(model.dataUnavailable, true);
      expect(model.cloudGenus, 'Unknown');
      expect(model.confidenceScore, 0.0);
    });
  });
}
