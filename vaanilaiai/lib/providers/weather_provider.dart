import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';

class _WeatherCacheEntry {
  final WeatherForecastModel forecast;
  final DateTime cachedAt;

  _WeatherCacheEntry(this.forecast, this.cachedAt);

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > const Duration(minutes: 15);
}

class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Map<String, _WeatherCacheEntry> _cache = {};

  WeatherForecastModel? _forecast;
  bool _isLoading = false;
  String? _errorMessage;
  int _requestId = 0;

  // Selected Location (Default: Nagercoil, Tamil Nadu, India)
  String _locationName = 'Nagercoil';
  String? _district = 'Kanyakumari';
  String? _state = 'Tamil Nadu';
  double _latitude = 8.1833;
  double _longitude = 77.4119;

  WeatherForecastModel? get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get locationName => _locationName;
  String? get district => _district;
  String? get state => _state;
  double get latitude => _latitude;
  double get longitude => _longitude;

  DateTime? get lastFetchedAt => _forecast?.lastFetchedAt;
  bool get isStale =>
      _forecast != null &&
      (_forecast?.dataSource == 'stale' || _errorMessage != null);
  bool get isCached => _forecast?.dataSource == 'cached';
  String get dataSource => _forecast?.dataSource ?? 'unavailable';

  WeatherProvider() {
    fetchWeather();
  }

  String _cacheKey(double lat, double lon) =>
      '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';

  Future<void> fetchWeather({bool forceRefresh = false}) async {
    final key = _cacheKey(_latitude, _longitude);

    // If cache is fresh and not forced to refresh, return cached immediately
    if (!forceRefresh && _cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (!entry.isExpired) {
        _forecast = entry.forecast.copyWith(dataSource: 'cached');
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return;
      }
    }

    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final forecast = await _apiService.getForecast(
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationName,
        district: _district,
        state: _state,
        days: 7,
      );

      if (requestId == _requestId) {
        final liveForecast = forecast.copyWith(
          dataSource: 'live',
          lastFetchedAt: DateTime.now(),
        );
        _cache[key] = _WeatherCacheEntry(liveForecast, DateTime.now());
        _forecast = liveForecast;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      if (requestId == _requestId) {
        _isLoading = false;
        // Retain last successful forecast if available
        if (_forecast != null) {
          _forecast = _forecast!.copyWith(dataSource: 'stale');
          _errorMessage =
              'Could not refresh weather. Showing previous data.';
        } else {
          _errorMessage =
              'We could not load weather data right now. Check your connection and try again.';
        }
        notifyListeners();
      }
    }
  }

  void updateLocation({
    required String name,
    String? district,
    String? state,
    required double latitude,
    required double longitude,
  }) {
    _locationName = name;
    _district = district;
    _state = state;
    _latitude = latitude;
    _longitude = longitude;
    fetchWeather();
  }

  void setLocationFromSearchResult(LocationSearchResultModel result) {
    updateLocation(
      name: result.name,
      district: result.district,
      state: result.state,
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }
}
