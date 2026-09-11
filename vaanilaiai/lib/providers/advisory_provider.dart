import 'package:flutter/material.dart';
import '../models/advisory_model.dart';
import '../services/api_service.dart';

class AdvisoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AgricultureAdvisoryModel? _agricultureAdvisory;
  TravelAdvisoryModel? _travelAdvisory;
  bool _isLoading = false;
  String? _errorMessage;

  AgricultureAdvisoryModel? get agricultureAdvisory => _agricultureAdvisory;
  TravelAdvisoryModel? get travelAdvisory => _travelAdvisory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAdvisories({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    String? district,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getAgricultureAdvisory(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          district: district,
        ),
        _apiService.getTravelAdvisory(
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          district: district,
        ),
      ]);

      _agricultureAdvisory = results[0] as AgricultureAdvisoryModel;
      _travelAdvisory = results[1] as TravelAdvisoryModel;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
