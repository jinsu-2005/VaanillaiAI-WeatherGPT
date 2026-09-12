import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';

class LocationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();

  List<LocationSearchResultModel> _searchResults = [];
  List<SavedLocationModel> _savedLocations = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  int _searchRequestId = 0;

  List<LocationSearchResultModel> get searchResults => _searchResults;
  List<SavedLocationModel> get savedLocations => _savedLocations;
  bool get isSearching => _isSearching;

  LocationProvider() {
    loadSavedLocations();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        syncFromFirestore(user.uid);
      }
    });
  }

  Future<void> syncFromFirestore(String uid) async {
    try {
      final remoteLocations = await _firestoreService.getSavedLocations(uid);
      if (remoteLocations.isNotEmpty) {
        // Merge remote locations into local list
        for (final rLoc in remoteLocations) {
          final idx = _savedLocations.indexWhere((l) => l.name.toLowerCase() == rLoc.name.toLowerCase());
          if (idx >= 0) {
            _savedLocations[idx] = rLoc;
          } else {
            _savedLocations.add(rLoc);
          }
        }
        await _saveToPrefs();
        notifyListeners();
      }
    } catch (_) {}
  }

  void search(String query) {
    _debounceTimer?.cancel();
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final reqId = ++_searchRequestId;
      try {
        final results = await _apiService.searchLocations(cleanQuery);
        if (reqId == _searchRequestId) {
          _searchResults = results;
          _isSearching = false;
          notifyListeners();
        }
      } catch (_) {
        if (reqId == _searchRequestId) {
          _searchResults = [];
          _isSearching = false;
          notifyListeners();
        }
      }
    });
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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.saveLocation(user.uid, newLoc);
    }

    notifyListeners();
  }

  Future<void> removeLocation(int id) async {
    _savedLocations.removeWhere((l) => l.id == id);
    await _saveToPrefs();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.deleteLocation(user.uid, id);
    }

    notifyListeners();
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

