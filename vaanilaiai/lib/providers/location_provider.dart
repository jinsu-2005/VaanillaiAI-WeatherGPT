import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';

class LocationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<LocationSearchResultModel> _searchResults = [];
  List<SavedLocationModel> _savedLocations = [];
  bool _isSearching = false;

  List<LocationSearchResultModel> get searchResults => _searchResults;
  List<SavedLocationModel> get savedLocations => _savedLocations;
  bool get isSearching => _isSearching;

  LocationProvider() {
    loadSavedLocations();
  }

  Future<void> search(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _searchResults = await _apiService.searchLocations(cleanQuery);
    _isSearching = false;
    notifyListeners();
  }

  Future<void> loadSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('saved_locations_cache');

      if (savedStr != null) {
        final List<dynamic> decoded = jsonDecode(savedStr);
        _savedLocations = decoded.map((item) => SavedLocationModel.fromJson(item)).toList();
      } else {
        // Default popular locations for India
        _savedLocations = [
          SavedLocationModel(
            id: 1,
            name: 'Nagercoil',
            district: 'Kanyakumari',
            state: 'Tamil Nadu',
            country: 'India',
            latitude: 8.1833,
            longitude: 77.4119,
            isVillage: false,
            isFavorite: true,
          ),
          SavedLocationModel(
            id: 2,
            name: 'Chennai',
            district: 'Chennai',
            state: 'Tamil Nadu',
            country: 'India',
            latitude: 13.0827,
            longitude: 80.2707,
            isVillage: false,
            isFavorite: true,
          ),
          SavedLocationModel(
            id: 3,
            name: 'Coimbatore',
            district: 'Coimbatore',
            state: 'Tamil Nadu',
            country: 'India',
            latitude: 11.0168,
            longitude: 76.9558,
            isVillage: false,
            isFavorite: false,
          ),
        ];
        _saveToPrefs();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_savedLocations.map((l) => l.toJson()).toList());
      await prefs.setString('saved_locations_cache', encoded);
    } catch (_) {}
  }

  Future<void> addLocation({
    required String name,
    String? district,
    String? state,
    required double latitude,
    required double longitude,
    bool isVillage = false,
  }) async {
    if (_savedLocations.any((l) => l.name.toLowerCase() == name.toLowerCase())) {
      return;
    }

    final newLoc = SavedLocationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      district: district,
      state: state,
      country: 'India',
      latitude: latitude,
      longitude: longitude,
      isVillage: isVillage,
      isFavorite: true,
    );

    _savedLocations.add(newLoc);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> removeLocation(int id) async {
    _savedLocations.removeWhere((l) => l.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
