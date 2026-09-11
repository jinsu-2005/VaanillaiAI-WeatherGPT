import 'package:flutter/material.dart';
import '../models/climate_model.dart';
import '../services/api_service.dart';

class ClimateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ClimateComparisonModel? _comparison;
  ClimateTrendModel? _trends;
  bool _isLoading = false;
  String? _errorMessage;

  ClimateComparisonModel? get comparison => _comparison;
  ClimateTrendModel? get trends => _trends;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int _year1 = 2022;
  int _year2 = 2023;

  int get year1 => _year1;
  int get year2 => _year2;

  Future<void> fetchClimateData({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    int? year1,
    int? year2,
  }) async {
    if (year1 != null) _year1 = year1;
    if (year2 != null) _year2 = year2;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.compareClimate(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          year1: _year1,
          year2: _year2,
        ),
        _apiService.getClimateTrends(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          startYear: 2018,
          endYear: 2024,
        ),
      ]);

      _comparison = results[0] as ClimateComparisonModel;
      _trends = results[1] as ClimateTrendModel;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setYears(int y1, int y2, {required double lat, required double lon, required String locName}) {
    _year1 = y1;
    _year2 = y2;
    fetchClimateData(latitude: lat, longitude: lon, locationName: locName, year1: y1, year2: y2);
  }
}
