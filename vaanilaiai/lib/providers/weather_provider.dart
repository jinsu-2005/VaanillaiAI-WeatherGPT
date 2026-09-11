import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';

class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  WeatherForecastModel? _forecast;
  bool _isLoading = false;
  String? _errorMessage;

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

  WeatherProvider() {
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _forecast = await _apiService.getForecast(
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationName,
        district: _district,
        state: _state,
        days: 7,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
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
