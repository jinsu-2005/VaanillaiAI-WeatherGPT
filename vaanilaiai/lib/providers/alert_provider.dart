import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/api_service.dart';

class AlertProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AlertSummaryModel? _alertSummary;
  bool _isLoading = false;
  String? _errorMessage;

  AlertSummaryModel? get alertSummary => _alertSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DisasterAlertModel> get activeAlerts => _alertSummary?.alerts ?? [];
  int get alertCount => _alertSummary?.totalActiveAlerts ?? 0;
  String get highestSeverity => _alertSummary?.highestSeverity ?? 'Green';

  Future<void> fetchAlerts({
    double? latitude,
    double? longitude,
    String? district,
    String? state,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alertSummary = await _apiService.getActiveAlerts(
        latitude: latitude,
        longitude: longitude,
        district: district,
        state: state,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
