import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/alert_model.dart';
import '../models/advisory_model.dart';
import '../models/climate_model.dart';
import '../models/location_model.dart';
import '../models/chat_model.dart';
import '../models/marine_model.dart';
import '../models/crop_stage_model.dart';
import '../models/lightning_model.dart';
import '../models/citizen_report_model.dart';
import '../models/sky_analysis_model.dart';
import '../models/agromet_bulletin_model.dart';
import '../models/multi_model_nwp_model.dart';
import '../models/imd_sop_model.dart';
import '../models/satellite_radar_model.dart';
import '../models/hydro_model.dart';
import '../models/monsoon_model.dart';
import '../models/safar_model.dart';
import '../models/cyclone_model.dart';
import '../models/fog_model.dart';
import '../models/coldwave_model.dart';
import '../models/pest_forewarning_model.dart';
import '../models/avalanche_snow_model.dart';
import '../models/convective_storm_model.dart';
import '../models/drought_model.dart';
import '../models/marine_heatwave_model.dart';
import '../models/cloudburst_model.dart';
import '../models/hazmat_model.dart';
import '../models/forest_fire_model.dart';
import '../models/heat_action_plan_model.dart';
import '../models/tsunami_model.dart';
import '../models/crop_water_stress_model.dart';
import '../models/storm_surge_model.dart';
import '../models/ocean_state_model.dart';
import '../models/livestock_heat_stress_model.dart';
import '../models/earthquake_model.dart';
import '../models/solar_energy_model.dart';
import '../models/lightning_cell_model.dart';
import '../models/wind_energy_model.dart';
import '../models/glof_model.dart';
import '../models/oil_spill_model.dart';
import '../models/urban_heat_island_model.dart';
import '../models/potential_fishing_zone_model.dart';
import '../models/extended_range_prediction_model.dart';
import '../models/snowmelt_runoff_model.dart';
import '../models/agri_storage_model.dart';
import '../models/flash_drought_model.dart';
import '../models/hydro_rating_model.dart';
import '../models/saltwater_intrusion_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _envBackendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');

  static String get defaultBaseUrl {
    if (_envBackendUrl.isNotEmpty) return _envBackendUrl;
    if (kIsWeb) {
      try {
        final host = Uri.base.host;
        if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
          return 'http://localhost:8000';
        }
        return 'https://vaanilai-ai-backend.onrender.com';
      } catch (_) {
        return 'http://localhost:8000';
      }
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'https://vaanilai-ai-backend.onrender.com';
      default:
        return 'http://localhost:8000';
    }
  }

  String baseUrl;

  ApiService({String? customBaseUrl}) : baseUrl = customBaseUrl ?? defaultBaseUrl;

  // 1. Weather Forecast with direct Open-Meteo fallback
  Future<WeatherForecastModel> getForecast({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    String? district,
    String? state,
    int days = 7,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/weather/forecast').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_name': locationName,
        if (district != null) 'district': district,
        if (state != null) 'state': state,
        'days': days.toString(),
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return WeatherForecastModel.fromJson(data);
      }
    } catch (_) {
      // Backend unavailable / waking up on Render - Fall back to direct Open-Meteo client
    }

    return _fetchDirectOpenMeteoForecast(latitude, longitude, locationName, district, state);
  }

  Future<WeatherForecastModel> _fetchDirectOpenMeteoForecast(
    double lat,
    double lon,
    String locationName,
    String? district,
    String? state,
  ) async {
    final uri = Uri.parse('https://api.open-meteo.com/v1/forecast').replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m,is_day',
        'hourly': 'temperature_2m,apparent_temperature,precipitation_probability,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m,relative_humidity_2m,uv_index,is_day',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,rain_sum,wind_speed_10m_max,wind_direction_10m_dominant,sunrise,sunset,uv_index_max',
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final current = data['current'] ?? {};
      final daily = data['daily'] ?? {};
      final hourly = data['hourly'] ?? {};

      final dailyList = <DailyForecastModel>[];
      final dailyTimes = (daily['time'] as List? ?? []);
      for (int i = 0; i < dailyTimes.length; i++) {
        dailyList.add(DailyForecastModel(
          date: dailyTimes[i].toString(),
          weatherCode: (daily['weather_code']?[i] as num?)?.toInt() ?? 0,
          conditionText: _weatherCodeToText((daily['weather_code']?[i] as num?)?.toInt() ?? 0),
          conditionIcon: '01d',
          tempMax: (daily['temperature_2m_max']?[i] as num?)?.toDouble() ?? 30.0,
          tempMin: (daily['temperature_2m_min']?[i] as num?)?.toDouble() ?? 24.0,
          precipitationSum: (daily['precipitation_sum']?[i] as num?)?.toDouble() ?? 0.0,
          precipitationProbabilityMax: (daily['precipitation_probability_max']?[i] as num?)?.toInt() ?? 20,
          rainSum: (daily['rain_sum']?[i] as num?)?.toDouble() ?? 0.0,
          windSpeedMax: (daily['wind_speed_10m_max']?[i] as num?)?.toDouble() ?? 12.0,
          windDirectionDominant: (daily['wind_direction_10m_dominant']?[i] as num?)?.toInt() ?? 180,
          sunrise: daily['sunrise']?[i]?.toString() ?? '',
          sunset: daily['sunset']?[i]?.toString() ?? '',
          uvIndexMax: (daily['uv_index_max']?[i] as num?)?.toDouble() ?? 6.0,
        ));
      }

      final hourlyList = <HourlyForecastModel>[];
      final hourlyTimes = (hourly['time'] as List? ?? []);
      for (int i = 0; i < hourlyTimes.length && i < 48; i++) {
        hourlyList.add(HourlyForecastModel(
          time: hourlyTimes[i].toString(),
          temperature: (hourly['temperature_2m']?[i] as num?)?.toDouble() ?? 28.0,
          feelsLike: (hourly['apparent_temperature']?[i] as num?)?.toDouble() ?? 30.0,
          precipitationProbability: (hourly['precipitation_probability']?[i] as num?)?.toInt() ?? 10,
          precipitation: (hourly['precipitation']?[i] as num?)?.toDouble() ?? 0.0,
          rain: (hourly['rain']?[i] as num?)?.toDouble() ?? 0.0,
          weatherCode: (hourly['weather_code']?[i] as num?)?.toInt() ?? 0,
          conditionText: _weatherCodeToText((hourly['weather_code']?[i] as num?)?.toInt() ?? 0),
          conditionIcon: '01d',
          windSpeed: (hourly['wind_speed_10m']?[i] as num?)?.toDouble() ?? 10.0,
          windDirection: (hourly['wind_direction_10m']?[i] as num?)?.toInt() ?? 180,
          humidity: (hourly['relative_humidity_2m']?[i] as num?)?.toInt() ?? 70,
          uvIndex: (hourly['uv_index']?[i] as num?)?.toDouble() ?? 0.0,
          isDay: ((hourly['is_day']?[i] as num?)?.toInt() ?? 1) == 1,
        ));
      }

      final wCode = (current['weather_code'] as num?)?.toInt() ?? 0;

      return WeatherForecastModel(
        locationName: locationName,
        district: district,
        state: state,
        latitude: lat,
        longitude: lon,
        elevation: (data['elevation'] as num?)?.toDouble() ?? 10.0,
        current: CurrentWeatherModel(
          temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 28.0,
          feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 30.0,
          humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 70,
          pressure: (current['surface_pressure'] as num?)?.toDouble() ?? 1012.0,
          windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 12.0,
          windDirection: (current['wind_direction_10m'] as num?)?.toInt() ?? 180,
          windGusts: (current['wind_gusts_10m'] as num?)?.toDouble() ?? 15.0,
          precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
          rain: (current['rain'] as num?)?.toDouble() ?? 0.0,
          cloudCover: 20,
          visibility: 10.0,
          uvIndex: 6.0,
          weatherCode: wCode,
          conditionText: _weatherCodeToText(wCode),
          conditionIcon: '01d',
          isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
          provenance: WeatherProvenanceModel(
            sourceType: 'FORECAST_MODEL',
            providerName: 'Open-Meteo (direct fallback)',
            forecastConfidence: 0.0, // No meaningful confidence for direct fallback
            lastUpdated: DateTime.now().toIso8601String(),
          ),
        ),
        hourly: hourlyList,
        daily: dailyList,
        // Air quality data not available via direct Open-Meteo forecast fallback
        airQuality: null,
        activeWarnings: [],
        dataSource: 'forecast_model',
      );
    }

    throw Exception('Failed to load live weather from both backend and satellite fallback.');
  }

  String _weatherCodeToText(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Partly Cloudy';
  }

  // 2. Location Search with direct Open-Meteo fallback
  Future<List<LocationSearchResultModel>> searchLocations(String query, {int count = 10}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final uri = Uri.parse('$baseUrl/api/v1/locations/search').replace(
        queryParameters: {'q': cleanQuery, 'count': count.toString()},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => LocationSearchResultModel.fromJson(e)).toList();
      }
    } catch (_) {
      // Fall back to direct Open-Meteo Geocoding API
    }

    try {
      final geoUri = Uri.parse('https://geocoding-api.open-meteo.com/v1/search').replace(
        queryParameters: {
          'name': cleanQuery,
          'count': count.toString(),
          'language': 'en',
          'format': 'json',
        },
      );
      final geoResp = await http.get(geoUri).timeout(const Duration(seconds: 8));
      if (geoResp.statusCode == 200) {
        final data = json.decode(utf8.decode(geoResp.bodyBytes));
        final results = (data['results'] as List? ?? []);
        return results.map((item) {
          final n = item['name'] ?? '';
          final d = item['admin2'] ?? item['admin3'];
          final s = item['admin1'];
          final disp = '$n${d != null ? ", $d" : ""}${s != null ? ", $s" : ""}';

          return LocationSearchResultModel(
            id: (item['id'] as num?)?.toInt() ?? 0,
            name: n,
            latitude: (item['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (item['longitude'] as num?)?.toDouble() ?? 0.0,
            elevation: (item['elevation'] as num?)?.toDouble(),
            country: item['country'] ?? 'India',
            state: s,
            district: d,
            isVillage: (item['feature_code'] == 'PPLX' || item['feature_code'] == 'PPLA3'),
            displayName: disp,
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }

  // 3. Saved Favorites
  Future<List<SavedLocationModel>> getSavedLocations() async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/locations/favorites');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => SavedLocationModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<SavedLocationModel?> addSavedLocation(SavedLocationModel loc) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/locations/favorites');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loc.toJson()),
      ).timeout(const Duration(seconds: 6));
      if (response.statusCode == 201) {
        return SavedLocationModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
    } catch (_) {}
    return null;
  }

  // 4. Disaster Alerts
  Future<AlertSummaryModel> getActiveAlerts({
    double? latitude,
    double? longitude,
    String? district,
    String? state,
  }) async {
    final queryParams = <String, String>{};
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (district != null) queryParams['district'] = district;
    if (state != null) queryParams['state'] = state;

    try {
      final uri = Uri.parse('$baseUrl/api/v1/alerts/active').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return AlertSummaryModel.fromJson(data);
      }
    } catch (_) {}

    // Fallback: evaluate synthetic alerts from weather forecast if coordinates provided
    if (latitude != null && longitude != null) {
      try {
        final forecast = await _fetchDirectOpenMeteoForecast(latitude, longitude, district ?? 'Location', district, state);
        final syntheticAlerts = <DisasterAlertModel>[];
        for (int i = 0; i < forecast.daily.length && i < 3; i++) {
          final d = forecast.daily[i];
          if (d.precipitationSum >= 64.5) {
            final isOrange = d.precipitationSum >= 115.6;
            syntheticAlerts.add(DisasterAlertModel(
              alertId: 'FORECAST-RAIN-${d.date}',
              source: 'Forecast model estimate (Open-Meteo) — not an official IMD warning',
              category: isOrange ? 'Heavy Rainfall Risk (Forecast)' : 'Rainfall Watch (Forecast)',
              severity: isOrange ? 'Orange' : 'Yellow',
              urgency: 'Expected',
              headline: '${isOrange ? "Heavy" : "Moderate to Heavy"} rain forecast: ${d.precipitationSum.toStringAsFixed(1)} mm',
              description: 'Weather models predict ${d.precipitationSum.toStringAsFixed(1)} mm rainfall with ${d.precipitationProbabilityMax}% probability. This is a forecast estimate, not an official warning.',
              instruction: 'Avoid low-lying waterlogged areas and keep an umbrella handy. Check official IMD alerts for confirmed warnings.',
              areaDescription: district ?? 'Selected Region',
              district: district,
              state: state,
              effectiveFrom: DateTime.now().toIso8601String(),
              expiresAt: DateTime.now().add(Duration(days: i + 1)).toIso8601String(),
              isActive: true,
              colorHex: isOrange ? '#DD6B20' : '#D69E2E',
            ));
          }
        }
        if (syntheticAlerts.isNotEmpty) {
          final hasOrange = syntheticAlerts.any((a) => a.severity == 'Orange');
          return AlertSummaryModel(
            totalActiveAlerts: syntheticAlerts.length,
            highestSeverity: hasOrange ? 'Orange' : 'Yellow',
            alerts: syntheticAlerts,
          );
        }
      } catch (_) {}
    }

    return AlertSummaryModel(totalActiveAlerts: 0, highestSeverity: 'Green', alerts: []);
  }

  // 5. Agriculture Advisory with Direct NWP Agro-met Fallback
  Future<AgricultureAdvisoryModel> getAgricultureAdvisory({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    String? district,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/advisories/agriculture').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
          if (district != null) 'district': district,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return AgricultureAdvisoryModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend agriculture advisory error: $e. Falling back to direct client agro-met engine.');
    }

    return _computeDirectAgricultureAdvisory(latitude, longitude, locationName, district);
  }

  // 6. Travel Advisory with Direct NWP Telemetry Fallback
  Future<TravelAdvisoryModel> getTravelAdvisory({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    String? district,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/advisories/travel').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
          if (district != null) 'district': district,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return TravelAdvisoryModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend travel advisory error: $e. Falling back to direct client travel intelligence.');
    }

    return _computeDirectTravelAdvisory(latitude, longitude, locationName, district);
  }

  // 7. Climate Comparison with SharedPreferences Cache & Direct Archive Fallback
  Future<ClimateComparisonModel> compareClimate({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    int year1 = 2022,
    int year2 = 2023,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'climate_compare_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${year1}_$year2';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/climate/compare').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
          'year_1': year1.toString(),
          'year_2': year2.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        await prefs.setString(cacheKey, json.encode(data));
        return ClimateComparisonModel.fromJson(data, isOfflineCached: false);
      }
    } catch (e) {
      debugPrint('Backend climate compare error: $e. Checking offline cache.');
    }

    // Check SharedPreferences offline cache
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return ClimateComparisonModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    return _fetchDirectClimateComparison(latitude, longitude, locationName, year1, year2);
  }

  // 8. Climate Trends with SharedPreferences Cache & Direct Archive Fallback
  Future<ClimateTrendModel> getClimateTrends({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    int startYear = 2018,
    int endYear = 2024,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'climate_trends_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${startYear}_$endYear';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/climate/trends').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
          'start_year': startYear.toString(),
          'end_year': endYear.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        await prefs.setString(cacheKey, json.encode(data));
        return ClimateTrendModel.fromJson(data, isOfflineCached: false);
      }
    } catch (e) {
      debugPrint('Backend climate trends error: $e. Checking offline cache.');
    }

    // Check SharedPreferences offline cache
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return ClimateTrendModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    return _fetchDirectClimateTrends(latitude, longitude, locationName, startYear, endYear);
  }

  // Health Check
  Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/health')).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 9. Conversational AI Chat with direct Gemini + Open-Meteo fallback
  Future<ChatMessageModel> sendChatMessage({
    required String query,
    String? sessionId,
    String language = 'en',
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/chat/message');
    final payload = {
      'query': query,
      if (sessionId != null) 'session_id': sessionId,
      'language': language,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'location_name': locationName,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return ChatMessageModel.fromJson(data, role: 'assistant');
      }
    } catch (e) {
      debugPrint('Backend chat error: $e. Falling back to direct Gemini AI + Open-Meteo client.');
    }

    return _fetchDirectGeminiChat(
      query: query,
      sessionId: sessionId,
      language: language,
      latitude: latitude ?? 8.1833,
      longitude: longitude ?? 77.4119,
      locationName: locationName ?? 'Nagercoil',
    );
  }

  // 10. Dedicated Spoken Voice Interaction Endpoint
  Future<Map<String, dynamic>> initLiveVoiceSession({
    String language = 'en',
    double? latitude,
    double? longitude,
    String? locationName,
    String? sessionId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/voice/init');
    final payload = {
      'language': language,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'location_name': locationName,
      if (sessionId != null) 'session_id': sessionId,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Live voice init error: $e. Falling back to local proactive briefing.');
    }

    final loc = locationName ?? 'Nagercoil';
    final greeting = language == 'ta'
        ? 'வணக்கம்! நான் வானிலைAI லைவ் (VaanilaiAI Live). $loc பகுதியில் தற்போதைய வானிலை ஆய்வு மற்றும் முன்னறிவிப்பு தகவல்களை வழங்க நான் தயார். என்ன கேட்க விரும்புகிறீர்கள்?'
        : language == 'hi'
            ? 'नमस्ते! मैं वानिलीएआई लाइव (VaanilaiAI Live) हूँ। $loc के वर्तमान मौसम और कृषि सलाह के लिए मैं उपस्थित हूँ। आज क्या जानकारी चाहिए?'
            : 'Namaste! I am VaanilaiAI Live, your real-time conversational weather companion for $loc. What weather intelligence or travel plans can I assist you with today?';

    return {
      'session_id': sessionId ?? 'live-session-${DateTime.now().millisecondsSinceEpoch}',
      'greeting_text': greeting,
      'system_prompt': 'VaanilaiAI Live Gemini Engine',
      'suggested_voice_prompts': [
        'Will it rain tomorrow in $loc?',
        'Is it safe for pesticide crop spraying today?',
        'Check active cyclone and disaster warnings',
        'Is coastal sea safe for fishing today?',
        'Give me a 7-day weather outlook summary',
      ],
      'audio_base64': null,
      'detected_language': language,
    };
  }

  Future<Map<String, dynamic>> sendVoiceQueryDetailed({
    required String query,
    String? audioBase64,
    String language = 'en',
    double? latitude,
    double? longitude,
    String? locationName,
    String? sessionId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/voice/query');
    final payload = {
      'transcription': query,
      if (audioBase64 != null) 'audio_base64': audioBase64,
      'language': language,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'location_name': locationName,
      if (sessionId != null) 'session_id': sessionId,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final chatResp = data['chat_response'];
        ChatMessageModel msg;
        if (chatResp != null) {
          msg = ChatMessageModel.fromJson(chatResp, role: 'assistant');
        } else {
          msg = ChatMessageModel(
            role: 'assistant',
            content: 'Voice intelligence retrieved.',
            language: language,
          );
        }
        return {
          'message': msg,
          'audio_base64': data['audio_base64'],
          'transcribed_text': data['transcribed_text'] ?? query,
        };
      }
    } catch (e) {
      debugPrint('Backend voice query error: $e.');
    }

    final fallbackMsg = await sendChatMessage(
      query: query,
      sessionId: sessionId,
      language: language,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );

    return {
      'message': fallbackMsg,
      'audio_base64': null,
      'transcribed_text': query,
    };
  }

  Future<ChatMessageModel> sendVoiceQuery({
    required String query,
    String? audioBase64,
    String language = 'en',
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final detailed = await sendVoiceQueryDetailed(
      query: query,
      audioBase64: audioBase64,
      language: language,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
    return detailed['message'] as ChatMessageModel;
  }

  Future<ChatMessageModel> _fetchDirectGeminiChat({
    required String query,
    String? sessionId,
    required String language,
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    WeatherForecastModel? weather;
    try {
      weather = await _fetchDirectOpenMeteoForecast(latitude, longitude, locationName, null, null);
    } catch (e) {
      debugPrint('Could not fetch Open-Meteo telemetry for direct chat: $e');
    }

    final curr = weather?.current;
    final today = (weather?.daily.isNotEmpty ?? false) ? weather!.daily[0] : null;
    final tomorrow = (weather != null && weather.daily.length > 1) ? weather.daily[1] : today;

    final contextData = {
      'location': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'current_weather': {
        'temperature': '${curr?.temperature.toStringAsFixed(1) ?? "32.0"}°C',
        'feels_like': '${curr?.feelsLike.toStringAsFixed(1) ?? "35.0"}°C',
        'condition': curr?.conditionText ?? 'Partly Cloudy',
        'humidity': '${curr?.humidity ?? 65}%',
        'wind_speed': '${curr?.windSpeed.toStringAsFixed(1) ?? "15.0"} km/h',
        'uv_index': curr?.uvIndex ?? 6.0,
      },
      'today_forecast': {
        'temp_min': '${today?.tempMin.toStringAsFixed(0) ?? "24"}°C',
        'temp_max': '${today?.tempMax.toStringAsFixed(0) ?? "33"}°C',
        'rain_probability': '${today?.precipitationProbabilityMax ?? 20}%',
        'rain_mm': '${today?.precipitationSum.toStringAsFixed(1) ?? "0.0"} mm',
        'condition': today?.conditionText ?? curr?.conditionText ?? 'Partly Cloudy',
      },
      'tomorrow_forecast': {
        'temp_min': '${tomorrow?.tempMin.toStringAsFixed(0) ?? "24"}°C',
        'temp_max': '${tomorrow?.tempMax.toStringAsFixed(0) ?? "33"}°C',
        'rain_probability': '${tomorrow?.precipitationProbabilityMax ?? 20}%',
        'rain_mm': '${tomorrow?.precipitationSum.toStringAsFixed(1) ?? "0.0"} mm',
        'condition': tomorrow?.conditionText ?? curr?.conditionText ?? 'Partly Cloudy',
      },
      'air_quality': {
        'aqi': weather?.airQuality?.aqi ?? 28,
        'category': weather?.airQuality?.category ?? 'Good',
        'pm2_5': '${weather?.airQuality?.pm25 ?? 15.0} µg/m³',
        'pm10': '${weather?.airQuality?.pm10 ?? 25.0} µg/m³',
      }
    };

    final prompt = '''
You are VaanilaiAI (WeatherGPT), a helpful weather assistant for India.
Answer the user query based on this weather data:
${json.encode(contextData)}

User Query: $query
Target Language: $language

Rules:
- Respond cleanly with emojis and bullet points.
- NEVER use triple asterisks '***' or '#' headers.
- Answer in $language (English, Tamil தமிழ், or Hindi हिन्दी).
- Data source is Open-Meteo forecast models. Do not call this "official IMD data".
- Provide practical recommendations for citizens and farmers (e.g., spray suitability, rain safety, heat index).
- For severe weather, recommend checking official IMD warnings.
''';

    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    const models = [
      'gemini-3.1-flash-lite',
      'gemini-3.6-flash',
      'gemini-3.7-flash',
      'gemini-3.5-flash-lite',
    ];

    String? generatedText;
    String usedModel = 'gemini-3.1-flash-lite';

    if (apiKey.isNotEmpty) {
      for (final model in models) {
        try {
          final uri = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
          );
        final body = json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
          }
        });

        final resp = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 25));

        if (resp.statusCode == 200) {
          final resData = json.decode(utf8.decode(resp.bodyBytes));
          final candidates = resData['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]?['content']?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              generatedText = parts[0]['text']?.toString();
              usedModel = model;
              if (generatedText != null && generatedText.isNotEmpty) {
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Direct Gemini call failed on model $model: $e');
      }
    }
  }

    if (generatedText != null && generatedText.isNotEmpty) {
      // Clean up any extra markdown
      generatedText = generatedText
          .replaceAll(RegExp(r'\*{3,}(.*?)\*{3,}'), r'**$1**')
          .replaceAll('***', '**')
          .replaceAll(RegExp(r'#{1,6}\s*'), '')
          .trim();

      return ChatMessageModel(
        sessionId: sessionId ?? 'direct-${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: generatedText,
        language: language,
        intent: 'gemini_agent_direct',
        detectedLocation: locationName,
        citations: ['Open-Meteo forecast model', 'Google $usedModel'],
        toolsUsed: ['get_weather_forecast'],
        weatherCard: curr != null
            ? WeatherCardSummaryModel(
                locationName: locationName,
                temperature: curr.temperature,
                feelsLike: curr.feelsLike,
                conditionText: curr.conditionText,
                conditionIcon: curr.conditionIcon,
                humidity: curr.humidity,
                windSpeed: curr.windSpeed,
                rainProbability: today?.precipitationProbabilityMax ?? 0,
                uvIndex: curr.uvIndex,
                sourceType: 'FORECAST_MODEL',
              )
            : null,
      );
    }

    // Rule-based deterministic fallback if internet or Gemini is fully unreachable
    return _buildDeterministicFallbackResponse(
      query: query,
      sessionId: sessionId,
      language: language,
      locationName: locationName,
      weather: weather,
    );
  }

  ChatMessageModel _buildDeterministicFallbackResponse({
    required String query,
    String? sessionId,
    required String language,
    required String locationName,
    WeatherForecastModel? weather,
  }) {
    final curr = weather?.current;
    final today = (weather?.daily.isNotEmpty ?? false) ? weather!.daily[0] : null;
    final qLower = query.toLowerCase();

    String reply;
    if (qLower.contains('spray') || qLower.contains('pesticide') || qLower.contains('crop')) {
      final wind = curr?.windSpeed ?? 15.0;
      final rainProb = today?.precipitationProbabilityMax ?? 20;
      final isSafe = wind <= 15.0 && rainProb < 30;
      reply = isSafe
          ? '• 🌾 **Pesticide Spraying Status**: **Favorable** in $locationName today.\n• 💨 **Wind Speed**: ${wind.toStringAsFixed(1)} km/h (within safe limit of 15 km/h).\n• 🌧️ **Rain Chance**: $rainProb% (low risk of chemical wash-off).\n• 💡 **Tip**: Spray during early morning or late evening for maximum absorption.'
          : '• ⚠️ **Pesticide Spraying Advisory**: **Exercise Caution** in $locationName today.\n• 💨 **Wind Speed**: ${wind.toStringAsFixed(1)} km/h ${wind > 15.0 ? "(Higher than 15 km/h, may cause chemical drift)" : ""}\n• 🌧️ **Rain Chance**: $rainProb% ${rainProb >= 30 ? "(Risk of chemical wash-off)" : ""}\n• 💡 **Tip**: Postpone spraying until winds drop below 15 km/h to avoid drift damage to neighboring fields.';
    } else if (qLower.contains('rain') || qLower.contains('umbrella')) {
      final rainProb = today?.precipitationProbabilityMax ?? 20;
      final rainMm = today?.precipitationSum ?? 0.0;
      reply = rainProb >= 40 || rainMm > 1.0
          ? '• 🌧️ **Rain Expected**: High probability of precipitation ($rainProb%, ${rainMm.toStringAsFixed(1)} mm) in $locationName today.\n• ☂️ **Recommendation**: Keep an umbrella handy and plan outdoor activities accordingly.'
          : '• 🌤️ **Mostly Dry**: Rain probability in $locationName is low ($rainProb%, ${rainMm.toStringAsFixed(1)} mm today).\n• 💡 **Recommendation**: Great day for outdoor activities.';
    } else {
      final temp = curr?.temperature ?? 32.0;
      final cond = curr?.conditionText ?? 'Partly Cloudy';
      reply = '• 🌡️ **Weather in $locationName**: $cond with current temperature of ${temp.toStringAsFixed(1)}°C (feels like ${curr?.feelsLike.toStringAsFixed(1) ?? temp.toStringAsFixed(1)}°C).\n• 💨 **Wind Speed**: ${curr?.windSpeed.toStringAsFixed(1) ?? 15.0} km/h | **Humidity**: ${curr?.humidity ?? 65}%\n• 🌧️ **Rain Chance**: ${today?.precipitationProbabilityMax ?? 20}%.';
    }

    return ChatMessageModel(
      sessionId: sessionId ?? 'direct-${DateTime.now().millisecondsSinceEpoch}',
      role: 'assistant',
      content: reply,
      language: language,
      intent: 'deterministic_offline_rule_engine',
      detectedLocation: locationName,
      citations: ['Open-Meteo forecast model (offline fallback)'],
      toolsUsed: ['get_weather_forecast'],
      weatherCard: curr != null
          ? WeatherCardSummaryModel(
              locationName: locationName,
              temperature: curr.temperature,
              feelsLike: curr.feelsLike,
              conditionText: curr.conditionText,
              conditionIcon: curr.conditionIcon,
              humidity: curr.humidity,
              windSpeed: curr.windSpeed,
              rainProbability: today?.precipitationProbabilityMax ?? 0,
              uvIndex: curr.uvIndex,
              sourceType: 'FORECAST_MODEL',
            )
          : null,
    );
  }

  // Direct Agro-met Decision Engine
  Future<AgricultureAdvisoryModel> _computeDirectAgricultureAdvisory(
    double lat,
    double lon,
    String locationName,
    String? district,
  ) async {
    final forecast = await _fetchDirectOpenMeteoForecast(lat, lon, locationName, district, null);
    final curr = forecast.current;
    final today = forecast.daily.isNotEmpty ? forecast.daily[0] : null;
    final rain24h = today?.precipitationSum ?? 0.0;
    final rainProb = today?.precipitationProbabilityMax ?? 20;
    final tempMax = today?.tempMax ?? curr.temperature;
    final windSpeed = curr.windSpeed;

    final suitableHours = <String>[];
    for (final h in forecast.hourly.take(18)) {
      if (h.isDay && h.windSpeed <= 15.0 && h.precipitationProbability <= 20 && h.precipitation == 0) {
        final timePart = h.time.contains('T') ? h.time.split('T').last : h.time;
        suitableHours.add(timePart);
      }
    }

    String suitability;
    String reason;
    if (rainProb > 50 || rain24h > 5.0) {
      suitability = 'Unfavorable';
      reason = 'High probability of rainfall ($rainProb% / ${rain24h.toStringAsFixed(1)}mm expected) which will wash off applied chemicals.';
    } else if (windSpeed > 20.0) {
      suitability = 'Risky';
      reason = 'High wind speeds (${windSpeed.toStringAsFixed(1)} km/h) cause chemical spray drift and uneven crop coverage.';
    } else if (tempMax > 36.0) {
      suitability = 'Risky';
      reason = 'High daytime temperature (${tempMax.toStringAsFixed(1)}°C) may lead to rapid spray evaporation and crop scorch.';
    } else {
      suitability = 'Favorable';
      reason = 'Calm winds, low rain probability, and moderate temperatures are ideal for pesticide/fertilizer spraying.';
    }

    String irrigationAdvice;
    String rainRiskLevel;
    if (rain24h > 15.0) {
      irrigationAdvice = 'Postpone irrigation. Significant rainfall of ${rain24h.toStringAsFixed(1)} mm is anticipated over the next 24 hours. Ensure adequate field drainage.';
      rainRiskLevel = rain24h < 64.5 ? 'High' : 'Severe';
    } else if (rain24h > 3.0 || rainProb > 40) {
      irrigationAdvice = 'Light irrigation only if necessary, monitoring incoming convective clouds.';
      rainRiskLevel = 'Moderate';
    } else {
      irrigationAdvice = 'Normal irrigation recommended. Irrigate during early morning or evening hours to minimize evapotranspiration.';
      rainRiskLevel = 'Low';
    }

    final heatStressLevel = tempMax >= 40.0 ? 'Severe' : (tempMax >= 36.0 ? 'Moderate' : 'Normal');

    final cropTips = <String>[];
    if (rain24h > 20.0) {
      cropTips.add('Clear drainage channels in paddy, vegetable, and horticultural fields to prevent root rot.');
    }
    if (heatStressLevel == 'Moderate' || heatStressLevel == 'Severe') {
      cropTips.add('Apply light, frequent irrigation and mulching to conserve soil moisture against excessive heat.');
    }
    if (curr.humidity > 80 && tempMax > 28.0) {
      cropTips.add('High humidity and warmth increase fungal/pest vulnerability; inspect lower leaves closely.');
    }

    return AgricultureAdvisoryModel(
      locationName: locationName,
      district: district,
      date: today?.date ?? DateTime.now().toIso8601String().split('T').first,
      sprayingSuitability: suitability,
      sprayingReason: reason,
      suitableSprayingHours: suitableHours.take(6).toList(),
      irrigationAdvice: irrigationAdvice,
      rainRisk24hMm: rain24h,
      rainRiskLevel: rainRiskLevel,
      heatStressLevel: heatStressLevel,
      pestDiseaseRisk: curr.humidity > 80 ? 'High' : 'Low',
      cropSpecificTips: cropTips,
      officialDisclaimer: 'Advisory generated based on meteorological conditions and IMD agro-met guidelines. Verify with local Krishi Vigyan Kendra (KVK) for specialized crop operations.',
    );
  }

  // Direct Travel Advisory Engine
  Future<TravelAdvisoryModel> _computeDirectTravelAdvisory(
    double lat,
    double lon,
    String locationName,
    String? district,
  ) async {
    final forecast = await _fetchDirectOpenMeteoForecast(lat, lon, locationName, district, null);
    final curr = forecast.current;
    final today = forecast.daily.isNotEmpty ? forecast.daily[0] : null;
    final rainProb = today?.precipitationProbabilityMax ?? 10;
    final rainMm = today?.precipitationSum ?? 0.0;
    final wind = curr.windSpeed;
    final vis = curr.visibility;

    int riskScore = 10;
    if (rainMm > 20.0 || rainProb > 70) {
      riskScore += 35;
    } else if (rainMm > 5.0 || rainProb > 40) {
      riskScore += 20;
    }

    if (wind > 40.0) {
      riskScore += 30;
    } else if (wind > 25.0) {
      riskScore += 15;
    }

    if (vis < 1000) {
      riskScore += 35;
    } else if (vis < 3000) {
      riskScore += 20;
    }

    if (riskScore > 100) riskScore = 100;

    final overall = riskScore >= 60 ? 'Hazardous' : (riskScore >= 35 ? 'Caution' : 'Good');
    final roadSafety = riskScore >= 60
        ? 'Dangerous road conditions. Waterlogging and slippery surfaces expected.'
        : (riskScore >= 35 ? 'Drive cautiously. Wet road surfaces possible.' : 'Road conditions are favorable for all transit.');

    final visCond = vis < 2000 ? 'Low visibility / Foggy' : (vis < 5000 ? 'Moderate visibility' : 'Clear visibility');
    final windHazard = wind > 40.0 ? 'Strong Gale / High Wind' : (wind > 25.0 ? 'Moderate Gusts' : 'Gentle Breeze');
    final flightRisk = riskScore >= 60 ? 'High' : (riskScore >= 40 ? 'Moderate' : 'Low');

    final tips = <String>[];
    if (rainProb > 40) tips.add('Keep umbrellas and rain gear accessible.');
    if (vis < 3000) tips.add('Use low-beam headlights and reduce vehicle speed in fog/mist.');
    if (wind > 30) tips.add('Exercise caution on elevated highways and coastal bridges.');
    if (tips.isEmpty) tips.add('Safe atmospheric conditions for general and highway travel.');

    return TravelAdvisoryModel(
      locationName: locationName,
      district: district,
      date: today?.date ?? DateTime.now().toIso8601String().split('T').first,
      overallSuitability: overall,
      travelRiskScore: riskScore,
      roadSafetyCondition: roadSafety,
      visibilityCondition: visCond,
      visibilityMeters: vis,
      windHazardLevel: windHazard,
      flightDisruptionRisk: flightRisk,
      safetyRecommendations: tips,
    );
  }

  // Direct Climate Comparison via Open-Meteo Archive
  Future<ClimateComparisonModel> _fetchDirectClimateComparison(
    double lat,
    double lon,
    String locationName,
    int year1,
    int year2,
  ) async {
    final stats1 = await _fetchDirectYearlyStats(lat, lon, year1);
    final stats2 = await _fetchDirectYearlyStats(lat, lon, year2);

    final diffRain = stats2.annualRainfallMm - stats1.annualRainfallMm;
    final pctRain = stats1.annualRainfallMm > 0 ? (diffRain / stats1.annualRainfallMm * 100) : 0.0;
    final diffTemp = stats2.annualMeanTempC - stats1.annualMeanTempC;

    final summary = 'Comparing $year2 with $year1 in $locationName: Total annual rainfall was ${stats2.annualRainfallMm.toStringAsFixed(1)} mm in $year2 vs ${stats1.annualRainfallMm.toStringAsFixed(1)} mm in $year1 (${diffRain >= 0 ? "+" : ""}${diffRain.toStringAsFixed(1)} mm, ${pctRain >= 0 ? "+" : ""}${pctRain.toStringAsFixed(1)}%). Mean annual temperature was ${stats2.annualMeanTempC.toStringAsFixed(2)}°C vs ${stats1.annualMeanTempC.toStringAsFixed(2)}°C (${diffTemp >= 0 ? "+" : ""}${diffTemp.toStringAsFixed(2)}°C).';

    return ClimateComparisonModel(
      locationName: locationName,
      latitude: lat,
      longitude: lon,
      year1: year1,
      year2: year2,
      year1Stats: stats1,
      year2Stats: stats2,
      rainfallDifferenceMm: double.parse(diffRain.toStringAsFixed(1)),
      rainfallChangePercent: double.parse(pctRain.toStringAsFixed(1)),
      temperatureDifferenceC: double.parse(diffTemp.toStringAsFixed(2)),
      climateSummary: summary,
    );
  }

  Future<YearlyClimateStatsModel> _fetchDirectYearlyStats(double lat, double lon, int year) async {
    final uri = Uri.parse('https://archive-api.open-meteo.com/v1/archive').replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'start_date': '$year-01-01',
        'end_date': '$year-12-31',
        'daily': 'temperature_2m_max,temperature_2m_min,temperature_2m_mean,precipitation_sum',
        'timezone': 'auto',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final daily = data['daily'] ?? {};
        final times = (daily['time'] as List? ?? []);
        final tMean = (daily['temperature_2m_mean'] as List? ?? []);
        final tMax = (daily['temperature_2m_max'] as List? ?? []);
        final tMin = (daily['temperature_2m_min'] as List? ?? []);
        final precips = (daily['precipitation_sum'] as List? ?? []);

        final monthNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];

        final monthlyTemps = List.generate(12, (_) => <double>[]);
        final monthlyPrecips = List.generate(12, (_) => <double>[]);
        final monthlyRainyDays = List.generate(12, (_) => 0);
        final allTemps = <double>[];

        for (int i = 0; i < times.length; i++) {
          final tStr = times[i].toString();
          final parts = tStr.split('-');
          if (parts.length < 2) continue;
          final mIdx = (int.tryParse(parts[1]) ?? 1) - 1;
          if (mIdx < 0 || mIdx >= 12) continue;

          final t = (i < tMean.length && tMean[i] != null) ? (tMean[i] as num).toDouble() : 26.0;
          final p = (i < precips.length && precips[i] != null) ? (precips[i] as num).toDouble() : 0.0;

          monthlyTemps[mIdx].add(t);
          monthlyPrecips[mIdx].add(p);
          allTemps.add(t);
          if (p >= 2.5) {
            monthlyRainyDays[mIdx]++;
          }
        }

        double totalAnnualRain = 0.0;
        final monthlyStats = <MonthlyClimateStatsModel>[];
        for (int m = 0; m < 12; m++) {
          final tList = monthlyTemps[m];
          final pList = monthlyPrecips[m];
          final avgT = tList.isNotEmpty ? tList.reduce((a, b) => a + b) / tList.length : 26.0;
          final sumP = pList.isNotEmpty ? pList.reduce((a, b) => a + b) : 0.0;
          totalAnnualRain += sumP;

          monthlyStats.add(MonthlyClimateStatsModel(
            monthName: monthNames[m],
            monthIndex: m + 1,
            avgTemperatureC: double.parse(avgT.toStringAsFixed(1)),
            totalRainfallMm: double.parse(sumP.toStringAsFixed(1)),
            rainyDaysCount: monthlyRainyDays[m],
          ));
        }

        final meanTemp = allTemps.isNotEmpty ? allTemps.reduce((a, b) => a + b) / allTemps.length : 26.0;
        final maxRecorded = tMax.isNotEmpty ? tMax.map((e) => (e as num?)?.toDouble() ?? 30.0).reduce((a, b) => a > b ? a : b) : 35.0;
        final minRecorded = tMin.isNotEmpty ? tMin.map((e) => (e as num?)?.toDouble() ?? 20.0).reduce((a, b) => a < b ? a : b) : 18.0;

        return YearlyClimateStatsModel(
          year: year,
          annualRainfallMm: double.parse(totalAnnualRain.toStringAsFixed(1)),
          annualMeanTempC: double.parse(meanTemp.toStringAsFixed(2)),
          maxTempRecordedC: double.parse(maxRecorded.toStringAsFixed(1)),
          minTempRecordedC: double.parse(minRecorded.toStringAsFixed(1)),
          monthlyStats: monthlyStats,
        );
      }
    } catch (_) {}

    throw Exception('Historical climate data unavailable for year $year. The archive service could not be reached.');
  }

  // Direct Climate Trends via Open-Meteo Archive
  Future<ClimateTrendModel> _fetchDirectClimateTrends(
    double lat,
    double lon,
    String locationName,
    int startYear,
    int endYear,
  ) async {
    final multiYear = <YearlyClimateStatsModel>[];
    for (int y = startYear; y <= endYear; y++) {
      try {
        final s = await _fetchDirectYearlyStats(lat, lon, y);
        multiYear.add(s);
      } catch (_) {
        // Skip unavailable years rather than fabricating data
      }
    }

    if (multiYear.isEmpty) {
      throw Exception('Historical climate data unavailable for the period $startYear-$endYear.');
    }

    final totalRain = multiYear.isNotEmpty ? multiYear.map((s) => s.annualRainfallMm).reduce((a, b) => a + b) : 0.0;
    final avgRain = multiYear.isNotEmpty ? totalRain / multiYear.length : 0.0;

    double rainSlope = 0.0;
    double warmingDecade = 0.0;
    if (multiYear.length >= 2) {
      rainSlope = (multiYear.last.annualRainfallMm - multiYear.first.annualRainfallMm) / (multiYear.length - 1);
      final tempDiff = multiYear.last.annualMeanTempC - multiYear.first.annualMeanTempC;
      warmingDecade = (tempDiff / (multiYear.length - 1)) * 10;
    }

    final desc = 'Over the $startYear-$endYear period in $locationName, average annual rainfall is ${avgRain.toStringAsFixed(1)} mm. Annual rainfall trend shows a shift of ${rainSlope >= 0 ? "+" : ""}${rainSlope.toStringAsFixed(1)} mm/year. Temperature trend indicates ${warmingDecade >= 0 ? "+" : ""}${warmingDecade.toStringAsFixed(2)}°C change per decade.';

    return ClimateTrendModel(
      locationName: locationName,
      latitude: lat,
      longitude: lon,
      startYear: startYear,
      endYear: endYear,
      multiYearStats: multiYear,
      averageAnnualRainfallMm: double.parse(avgRain.toStringAsFixed(1)),
      rainfallTrendSlope: double.parse(rainSlope.toStringAsFixed(2)),
      warmingTrendCPerDecade: double.parse(warmingDecade.toStringAsFixed(2)),
      trendDescription: desc,
    );
  }

  // 10. INCOIS Marine & Ocean Advisory
  Future<MarineAdvisoryModel> getMarineAdvisory({
    required double latitude,
    required double longitude,
    String locationName = 'Coastal Waters',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'marine_advisory_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/advisories/marine').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        await prefs.setString(cacheKey, json.encode(data));
        return MarineAdvisoryModel.fromJson(data, isCached: false);
      }
    } catch (e) {
      debugPrint('Backend marine advisory error: $e. Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return MarineAdvisoryModel.fromJson(cachedData, isCached: true);
      } catch (_) {}
    }

    // Return calibrated fallback with coastal vs inland detection
    final isLikelyCoastal = (latitude <= 24.0 && (longitude >= 68.0 && longitude <= 89.5));
    return MarineAdvisoryModel.defaultFallback(locationName, isCoastal: isLikelyCoastal);
  }

  // 11. ICAR-GKMS Crop Phenology & Stage-Based Advisory
  Future<CropStageAdvisoryModel> getCropStageAdvisory({
    required String cropType,
    required String stage,
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/advisories/crop-stage');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'crop_type': cropType,
              'growth_stage': stage,
              'latitude': latitude,
              'longitude': longitude,
              'location_name': locationName,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return CropStageAdvisoryModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend crop stage advisory error: $e. Falling back to direct ICAR GKMS logic.');
    }

    return _computeDirectCropStageAdvisory(cropType, stage, locationName);
  }

  CropStageAdvisoryModel _computeDirectCropStageAdvisory(String cropType, String stage, String locationName) {
    final lowerCrop = cropType.toLowerCase();
    final lowerStage = stage.toLowerCase();

    String vulnerability = 'Moderate';
    String waterStatus = 'Optimal Moisture';
    String irrigation = 'Maintain adequate field moisture based on current soil telemetry.';
    String chemical = 'Spray recommended micronutrients during non-rainy calm morning hours.';
    String pest = 'Monitor leaf tips for defoliator and sucking pests under humid conditions.';
    List<String> items = [
      'Maintain proper drainage channels to prevent stagnant waterlogging.',
      'Check pest population thresholds before application of synthetic sprays.',
      'Ensure field bunds are strengthened against heavy run-off.',
    ];

    if (lowerCrop.contains('paddy') || lowerCrop.contains('rice')) {
      if (lowerStage.contains('nursery') || lowerStage.contains('seedling')) {
        vulnerability = 'High';
        waterStatus = 'Standing Water (2-3 cm)';
        irrigation = 'Maintain 2-3 cm thin water layer. Drain excess water if continuous rain is expected.';
        chemical = 'Apply Carbofuran or Phorate granules if thrips or caseworm infestation crosses ETL.';
        pest = 'Thrips and green leafhopper active in high humidity.';
        items = [
          'Drain excess standing water during heavy showers to prevent seedling uprooting.',
          'Spray Zinc Sulphate @ 0.5% if chlorosis appears on younger leaves.',
        ];
      } else if (lowerStage.contains('tillering')) {
        vulnerability = 'Moderate';
        waterStatus = 'Shallow Water (3-5 cm)';
        irrigation = 'Alternate wetting and drying (AWD) recommended to promote root oxygenation.';
        chemical = 'Top dress with Neem-coated Urea (25-30 kg/acre). Avoid spraying during rain.';
        pest = 'Stem borer (Scirpophaga incertulas) and Leaf folder vigilance required.';
        items = [
          'Adopt alternate wetting and drying to conserve water and reduce methane emissions.',
          'Install pheromone traps @ 5 per hectare to monitor Yellow Stem Borer adults.',
        ];
      } else if (lowerStage.contains('flowering') || lowerStage.contains('panicle')) {
        vulnerability = 'Critical';
        waterStatus = 'High Moisture Essential';
        irrigation = 'Do not let field go dry. Moisture stress at flowering causes severe spikelet sterility.';
        chemical = 'Do not apply insecticide during peak anthesis (9:00 AM - 11:30 AM) to protect pollinators.';
        pest = 'Brown Plant Hopper (BPH) and False Smut alert. Scout bottom stems daily.';
        items = [
          'Scout the base of paddy hills for Brown Plant Hopper nymphs; maintain alleyways.',
          'Avoid spray operations during active anthesis hours to safeguard pollination.',
        ];
      }
    } else if (lowerCrop.contains('wheat')) {
      if (lowerStage.contains('crown') || lowerStage.contains('cri')) {
        vulnerability = 'Critical';
        waterStatus = 'First Irrigation Window';
        irrigation = 'Provide first crucial irrigation at Crown Root Initiation (CRI, 21 days after sowing).';
        chemical = 'Pre-emergence herbicide Pendimethalin 30 EC if weed density is high.';
        pest = 'Termite protection in light sandy soils.';
        items = [
          'CRI irrigation is mandatory; delaying causes 20-30% permanent yield penalty.',
          'Light and uniform irrigation to avoid water stagnation at crown depth.',
        ];
      } else if (lowerStage.contains('booting') || lowerStage.contains('heading')) {
        vulnerability = 'High';
        waterStatus = 'Moisture Sensitive';
        irrigation = 'Irrigate before temperatures spike. Terminal heat stress risk during heading.';
        chemical = 'Foliar spray of Potassium Nitrate (13:0:45) @ 1% to mitigate heat shock.';
        pest = 'Yellow Rust (Puccinia striiformis) alert in North-Western plains.';
        items = [
          'Spray Propiconazole 25% EC @ 0.1% if yellow rust stripes appear on upper leaves.',
          'Avoid heavy irrigation when winds exceed 20 km/h to prevent crop lodging.',
        ];
      }
    } else if (lowerCrop.contains('cotton')) {
      if (lowerStage.contains('squaring') || lowerStage.contains('boll')) {
        vulnerability = 'Critical';
        waterStatus = 'Sensitive to Stagnation';
        irrigation = 'Provide alternate furrow irrigation. Waterlogging causes immediate flower bud and boll shedding.';
        chemical = 'Install yellow sticky traps for whitefly; spray Neem oil 1500 ppm @ 3 ml/L.';
        pest = 'Pink bollworm and Whitefly surveillance critical.';
        items = [
          'Destroy rosette flowers to control first generation pink bollworm larvae.',
          'Immediately drain excess storm water as cotton is severely sensitive to hypoxia.',
        ];
      }
    }

    return CropStageAdvisoryModel(
      cropType: cropType,
      growthStage: stage,
      locationName: locationName,
      stageVulnerability: vulnerability,
      waterRequirementStatus: waterStatus,
      irrigationDirective: irrigation,
      chemicalSprayingDirective: chemical,
      pestDiseaseAlert: pest,
      harvestLogisticsAdvice: lowerStage.contains('harvest')
          ? 'Clear threshing yards, dry produce down to <12% moisture, and cover storage bags.'
          : null,
      actionItems: items,
    );
  }

  // 12. Real-Time Lightning Detection & Damini Strike Radar
  Future<LightningAlertModel> getLightningAlert({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'lightning_alert_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/alerts/lightning').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return LightningAlertModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend lightning alert error: $e. Checking offline cache.');
    }

    final cachedStr = prefs.getString(cacheKey);
    if (cachedStr != null) {
      try {
        final cachedData = json.decode(cachedStr) as Map<String, dynamic>;
        return LightningAlertModel.fromJson(cachedData);
      } catch (_) {}
    }

    // No fabricated data — return an honest "unavailable" response
    return LightningAlertModel.unavailable(locationName);
  }


  // 13. Multimodal Sky Vision AI
  Future<SkyAnalysisModel> analyzeSkyBase64({
    required String imageBase64,
    String locationName = 'Current Location',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/vision/analyze-sky-base64');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'image_base64': imageBase64,
              'location_name': locationName,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return SkyAnalysisModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend sky vision error: $e.');
    }

    // No fabricated data — return an honest "unavailable" response
    return SkyAnalysisModel.unavailable(locationName);
  }

  // 14. Crowdsourced Citizen Science & Urban Telemetry
  Future<List<CitizenReportModel>> getCitizenReports({
    double? latitude,
    double? longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/reports/citizen').replace(
        queryParameters: {
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
          'radius_km': radiusKm.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final list = json.decode(utf8.decode(response.bodyBytes)) as List;
        return list.map((item) => CitizenReportModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Backend citizen reports error: $e.');
    }

    // No fabricated fallback data — return empty list
    return [];
  }

  Future<CitizenReportModel> submitCitizenReport(CitizenReportModel report) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/reports/citizen');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(report.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return CitizenReportModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend submit report error: $e. Using optimistic local model.');
    }

    return CitizenReportModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      reportType: report.reportType,
      severity: report.severity,
      waterDepthInches: report.waterDepthInches,
      description: report.description,
      latitude: report.latitude,
      longitude: report.longitude,
      locationName: report.locationName,
      photoUrl: report.photoUrl,
      reporterRole: report.reporterRole,
      upvotes: 1,
      createdAt: 'Just now',
    );
  }

  Future<int> upvoteCitizenReport(String reportId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/reports/citizen/$reportId/upvote');
      final response = await http.post(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['upvotes'] as int? ?? 1;
      }
    } catch (_) {}
    return 1;
  }

  // 15. ICAR-IMD Gramin Krishi Mausam Seva (GKMS) District Agromet Bulletin
  Future<DistrictAgrometBulletinModel> getDistrictAgrometBulletin({
    required double latitude,
    required double longitude,
    String? district,
    String? state,
    String language = 'en',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final distKey = (district ?? 'loc').replaceAll(' ', '_');
    final cacheKey = 'agromet_bulletin_${distKey}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/advisories/agromet-bulletin').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          if (district != null && district.isNotEmpty) 'district': district,
          if (state != null && state.isNotEmpty) 'state': state,
          'language': language,
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        // Cache successful response for offline resilience in rural fields
        await prefs.setString(cacheKey, json.encode(data));
        return DistrictAgrometBulletinModel.fromJson(data, isOffline: false);
      }
    } catch (e) {
      debugPrint('Backend agromet bulletin fetch failed ($e). Attempting offline cache.');
    }

    // Try reading cached bulletin from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return DistrictAgrometBulletinModel.fromJson(cachedData, isOffline: true);
      } catch (_) {}
    }

    // Fallback: build a direct local agromet bulletin conforming to ICAR-GKMS standards
    return _buildDirectAgrometBulletin(latitude, longitude, district, state);
  }

  DistrictAgrometBulletinModel _buildDirectAgrometBulletin(
    double lat,
    double lon,
    String? district,
    String? state,
  ) {
    final resolvedDistrict = (district != null && district.isNotEmpty)
        ? district
        : (lat >= 8.0 && lat <= 13.5 ? 'Kanniyakumari' : 'District Agromet Zone');
    final resolvedState = (state != null && state.isNotEmpty)
        ? state
        : (lat >= 8.0 && lat <= 13.5 ? 'Tamil Nadu' : 'India');

    final now = DateTime.now();
    final issueStr = '${now.day.toString().padLeft(2, '0')}-${_monthName(now.month)}-${now.year}';
    final validUntil = now.add(const Duration(days: 5));
    final validUntilStr = '${validUntil.day.toString().padLeft(2, '0')}-${_monthName(validUntil.month)}-${validUntil.year}';

    final fiveDay = List.generate(5, (i) {
      final dayDate = now.add(Duration(days: i));
      return AgrometDayForecastModel(
        date: '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}',
        dayName: _dayOfWeekName(dayDate.weekday),
        rainfallMm: 0.0,
        tempMaxC: 33.0,
        tempMinC: 23.5,
        humidityMorningPct: 75,
        humidityEveningPct: 50,
        windSpeedKmh: 12.0,
        windDirectionCardinal: 'NW',
        cloudCoverOcta: 2,
      );
    });

    return DistrictAgrometBulletinModel(
      district: resolvedDistrict,
      state: resolvedState,
      bulletinNumber: 'GKMS/${resolvedState.substring(0, 3).toUpperCase()}/${resolvedDistrict.replaceAll(" ", "").substring(0, 4).toUpperCase()}/${now.year}/LOCAL',
      issueDate: issueStr,
      validFrom: issueStr,
      validUntil: validUntilStr,
      amfuCenter: 'ICAR-IMD District Agromet Field Unit (AMFU), $resolvedDistrict',
      synopticWeatherSummary: 'Dry and warm weather conditions expected across $resolvedDistrict over the 5-day bulletin cycle. Surface winds moderate.',
      fiveDayForecast: fiveDay,
      generalFarmAdvisories: [
        '💧 SCHEDULED IRRIGATION: Maintain regular scheduled irrigation in standing crops. Irrigate during early morning or evening hours.',
        '🚜 SPRAY WINDOW: Spraying of crop protection chemicals can be carried out during calm morning hours (07:00–09:30 AM).',
        '🌾 SOIL CONSERVATION: Perform inter-cultivation and mulching in broad-spaced crops to minimize evaporative moisture loss.',
      ],
      cropAdvisories: [
        CropAgrometAdvisoryModel(
          cropName: 'Paddy / Rice',
          stage: 'Tillering / Panicle Initiation',
          riskLevel: 'Normal',
          advisoryText: 'Maintain 3 to 5 cm water level in fields. Keep drainage channels open.',
          pestDiseaseAdvisory: 'Monitor for Stem Borer and Leaf Folder moths in field corners.',
          recommendedIntervention: 'Apply Neem Seed Kernel Extract (NSKE 5%) if egg masses observed.',
        ),
        CropAgrometAdvisoryModel(
          cropName: 'Cotton / Pulses',
          stage: 'Vegetative / Square Formation',
          riskLevel: 'Normal',
          advisoryText: 'Avoid waterlogging at root zones. Perform weed hoeing.',
          pestDiseaseAdvisory: 'Scout lower leaf surface for Whitefly and Jassids.',
          recommendedIntervention: 'Spray Yellow Sticky Traps @ 5-6 per acre for early pest detection.',
        ),
        CropAgrometAdvisoryModel(
          cropName: 'Horticulture & Vegetables',
          stage: 'Flowering & Fruiting',
          riskLevel: 'Normal',
          advisoryText: 'Harvest marketable fruits and vegetables in the morning.',
          pestDiseaseAdvisory: 'Warm sunny intervals favor Fruit Borer.',
          recommendedIntervention: 'Install Pheromone traps @ 4-5 per acre for monitoring.',
        ),
      ],
      livestockAdvisories: [
        LivestockAdvisoryModel(
          livestockType: 'Dairy Cattle & Buffaloes',
          riskLevel: 'Normal',
          managementAdvice: 'Provide clean, cool drinking water ad libitum. Ensure cross-ventilation in sheds. Feed green fodder with dry roughage in 3:1 ratio.',
          vaccinationOrDiseaseAlert: 'Ensure routine FMD and HS vaccinations are up to date.',
        ),
        LivestockAdvisoryModel(
          livestockType: 'Poultry',
          riskLevel: 'Normal',
          managementAdvice: 'Keep litter dry and well aerated (2-inch depth). Provide electrolytes in water during warm afternoons.',
          vaccinationOrDiseaseAlert: 'Administer Lasota strain vaccine for Newcastle Disease (ND).',
        ),
      ],
      provenanceDisclaimer: 'Offline Synthesized Agromet Guidance (ICAR-IMD GKMS Standards). Connect to network to refresh official district bulletin.',
      isOfflineCached: true,
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  String _dayOfWeekName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1).clamp(0, 6)];
  }

  // 16. Multi-Model NWP Ensemble Comparison (ECMWF IFS, NOAA GFS, DWD ICON)
  Future<MultiModelComparisonModel> getMultiModelComparison({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    int days = 5,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'nwp_comparison_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_$days';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/weather/multi-model-comparison').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
          'days': days.toString(),
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return MultiModelComparisonModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend NWP comparison fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached NWP comparison from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return MultiModelComparisonModel.fromJson(cachedData);
      } catch (_) {}
    }

    return MultiModelComparisonModel.unavailable(locationName);
  }

  // 17. IMD Warning Matrix & NDMA Standard Operating Procedures (SOPs)
  Future<IMDSOPResponseModel> getImdSopMatrix({
    String? hazard,
    String? state,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'imd_sop_matrix_${hazard ?? "all"}_${state ?? "all"}';

    try {
      final queryParams = <String, String>{};
      if (hazard != null && hazard.isNotEmpty) queryParams['hazard'] = hazard;
      if (state != null && state.isNotEmpty) queryParams['state'] = state;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/sop').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return IMDSOPResponseModel.fromJson(data, isOfflineCached: false);
      }
    } catch (e) {
      debugPrint('Backend IMD SOP fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached SOP from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return IMDSOPResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Complete offline resilience: return built-in offline SOP catalog
    return IMDSOPResponseModel.defaultFallback();
  }

  // 18. ISRO MOSDAC Satellite Feeds & IMD Doppler Weather Radar Network
  Future<SatelliteRadarOverviewModel> getSatelliteRadarOverview({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'sat_radar_overview_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    try {
      final uri = Uri.parse('$baseUrl/api/v1/weather/satellite-radar').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'location_name': locationName,
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return SatelliteRadarOverviewModel.fromJson(data, isOfflineCached: false);
      }
    } catch (e) {
      debugPrint('Backend satellite-radar fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return SatelliteRadarOverviewModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Return built-in offline fallback with official DWR stations catalog
    return SatelliteRadarOverviewModel.defaultFallback(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  // 17. CWC River Basin & Dam Hydro-Telemetry
  Future<CwcHydroOverviewModel> getCwcHydroOverview({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    String? basinName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cwc_hydro_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${basinName ?? 'auto'}';

    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_name': locationName,
      };
      if (basinName != null && basinName.isNotEmpty) {
        queryParams['basin_name'] = basinName;
      }
      final uri = Uri.parse('$baseUrl/api/v1/hydro/overview').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return CwcHydroOverviewModel.fromJson(data, isOfflineCached: false);
      }
    } catch (e) {
      debugPrint('Backend CWC hydro-telemetry fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return CwcHydroOverviewModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return CwcHydroOverviewModel.defaultFallback(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      basinName: basinName ?? 'Ganga',
    );
  }

  // 18. NCMRWF & IMD Sub-Divisional Monsoon Teleconnections & LRF
  Future<MonsoonIntelligenceModel> getMonsoonIntelligence({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'monsoon_intel_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_name': locationName,
      };
      final uri = Uri.parse('$baseUrl/api/v1/monsoon/teleconnections').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return MonsoonIntelligenceModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend monsoon teleconnections fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return MonsoonIntelligenceModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return MonsoonIntelligenceModel.defaultFallback(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  // 19. IITM SAFAR & IMD AQEWS Multi-Pollutant & Atmospheric Dispersion
  Future<SafarAirQualityModel> getSafarAirQuality({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    String? cityCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'safar_aq_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${cityCode ?? 'auto'}';

    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_name': locationName,
      };
      if (cityCode != null && cityCode.isNotEmpty) {
        queryParams['city_code'] = cityCode;
      }
      final uri = Uri.parse('$baseUrl/api/v1/air-quality/safar').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return SafarAirQualityModel.fromJson(data, isOfflineCached: false);
      }
    } catch (e) {
      debugPrint('Backend SAFAR air quality fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return SafarAirQualityModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return SafarAirQualityModel.defaultFallback(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      cityCode: cityCode ?? 'delhi',
    );
  }

  // 20. IMD RSMC Tropical Cyclone Track, Storm Surge & Dvorak T-Number Intensity
  Future<CycloneTrackerResponseModel> getCycloneTrackerData({
    double? latitude,
    double? longitude,
    String? systemId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'cyclone_tracker_${latitude?.toStringAsFixed(2) ?? 'all'}_${longitude?.toStringAsFixed(2) ?? 'all'}_${systemId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (systemId != null && systemId.isNotEmpty) queryParams['system_id'] = systemId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/cyclone-tracker').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return CycloneTrackerResponseModel.fromJson(data, isOffline: false);
      }
    } catch (e) {
      debugPrint('Backend cyclone tracker fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return CycloneTrackerResponseModel.fromJson(cachedData, isOffline: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return CycloneTrackerResponseModel.defaultFallback();
  }

  // 22. IMD FogPass & Highway/Aviation Low-Visibility Nowcasting
  Future<FogNowcastResponseModel> getFogNowcastData({
    double? latitude,
    double? longitude,
    String locationName = 'Indo-Gangetic Corridor',
    String? stationId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'fog_nowcast_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${stationId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      queryParams['location_name'] = locationName;
      if (stationId != null) queryParams['station_id'] = stationId;

      final uri = Uri.parse('$baseUrl/api/v1/fog/nowcast').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return FogNowcastResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend fog nowcast fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return FogNowcastResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return FogNowcastResponseModel.defaultFallback(
      location: locationName,
      lat: latitude ?? 28.5665,
      lon: longitude ?? 77.1031,
    );
  }

  // 23. IMD Cold Wave & Ground Frost Agronomic Vulnerability Engine
  Future<ColdWaveResponseModel> getColdWaveAssessment({
    double? latitude,
    double? longitude,
    String? stationId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'coldwave_assessment_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${stationId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (stationId != null) queryParams['station_id'] = stationId;

      final uri = Uri.parse('$baseUrl/api/v1/coldwave/assessment').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return ColdWaveResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend cold wave fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return ColdWaveResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return ColdWaveResponseModel.defaultFallback();
  }

  // 24. IMD Agro-Climatic Zone Crop Pest & Disease Forewarning Engine
  Future<PestForewarningResponseModel> getPestForewarningData({
    double? latitude,
    double? longitude,
    int? zoneId,
    double? temperatureC,
    double? relativeHumidityPct,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pest_forewarning_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${zoneId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (zoneId != null) queryParams['zone_id'] = zoneId.toString();
      if (temperatureC != null) queryParams['temperature_c'] = temperatureC.toString();
      if (relativeHumidityPct != null) queryParams['relative_humidity_pct'] = relativeHumidityPct.toString();

      final uri = Uri.parse('$baseUrl/api/v1/advisories/pest-forewarning').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return PestForewarningResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend pest forewarning fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return PestForewarningResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return PestForewarningResponseModel.defaultFallback();
  }

  // 25. IMD & DGRE Himalayan Western Disturbance, Snowpack & Avalanche Early Warning Engine
  Future<AvalancheSnowResponseModel> getAvalancheSnowAssessment({
    double? latitude,
    double? longitude,
    String? sectorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'avalanche_snow_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${sectorId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (sectorId != null) queryParams['sector_id'] = sectorId;

      final uri = Uri.parse('$baseUrl/api/v1/avalanche/assessment').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return AvalancheSnowResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend avalanche assessment fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return AvalancheSnowResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return AvalancheSnowResponseModel.defaultFallback();
  }

  // 26. IMD Severe Thunderstorm, Kalbaishakhi & Haboob Dust Storm Warning Engine
  Future<ConvectiveStormResponseModel> getConvectiveStormAssessment({
    double? latitude,
    double? longitude,
    String? hotspotId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'convective_storm_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${hotspotId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (hotspotId != null) queryParams['hotspot_id'] = hotspotId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/convective-storm').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return ConvectiveStormResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend convective storm fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return ConvectiveStormResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return ConvectiveStormResponseModel.defaultFallback();
  }

  // 27. IMD & CGWB Agricultural Drought, Soil Moisture Stress & Groundwater Vulnerability Engine
  Future<AgriculturalDroughtResponseModel> getAgriculturalDroughtAssessment({
    double? latitude,
    double? longitude,
    String? hotspotId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'drought_assessment_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${hotspotId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (hotspotId != null) queryParams['hotspot_id'] = hotspotId;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/drought-assessment').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return AgriculturalDroughtResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend drought assessment fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return AgriculturalDroughtResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return AgriculturalDroughtResponseModel.defaultFallback();
  }

  // 28. INCOIS Marine Heatwave, Coral Bleaching & Coastal Sea Fog Warning Engine
  Future<MarineHeatwaveResponseModel> getMarineHeatwaveAssessment({
    double? latitude,
    double? longitude,
    String? sectorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'marine_heatwave_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${sectorId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (sectorId != null) queryParams['sector_id'] = sectorId;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/marine-heatwave').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return MarineHeatwaveResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend marine heatwave fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return MarineHeatwaveResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return MarineHeatwaveResponseModel.defaultFallback();
  }

  // 29. Western Ghats & Himalayan Orographic Cloudburst & Landslide Debris Flow Engine
  Future<CloudburstResponseModel> getCloudburstAssessment({
    double? latitude,
    double? longitude,
    String? catchmentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cloudburst_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${catchmentId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (catchmentId != null) queryParams['catchment_id'] = catchmentId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/cloudburst').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return CloudburstResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend cloudburst fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return CloudburstResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return CloudburstResponseModel.defaultFallback();
  }

  // 30. CPCB & IMD Industrial Hazmat Atmospheric Dispersion & Toxic Gas Plume Engine
  Future<HazmatDispersionResponse> getHazmatDispersionAssessment({
    double? latitude,
    double? longitude,
    String? clusterId,
    String? gasSpecies,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'hazmat_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${clusterId ?? 'default'}_${gasSpecies ?? 'all'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (clusterId != null) queryParams['cluster_id'] = clusterId;
      if (gasSpecies != null) queryParams['gas_species'] = gasSpecies;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/hazmat-dispersion').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return HazmatDispersionResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend hazmat dispersion fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return HazmatDispersionResponse.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return HazmatDispersionResponse.defaultFallback();
  }

  // 31. FSI & ISRO-Bhuvan Forest Fire Danger & Fire Weather Index (FWI) Early Warning Engine
  Future<ForestFireResponse> getForestFireAssessment({
    double? latitude,
    double? longitude,
    String? zoneId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'forest_fire_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${zoneId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (zoneId != null) queryParams['zone_id'] = zoneId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/forest-fire').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return ForestFireResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend forest fire fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return ForestFireResponse.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return ForestFireResponse.defaultFallback();
  }

  // 32. NDMA & IMD National Heat Action Plan (HAP) & Solar UV Radiation Index Engine
  Future<HeatActionPlanResponseModel> getHeatActionPlanAssessment({
    double? latitude,
    double? longitude,
    String? zoneId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'heat_action_plan_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${zoneId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (zoneId != null) queryParams['zone_id'] = zoneId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/heat-action-plan').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return HeatActionPlanResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend heat action plan fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return HeatActionPlanResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return HeatActionPlanResponseModel.defaultFallback();
  }

  // 33. INCOIS & IMD Indian Tsunami Early Warning Centre (ITEWS) Engine
  Future<TsunamiWarningResponseModel> getTsunamiAssessment({
    double? latitude,
    double? longitude,
    String? sectorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'tsunami_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${sectorId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (sectorId != null) queryParams['sector_id'] = sectorId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/tsunami-warning').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return TsunamiWarningResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend tsunami fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return TsunamiWarningResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return TsunamiWarningResponseModel.defaultFallback();
  }

  // 34. ICAR-CRIDA & IMD Crop Water Stress Index (CWSI) & Soil Moisture Engine
  Future<CropWaterStressResponseModel> getCropWaterStressAssessment({
    double? latitude,
    double? longitude,
    String? zoneId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'crop_water_stress_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${zoneId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (zoneId != null) queryParams['zone_id'] = zoneId;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/crop-water-stress').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return CropWaterStressResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend crop water stress fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return CropWaterStressResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return CropWaterStressResponseModel.defaultFallback();
  }

  // 35. INCOIS-IMD Coastal Storm Surge & Tidal Inundation Nowcasting Engine
  Future<StormSurgeResponseModel> getStormSurgeAssessment({
    double? latitude,
    double? longitude,
    String? sectorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'storm_surge_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${sectorId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (sectorId != null) queryParams['sector_id'] = sectorId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/storm-surge').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return StormSurgeResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend storm surge fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return StormSurgeResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return StormSurgeResponseModel.defaultFallback();
  }

  // 36. INCOIS Ocean State Forecast (OSF), Swell Surge & Rip Current Warning
  Future<OceanStateResponseModel> getOceanStateAssessment({
    double? latitude,
    double? longitude,
    String? beachId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'ocean_state_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${beachId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (beachId != null) queryParams['beach_id'] = beachId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/ocean-state').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return OceanStateResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend ocean state fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return OceanStateResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return OceanStateResponseModel.defaultFallback();
  }

  // 37. ICAR-NDRI & IMD Dairy Livestock Microclimate & Temperature-Humidity Index (THI)
  Future<LivestockHeatStressResponseModel> getLivestockHeatStressAssessment({
    double? latitude,
    double? longitude,
    String? basinId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'livestock_heat_stress_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${basinId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (basinId != null) queryParams['basin_id'] = basinId;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/livestock-heat-stress').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return LivestockHeatStressResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend livestock heat stress fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return LivestockHeatStressResponseModel.fromJson(cachedData, isOffline: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return LivestockHeatStressResponseModel.defaultFallback();
  }

  // 38. NCS/IMD & NDMA National Earthquake Seismology, Fault-Line Proximity & Aftershock Probabilistic Engine
  Future<EarthquakeResponseModel> getEarthquakeAssessment({
    double? latitude,
    double? longitude,
    String? provinceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'earthquake_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${provinceId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (provinceId != null) queryParams['province_id'] = provinceId;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/earthquake').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return EarthquakeResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend earthquake assessment fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return EarthquakeResponseModel.fromJson(cachedData, isOffline: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return EarthquakeResponseModel.defaultFallback();
  }

  // 39. NISE, MNRE & IMD Solar Radiation, Photovoltaic (PV) Yield & Rooftop Solar Forecasting Engine
  Future<SolarEnergyResponseModel> getSolarEnergyAssessment({
    double? latitude,
    double? longitude,
    String? parkId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'solar_energy_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${parkId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (parkId != null) queryParams['park_id'] = parkId;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/solar-energy').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return SolarEnergyResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend solar energy assessment fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return SolarEnergyResponseModel.fromJson(cachedData, isOffline: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return SolarEnergyResponseModel.defaultFallback();
  }

  // 40. IITM & IMD Lightning Flash Density, Cell Lifecycle & Downburst Nowcasting Engine
  Future<LightningCellResponseModel> getLightningCellAssessment({
    String? corridorId,
    double? latitude,
    double? longitude,
    String language = 'en',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'lightning_cell_${corridorId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_$language';

    try {
      final queryParams = <String, String>{};
      if (corridorId != null) queryParams['corridor_id'] = corridorId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      queryParams['language'] = language;

      final uri = Uri.parse('$baseUrl/api/v1/alerts/lightning-density').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return LightningCellResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend lightning cell fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return LightningCellResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return LightningCellResponseModel.defaultFallback();
  }

  // 41. NIWE & IMD National Wind Resource Assessment, Hub-Height Shear & Wind Farm Generation
  Future<WindEnergyResponseModel> getWindEnergyAssessment({
    String? corridorId,
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'wind_energy_${corridorId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}';

    try {
      final queryParams = <String, String>{};
      if (corridorId != null) queryParams['corridor_id'] = corridorId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();

      final uri = Uri.parse('$baseUrl/api/v1/advisories/wind-energy').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return WindEnergyResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend wind energy fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return WindEnergyResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return WindEnergyResponseModel.defaultFallback();
  }

  // 42. NRSC-ISRO, CWC & NDMA Himalayan Glacial Lake Outburst Flood (GLOF) Early Warning
  Future<GlofResponseModel> getGlofAssessment({
    String? lakeId,
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'glof_${lakeId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}';

    try {
      final queryParams = <String, String>{};
      if (lakeId != null) queryParams['lake_id'] = lakeId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();

      final uri = Uri.parse('$baseUrl/api/v1/alerts/glof').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return GlofResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend GLOF assessment fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return GlofResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return GlofResponseModel.defaultFallback();
  }

  // 43. INCOIS & Indian Coast Guard (ICG) Marine Oil Spill Trajectory & Coastal Ecology Engine
  Future<OilSpillResponseModel> getOilSpillAssessment({
    String? corridorId,
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'oil_spill_${corridorId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}';

    try {
      final queryParams = <String, String>{};
      if (corridorId != null) queryParams['corridor_id'] = corridorId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();

      final uri = Uri.parse('$baseUrl/api/v1/alerts/oil-spill').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return OilSpillResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend oil spill assessment fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return OilSpillResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return OilSpillResponseModel.defaultFallback();
  }

  // 44. IMD & NDMA Urban Heat Island (UHI) & Cool Roof Albedo Engine
  Future<UrbanHeatIslandResponseModel> getUrbanHeatIslandAssessment({
    String? corridorId,
    double? latitude,
    double? longitude,
    String? roofType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'uhi_${corridorId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${roofType ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (corridorId != null) queryParams['corridor_id'] = corridorId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (roofType != null) queryParams['roof_type'] = roofType;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/urban-heat-island').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return UrbanHeatIslandResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend urban heat island fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return UrbanHeatIslandResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return UrbanHeatIslandResponseModel.defaultFallback();
  }

  // 45. INCOIS & CMFRI Potential Fishing Zone (PFZ), Chlorophyll-a & Fuel Conservation Engine
  Future<PfzResponseModel> getPotentialFishingZoneAssessment({
    String? sectorId,
    double? latitude,
    double? longitude,
    String? craftType,
    String language = 'en',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'pfz_${sectorId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_${craftType ?? 'default'}_$language';

    try {
      final queryParams = <String, String>{};
      if (sectorId != null) queryParams['sector_id'] = sectorId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (craftType != null) queryParams['craft_type'] = craftType;
      queryParams['language'] = language;

      final uri = Uri.parse('$baseUrl/api/v1/advisories/potential-fishing-zone').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return PfzResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend PFZ fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return PfzResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return PfzResponseModel.defaultFallback();
  }

  // 46. IMD, NCMRWF & IITM Extended Range Prediction (ERP) & Intra-Seasonal Monsoon Pulse Engine
  Future<ErpResponseModel> getExtendedRangePredictionAssessment({
    String? zoneId,
    double? latitude,
    double? longitude,
    String language = 'en',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey =
        'erp_${zoneId ?? 'default'}_${latitude?.toStringAsFixed(2)}_${longitude?.toStringAsFixed(2)}_$language';

    try {
      final queryParams = <String, String>{};
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      queryParams['language'] = language;

      final uri = Uri.parse('$baseUrl/api/v1/monsoon/extended-range').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return ErpResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend ERP fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return ErpResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return ErpResponseModel.defaultFallback();
  }

  // 47. IMD, CWC & DGRE Himalayan Snowmelt Runoff, Snow Cover Area (SCA) & Glacial Hydrology Engine
  Future<SnowmeltRunoffResponseModel> getSnowmeltRunoffAssessment({
    String? basinId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'snowmelt_runoff_${basinId ?? 'default'}';

    try {
      final queryParams = <String, String>{};
      if (basinId != null) queryParams['basin_id'] = basinId;

      final uri = Uri.parse('$baseUrl/api/v1/hydro/snowmelt-runoff').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return SnowmeltRunoffResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend Snowmelt Runoff fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return SnowmeltRunoffResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return SnowmeltRunoffResponseModel.defaultFallback();
  }

  // 48. IMD & ICAR Post-Harvest Mandi Weather Defense, Grain Moisture & Open-Godown Spoilage Engine
  Future<AgriStorageResponseModel> getAgriStorageAssessment({
    String? mandiId,
    double? lat,
    double? lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'agri_storage_${mandiId ?? '${lat}_$lon'}';

    try {
      final queryParams = <String, String>{};
      if (mandiId != null) queryParams['mandi_id'] = mandiId;
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lon != null) queryParams['lon'] = lon.toString();

      final uri = Uri.parse('$baseUrl/api/v1/advisories/agri-storage').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return AgriStorageResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend Agri-Storage fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return AgriStorageResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return AgriStorageResponseModel.defaultFallback();
  }

  // 49. IMD & CWC Flash Drought, Rapid Soil Desiccation & Atmospheric Evaporative Demand Engine
  Future<FlashDroughtResponseModel> getFlashDroughtAssessment({
    String? hotspotId,
    double? lat,
    double? lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'flash_drought_${hotspotId ?? '${lat}_$lon'}';

    try {
      final queryParams = <String, String>{};
      if (hotspotId != null) queryParams['hotspot_id'] = hotspotId;
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lon != null) queryParams['lon'] = lon.toString();

      final uri = Uri.parse('$baseUrl/api/v1/advisories/flash-drought').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return FlashDroughtResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend Flash-Drought fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return FlashDroughtResponseModel.fromJson(cachedData);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return FlashDroughtResponseModel.defaultFallback();
  }

  // 50. IMD & CWC National Flood Forecasting, Hydrological Rating Curve & Embankment Breach Telemetry Engine
  Future<HydroRatingResponseModel> getHydroRatingAssessment({
    String? basinId,
    double? lat,
    double? lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'hydro_rating_${basinId ?? '${lat}_$lon'}';

    try {
      final queryParams = <String, String>{};
      if (basinId != null) queryParams['basin_id'] = basinId;
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lon != null) queryParams['lon'] = lon.toString();

      final uri = Uri.parse('$baseUrl/api/v1/hydro/rating-curve').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return HydroRatingResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend Hydro-Rating fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return HydroRatingResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return HydroRatingResponseModel.defaultFallback();
  }

  // 51. IMD, INCOIS & CGWB Coastal Estuarine Saltwater Intrusion & Aquifer Salinization Engine
  Future<SaltwaterIntrusionResponseModel> getSaltwaterIntrusionAssessment({
    String? zoneId,
    double? lat,
    double? lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'saltwater_intrusion_${zoneId ?? '${lat}_$lon'}';

    try {
      final queryParams = <String, String>{};
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lon != null) queryParams['lon'] = lon.toString();

      final uri = Uri.parse('$baseUrl/api/v1/coastal/saltwater-intrusion').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        await prefs.setString(cacheKey, json.encode(data));
        return SaltwaterIntrusionResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend Saltwater Intrusion fetch failed ($e). Checking offline cache.');
    }

    // Try reading cached data from SharedPreferences
    final cachedJsonStr = prefs.getString(cacheKey);
    if (cachedJsonStr != null) {
      try {
        final cachedData = json.decode(cachedJsonStr) as Map<String, dynamic>;
        return SaltwaterIntrusionResponseModel.fromJson(cachedData, isOfflineCached: true);
      } catch (_) {}
    }

    // Fallback to calibrated offline baseline
    return SaltwaterIntrusionResponseModel.defaultFallback();
  }
}






