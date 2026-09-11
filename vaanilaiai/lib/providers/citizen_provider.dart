import 'package:flutter/material.dart';
import '../models/citizen_report_model.dart';
import '../services/api_service.dart';

class CitizenProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CitizenReportModel> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _activeFilter = 'All';

  List<CitizenReportModel> get reports {
    if (_activeFilter == 'All') return _reports;
    return _reports.where((r) => r.reportType.toLowerCase() == _activeFilter.toLowerCase()).toList();
  }

  List<CitizenReportModel> get allReports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeFilter => _activeFilter;

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> fetchReports({double? latitude, double? longitude, double radiusKm = 50.0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getCitizenReports(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      _reports = fetched;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> submitReport(CitizenReportModel report) async {
    try {
      final created = await _apiService.submitCitizenReport(report);
      _reports.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Citizen report submission failed: $e');
      return false;
    }
  }

  Future<void> upvote(String reportId) async {
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      final old = _reports[idx];
      _reports[idx] = CitizenReportModel(
        id: old.id,
        reportType: old.reportType,
        severity: old.severity,
        waterDepthInches: old.waterDepthInches,
        description: old.description,
        latitude: old.latitude,
        longitude: old.longitude,
        locationName: old.locationName,
        photoUrl: old.photoUrl,
        reporterRole: old.reporterRole,
        upvotes: old.upvotes + 1,
        createdAt: old.createdAt,
      );
      notifyListeners();
      await _apiService.upvoteCitizenReport(reportId);
    }
  }
}
